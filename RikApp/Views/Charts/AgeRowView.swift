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

    override init(frame: CGRect) {
        super.init(frame: frame)

        ageLabel.font = .systemFont(ofSize: 16, weight: .medium)

        menBar.backgroundColor = UIColor(red: 1, green: 80/255, blue: 60/255, alpha: 1)
        womenBar.backgroundColor = UIColor(red: 1, green: 150/255, blue: 120/255, alpha: 1)

        menBar.layer.cornerRadius = 3
        womenBar.layer.cornerRadius = 3

        menPercentLabel.font = .systemFont(ofSize: 14)
        womenPercentLabel.font = .systemFont(ofSize: 14)

        addSubview(ageLabel)
        addSubview(menBar)
        addSubview(womenBar)
        addSubview(menPercentLabel)
        addSubview(womenPercentLabel)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()

        ageLabel.pin.left().vCenter().sizeToFit()

        let barWidth: CGFloat = bounds.width * 0.35

        menBar.pin
            .after(of: ageLabel, aligned: .center)
            .marginLeft(16)
            .width(barWidth)
            .height(6)

        menPercentLabel.pin
            .right(of: menBar, aligned: .center)
            .marginLeft(8)
            .sizeToFit()

        womenBar.pin
            .below(of: menBar)
            .marginTop(8)
            .left(to: menBar.edge.left)
            .width(barWidth)
            .height(6)

        womenPercentLabel.pin
            .right(of: womenBar, aligned: .center)
            .marginLeft(8)
            .sizeToFit()
    }

    // MARK: — публичный метод
    func configure(age: String, menPercent: Int, womenPercent: Int) {
        ageLabel.text = age
        menPercentLabel.text = "\(menPercent)%"
        womenPercentLabel.text = "\(womenPercent)%"

        // Динамическая длина полос:
        let maxWidth: CGFloat = UIScreen.main.bounds.width * 0.35
        let menWidth = maxWidth * CGFloat(menPercent) / 100
        let womenWidth = maxWidth * CGFloat(womenPercent) / 100

        menBar.pin.width(menWidth)
        womenBar.pin.width(womenWidth)

        setNeedsLayout()
    }
}
