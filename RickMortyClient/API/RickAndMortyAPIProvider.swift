//
//  RickAndMortyAPIProvider.swift
//  RickMortyClient
//
//  Created by Vladimir Gonta on 21.03.2023.
//

import Foundation
import Moya

enum RickAndMortyAPIError: Error {
    case noMoreContent
}

class RickAndMortyAPIProvider {
    
    private let provider = MoyaProvider<RickAndMortyAPI>(plugins: [
//        NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
    ])
    
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.iso8601Full)
        return decoder
    }()
    
    func getItem<T: Decodable>(id: [Int], completion: @escaping (Result<T, Error>) -> Void) {
        
        provider.request(.getItem(T: T.self, id: id)) { [decoder] result in
            switch result {
            case let .success(response):
                do {
                    let episodeList = try response.map(T.self, using: decoder)
                    completion(.success(episodeList))
                } catch {
                    completion(.failure(error))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    func getItemsList<T: Decodable>(page: Int, completion: @escaping (Result<T, Error>) -> Void) {
        
        provider.request(.getItems(T: T.self, page: page)) { [decoder] result in
            switch result {
            case let .success(response):
                do {
                    let episodeList = try response.map(T.self, using: decoder)
                    completion(.success(episodeList))
                } catch {
//                    completion(.failure(error))
                    do {
                        let error = try response.map([String: String].self, using: decoder)
                        if let error = error["error"],
                           error == "There is nothing here" {
                            completion(.failure(RickAndMortyAPIError.noMoreContent))
                        }
                    } catch {
                        completion(.failure(error))
                    }
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
