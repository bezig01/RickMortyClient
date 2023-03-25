//
//  RickAndMortyAPI.swift
//  RickMortyClient
//
//  Created by Vladimir Gonta on 21.03.2023.
//

import Foundation
import Moya

enum RickAndMortyAPI {
    case getCharacter(id: [Int])
    case getCharacters(page: Int)
    case getLocation(id: [Int])
    case getLocations(page: Int)
    case getEpisode(id: [Int])
    case getEpisodes(page: Int)
    case getItem(T: Any, id: [Int])
    case getItems(T: Any, page: Int)
}

extension RickAndMortyAPI: TargetType {
    
    var baseURL: URL { URL(string: "https://rickandmortyapi.com/api")! }
    
    var path: String {
        switch self {
        case .getCharacter(let id):
            return "/character/[\(id.map(String.init).joined(separator: ","))]"
        case .getCharacters:
            return "/character/"
        case .getLocation(let id):
            return "/location/[\(id.map(String.init).joined(separator: ","))]"
        case .getLocations:
            return "/location/"
        case .getEpisode(let id):
            return "/episode/[\(id.map(String.init).joined(separator: ","))]"
        case .getEpisodes:
            return "/episode/"
        case .getItem(let T, let id):
            switch T {
            case is Character.Type, is [Character].Type:
                return Self.getCharacter(id: id).path
            case is Location.Type, is [Location].Type:
                return Self.getLocation(id: id).path
            case is Episode.Type, is [Episode].Type:
                return Self.getEpisode(id: id).path
            default:
                fatalError()
            }
        case .getItems(let T, let page):
            switch T {
            case is ItemsList<Character>.Type:
                return Self.getCharacters(page: page).path
            case is ItemsList<Location>.Type:
                return Self.getLocations(page: page).path
            case is ItemsList<Episode>.Type:
                return Self.getEpisodes(page: page).path
            default:
                fatalError()
            }
        }
    }
    
    var method: Moya.Method { .get }
    
    var task: Task {
        switch self {
        case .getCharacter, .getLocation, .getEpisode, .getItem:
            return .requestPlain
        case .getCharacters(let page), .getLocations(let page), .getEpisodes(let page), .getItems(_, let page):
            return .requestParameters(parameters: ["page": page], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String: String]? { nil }
}
