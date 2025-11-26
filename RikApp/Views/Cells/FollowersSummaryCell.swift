//
//  FollowersSummaryCell.swift
//  RikApp
//
//  Created by Егор Худяев on 25.11.2025.
//

import UIKit
import PinLayout
import BusinessLogicFramework

final class FollowersSummaryCell: UITableViewCell {

    private let titleLabel = UILabel()
    private let container = UIView()

    //NEW
    private let newIcon = UIImageView()
    private let newCountLabel = UILabel()
    private let newArrow = UIImageView()
    private let newDescriptionLabel = UILabel()
    private let separatorView = UIView()

    //LOST
    private let lostIcon = UIImageView()
    private let lostCountLabel = UILabel()
    private let lostArrow = UIImageView()
    private let lostDescriptionLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = Constants.Colors.backColor.color
        contentView.backgroundColor = Constants.Colors.backColor.color
        selectionStyle = .none

        titleLabel.text = "Наблюдатели"
        titleLabel.font = Constants.AppFont.bold(size: 20).font
        titleLabel.textColor = Constants.Colors.black.color
        contentView.addSubview(titleLabel)

        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        container.clipsToBounds = true
        contentView.addSubview(container)

        newIcon.image = UIImage(named: "chartUp")
        newIcon.contentMode = .scaleAspectFit
        container.addSubview(newIcon)

        newCountLabel.text = "1356"
        newCountLabel.font = Constants.AppFont.bold(size: 22).font
        newCountLabel.textColor = Constants.Colors.black.color
        container.addSubview(newCountLabel)

        newArrow.image = UIImage(named: "arrowUp")
        newArrow.contentMode = .scaleAspectFit
        container.addSubview(newArrow)

        newDescriptionLabel.text = "Новые наблюдатели в этом месяце"
        newDescriptionLabel.font = Constants.AppFont.light(size: 14).font
        newDescriptionLabel.textColor = Constants.Colors.gray.color
        newDescriptionLabel.numberOfLines = 0
        container.addSubview(newDescriptionLabel)
        
        separatorView.backgroundColor = Constants.Colors.gray.color.withAlphaComponent(0.2)
        container.addSubview(separatorView)

        lostIcon.image = UIImage(named: "chartDown")
        lostIcon.contentMode = .scaleAspectFit
        container.addSubview(lostIcon)

        lostCountLabel.text = "10"
        lostCountLabel.font = Constants.AppFont.bold(size: 22).font
        lostCountLabel.textColor = Constants.Colors.black.color
        container.addSubview(lostCountLabel)

        lostArrow.image = UIImage(named: "arrowDown")
        lostArrow.contentMode = .scaleAspectFit
        container.addSubview(lostArrow)

        lostDescriptionLabel.text = "Пользователей перестали за вами наблюдать"
        lostDescriptionLabel.font = Constants.AppFont.light(size: 14).font
        lostDescriptionLabel.textColor = Constants.Colors.gray.color
        lostDescriptionLabel.numberOfLines = 0
        container.addSubview(lostDescriptionLabel)
        
        loadFollowersSummary()
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

        var y: CGFloat = 16
        let containerWidth = container.bounds.width

        newIcon.pin
            .left(16)
            .top(y)
            .width(containerWidth / 3)
            .height(80)

        newCountLabel.pin
            .top(y + 4)
            .after(of: newIcon)
            .marginLeft(16)
            .sizeToFit()

        newArrow.pin
            .after(of: newCountLabel)
            .marginLeft(6)
            .vCenter(to: newCountLabel.edge.vCenter)
            .width(18)
            .height(18)

        newDescriptionLabel.pin
            .below(of: newCountLabel)
            .marginTop(6)
            .after(of: newIcon)
            .marginLeft(16)
            .right(16)
            .sizeToFit(.width)

        y = newDescriptionLabel.frame.maxY + 24

        lostIcon.pin
            .left(16)
            .top(y)
            .width(containerWidth / 3)
            .height(80)

        lostCountLabel.pin
            .top(y + 4)
            .after(of: lostIcon)
            .marginLeft(16)
            .sizeToFit()

        lostArrow.pin
            .after(of: lostCountLabel)
            .marginLeft(6)
            .vCenter(to: lostCountLabel.edge.vCenter)
            .width(18)
            .height(18)

        lostDescriptionLabel.pin
            .below(of: lostCountLabel)
            .marginTop(6)
            .after(of: lostIcon)
            .marginLeft(16)
            .right(16)
            .sizeToFit(.width)

        y = lostDescriptionLabel.frame.maxY + 16

        container.pin.height(y)
        
        separatorView.pin
            .vCenter()
            .right(16)
            .left(16)
            .height(1)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        layoutSubviews()
        return CGSize(width: size.width, height: container.frame.maxY + 10)
    }
    
    func loadFollowersSummary() {
        if let counts = RealmService.shared.getFollowersCountsLastMonth() {
            newCountLabel.text = "\(counts.new)"
            lostCountLabel.text = "\(counts.lost)"
        } else {
            newCountLabel.text = "0"
            lostCountLabel.text = "0"
        }
    }
}
