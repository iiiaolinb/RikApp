//
//  CircleChartViewContainer.swift
//  RikApp
//
//  Created by Егор Худяев on 25.11.2025.
//

import UIKit
import DGCharts
import PinLayout

final class CircleChartViewContainer: UIView {

    // MARK: - UI

    private let chart = PieChartView()

    private let maleDot = UIView()
    private let maleLabel = UILabel()

    private let femaleDot = UIView()
    private let femaleLabel = UILabel()

    private let agesContainer = UIView()
    private var ageRows: [AgeRowView] = []

    // Colors
    private let maleColor = UIColor(red: 0.95, green: 0.17, blue: 0.14, alpha: 1)
    private let femaleColor = UIColor(red: 1.0, green: 0.63, blue: 0.40, alpha: 1)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setData(men: 40, women: 60, ages: mockAges)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setupLayout() {
        backgroundColor = .white
        layer.cornerRadius = 20
        clipsToBounds = true

        setupChart()
        setupLegend()

        addSubview(chart)
        addSubview(maleDot)
        addSubview(maleLabel)
        addSubview(femaleDot)
        addSubview(femaleLabel)
        addSubview(agesContainer)
    }

    private func setupChart() {
        chart.legend.enabled = false
        chart.isUserInteractionEnabled = false
        chart.holeRadiusPercent = 0.80
        chart.transparentCircleRadiusPercent = 0
        chart.rotationAngle = 270

        chart.drawEntryLabelsEnabled = false
        chart.highlightPerTapEnabled = false
        chart.usePercentValuesEnabled = false

    }

    private func setupLegend() {
        maleDot.backgroundColor = maleColor
        maleDot.layer.cornerRadius = 6

        maleLabel.font = .systemFont(ofSize: 14)
        maleLabel.textColor = .black

        femaleDot.backgroundColor = femaleColor
        femaleDot.layer.cornerRadius = 6

        femaleLabel.font = .systemFont(ofSize: 14)
        femaleLabel.textColor = .black
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        chart.pin
            .top(20)
            .hCenter()
            .width(200)
            .height(200)

        maleDot.pin
            .below(of: chart)
            .marginTop(12)
            .left(28)
            .size(12)

        maleLabel.pin
            .vCenter(to: maleDot.edge.vCenter)
            .after(of: maleDot)
            .marginLeft(6)
            .sizeToFit(.width)

        femaleDot.pin
            .vCenter(to: maleDot.edge.vCenter)
            .after(of: maleLabel)
            .marginLeft(24)
            .size(12)

        femaleLabel.pin
            .vCenter(to: femaleDot.edge.vCenter)
            .after(of: femaleDot)
            .marginLeft(6)
            .sizeToFit(.width)

        agesContainer.pin
            .below(of: maleDot)
            .marginTop(20)
            .horizontally(20)
            .bottom(20)

        layoutAgeRows()
    }

    private func layoutAgeRows() {
        var y: CGFloat = 0
        for row in ageRows {
            row.pin.top(y).horizontally().height(32)
            y += 32
        }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: 460)
    }

    // MARK: - Data

    struct AgeStats {
        let range: String   // "18–21"
        let men: Int        // %
        let women: Int      // %
    }

    private let mockAges: [AgeStats] = [
        .init(range: "18–21", men: 10, women: 20),
        .init(range: "22–25", men: 20, women: 30),
        .init(range: "26–30", men: 5, women: 0),
        .init(range: "31–35", men: 0, women: 0),
        .init(range: "36–40", men: 5, women: 0),
        .init(range: "40–50", men: 0, women: 10),
        .init(range: ">50",  men: 0, women: 0)
    ]

    func setData(men: Int, women: Int, ages: [AgeStats]) {
        // Update legend
        maleLabel.text = "Мужчины \(men)%"
        femaleLabel.text = "Женщины \(women)%"

        // Update chart
        let entries = [
            PieChartDataEntry(value: Double(men)),
            PieChartDataEntry(value: Double(women))
        ]

        let set = PieChartDataSet(entries: entries)
        set.colors = [maleColor, femaleColor]
        set.drawValuesEnabled = false
        set.sliceSpace = 6
        set.selectionShift = 0

        let data = PieChartData(dataSet: set)
        chart.data = data

        // Update age rows
        ageRows.forEach { $0.removeFromSuperview() }
        ageRows = []

        for age in ages {
            let row = AgeRowView()
            ageRows.append(row)
            agesContainer.addSubview(row)
        }

        setNeedsLayout()
    }
}
