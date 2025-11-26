//
//  NetworkAssistent.swift
//  NetworkLayerFramework
//
//  Created by Егор Худяев on 24.11.2025.
//

import Foundation

public final class NetworkAssistent {

    public static let shared = NetworkAssistent()
    private init() {}

    private let decoder: JSONDecoder = {
        let dec = JSONDecoder()
        dec.keyDecodingStrategy = .convertFromSnakeCase
        return dec
    }()
    
    public func fetchStatistics() async throws -> StatisticsResponse {
        try await request(.statistics)
    }

    public func fetchUsers() async throws -> UsersResponse {
        try await request(.users)
    }

    private func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = endpoint.method

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw NSError(domain: "BadStatusCode", code: 1)
        }

        do {
            let decoded = try decoder.decode(T.self, from: data)
            return decoded
        } catch {
            throw error
        }
    }
    
    public func requestRaw(_ endpoint: APIEndpoint) async throws -> Data {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = endpoint.method

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw NSError(domain: "BadStatusCode", code: 1)
        }

        return data
    }
}

