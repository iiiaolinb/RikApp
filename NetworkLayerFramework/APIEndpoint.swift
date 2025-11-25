//
//  APIEndpoint.swift
//  NetworkLayerFramework
//
//  Created by Егор Худяев on 24.11.2025.
//

import Foundation

public enum APIEndpoint {
    case statistics
    case users
}

extension APIEndpoint {
    public var url: URL {
        switch self {
        case .statistics:
            return URL(string: "http://test-case.rikmasters.ru/api/episode/statistics/")!
        case .users:
            return URL(string: "http://test-case.rikmasters.ru/api/episode/users/")!
        }
    }
    
    public var method: String {
        "GET"
    }
}

