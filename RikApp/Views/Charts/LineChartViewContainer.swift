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

    private func setupChart() {
        addSubview(lineChartView)
        lineChartView.pin.all()
        
        // Убеждаемся, что view видим
        lineChartView.backgroundColor = .clear
        backgroundColor = .clear

        // Настройки графика
        lineChartView.rightAxis.enabled = false
        lineChartView.leftAxis.enabled = false // Скрываем ось Y
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.legend.enabled = false
        lineChartView.chartDescription.enabled = false
        
        // Настройка оси X
        lineChartView.xAxis.labelTextColor = .black
        lineChartView.xAxis.axisLineColor = .lightGray
        lineChartView.xAxis.granularity = 1
        lineChartView.xAxis.avoidFirstLastClippingEnabled = true
        
        // Настройка маркера для аннотации
        marker.chartView = lineChartView
        lineChartView.marker = marker
        
        // Включаем интерактивность для показа маркера
        lineChartView.highlightPerTapEnabled = true
        lineChartView.highlightPerDragEnabled = true
    }

    /// Устанавливает данные графика из timestamps (Unix timestamp в секундах)
    /// - Parameters:
    ///   - timestamps: Массив Unix timestamps в секундах
    ///   - values: Массив значений (количество просмотров) для каждой даты
    func setData(timestamps: [Int], values: [Int]) {
        guard !timestamps.isEmpty, !values.isEmpty, timestamps.count == values.count else {
            print("LineChartViewContainer: Пустые данные или несоответствие количества timestamps и values")
            return
        }
        
        // Создаем entries с timestamps как x координаты
        var entries: [ChartDataEntry] = []
        for (index, timestamp) in timestamps.enumerated() {
            entries.append(ChartDataEntry(x: Double(timestamp), y: Double(values[index])))
        }
        
        // Сортируем по дате
        entries.sort { $0.x < $1.x }

        let dataSet = LineChartDataSet(entries: entries, label: "Просмотры")
        dataSet.colors = [Constants.Colors.red.color] // цвет линии
        dataSet.circleColors = [Constants.Colors.red.color] // цвет точек
        dataSet.circleRadius = 4
        dataSet.lineWidth = 2
        dataSet.mode = .cubicBezier // плавная кривая
        dataSet.drawValuesEnabled = false
        dataSet.drawFilledEnabled = true
        dataSet.fillColor = Constants.Colors.red.color
        dataSet.fillAlpha = 0.1
        dataSet.drawCirclesEnabled = true
        dataSet.drawCircleHoleEnabled = false
        dataSet.highlightColor = Constants.Colors.red.color
        dataSet.highlightLineWidth = 2

        let data = LineChartData(dataSet: dataSet)
        lineChartView.data = data

        // Настройка форматтера для оси X (даты)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM"
        
        lineChartView.xAxis.valueFormatter = DateValueFormatter(dateFormatter: dateFormatter, timestamps: timestamps)
        lineChartView.xAxis.granularity = 1
        lineChartView.xAxis.forceLabelsEnabled = false
        
        // Настройка масштаба для оси X (используем timestamps)
        if let minTimestamp = timestamps.min(), let maxTimestamp = timestamps.max() {
            lineChartView.xAxis.axisMinimum = Double(minTimestamp)
            lineChartView.xAxis.axisMaximum = Double(maxTimestamp)
        }
        
        // Настройка масштаба для оси Y (скрыта, но нужна для правильного отображения)
        if let maxValue = values.max(), maxValue > 0 {
            lineChartView.leftAxis.axisMinimum = 0
            lineChartView.leftAxis.axisMaximum = Double(maxValue) * 1.2
        } else {
            lineChartView.leftAxis.axisMinimum = 0
            lineChartView.leftAxis.axisMaximum = 10
        }
        
        lineChartView.isHidden = false
        lineChartView.alpha = 1.0
        
        lineChartView.notifyDataSetChanged()
        lineChartView.setNeedsDisplay()
        lineChartView.setNeedsLayout()
        
        setNeedsLayout()
        layoutIfNeeded()
        lineChartView.layoutIfNeeded()
    }
}

// MARK: - Date Value Formatter
final class DateValueFormatter: AxisValueFormatter {
    private let dateFormatter: DateFormatter
    private let timestamps: [Int]
    
    init(dateFormatter: DateFormatter, timestamps: [Int]) {
        self.dateFormatter = dateFormatter
        self.timestamps = timestamps.sorted()
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let timestamp = Int(value)
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        return dateFormatter.string(from: date)
    }
}

