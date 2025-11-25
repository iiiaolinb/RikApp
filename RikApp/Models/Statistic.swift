//
//  Statistic.swift
//  RikApp
//
//  Created by Егор Худяев on 24.11.2025.
//

import Foundation

struct StatisticsResponse: Codable {
    let statistics: [StatisticItem]
}

struct StatisticItem: Codable {
    let userId: Int
    let type: StatisticType
    let dates: [Int]
}

enum StatisticType: String, Codable {
    case view
    case subscription
    case unsubscription
}
