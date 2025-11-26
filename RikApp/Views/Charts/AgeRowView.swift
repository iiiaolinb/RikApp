//
//  AgeRowView.swift
//  RikApp
//
//  Created by Егор Худяев on 25.11.2025.
//

import UIKit
import PinLayout

final class AgeRowView: UIView {

    private let ageLabel = UILabel()
    private let menBar = UIView()
    private let womenBar = UIView()
    private let menPercentLabel = UILabel()
    private let womenPercentLabel = UILabel()
    
    private var menPercent: Int = 0
    private var womenPercent: Int = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        ageLabel.font = Constants.AppFont.medium(size: 18).font
        ageLabel.textColor = Constants.Colors.black.color

        menBar.backgroundColor = Constants.Colors.red.color
        womenBar.backgroundColor = Constants.Colors.orange.color

        menBar.layer.cornerRadius = 3
        womenBar.layer.cornerRadius = 3
        
        menPercentLabel.font = Constants.AppFont.light(size: 12).font
        menPercentLabel.textColor = Constants.Colors.black.color
        womenPercentLabel.font = Constants.AppFont.light(size: 12).font
        womenPercentLabel.textColor = Constants.Colors.black.color

        addSubview(ageLabel)
        addSubview(menBar)
        addSubview(womenBar)
        addSubview(menPercentLabel)
        addSubview(womenPercentLabel)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        menPercent = menPercent == 0 ? 5 : menPercent
        womenPercent = womenPercent == 0 ? 5 : womenPercent

        ageLabel.pin.left().vCenter().sizeToFit()

        let maxBarWidth: CGFloat = bounds.width * 0.35
        let menWidth = maxBarWidth * CGFloat(menPercent) / 100
        let womenWidth = maxBarWidth * CGFloat(womenPercent) / 100
        
        let barSpacing: CGFloat = 8
        let barHeight: CGFloat = 6
        let centerY = bounds.height / 2
        let offsetFromCenter = barHeight / 2 + barSpacing / 2
        
        menBar.pin
            .left()
            .marginLeft(100)
            .width(menWidth)
            .height(barHeight)
            .top(centerY - offsetFromCenter)

        menPercentLabel.pin
            .right(of: menBar, aligned: .center)
            .marginLeft(8)
            .sizeToFit()

        womenBar.pin
            .left()
            .marginLeft(100)
            .width(womenWidth)
            .height(barHeight)
            .top(centerY + offsetFromCenter)

        womenPercentLabel.pin
            .right(of: womenBar, aligned: .center)
            .marginLeft(8)
            .sizeToFit()
    }

    func configure(age: String, menPercent: Int, womenPercent: Int) {
        ageLabel.text = age
        menPercentLabel.text = "\(menPercent)%"
        womenPercentLabel.text = "\(womenPercent)%"
        
        self.menPercent = menPercent
        self.womenPercent = womenPercent

        setNeedsLayout()
    }
}
