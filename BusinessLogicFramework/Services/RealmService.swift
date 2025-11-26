//
//  RealmService.swift
//  BusinessLogicFramework
//
//  Created by Егор Худяев on 24.11.2025.
//

import Foundation
import RealmSwift
import NetworkLayerFramework

public final class RealmService {
    public static let shared = RealmService()
    
    private let config: Realm.Configuration
    
    private init() {
        config = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in }
        )
        print("Realm конфигурация инициализирована успешно")
    }
    
    func getRealm() throws -> Realm {
        return try Realm(configuration: config)
    }
    
    // MARK: - Statistics
    
    public func getCachedStatistics() -> StatisticsResponse? {
        do {
            let realm = try getRealm()
            let cachedItems = realm.objects(RealmStatisticItem.self)
            
            if cachedItems.isEmpty {
                print("Кэшированных статистик нет в базе данных")
                return nil
            }
            
            let statistics = Array(cachedItems.compactMap { $0.toStatisticItem() })
            print("Найдено \(statistics.count) статистик в кэше")
            return StatisticsResponse(statistics: statistics)
        } catch {
            print("Ошибка доступа к Realm: \(error)")
            return nil
        }
    }
    
    public func saveStatistics(_ statistics: StatisticsResponse) {
        do {
            let realm = try getRealm()
            try realm.write {
                realm.delete(realm.objects(RealmStatisticItem.self))
                
                let realmItems = statistics.statistics.map { RealmStatisticItem(from: $0) }
                realm.add(realmItems)
            }
            print("Статистики сохранены в кэш (\(statistics.statistics.count) записей)")
        } catch {
            print("Ошибка сохранения статистик: \(error)")
        }
    }
    
    /// Преобразует timestamp формата ddMMyyyy (например, 01012025) в `Date`.
    /// Если число короче 8 символов, добивает ведущими нулями.
    private func statisticDate(from timestamp: Int) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMyyyy"
        
        var s = String(timestamp)
        if s.count < 8 {
            s = String(repeating: "0", count: 8 - s.count) + s
        }
        
        return formatter.date(from: s)
    }
    
    /// Возвращает количество подписок и отписок за последний месяц,
    /// отсчитывая от самой последней известной даты в статистиках.
    ///
    /// - Returns: Кортеж `(new: Int, lost: Int)` или `nil`, если статистики нет.
    public func getFollowersCountsLastMonth() -> (new: Int, lost: Int)? {
        do {
            let realm = try getRealm()
            let followerStats = realm.objects(RealmStatisticItem.self)
                .filter("type == 'subscription' OR type == 'unsubscription'")
            
            guard !followerStats.isEmpty else {
                print("getFollowersCountsLastMonth: нет статистики подписок/отписок")
                return nil
            }
            
            // Находим максимальный timestamp среди всех дат
            var allTimestamps: [Int] = []
            for stat in followerStats {
                allTimestamps.append(contentsOf: stat.dates)
            }
            
            guard let maxTimestamp = allTimestamps.max(),
                  let maxDate = statisticDate(from: maxTimestamp) else {
                print("getFollowersCountsLastMonth: не удалось определить максимальную дату")
                return nil
            }
            
            let calendar = Calendar.current
            guard let monthAgo = calendar.date(byAdding: .day, value: -30, to: maxDate) else {
                print("getFollowersCountsLastMonth: не удалось вычислить дату месяц назад")
                return nil
            }
            
            var newCount = 0
            var lostCount = 0
            
            // Считаем все события за период [monthAgo, maxDate]
            for stat in followerStats {
                for ts in stat.dates {
                    guard let date = statisticDate(from: ts) else { continue }
                    if date >= monthAgo && date <= maxDate {
                        if stat.type == "subscription" {
                            newCount += 1
                        } else if stat.type == "unsubscription" {
                            lostCount += 1
                        }
                    }
                }
            }
            
            return (new: newCount, lost: lostCount)
        } catch {
            print("getFollowersCountsLastMonth: ошибка доступа к Realm: \(error)")
            return nil
        }
    }
    
    /// Получает статистики типа "view" из кэша
    public func getViewStatistics() -> [StatisticItem] {
        do {
            let realm = try getRealm()
            let viewStats = realm.objects(RealmStatisticItem.self)
                .filter("type == 'view'")
            
            return Array(viewStats.compactMap { $0.toStatisticItem() })
        } catch {
            print("Ошибка получения статистик просмотров: \(error)")
            return []
        }
    }
    
    // MARK: - Users
    
    public func getCachedUsers() -> UsersResponse? {
        do {
            let realm = try getRealm()
            let cachedUsers = realm.objects(RealmUser.self)
            
            if cachedUsers.isEmpty {
                print("Кэшированных пользователей нет в базе данных")
                return nil
            }
            
            let users = Array(cachedUsers.compactMap { $0.toUser() })
            print("Найдено \(users.count) пользователей в кэше")
            return UsersResponse(users: users)
        } catch {
            print("Ошибка доступа к Realm: \(error)")
            return nil
        }
    }
    
    public func saveUsers(_ users: UsersResponse) {
        do {
            let realm = try getRealm()
            try realm.write {
                realm.delete(realm.objects(RealmUser.self))
                
                let realmUsers = users.users.map { RealmUser(from: $0) }
                realm.add(realmUsers)
            }
            print("Пользователи сохранены в кэш (\(users.users.count) записей)")
        } catch {
            print("Ошибка сохранения пользователей: \(error)")
        }
    }
}

