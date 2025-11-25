//
//  FollowersSummaryCell.swift
//  RikApp
//
//  Created by Егор Худяев on 25.11.2025.
//

import UIKit
import PinLayout
//5
final class FollowersSummaryCell: UITableViewCell {

    private let container = UIView()

    private let newIcon = UIImageView()
    private let newLabel = UILabel()
    private let newDesc = UILabel()

    private let lostIcon = UIImageView()
    private let lostLabel = UILabel()
    private let lostDesc = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = Constants.Colors.backColor.color
        contentView.backgroundColor = Constants.Colors.backColor.color
        selectionStyle = .none

        container.backgroundColor = Constants.Colors.backColor.color
        container.layer.cornerRadius = 16

        newIcon.image = UIImage(named: "green_wave")
        newLabel.font = .boldSystemFont(ofSize: 22)
        newLabel.text = "1356 ↑"
        newDesc.text = "Новые наблюдатели в этом месяце"
        newDesc.numberOfLines = 0

        lostIcon.image = UIImage(named: "red_wave")
        lostLabel.font = .boldSystemFont(ofSize: 22)
        lostLabel.text = "10 ↓"
        lostDesc.text = "Пользователей перестали за Вами наблюдать"
        lostDesc.numberOfLines = 0

        contentView.addSubview(container)
        [newIcon, newLabel, newDesc, lostIcon, lostLabel, lostDesc].forEach { container.addSubview($0) }
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()

        container.pin.top(12).horizontally(16).bottom(12)

        var y: CGFloat = 16

        // First block
        newIcon.pin.top(y).left(16).size(40)
        newLabel.pin.after(of: newIcon).marginLeft(12).top(y).sizeToFit(.width)
        newDesc.pin.below(of: newLabel).marginTop(4).after(of: newIcon).right(16).sizeToFit(.width)

        y = newDesc.frame.maxY + 20

        // Second block
        lostIcon.pin.top(y).left(16).size(40)
        lostLabel.pin.after(of: lostIcon).marginLeft(12).top(y).sizeToFit(.width)
        lostDesc.pin.below(of: lostLabel).marginTop(4).after(of: lostIcon).right(16).sizeToFit(.width)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {

        return CGSize(width: size.width, height: 240)
    }
}
