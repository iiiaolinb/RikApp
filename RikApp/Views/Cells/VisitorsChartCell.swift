//
//  VisitorsChartCell.swift
//  RikApp
//
//  Created by Егор Худяев on 25.11.2025.
//

import UIKit
import PinLayout
import DGCharts
import BusinessLogicFramework
import NetworkLayerFramework

final class VisitorsChartCell: UITableViewCell {

    private let chartContainer = LineChartViewContainer()
    private var segmentedControl: CustomSegmentedControl?
    private let items = ["По дням", "По неделям", "По месяцам"]
    private var selectedItem = 0
    private var dateCounts: [Int: Int] = [:]

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = Constants.Colors.backColor.color
        contentView.backgroundColor = Constants.Colors.backColor.color
        selectionStyle = .none
        
        segmentedControl = CustomSegmentedControl(items: items)
        segmentedControl?.delegate = self
        if let segmentedControl {
            contentView.addSubview(segmentedControl)
        }
        contentView.addSubview(chartContainer)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let segmentedControl = segmentedControl {
            segmentedControl.pin
                .top(8)
                .horizontally(16)
                .height(36)

            chartContainer.pin
                .below(of: segmentedControl)
                .marginTop(12)
                .horizontally(16)
                .height(180)
                .bottom(12)
        } else {
            // Если segmentedControl еще не создан, размещаем график от верха
            chartContainer.pin
                .top(8)
                .horizontally(16)
                .height(180)
                .bottom(12)
        }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: 260)
    }
    
    func loadChartData() {
        let viewStatistics = DataService.shared.getViewStatistics()

        var dateCountsLocal: [Int: Int] = [:]

        for stat in viewStatistics {
            for timestamp in stat.dates {
                dateCountsLocal[timestamp, default: 0] += 1
            }
        }

        self.dateCounts = dateCountsLocal

        applySelectedSegment()
    }
}

extension VisitorsChartCell: CustomSegmentedControlDelegate {
    func segmentedControl(_ control: CustomSegmentedControl, didSelectItemAt index: Int) {
        selectedItem = index
        // При смене сегмента сбрасываем текущее выделение/аннотацию
        chartContainer.clearHighlight()
        applySelectedSegment()
    }
}

extension VisitorsChartCell {

    /// Преобразуем timestamp → Date
    private func date(from timestamp: Int) -> Date? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "ddMMyyyy"

        var s = String(timestamp)

        // Добавляем ведущие нули (например, 5022024 → 05022024)
        if s.count < 8 {
            s = String(repeating: "0", count: 8 - s.count) + s
        }

        guard let date = inputFormatter.date(from: s) else {
            print("Failed to parse custom date from timestamp: \(timestamp)")
            return nil
        }

        return date
    }

    /// Возвращает данные для показа "По дням" — первые 7 дней от минимальной даты
    private func makeDailyData(from dateCounts: [Int: Int]) -> ([Int], [Int]) {
        let sortedTimestamps = dateCounts.keys.sorted()
        let first7 = Array(sortedTimestamps.prefix(7))
        let values = first7.map { dateCounts[$0] ?? 0 }
        return (first7, values)
    }

    private func makeWeeklyData(from dateCounts: [Int: Int]) -> ([Int], [Int]) {
        var weekBuckets: [Int: Int] = [:]  // (year * 100 + weekOfYear) -> sum
        let calendar = Calendar.current

        for (timestamp, count) in dateCounts {
            guard let date = date(from: timestamp) else { continue }

            let weekOfYear = calendar.component(.weekOfYear, from: date)
            let year = calendar.component(.yearForWeekOfYear, from: date)

            let key = year * 100 + weekOfYear  // YYYYWW
            weekBuckets[key, default: 0] += count
        }

        // Сортируем в хронологическом порядке
        let sortedKeys = weekBuckets.keys.sorted()

        // Возвращаем только недели
        let weeks = sortedKeys.map { $0 % 100 }     // ← WW

        // Значения в том же порядке
        let values = sortedKeys.map { weekBuckets[$0]! }

        return (weeks, values)
    }

    private func makeMonthlyData(from dateCounts: [Int: Int]) -> ([Int], [Int]) {
        var monthBuckets: [Int: Int] = [:]  // (year * 100 + month) -> sum
        let calendar = Calendar.current

        for (timestamp, count) in dateCounts {
            guard let date = date(from: timestamp) else { continue }

            let month = calendar.component(.month, from: date)         // 1 ... 12
            let year = calendar.component(.year, from: date)

            let key = year * 100 + month   // чтобы не смешивать месяцы разных лет

            monthBuckets[key, default: 0] += count
        }

        let sortedKeys = monthBuckets.keys.sorted()

        let months = sortedKeys
        let values = sortedKeys.map { monthBuckets[$0]! }

        return (months, values)
    }
}

extension VisitorsChartCell {

    private func applySelectedSegment() {
        let timestamps: [Int]
        let values: [Int]

        switch selectedItem {
        case 0:     // По дням
            (timestamps, values) = makeDailyData(from: dateCounts)
            chartContainer.setDataForDays(timestamps: timestamps, values: values)
        case 1:     // По неделям
            (timestamps, values) = makeWeeklyData(from: dateCounts)
            chartContainer.setDataForWeeks(weeks: timestamps, values: values)
        case 2:     // По месяцам
            (timestamps, values) = makeMonthlyData(from: dateCounts)
            chartContainer.setDataForYears(months: timestamps, values: values)
        default:
            return
        }

        
    }
}
