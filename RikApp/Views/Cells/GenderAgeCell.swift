//
//  GenderAgeCell.swift
//  RikApp
//
//  Created by Егор Худяев on 25.11.2025.
//

import UIKit
import DGCharts
import PinLayout
import BusinessLogicFramework

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

        loadData()
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
            .height(593) // Высота для 7 строк: 20 + 200 + 12 + 20 + 20 + 1 + 20 + 280 + 20 = 593
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        // Высота рассчитывается динамически на основе содержимого
        let titleHeight: CGFloat = 12 + 22 + 12 // top + title + margin
        let segmentHeight: CGFloat = 36 + 12 // segment + margin
        // Высота CircleChartViewContainer для 7 строк: 20 + 200 + 12 + 20 + 20 + 1 + 20 + 280 + 20 = 593
        let chartHeight: CGFloat = 593
        let bottomMargin: CGFloat = 12
        return CGSize(width: size.width, height: titleHeight + segmentHeight + chartHeight + bottomMargin)
    }

    // MARK: - Data Loading
    
    private func loadData() {
        Task {
            if let data = DataService.shared.getGenderAndAgeData() {
                let ageStats = data.ageStats.map { ageStat in
                    CircleChartViewContainer.AgeStats(
                        range: ageStat.range,
                        men: ageStat.men,
                        women: ageStat.women
                    )
                }
                
                await MainActor.run {
                    setChartData(men: data.men, women: data.women, ages: ageStats)
                }
            } else {
                print("Не удалось загрузить данные по полу и возрасту")
                // Устанавливаем пустые данные
                await MainActor.run {
                    let emptyAges = (0..<7).map { _ in
                        CircleChartViewContainer.AgeStats(range: "", men: 0, women: 0)
                    }
                    setChartData(men: 0, women: 0, ages: emptyAges)
                }
            }
        }
    }
    
    // MARK: - Data for Chart
    func setChartData(men: Int, women: Int, ages: [CircleChartViewContainer.AgeStats]) {
        let entry1 = PieChartDataEntry(value: Double(men))
        let entry2 = PieChartDataEntry(value: Double(women))

        let dataSet = PieChartDataSet(entries: [entry1, entry2])
        dataSet.drawValuesEnabled = false
        dataSet.selectionShift = 0
        dataSet.sliceSpace = 12

        dataSet.colors = [
            Constants.Colors.red.color,
            Constants.Colors.orange.color
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
