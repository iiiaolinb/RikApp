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

//    private func setupChart() {
//        addSubview(lineChartView)
//        lineChartView.pin.all()
//        
//        lineChartView.backgroundColor = .clear
//        backgroundColor = .clear
//
//        // Настройки графика
//        lineChartView.rightAxis.enabled = false
//        lineChartView.leftAxis.enabled = true
//        lineChartView.leftAxis.drawGridLinesEnabled = false
//        lineChartView.leftAxis.drawAxisLineEnabled = false
//        lineChartView.leftAxis.labelTextColor = .clear
//        
//        lineChartView.xAxis.labelPosition = .bottom
//        lineChartView.xAxis.drawGridLinesEnabled = false
//        lineChartView.xAxis.labelTextColor = .black
//        lineChartView.legend.enabled = false
//        lineChartView.chartDescription.enabled = false
//
//        marker.chartView = lineChartView
//        lineChartView.marker = marker
//        lineChartView.highlightPerTapEnabled = true
//        lineChartView.highlightPerDragEnabled = true
//    }
    
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
        lineChartView.xAxis.labelTextColor = .black

        lineChartView.legend.enabled = false
        lineChartView.chartDescription.enabled = false

        // --- Маркер ---
        marker.chartView = lineChartView
        lineChartView.marker = marker

        lineChartView.highlightPerTapEnabled = true
        lineChartView.highlightPerDragEnabled = true

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

    /// Сбрасывает выделение/аннотацию на графике
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
        formatter.dateFormat = "LLL" // 3 буквы месяца, например: "янв", "фев"

        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date()) // год нужен для создания даты, можно любой

        return months.map { key in
            let monthNumber = key % 100 // извлекаем номер месяца из YYYYMM или просто MM
            let monthComponents = DateComponents(year: year, month: monthNumber)
            if let date = calendar.date(from: monthComponents) {
                return formatter.string(from: date)
            } else {
                return ""
            }
        }
    }

//    private func makeMonthLabels(from years: [Int]) -> [String] {
//        return years.map { "\($0)" }
//    }


    // MARK: - Core rendering logic

    private func applyChartData(labels: [String], values: [Int]) {
        guard !labels.isEmpty,
              !values.isEmpty,
              labels.count == values.count
        else { return }

        // --- ChartDataEntry ---
        var entries: [ChartDataEntry] = []
        for (index, value) in values.enumerated() {
            entries.append(ChartDataEntry(x: Double(index), y: Double(value)))
        }

        let dataSet = LineChartDataSet(entries: entries, label: "Просмотры")
        
        // Отключаем стандартные линии подсветки чарта,
        // чтобы оставить только нашу вертикальную пунктирную линию из ChartMarker
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

        // --- XAxis ---
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: labels)
        lineChartView.xAxis.granularity = 1
        lineChartView.xAxis.labelCount = min(labels.count, 7)
        lineChartView.xAxis.forceLabelsEnabled = false
        lineChartView.xAxis.avoidFirstLastClippingEnabled = true
        lineChartView.xAxis.spaceMin = 0.5
        lineChartView.xAxis.spaceMax = 0.5

        // --- пунктирные линии ---
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

//    func setData(timestamps: [Int], values: [Int]) {
//        guard !timestamps.isEmpty, !values.isEmpty, timestamps.count == values.count else { return }
//        
//        // --- Преобразуем даты в строки ddMMyyyy и затем в отображаемый формат dd.MM ---
//        var dateStrings: [String] = []
//        let displayFormatter = DateFormatter()
//        displayFormatter.dateFormat = "dd.MM"
//        
//        let inputFormatter = DateFormatter()
//        inputFormatter.dateFormat = "ddMMyyyy"
//        
//        for ts in timestamps {
//            var s = String(ts)
//            // Добавляем ведущие нули, чтобы строка была 8 символов
//            if s.count < 8 {
//                s = String(repeating: "0", count: 8 - s.count) + s
//            }
//            if let date = inputFormatter.date(from: s) {
//                dateStrings.append(displayFormatter.string(from: date))
//            } else {
//                dateStrings.append("")
//                print("Failed to parse date from: \(ts)")
//            }
//        }
//        dateStrings.forEach { print($0) }
//        print("---")
//        values.forEach { print($0) }
//
//        // --- ChartDataEntry с индексами ---
//        var entries: [ChartDataEntry] = []
//        for (index, value) in values.enumerated() {
//            entries.append(ChartDataEntry(x: Double(index), y: Double(value)))
//        }
//
//        let dataSet = LineChartDataSet(entries: entries, label: "Просмотры")
//        dataSet.colors = [Constants.Colors.red.color]
//        dataSet.circleColors = [Constants.Colors.red.color]
//        dataSet.circleRadius = 4
//        dataSet.lineWidth = 2
//        dataSet.mode = .cubicBezier
//        dataSet.drawValuesEnabled = false
//        dataSet.drawCirclesEnabled = true
//        dataSet.drawCircleHoleEnabled = false
//        dataSet.highlightColor = Constants.Colors.red.color
//        dataSet.highlightLineWidth = 2
//        dataSet.drawFilledEnabled = false
//
//        lineChartView.data = LineChartData(dataSet: dataSet)
//
//        // --- Настройка XAxis ---
//        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dateStrings)
//        lineChartView.xAxis.granularity = 1
//        lineChartView.xAxis.labelCount = min(dateStrings.count, 7) // максимум 7 подписей
//        lineChartView.xAxis.forceLabelsEnabled = false // Chart сам распределяет их равномерно
//        lineChartView.xAxis.avoidFirstLastClippingEnabled = true
//        lineChartView.xAxis.spaceMin = 0.5
//        lineChartView.xAxis.spaceMax = 0.5
//
//        // --- 3 пунктирные линии по Y ---
//        if let maxValue = values.max() {
//            let yAxis = lineChartView.leftAxis
//            let minY = 0.0
//            let maxY = Double(maxValue) * 1.2
//            yAxis.axisMinimum = minY
//            yAxis.axisMaximum = maxY
//
//            let midY = (minY + maxY) / 2
//            yAxis.removeAllLimitLines()
//
//            let lines = [
//                ChartLimitLine(limit: minY),
//                ChartLimitLine(limit: midY),
//                ChartLimitLine(limit: maxY)
//            ]
//            lines.forEach {
//                $0.lineDashLengths = [5, 5]
//                $0.lineColor = .lightGray
//                $0.lineWidth = 1
//                yAxis.addLimitLine($0)
//            }
//        }
//
//        lineChartView.notifyDataSetChanged()
//    }
}

// MARK: - ChartViewDelegate для отключения горизонтальной линии
extension LineChartViewContainer: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        // Принудительно создаём highlight только для вертикали
        chartView.highlightValue(Highlight(x: highlight.x, y: highlight.y, dataSetIndex: highlight.dataSetIndex), callDelegate: false)
    }

    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        chartView.highlightValue(nil)
    }
}

