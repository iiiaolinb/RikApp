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
    private let items = ["По дням", "По неделям", "По месяцам", "По годам"]

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
    
    /// Загружает данные из Realm и отображает график
    func loadChartData() {
        let viewStatistics = DataService.shared.getViewStatistics()
        
        // Объединяем все даты из всех статистик просмотров
        // Подсчитываем количество просмотров для каждого уникального timestamp
        var dateCounts: [Int: Int] = [:] // [timestamp: количество просмотров]
        
        for stat in viewStatistics {
            for timestamp in stat.dates {
                // Если timestamp встречается несколько раз, это означает несколько просмотров в этот момент
                dateCounts[timestamp, default: 0] += 1
            }
        }
        
        // Сортируем по дате (timestamp)
        let sortedDates = dateCounts.keys.sorted()
        let timestamps = sortedDates
        let values = sortedDates.map { dateCounts[$0] ?? 0 }
        
        DispatchQueue.main.async {
            if !timestamps.isEmpty && !values.isEmpty {
                self.chartContainer.setData(timestamps: timestamps, values: values)
            } else {
                print("VisitorsChartCell: Нет данных для отображения графика (найдено \(viewStatistics.count) статистик)")
            }
        }
    }
    
    // Старый метод для обратной совместимости (можно удалить позже)
    func setChartData(values: [Int], labels: [String]) {
        // Преобразуем labels в timestamps (если labels это даты в формате строки)
        // Для обратной совместимости создаем фиктивные timestamps
        let now = Int(Date().timeIntervalSince1970)
        let timestamps = (0..<values.count).map { now - (values.count - $0 - 1) * 86400 }
        
        DispatchQueue.main.async {
            self.chartContainer.setData(timestamps: timestamps, values: values)
        }
    }
}

extension VisitorsChartCell: CustomSegmentedControlDelegate {
    func segmentedControl(_ control: CustomSegmentedControl, didSelectItemAt index: Int) {
        // Здесь можно обрабатывать смену сегмента
        print("Выбран сегмент: \(items[index])")
    }
}
