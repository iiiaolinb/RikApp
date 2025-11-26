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
    
    // MARK: - View Statistics
    
    /// Получает статистики просмотров из кэша
    public func getViewStatistics() -> [StatisticItem] {
        return realmService.getViewStatistics()
    }
    
    // MARK: - Gender and Age Statistics
    
    /// Получает данные по полу и возрасту для последней даты из статистик
    public func getGenderAndAgeData() -> (men: Int, women: Int, ageStats: [(range: String, men: Int, women: Int)])? {
        do {
            let realm = try RealmService.shared.getRealm()
            
            // Получаем все статистики типа "view"
            let viewStats = realm.objects(RealmStatisticItem.self)
                .filter("type == 'view'")
            
            guard !viewStats.isEmpty else {
                print("Нет статистик просмотров")
                return nil
            }
            
            // Находим последнюю дату (максимальный timestamp)
            var maxDate: Int = 0
            for stat in viewStats {
                if let maxInStat = stat.dates.max() {
                    maxDate = max(maxDate, maxInStat)
                }
            }
            
            guard maxDate > 0 else {
                print("Не найдено дат в статистиках")
                return nil
            }
            
            // Находим всех пользователей, у которых есть эта дата в их статистике
            var userIdsWithMaxDate: Set<Int> = []
            for stat in viewStats {
                if stat.dates.contains(maxDate) {
                    userIdsWithMaxDate.insert(stat.userId)
                }
            }
            
            guard !userIdsWithMaxDate.isEmpty else {
                print("Не найдено пользователей с последней датой")
                return nil
            }
            
            // Получаем данные пользователей
            let userIdsArray = Array(userIdsWithMaxDate)
            let users = realm.objects(RealmUser.self)
                .filter("id IN %@", userIdsArray)
            
            guard !users.isEmpty else {
                print("Не найдено пользователей в базе")
                return nil
            }
            
            // Подсчитываем пол
            var menCount = 0
            var womenCount = 0
            var ageGroups: [String: (men: Int, women: Int)] = [:]
            
            // Определяем возрастные группы
            let ageRanges = [
                (range: "18–21", min: 18, max: 21),
                (range: "22–25", min: 22, max: 25),
                (range: "26–30", min: 26, max: 30),
                (range: "31–35", min: 31, max: 35),
                (range: "36–40", min: 36, max: 40),
                (range: "40–50", min: 40, max: 50),
                (range: ">50", min: 51, max: Int.max)
            ]
            
            // Инициализируем все возрастные группы
            for ageRange in ageRanges {
                ageGroups[ageRange.range] = (men: 0, women: 0)
            }
            
            // Подсчитываем
            for user in users {
                if user.sex == "M" {
                    menCount += 1
                } else if user.sex == "W" {
                    womenCount += 1
                }
                
                // Определяем возрастную группу (пользователь попадает только в одну группу)
                var ageGroupFound = false
                for ageRange in ageRanges {
                    if ageGroupFound { break }
                    
                    if ageRange.range == ">50" {
                        if user.age > 50 {
                            if user.sex == "M" {
                                ageGroups[ageRange.range]?.men += 1
                            } else if user.sex == "W" {
                                ageGroups[ageRange.range]?.women += 1
                            }
                            ageGroupFound = true
                        }
                    } else {
                        // Для групп "36–40" и "40–50" нужно учесть пересечение
                        if ageRange.range == "36–40" {
                            if user.age >= 36 && user.age <= 40 {
                                if user.sex == "M" {
                                    ageGroups[ageRange.range]?.men += 1
                                } else if user.sex == "W" {
                                    ageGroups[ageRange.range]?.women += 1
                                }
                                ageGroupFound = true
                            }
                        } else if ageRange.range == "40–50" {
                            if user.age >= 41 && user.age <= 50 {
                                if user.sex == "M" {
                                    ageGroups[ageRange.range]?.men += 1
                                } else if user.sex == "W" {
                                    ageGroups[ageRange.range]?.women += 1
                                }
                                ageGroupFound = true
                            }
                        } else {
                            if user.age >= ageRange.min && user.age <= ageRange.max {
                                if user.sex == "M" {
                                    ageGroups[ageRange.range]?.men += 1
                                } else if user.sex == "W" {
                                    ageGroups[ageRange.range]?.women += 1
                                }
                                ageGroupFound = true
                            }
                        }
                    }
                }
            }
            
            let total = menCount + womenCount
            guard total > 0 else {
                print("Нет пользователей для подсчета")
                return nil
            }
            
            // Вычисляем проценты
            let menPercent = Int((Double(menCount) / Double(total)) * 100)
            let womenPercent = Int((Double(womenCount) / Double(total)) * 100)
            
            // Формируем статистику по возрастам в процентах
            var ageStats: [(range: String, men: Int, women: Int)] = []
            for ageRange in ageRanges {
                if let stats = ageGroups[ageRange.range] {
                    let menPercent = Int((Double(stats.men) / Double(total)) * 100)
                    let womenPercent = Int((Double(stats.women) / Double(total)) * 100)
                    ageStats.append((range: ageRange.range, men: menPercent, women: womenPercent))
                }
            }
            
            print("Данные по полу и возрасту: мужчины \(menPercent)%, женщины \(womenPercent)%")
            return (men: menPercent, women: womenPercent, ageStats: ageStats)
            
        } catch {
            print("Ошибка получения данных по полу и возрасту: \(error)")
            return nil
        }
    }
}

