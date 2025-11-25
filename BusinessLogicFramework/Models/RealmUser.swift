//
//  RealmUser.swift
//  BusinessLogicFramework
//
//  Created by Егор Худяев on 24.11.2025.
//

import Foundation
import RealmSwift
import NetworkLayerFramework

public final class RealmUser: Object {
    @Persisted public var id: Int = 0
    @Persisted public var sex: String = ""
    @Persisted public var username: String = ""
    @Persisted public var isOnline: Bool = false
    @Persisted public var age: Int = 0
    @Persisted public var files: List<RealmFileItem> = List<RealmFileItem>()
    @Persisted public var cachedAt: Date = Date()
    
    public convenience init(from user: NetworkLayerFramework.User) {
        self.init()
        self.id = user.id
        self.sex = user.sex.rawValue
        self.username = user.username
        self.isOnline = user.isOnline
        self.age = user.age
        self.files.append(objectsIn: user.files.map { RealmFileItem(from: $0) })
        self.cachedAt = Date()
    }
    
    public func toUser() -> NetworkLayerFramework.User? {
        guard let sexEnum = Sex(rawValue: sex) else {
            return nil
        }
        let fileItems = Array(files.compactMap { $0.toFileItem() })
        return NetworkLayerFramework.User(
            id: id,
            sex: sexEnum,
            username: username,
            isOnline: isOnline,
            age: age,
            files: fileItems
        )
    }
}

