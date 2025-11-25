//
//  GenderAgeCell.swift
//  RikApp
//
//  Created by Егор Худяев on 25.11.2025.
//

import UIKit
import DGCharts
import PinLayout

final class GenderAgeCell: UITableViewCell {

    private let titleLabel = UILabel()
    private var segmentedControl: CustomSegmentedControl?
    private let circleChartView = CircleChartViewContainer()
    private let chartContainer = UIView()

    private let segments = ["Сегодня", "Неделя", "Месяц", "Все время"]

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = Constants.Colors.backColor.color
        contentView.backgroundColor = Constants.Colors.backColor.color
        selectionStyle = .none

        // Заголовок
        titleLabel.text = "Пол и возраст"
        titleLabel.font = .boldSystemFont(ofSize: 22)
        titleLabel.textColor = Constants.Colors.black.color
        contentView.addSubview(titleLabel)

        // Сегменты
        let sc = CustomSegmentedControl(items: segments)
        self.segmentedControl = sc
        contentView.addSubview(sc)

        // Контейнер для диаграммы
        chartContainer.layer.cornerRadius = 20
        chartContainer.backgroundColor = .white
        contentView.addSubview(chartContainer)

        contentView.addSubview(circleChartView)

        setChartData(men: 40, women: 60, ages: [])
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()

        titleLabel.pin
            .top(12)
            .horizontally(16)
            .sizeToFit(.width)

        segmentedControl?.pin
            .below(of: titleLabel)
            .marginTop(12)
            .horizontally(16)
            .height(36)

        chartContainer.pin
            .below(of: segmentedControl!)
            .marginTop(12)
            .horizontally(12)
            .bottom(12)

        circleChartView.pin
            .below(of: segmentedControl!)
            .marginTop(12)
            .horizontally(12)
            .height(260)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: 380)
    }

    // MARK: - Data for Chart
    func setChartData(men: Int, women: Int, ages: [CircleChartViewContainer.AgeStats]) {
        let entry1 = PieChartDataEntry(value: Double(men))
        let entry2 = PieChartDataEntry(value: Double(women))

        let dataSet = PieChartDataSet(entries: [entry1, entry2])
        dataSet.drawValuesEnabled = false
        dataSet.selectionShift = 0
        dataSet.sliceSpace = 6

        dataSet.colors = [
            UIColor(red: 0.95, green: 0.17, blue: 0.14, alpha: 1.0), // red
            UIColor(red: 1.0, green: 0.63, blue: 0.40, alpha: 1.0) // peach
        ]

        circleChartView.setData(men: men, women: women, ages: ages)
    }
}

// MARK: - CustomSegmentedControlDelegate
extension GenderAgeCell: CustomSegmentedControlDelegate {
    func segmentedControl(_ control: CustomSegmentedControl, didSelectItemAt index: Int) {
        print("Выбран сегмент: \(segments[index])")
        // Здесь можно обновлять данные на основе выбранного периода
    }
}
