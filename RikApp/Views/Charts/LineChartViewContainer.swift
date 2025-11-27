//
//  LineChartViewContainer.swift
//  RikApp
//
//  Created by Егор Худяев on 25.11.2025.
//

import UIKit
import DGCharts
import PinLayout

final class LineChartViewContainer: UIView {

    private let lineChartView = LineChartView()
    private let marker = ChartMarker()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupChart()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lineChartView.pin.all()
    }

    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Настройка графика
    private func setupChart() {
        addSubview(lineChartView)
        lineChartView.pin.all()
        
        lineChartView.backgroundColor = .clear
        backgroundColor = .clear

        lineChartView.rightAxis.enabled = false
        lineChartView.leftAxis.enabled = true
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.leftAxis.drawAxisLineEnabled = false
        lineChartView.leftAxis.labelTextColor = .clear

        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.labelTextColor = Constants.Colors.gray.color
        lineChartView.xAxis.drawAxisLineEnabled = true
        lineChartView.xAxis.axisLineColor = Constants.Colors.gray.color
        lineChartView.xAxis.axisLineDashLengths = [5, 5]

        lineChartView.legend.enabled = false
        lineChartView.chartDescription.enabled = false

        marker.chartView = lineChartView
        lineChartView.marker = marker

        lineChartView.highlightPerTapEnabled = true
        lineChartView.highlightPerDragEnabled = true

        // Отключаем масштабирование
        lineChartView.scaleXEnabled = false
        lineChartView.scaleYEnabled = false
        lineChartView.pinchZoomEnabled = false
        lineChartView.doubleTapToZoomEnabled = false

        lineChartView.delegate = self
    }
    
    // MARK: - Public API

    func setDataForDays(timestamps: [Int], values: [Int]) {
        let labels = makeDayLabels(from: timestamps)
        marker.dateType = .day
        applyChartData(labels: labels, values: values)
    }

    func setDataForWeeks(weeks: [Int], values: [Int]) {
        let labels = makeWeekLabels(from: weeks)
        marker.dateType = .week
        applyChartData(labels: labels, values: values)
    }

    func setDataForYears(months: [Int], values: [Int]) {
        let labels = makeMonthLabels(from: months)
        marker.dateType = .month
        applyChartData(labels: labels, values: values)
    }

    func clearHighlight() {
        lineChartView.highlightValue(nil)
    }

    // MARK: - Label builders

    private func makeDayLabels(from timestamps: [Int]) -> [String] {
        var result: [String] = []

        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "dd.MM"

        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "ddMMyyyy"

        for ts in timestamps {
            var s = String(ts)
            if s.count < 8 {
                s = String(repeating: "0", count: 8 - s.count) + s
            }

            if let date = inputFormatter.date(from: s) {
                result.append(displayFormatter.string(from: date))
            } else {
                result.append("")
                print("Failed to parse date from: \(ts)")
            }
        }

        return result
    }

    private func makeWeekLabels(from weeks: [Int]) -> [String] {
        return weeks.map { "\($0)" }
    }
    
    private func makeMonthLabels(from months: [Int]) -> [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "LLL"

        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())

        return months.map { key in
            let monthNumber = key % 100
            let monthComponents = DateComponents(year: year, month: monthNumber)
            if let date = calendar.date(from: monthComponents) {
                return formatter.string(from: date)
            } else {
                return ""
            }
        }
    }

    // MARK: - Core rendering logic

    private func applyChartData(labels: [String], values: [Int]) {
        guard !labels.isEmpty,
              !values.isEmpty,
              labels.count == values.count
        else { return }

        var entries: [ChartDataEntry] = []
        for (index, value) in values.enumerated() {
            entries.append(ChartDataEntry(x: Double(index), y: Double(value)))
        }

        let dataSet = LineChartDataSet(entries: entries, label: "Просмотры")
        
        dataSet.drawHorizontalHighlightIndicatorEnabled = false
        dataSet.drawVerticalHighlightIndicatorEnabled = false
        
        dataSet.colors = [Constants.Colors.red.color]
        dataSet.circleColors = [Constants.Colors.red.color]
        dataSet.circleRadius = 6
        dataSet.circleHoleRadius = 3
        dataSet.circleHoleColor = .white
        dataSet.drawCircleHoleEnabled = true
        dataSet.lineWidth = 3
        dataSet.mode = .linear
        dataSet.drawValuesEnabled = false
        dataSet.drawCirclesEnabled = true
        dataSet.highlightColor = Constants.Colors.red.color
        dataSet.highlightLineWidth = 2
        dataSet.drawFilledEnabled = false

        lineChartView.data = LineChartData(dataSet: dataSet)

        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: labels)
        lineChartView.xAxis.granularity = 1
        lineChartView.xAxis.labelCount = min(labels.count, 7)
        lineChartView.xAxis.forceLabelsEnabled = false
        lineChartView.xAxis.avoidFirstLastClippingEnabled = true
        lineChartView.xAxis.spaceMin = 0.5
        lineChartView.xAxis.spaceMax = 0.5

        if let maxValue = values.max() {
            let yAxis = lineChartView.leftAxis
            let minY = 0.0
            let maxY = Double(maxValue) * 1.2
            yAxis.axisMinimum = minY
            yAxis.axisMaximum = maxY

            let midY = (minY + maxY) / 2
            yAxis.removeAllLimitLines()

            let lines = [
                ChartLimitLine(limit: minY),
                ChartLimitLine(limit: midY),
                ChartLimitLine(limit: maxY)
            ]
            lines.forEach {
                $0.lineDashLengths = [5, 5]
                $0.lineColor = .lightGray
                $0.lineWidth = 1
                yAxis.addLimitLine($0)
            }
        }

        lineChartView.notifyDataSetChanged()
    }
}

// MARK: - ChartViewDelegate
extension LineChartViewContainer: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        chartView.highlightValue(Highlight(x: highlight.x, y: highlight.y, dataSetIndex: highlight.dataSetIndex), callDelegate: false)
    }

    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        chartView.highlightValue(nil)
    }
}

