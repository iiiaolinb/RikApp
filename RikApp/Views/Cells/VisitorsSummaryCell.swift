//
//  VisitorsSummaryCell.swift
//  RikApp
//
//  Created by Егор Худяев on 25.11.2025.
//

import UIKit
import PinLayout
import BusinessLogicFramework
import NetworkLayerFramework

final class VisitorsSummaryCell: UITableViewCell {

    private let titleLabel = UILabel()
    private let container = UIView()

    private let iconView = UIImageView()

    private let countTextLabel = UILabel()
    private let arrowView = UIImageView()

    private let descriptionLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = Constants.Colors.backColor.color
        contentView.backgroundColor = Constants.Colors.backColor.color
        selectionStyle = .none

        titleLabel.text = "Посетители"
        titleLabel.font = Constants.AppFont.bold(size: 20).font
        titleLabel.textColor = Constants.Colors.black.color
        contentView.addSubview(titleLabel)

        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        contentView.addSubview(container)

        iconView.image = UIImage(named: "chartUp")
        iconView.contentMode = .scaleAspectFit
        container.addSubview(iconView)

        countTextLabel.text = "1356"
        countTextLabel.font = Constants.AppFont.bold(size: 22).font
        countTextLabel.textColor = Constants.Colors.black.color
        container.addSubview(countTextLabel)

        arrowView.image = UIImage(named: "arrowUp")
        arrowView.contentMode = .scaleAspectFit
        container.addSubview(arrowView)

        descriptionLabel.text = "Количество посетителей в этом месяце выросло"
        descriptionLabel.font = Constants.AppFont.light(size: 14).font
        descriptionLabel.textColor = Constants.Colors.gray.color
        descriptionLabel.numberOfLines = 0
        container.addSubview(descriptionLabel)
        
        loadTotalVisitors()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()

        titleLabel.pin
            .top(8)
            .horizontally(16)
            .sizeToFit()

        container.pin
            .below(of: titleLabel)
            .marginTop(12)
            .horizontally(16)
            .height(100)

        let containerWidth = container.bounds.width

        iconView.pin
            .left(16)
            .vCenter()
            .width(containerWidth / 3)
            .height(80)

        countTextLabel.pin
            .top(18)
            .after(of: iconView)
            .marginLeft(16)
            .sizeToFit()

        arrowView.pin
            .after(of: countTextLabel)
            .marginLeft(6)
            .vCenter(to: countTextLabel.edge.vCenter)
            .width(18)
            .height(18)

        descriptionLabel.pin
            .below(of: countTextLabel)
            .marginTop(6)
            .after(of: iconView)
            .marginLeft(16)
            .right(16)
            .sizeToFit(.width)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: 170)
    }
    
    func loadTotalVisitors() {
        let viewStats = RealmService.shared.getViewStatistics()
        let total = viewStats.reduce(0) { $0 + $1.dates.count }
        countTextLabel.text = "\(total)"
    }
}
