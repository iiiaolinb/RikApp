//
//  ChartMarker.swift
//  RikApp
//
//  Created by Егор Худяев on 25.11.2025.
//

import UIKit
import DGCharts
import PinLayout

// MARK: - ChartMarker с вертикальной линией
final class ChartMarker: MarkerImage {
    
    enum DateType {
        case day, week, month
    }
    
    var dateType: DateType = .day
    
    private var visitorsText: String = ""
    private var dateText: String = ""
    
    private var visitorsAttrs: [NSAttributedString.Key: Any] = [:]
    private var dateAttrs: [NSAttributedString.Key: Any] = [:]
    
    private var visitorsSize: CGSize = .zero
    private var dateSize: CGSize = .zero
    private var totalSize: CGSize = .zero
    
    private let padding: CGFloat = 12
    private let cornerRadius: CGFloat = 12
    private let lineSpacing: CGFloat = 6
    
    nonisolated override init() { super.init() }
    
    nonisolated override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        let count = Int(entry.y)
        visitorsText = "\(count) \(getVisitorsWord(for: count))"
        visitorsAttrs = [
            .font: Constants.AppFont.medium(size: 14).font,
            .foregroundColor: UIColor.red
        ]
        visitorsSize = visitorsText.size(withAttributes: visitorsAttrs)
        
        dateText = ""
        if let chart = chartView as? LineChartView {
            let xIndex = Int(entry.x)
            if let xLabel = chart.xAxis.valueFormatter?.stringForValue(Double(xIndex), axis: chart.xAxis) {
                dateText = formatDateLabel(xLabel)
            }
        }
        dateAttrs = [
            .font: Constants.AppFont.light(size: 12).font,
            .foregroundColor: UIColor.gray
        ]
        dateSize = dateText.size(withAttributes: dateAttrs)
        
        let width = max(visitorsSize.width, dateSize.width) + padding * 2
        let height = visitorsSize.height + lineSpacing + dateSize.height + padding * 2
        totalSize = CGSize(width: width, height: height)
        size = totalSize
    }
    
    nonisolated override func draw(context: CGContext, point: CGPoint) {
        guard totalSize != .zero, let chart = chartView else { return }
        
        context.saveGState()
        
        // --- вертикальная пунктирная линия ---
        context.setStrokeColor(UIColor.red.cgColor)
        context.setLineWidth(1)
        context.setLineDash(phase: 0, lengths: [5,5])
        context.move(to: CGPoint(x: point.x, y: chart.viewPortHandler.contentTop))
        context.addLine(to: CGPoint(x: point.x, y: chart.viewPortHandler.contentBottom))
        context.strokePath()
        context.setLineDash(phase: 0, lengths: []) // сброс dash
        
        // --- плашка с текстом ---
        var rect = CGRect(
            x: point.x - totalSize.width / 2,
            y: point.y - totalSize.height - 8,
            width: totalSize.width,
            height: totalSize.height
        )
        
        if rect.minX < 0 { rect.origin.x = 4 }
        if rect.maxX > chart.bounds.width { rect.origin.x = chart.bounds.width - rect.width - 4 }
        if rect.minY < 0 { rect.origin.y = point.y + 8 }
        
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        context.setFillColor(UIColor.white.cgColor)
        context.setStrokeColor(UIColor.lightGray.cgColor)
        context.setLineWidth(1)
        context.addPath(path.cgPath)
        context.drawPath(using: .fillStroke)
        
        let visitorsOrigin = CGPoint(x: rect.origin.x + padding, y: rect.origin.y + padding)
        visitorsText.draw(at: visitorsOrigin, withAttributes: visitorsAttrs)
        
        let dateOrigin = CGPoint(x: rect.origin.x + padding, y: visitorsOrigin.y + visitorsSize.height + lineSpacing)
        dateText.draw(at: dateOrigin, withAttributes: dateAttrs)
        
        context.restoreGState()
    }
    
    private func getVisitorsWord(for count: Int) -> String {
        let lastDigit = count % 10
        let lastTwoDigits = count % 100
        if lastTwoDigits >= 11 && lastTwoDigits <= 14 { return "посетителей" }
        switch lastDigit {
        case 1: return "посетитель"
        case 2,3,4: return "посетителя"
        default: return "посетителей"
        }
    }
    
    private func formatDateLabel(_ label: String) -> String {
        switch dateType {
        case .day:
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM"
            formatter.locale = Locale(identifier: "ru_RU")
            if let date = formatter.date(from: label) {
                let monthFormatter = DateFormatter()
                monthFormatter.dateFormat = "d MMMM"
                monthFormatter.locale = Locale(identifier: "ru_RU")
                return monthFormatter.string(from: date)
            }
            return label
        case .week:
            return "\(label) неделя"
        case .month:
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ru_RU")
            formatter.dateFormat = "MMM"
            if let date = formatter.date(from: label) {
                let monthFormatter = DateFormatter()
                monthFormatter.dateFormat = "LLLL"
                monthFormatter.locale = Locale(identifier: "ru_RU")
                return monthFormatter.string(from: date)
            }
            return label
        }
    }
}
