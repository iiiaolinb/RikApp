//
//  NetworkAssistent.swift
//  RikApp
//
//  Created by Егор Худяев on 24.11.2025.
//

import Foundation

final class NetworkAssistent {

    static let shared = NetworkAssistent()
    private init() {}

    private let decoder: JSONDecoder = {
        let dec = JSONDecoder()
        dec.keyDecodingStrategy = .convertFromSnakeCase
        return dec
    }()
    
    func fetchStatistics() async -> Result<StatisticsResponse, Error> {
        await request(.statistics)
    }

    func fetchUsers() async -> Result<UsersResponse, Error> {
        await request(.users)
    }

    private func request<T: Decodable>(_ endpoint: APIEndpoint) async -> Result<T, Error> {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = endpoint.method

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let http = response as? HTTPURLResponse,
                  (200..<300).contains(http.statusCode) else {
                return .failure(NSError(domain: "BadStatusCode", code: 1))
            }

            do {
                let decoded = try decoder.decode(T.self, from: data)
                return .success(decoded)
            } catch {
                return .failure(error)
            }

        } catch {
            return .failure(error)
        }
    }
}
