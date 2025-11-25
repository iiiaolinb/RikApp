//
//  User.swift
//  NetworkLayerFramework
//
//  Created by Егор Худяев on 24.11.2025.
//

import Foundation

public struct UsersResponse: Codable {
    public let users: [User]
    
    public init(users: [User]) {
        self.users = users
    }
}

public struct User: Codable {
    public let id: Int
    public let sex: Sex
    public let username: String
    public let isOnline: Bool
    public let age: Int
    public let files: [FileItem]
    
    public init(id: Int, sex: Sex, username: String, isOnline: Bool, age: Int, files: [FileItem]) {
        self.id = id
        self.sex = sex
        self.username = username
        self.isOnline = isOnline
        self.age = age
        self.files = files
    }
}

public enum Sex: String, Codable {
    case M
    case W
}

public struct FileItem: Codable {
    public let id: Int
    public let url: String
    public let type: FileType
    
    public init(id: Int, url: String, type: FileType) {
        self.id = id
        self.url = url
        self.type = type
    }
}

public enum FileType: String, Codable {
    case avatar
}

