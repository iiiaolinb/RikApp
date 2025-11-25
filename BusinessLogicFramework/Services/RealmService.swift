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
    
    private func getRealm() throws -> Realm {
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
                // Удаляем старые данные
                realm.delete(realm.objects(RealmStatisticItem.self))
                
                // Сохраняем новые
                let realmItems = statistics.statistics.map { RealmStatisticItem(from: $0) }
                realm.add(realmItems)
            }
            print("Статистики сохранены в кэш (\(statistics.statistics.count) записей)")
        } catch {
            print("Ошибка сохранения статистик: \(error)")
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
                // Удаляем старые данные
                realm.delete(realm.objects(RealmUser.self))
                
                // Сохраняем новые
                let realmUsers = users.users.map { RealmUser(from: $0) }
                realm.add(realmUsers)
            }
            print("Пользователи сохранены в кэш (\(users.users.count) записей)")
        } catch {
            print("Ошибка сохранения пользователей: \(error)")
        }
    }
}

