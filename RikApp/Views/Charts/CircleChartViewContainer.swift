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

    private let separator = UIView()
    private let agesContainer = UIView()
    private var ageRows: [AgeRowView] = []

    // Colors
    private let maleColor = Constants.Colors.red.color
    private let femaleColor = Constants.Colors.orange.color

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
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
        addSubview(separator)
        addSubview(agesContainer)
    }

    private func setupChart() {
        chart.legend.enabled = false
        chart.isUserInteractionEnabled = false
        chart.holeRadiusPercent = 0.90
        chart.transparentCircleRadiusPercent = 0
        chart.rotationAngle = 270

        chart.drawEntryLabelsEnabled = false
        chart.highlightPerTapEnabled = false
        chart.usePercentValuesEnabled = false
        
        // Закругляем края chart
        chart.layer.cornerRadius = 100
        chart.clipsToBounds = true
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
        
        // Настройка сепаратора
        separator.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
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
        
        femaleLabel.pin
            .below(of: chart)
            .marginTop(12)
            .right(28)
            .sizeToFit(.width)

        femaleDot.pin
            .vCenter(to: femaleLabel.edge.vCenter)
            .before(of: femaleLabel)
            .marginRight(6)
            .size(12)

        // Размещаем сепаратор ниже легенды
        separator.pin
            .below(of: maleDot)
            .marginTop(20)
            .horizontally(20)
            .height(1)

        // Размещаем agesContainer ниже сепаратора
        // Фиксированная высота для 7 строк: 7 * 40 = 280
        agesContainer.pin
            .below(of: separator)
            .marginTop(20)
            .horizontally(20)
            .height(280)

        layoutAgeRows()
    }

    private func layoutAgeRows() {
        var y: CGFloat = 0
        for row in ageRows {
            row.pin.top(y).horizontally(0).height(40)
            y += 40
        }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        // Расчет высоты для 7 строк AgeRowView
        let chartTop: CGFloat = 20
        let chartHeight: CGFloat = 200
        let legendTop: CGFloat = 12
        let legendHeight: CGFloat = 20 // примерная высота элементов легенды
        let separatorTopMargin: CGFloat = 20
        let separatorHeight: CGFloat = 1
        let containerTopMargin: CGFloat = 20
        let containerHeight: CGFloat = 280 // 7 строк * 40
        let bottomMargin: CGFloat = 20
        
        let totalHeight = chartTop + chartHeight + legendTop + legendHeight + separatorTopMargin + separatorHeight + containerTopMargin + containerHeight + bottomMargin
        
        return CGSize(width: size.width, height: totalHeight)
    }

    // MARK: - Data

    struct AgeStats {
        let range: String   // "18–21"
        let men: Int        // %
        let women: Int      // %
    }


    func setData(men: Int, women: Int, ages: [AgeStats]) {
        // Update legend
        maleLabel.text = "Мужчины \(men)%"
        femaleLabel.text = "Женщины \(women)%"
        maleLabel.sizeToFit()
        femaleLabel.sizeToFit()

        // Update chart
        let entries = [
            PieChartDataEntry(value: Double(women)),
            PieChartDataEntry(value: Double(men))
        ]

        let set = PieChartDataSet(entries: entries)
        set.colors = [femaleColor, maleColor]
        set.drawValuesEnabled = false
        set.sliceSpace = 12
        set.selectionShift = 0

        let data = PieChartData(dataSet: set)
        chart.data = data

        // Update age rows
        ageRows.forEach { $0.removeFromSuperview() }
        ageRows = []

        for age in ages {
            let row = AgeRowView()
            row.configure(age: age.range, menPercent: age.men, womenPercent: age.women)
            ageRows.append(row)
            agesContainer.addSubview(row)
        }

        setNeedsLayout()
        layoutIfNeeded()
        
        // Явно обновляем layout для agesContainer
        agesContainer.setNeedsLayout()
        agesContainer.layoutIfNeeded()
    }
}
