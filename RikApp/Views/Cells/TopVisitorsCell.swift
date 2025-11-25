//
//  TopVisitorsCell.swift
//  RikApp
//
//  Created by Егор Худяев on 25.11.2025.
//

import UIKit
import PinLayout

final class TopVisitorsCell: UITableViewCell {

    struct Visitor {
        let image: UIImage?
        let name: String
        let age: Int
        let emoji: String
        let isOnline: Bool
    }

    private let titleLabel = UILabel()
    private let container = UIView()
    private var rowViews: [VisitorRowView] = []

    private let mock: [Visitor] = [
        .init(image: UIImage(named: "ava1"), name: "ann.aeom", age: 25, emoji: "🍒", isOnline: true),
        .init(image: UIImage(named: "ava2"), name: "akimovahuiw", age: 23, emoji: "😈", isOnline: false),
        .init(image: nil, name: "gulia.filova", age: 32, emoji: "", isOnline: true)
    ]

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = Constants.Colors.backColor.color
        contentView.backgroundColor = Constants.Colors.backColor.color
        selectionStyle = .none

        titleLabel.text = "Чаще всех посещают Ваш профиль"
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textColor = Constants.Colors.black.color

        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.08
        container.layer.shadowRadius = 8
        container.layer.shadowOffset = CGSize(width: 0, height: 4)

        contentView.addSubview(titleLabel)
        contentView.addSubview(container)
        
        mock.enumerated().forEach { index, visitor in
            let row = VisitorRowView(visitor: visitor, isLast: index == mock.count - 1)
            rowViews.append(row)
            container.addSubview(row)
        }
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
}
