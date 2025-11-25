//
//  User.swift
//  RikApp
//
//  Created by Егор Худяев on 24.11.2025.
//

import Foundation

struct UsersResponse: Codable {
    let users: [User]
}

struct User: Codable {
    let id: Int
    let sex: Sex
    let username: String
    let isOnline: Bool
    let age: Int
    let files: [FileItem]
}

enum Sex: String, Codable {
    case M
    case W
}

struct FileItem: Codable {
    let id: Int
    let url: String
    let type: FileType
}

enum FileType: String, Codable {
    case avatar
}
