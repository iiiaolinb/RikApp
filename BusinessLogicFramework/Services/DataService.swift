//
//  DataService.swift
//  BusinessLogicFramework
//
//  Created by Егор Худяев on 24.11.2025.
//

import Foundation
import NetworkLayerFramework

// MARK: - Gender & Age Periods

public enum GenderAgePeriod {
    case today
    case week
    case month
    case allTime
}

// MARK: - Data Result

public struct DataResult {
    public let statistics: StatisticsResponse
    public let users: UsersResponse
    
    public init(statistics: StatisticsResponse, users: UsersResponse) {
        self.statistics = statistics
        self.users = users
    }
}

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
        do {
            let stats = try await networkService.fetchStatistics()
            print("Статистики успешно загружены с сервера: \(stats.statistics)")
            realmService.saveStatistics(stats)
            return stats
        } catch {
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
        do {
            let users = try await networkService.fetchUsers()
            print("Пользователи успешно загружены с сервера: \(users.users)")
            realmService.saveUsers(users)
            return users
        } catch {
            print("Ошибка загрузки пользователей с сервера: \(error)")
            return nil
        }
    }
    
    /// Возвращает всех пользователей из кэша (Realm).
    /// Если пользователей нет, вернет пустой массив.
    public func getCachedUsers() -> [User] {
        return realmService.getCachedUsers()?.users ?? []
    }
    
    /// Возвращает пользователей, отсортированных по количеству просмотров (type == "view").
    /// Пользователь с максимальным количеством дат в статистике просмотров будет первым.
    public func getTopViewers(limit: Int? = nil) -> [User] {
        do {
            let realm = try RealmService.shared.getRealm()
            
            // Берём только статистику с типом "view"
            let viewStats = realm.objects(RealmStatisticItem.self)
                .filter("type == 'view'")
            
            guard !viewStats.isEmpty else {
                print("getTopViewers: нет статистики просмотров")
                return []
            }
            
            // Суммируем количество дат по каждому userId
            var viewsPerUser: [Int: Int] = [:]  // userId -> count
            for stat in viewStats {
                viewsPerUser[stat.userId, default: 0] += stat.dates.count
            }
            
            // Сортируем по количеству просмотров по убыванию
            let sortedUserIds = viewsPerUser
                .sorted { $0.value > $1.value }
                .map { $0.key }
            
            let finalUserIds: [Int]
            if let limit = limit {
                finalUserIds = Array(sortedUserIds.prefix(limit))
            } else {
                finalUserIds = sortedUserIds
            }
            
            guard !finalUserIds.isEmpty else {
                print("getTopViewers: после сортировки нет userId")
                return []
            }
            
            // Получаем пользователей из RealmUser по найденным id
            let realmUsers = realm.objects(RealmUser.self)
                .filter("id IN %@", finalUserIds)
            
            // Преобразуем в сет для быстрого поиска
            let usersArray = Array(realmUsers.compactMap { $0.toUser() })
            
            // Сохраняем порядок по количеству просмотров
            let usersById = Dictionary(uniqueKeysWithValues: usersArray.map { ($0.id, $0) })
            let orderedUsers: [User] = finalUserIds.compactMap { usersById[$0] }
            
            return orderedUsers
        } catch {
            print("getTopViewers: ошибка доступа к Realm: \(error)")
            return []
        }
    }
    
    // MARK: - Combined Operations
    
    /// Загружает все данные: сначала из кэша, если нет - с сервера
    public func loadAllData() async -> DataResult? {
        async let stats = loadStatistics()
        async let users = loadUsers()
        
        guard let statsResult = await stats, let usersResult = await users else {
            return nil
        }
        
        return DataResult(statistics: statsResult, users: usersResult)
    }
    
    /// Принудительное обновление всех данных с сервера
    public func refreshAllData() async -> DataResult? {
        print("Принудительное обновление: загрузка всех данных с сервера")
        async let stats = fetchStatisticsFromServer()
        async let users = fetchUsersFromServer()
        
        guard let statsResult = await stats, let usersResult = await users else {
            return nil
        }
        
        return DataResult(statistics: statsResult, users: usersResult)
    }
    
    // MARK: - View Statistics
    
    /// Получает статистики просмотров из кэша
    public func getViewStatistics() -> [StatisticItem] {
        return realmService.getViewStatistics()
    }
    
    // MARK: - Gender and Age Statistics
    
    /// Преобразуем timestamp (ddMMyyyy) → Date так же, как в VisitorsChartCell
    private func statisticDate(from timestamp: Int) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMyyyy"
        
        var s = String(timestamp)
        if s.count < 8 {
            s = String(repeating: "0", count: 8 - s.count) + s
        }
        
        return formatter.date(from: s)
    }
    
    /// Получает данные по полу и возрасту для указанного периода
    public func getGenderAndAgeData(for period: GenderAgePeriod) -> (men: Int, women: Int, ageStats: [(range: String, men: Int, women: Int)])? {
        do {
            let realm = try RealmService.shared.getRealm()
            
            // Получаем все статистики типа "view"
            let viewStats = realm.objects(RealmStatisticItem.self)
                .filter("type == 'view'")
            
            guard !viewStats.isEmpty else {
                print("Нет статистик просмотров")
                return nil
            }
            
            // Собираем все timestamps, чтобы найти максимальную дату
            var allTimestamps: [Int] = []
            for stat in viewStats {
                allTimestamps.append(contentsOf: stat.dates)
            }
            
            guard let maxTimestamp = allTimestamps.max(),
                  let maxDate = statisticDate(from: maxTimestamp) else {
                print("Не найдено дат в статистиках или не удаётся распарсить дату")
                return nil
            }
            
            let calendar = Calendar.current
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: maxDate)
            let monthAgo = calendar.date(byAdding: .day, value: -30, to: maxDate)
            
            // Считаем КОЛИЧЕСТВО ПОСЕЩЕНИЙ (events) по каждому пользователю за период
            var userIdsForPeriod: Set<Int> = []
            var visitsByUser: [Int: Int] = [:] // userId -> visits count in period
            var totalVisitsAll: Int = 0
            
            for stat in viewStats {
                var visitsInPeriod = 0
                
                switch period {
                case .today:
                    // День: считаем только события в последний день (maxTimestamp)
                    visitsInPeriod = stat.dates.filter { $0 == maxTimestamp }.count
                    
                case .week:
                    if let weekAgo {
                        for ts in stat.dates {
                            guard let d = statisticDate(from: ts) else { continue }
                            if d >= weekAgo && d <= maxDate {
                                visitsInPeriod += 1
                            }
                        }
                    }
                    
                case .month:
                    if let monthAgo {
                        for ts in stat.dates {
                            guard let d = statisticDate(from: ts) else { continue }
                            if d >= monthAgo && d <= maxDate {
                                visitsInPeriod += 1
                            }
                        }
                    }
                    
                case .allTime:
                    visitsInPeriod = stat.dates.count
                }
                
                guard visitsInPeriod > 0 else { continue }
                
                userIdsForPeriod.insert(stat.userId)
                visitsByUser[stat.userId, default: 0] += visitsInPeriod
                totalVisitsAll += visitsInPeriod
            }
            
            guard !userIdsForPeriod.isEmpty, totalVisitsAll > 0 else {
                print("Не найдено посещений для выбранного периода \(period)")
                return nil
            }
            
            // Получаем данные пользователей
            let userIdsArray = Array(userIdsForPeriod)
            let users = realm.objects(RealmUser.self)
                .filter("id IN %@", userIdsArray)
            
            guard !users.isEmpty else {
                print("Не найдено пользователей в базе")
                return nil
            }
            
            // Мапа пользователей по id для быстрого доступа
            let usersById: [Int: RealmUser] = Dictionary(uniqueKeysWithValues: users.map { ($0.id, $0) })
            
            // Подсчитываем пол и возрастные группы
            // ВАЖНО: считаем по количеству посещений, а не по количеству пользователей
            var menVisits = 0
            var womenVisits = 0
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
            for (userId, visits) in visitsByUser {
                guard let user = usersById[userId], visits > 0 else { continue }
                
                // Считаем общие визиты по полу (включая пользователей младше 18 лет)
                // Определяем возрастную группу (пользователь попадает только в одну группу)
                if user.sex == "M" {
                    menVisits += visits
                } else if user.sex == "W" {
                    womenVisits += visits
                }
                
                // Пользователи младше 18 не попадают ни в одну возрастную группу
                guard user.age >= 18 else { continue }
                
                var ageGroupFound = false
                for ageRange in ageRanges {
                    if ageGroupFound { break }
                    
                    if ageRange.range == ">50" {
                        if user.age > 50 {
                            if user.sex == "M" {
                                ageGroups[ageRange.range]?.men += visits
                            } else if user.sex == "W" {
                                ageGroups[ageRange.range]?.women += visits
                            }
                            ageGroupFound = true
                        }
                    } else {
                        // Для групп "36–40" и "40–50" нужно учесть пересечение
                        if ageRange.range == "36–40" {
                            if user.age >= 36 && user.age <= 40 {
                                if user.sex == "M" {
                                    ageGroups[ageRange.range]?.men += visits
                                } else if user.sex == "W" {
                                    ageGroups[ageRange.range]?.women += visits
                                }
                                ageGroupFound = true
                            }
                        } else if ageRange.range == "40–50" {
                            if user.age >= 41 && user.age <= 50 {
                                if user.sex == "M" {
                                    ageGroups[ageRange.range]?.men += visits
                                } else if user.sex == "W" {
                                    ageGroups[ageRange.range]?.women += visits
                                }
                                ageGroupFound = true
                            }
                        } else {
                            if user.age >= ageRange.min && user.age <= ageRange.max {
                                if user.sex == "M" {
                                    ageGroups[ageRange.range]?.men += visits
                                } else if user.sex == "W" {
                                    ageGroups[ageRange.range]?.women += visits
                                }
                                ageGroupFound = true
                            }
                        }
                    }
                }
            }
            
            let totalVisitsForGender = menVisits + womenVisits
            guard totalVisitsForGender > 0 else {
                print("Нет посещений для подсчета пола")
                return nil
            }
            
            // Вычисляем проценты пола относительно всех посещений за период
            let menPercent = Int((Double(menVisits) / Double(totalVisitsAll)) * 100)
            let womenPercent = Int((Double(womenVisits) / Double(totalVisitsAll)) * 100)
            
            // Формируем статистику по возрастам в процентах
            var ageStats: [(range: String, men: Int, women: Int)] = []
            for ageRange in ageRanges {
                if let stats = ageGroups[ageRange.range] {
                    let groupTotal = stats.men + stats.women
                    guard groupTotal > 0, totalVisitsAll > 0 else {
                        ageStats.append((range: ageRange.range, men: 0, women: 0))
                        continue
                    }
                    // Для строки возраста считаем проценты относительно общего количества посещений за период
                    let menPercent = Int((Double(stats.men) / Double(totalVisitsAll)) * 100)
                    let womenPercent = Int((Double(stats.women) / Double(totalVisitsAll)) * 100)
                    ageStats.append((range: ageRange.range, men: menPercent, women: womenPercent))
                }
            }
            
            print("Данные по полу и возрасту (\(period)): мужчины \(menPercent)%, женщины \(womenPercent)%")
            return (men: menPercent, women: womenPercent, ageStats: ageStats)
            
        } catch {
            print("Ошибка получения данных по полу и возрасту: \(error)")
            return nil
        }
    }

    /// Backwards-совместимый метод: возвращает данные только за последний день
    public func getGenderAndAgeData() -> (men: Int, women: Int, ageStats: [(range: String, men: Int, women: Int)])? {
        return getGenderAndAgeData(for: .today)
    }
}

