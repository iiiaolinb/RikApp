//
//  Statistic.swift
//  NetworkLayerFramework
//
//  Created by Егор Худяев on 24.11.2025.
//

import Foundation

public struct StatisticsResponse: Codable {
    public let statistics: [StatisticItem]
    
    public init(statistics: [StatisticItem]) {
        self.statistics = statistics
    }
}

public struct StatisticItem: Codable {
    public let userId: Int
    public let type: StatisticType
    public let dates: [Int]
    
    public init(userId: Int, type: StatisticType, dates: [Int]) {
        self.userId = userId
        self.type = type
        self.dates = dates
    }
}

public enum StatisticType: String, Codable {
    case view
    case subscription
    case unsubscription
}

