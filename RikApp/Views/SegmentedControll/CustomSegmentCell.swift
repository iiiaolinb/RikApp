//
//  CustomSegmentCell.swift
//  RikApp
//
//  Created by Егор Худяев on 25.11.2025.
//

import UIKit
import PinLayout

final class SegmentCell: UICollectionViewCell {

    private let titleLabel = UILabel()
    private let borderLayer = CALayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLabel)
        contentView.layer.addSublayer(borderLayer)
        titleLabel.textAlignment = .center
        titleLabel.font = Constants.AppFont.medium(size: 14).font
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        borderLayer.borderWidth = 1
        borderLayer.cornerRadius = 16
        borderLayer.masksToBounds = true
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = contentView.bounds
        borderLayer.frame = contentView.bounds
    }

    func configure(title: String, isSelected: Bool) {
        titleLabel.text = title
        if isSelected {
            contentView.backgroundColor = Constants.Colors.red.color
            titleLabel.textColor = .white
            borderLayer.borderColor = UIColor.clear.cgColor
        } else {
            contentView.backgroundColor = .white
            titleLabel.textColor = .black
            borderLayer.borderColor = Constants.Colors.gray.color.cgColor
        }
    }
}



