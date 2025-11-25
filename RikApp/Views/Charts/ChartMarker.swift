//
//  ChartMarker.swift
//  RikApp
//
//  Created by Егор Худяев on 25.11.2025.
//

import UIKit
import DGCharts
import PinLayout

// MARK: - Chart Marker для аннотации
final class ChartMarker: MarkerImage {
    private var label: String = ""
    private var attrs: [NSAttributedString.Key: Any] = [:]
    private var labelSize: CGSize = CGSize()
    
    nonisolated override init() {
        super.init()
    }
    
    nonisolated override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint {
        var offset = self.offset
        let size = self.size
        
        let width = size.width
        let height = size.height
        let padding: CGFloat = 8
        
        var origin = point
        origin.x -= width / 2
        origin.y -= height
        
        if origin.x + offset.x < 0.0 {
            offset.x = -origin.x + padding
        } else if let chart = chartView, origin.x + width + offset.x > chart.bounds.size.width {
            offset.x = chart.bounds.size.width - origin.x - width - padding
        }
        
        if origin.y + offset.y < 0 {
            offset.y = height + padding
        } else if let chart = chartView, origin.y + height + offset.y > chart.bounds.size.height {
            offset.y = chart.bounds.size.height - origin.y - height - padding
        }
        
        return offset
    }
    
    nonisolated override func draw(context: CGContext, point: CGPoint) {
        let offset = self.offsetForDrawing(atPoint: point)
        let size = self.size
        
        var rect = CGRect(
            origin: CGPoint(
                x: point.x + offset.x,
                y: point.y + offset.y
            ),
            size: size
        )
        rect.origin.x -= size.width / 2.0
        rect.origin.y -= size.height
        
        context.saveGState()
        
        // Рисуем фон
        context.setFillColor(UIColor.black.withAlphaComponent(0.8).cgColor)
        context.beginPath()
        context.addRect(rect)
        context.fillPath()
        
        // Рисуем текст
        rect.origin.y += 4
        rect.origin.x += 8
        rect.size.width -= 16
        rect.size.height -= 8
        label.draw(with: rect, options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
        
        context.restoreGState()
    }
    
    nonisolated override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        let value = formatter.string(from: NSNumber(value: entry.y)) ?? "\(Int(entry.y))"
        label = "\(value) просмотров"
        
        attrs[.font] = UIFont.systemFont(ofSize: 12, weight: .medium)
        attrs[.foregroundColor] = UIColor.white
        
        labelSize = label.size(withAttributes: attrs)
        size = CGSize(width: labelSize.width + 16, height: labelSize.height + 8)
    }
}
