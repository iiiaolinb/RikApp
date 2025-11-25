//
//  RealmStatisticItem.swift
//  BusinessLogicFramework
//
//  Created by Егор Худяев on 24.11.2025.
//

import Foundation
import RealmSwift
import NetworkLayerFramework

public final class RealmStatisticItem: Object {
    @Persisted public var userId: Int = 0
    @Persisted public var type: String = ""
    @Persisted public var dates: List<Int> = List<Int>()
    @Persisted public var cachedAt: Date = Date()
    
    public convenience init(from statisticItem: StatisticItem) {
        self.init()
        self.userId = statisticItem.userId
        self.type = statisticItem.type.rawValue
        self.dates.append(objectsIn: statisticItem.dates)
        self.cachedAt = Date()
    }
    
    public func toStatisticItem() -> StatisticItem? {
        guard let statisticType = StatisticType(rawValue: type) else {
            return nil
        }
        return StatisticItem(
            userId: userId,
            type: statisticType,
            dates: Array(dates)
        )
    }
}

