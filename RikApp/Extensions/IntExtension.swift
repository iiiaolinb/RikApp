//
//  IntExtension.swift
//  RikApp
//
//  Created by Егор Худяев on 24.11.2025.
//

import Foundation

extension Int {
    // Преобразует Int в Date, если формат dMyyyy или ddMMyyyy
    func toDate() -> Date? {
        let dateString = String(self)
        let calendar = Calendar.current
        
        var day = 0
        var month = 0
        var year = 0
        
        switch dateString.count {
        case 7:
            // 1092024 -> 1 09 2024
            day = Int(dateString.prefix(1)) ?? 1
            month = Int(dateString.dropFirst(1).prefix(2)) ?? 1
            year = Int(dateString.suffix(4)) ?? 1970
        case 8:
            // 10092024 -> 10 09 2024
            day = Int(dateString.prefix(2)) ?? 1
            month = Int(dateString.dropFirst(2).prefix(2)) ?? 1
            year = Int(dateString.suffix(4)) ?? 1970
        default:
            return nil
        }
        
        var components = DateComponents()
        components.day = day
        components.month = month
        components.year = year
        
        return calendar.date(from: components)
    }
    
    // Преобразует Int в строку формата "dd.MM.yyyy"
    func toDateString() -> String? {
        guard let date = self.toDate() else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
}
