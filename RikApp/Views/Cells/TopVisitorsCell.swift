//
//  TopVisitorsCell.swift
//  RikApp
//
//  Created by Егор Худяев on 25.11.2025.
//

import UIKit
import PinLayout
import BusinessLogicFramework
import NetworkLayerFramework

final class TopVisitorsCell: UITableViewCell {

    struct Visitor {
        let user: NetworkLayerFramework.User
        let name: String
        let age: Int
        let emoji: String
        let isOnline: Bool
    }

    var onUserSelected: ((NetworkLayerFramework.User) -> Void)?

    private let titleLabel = UILabel()
    private let container = UIView()
    private var rowViews: [VisitorRowView] = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = Constants.Colors.backColor.color
        contentView.backgroundColor = Constants.Colors.backColor.color
        selectionStyle = .none

        titleLabel.text = "Чаще всех посещают Ваш профиль"
        titleLabel.font = Constants.AppFont.bold(size: 20).font
        titleLabel.textColor = Constants.Colors.black.color

        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        container.layer.shadowColor = Constants.Colors.black.color.cgColor
        container.layer.shadowOpacity = 0.08
        container.layer.shadowRadius = 8
        container.layer.shadowOffset = CGSize(width: 0, height: 4)

        contentView.addSubview(titleLabel)
        contentView.addSubview(container)

        loadTopVisitors()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()

        titleLabel.pin
            .top(12)
            .horizontally(16)
            .sizeToFit(.width)

        container.pin
            .below(of: titleLabel)
            .marginTop(12)
            .horizontally(16)
            .height(CGFloat(rowViews.count) * 64)

        var y: CGFloat = 0
        for row in rowViews {
            row.pin
                .top(y)
                .left()
                .right()
                .height(64)
            y += 64
        }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let height = 12 + titleLabel.intrinsicContentSize.height + 12 + CGFloat(rowViews.count) * 64 + 12
        return .init(width: size.width, height: height)
    }

    // MARK: - Configuration

    func configure(with users: [NetworkLayerFramework.User]) {
        rowViews.forEach { $0.removeFromSuperview() }
        rowViews.removeAll()

        let topUsers = Array(users.prefix(3))

        topUsers.enumerated().forEach { index, user in
            let visitor = Visitor(
                user: user,
                name: user.username,
                age: user.age,
                emoji: "",
                isOnline: user.isOnline
            )

            let row = VisitorRowView(visitor: visitor, isLast: index == topUsers.count - 1)
            row.delegate = self
            rowViews.append(row)
            container.addSubview(row)
        }

        setNeedsLayout()
        layoutIfNeeded()
    }

    func loadTopVisitors(limit: Int = 3) {
        let topViewers = DataService.shared.getTopViewers(limit: limit)
        configure(with: topViewers)
    }
}

extension TopVisitorsCell: VisitorRowViewDelegate {
    func visitorRowView(_ view: VisitorRowView, didTap visitor: Visitor) {
        onUserSelected?(visitor.user)
    }
}
