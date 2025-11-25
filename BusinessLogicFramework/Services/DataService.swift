//
//  DataService.swift
//  BusinessLogicFramework
//
//  Created by Егор Худяев on 24.11.2025.
//

import Foundation
import NetworkLayerFramework

public final class DataService {
    public static let shared = DataService()
    
    private let realmService = RealmService.shared
    private let networkService = NetworkAssistent.shared
    
    private init() {}
    
    // MARK: - Statistics
    
    /// Загружает статистики: сначала из кэша, если нет - с сервера
    public func loadStatistics() async -> StatisticsResponse? {
        print("Загрузка статистик: проверка данных в базе данных")
        
        if let cachedStats = realmService.getCachedStatistics() {
            print("Статистики загружены из кэша")
            print("Статистики из кэша: \(cachedStats.statistics)")
            return cachedStats
        }
        
        print("Кэша нет, загружаем статистики с сервера")
        return await fetchStatisticsFromServer()
    }
    
    /// Принудительная загрузка статистик с сервера
    public func fetchStatisticsFromServer() async -> StatisticsResponse? {
        print("Запрос статистик с сервера...")
        let statsResult = await networkService.fetchStatistics()
        
        switch statsResult {
        case .success(let stats):
            print("Статистики успешно загружены с сервера: \(stats.statistics)")
            realmService.saveStatistics(stats)
            return stats
        case .failure(let error):
            print("Ошибка загрузки статистик с сервера: \(error)")
            return nil
        }
    }
    
    // MARK: - Users
    
    /// Загружает пользователей: сначала из кэша, если нет - с сервера
    public func loadUsers() async -> UsersResponse? {
        print("Загрузка пользователей: проверка данных в базе данных")
        
        if let cachedUsers = realmService.getCachedUsers() {
            print("Пользователи загружены из кэша")
            print("Пользователи из кэша: \(cachedUsers.users)")
            return cachedUsers
        }
        
        print("Кэша нет, загружаем пользователей с сервера")
        return await fetchUsersFromServer()
    }
    
    /// Принудительная загрузка пользователей с сервера
    public func fetchUsersFromServer() async -> UsersResponse? {
        print("Запрос пользователей с сервера...")
        let usersResult = await networkService.fetchUsers()
        
        switch usersResult {
        case .success(let users):
            print("Пользователи успешно загружены с сервера: \(users.users)")
            realmService.saveUsers(users)
            return users
        case .failure(let error):
            print("Ошибка загрузки пользователей с сервера: \(error)")
            return nil
        }
    }
    
    // MARK: - Combined Operations
    
    /// Загружает все данные: сначала из кэша, если нет - с сервера
    public func loadAllData() async -> (statistics: StatisticsResponse?, users: UsersResponse?) {
        async let stats = loadStatistics()
        async let users = loadUsers()
        return (await stats, await users)
    }
    
    /// Принудительное обновление всех данных с сервера
    public func refreshAllData() async -> (statistics: StatisticsResponse?, users: UsersResponse?) {
        print("Принудительное обновление: загрузка всех данных с сервера")
        async let stats = fetchStatisticsFromServer()
        async let users = fetchUsersFromServer()
        return (await stats, await users)
    }
}

