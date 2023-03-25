//
//  RickAndMortyAPIModels.swift
//  RickMortyClient
//
//  Created by Vladimir Gonta on 21.03.2023.
//

import Foundation

struct Info: Decodable {
    let count: Int
    let pages: Int
    let next: URL?
    let prev: URL?
}

struct Character: Codable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let type: String
    let gender: String
    let origin: Location
    let location: Location
    let image: URL
    let episode: [URL]
    let url: URL
    let created: Date
}

extension Character {
    struct Location: Codable {
        let name: String
        let url: String
    }
}

struct Location: Decodable {
    let id: Int
    let name: String
    let type: String
    let dimension: String
    let residents: [URL]
    let url: URL
    let created: Date
}

struct Episode: Codable {
    let id: Int
    let name: String
    let airDate: String
    let episode: String
    let characters: [URL]
    let url: URL
    let created: Date
    
    enum CodingKeys: String, CodingKey {
        case id, name, episode, characters, url, created
        case airDate = "air_date"
    }
}

struct ItemsList<T: Decodable>: Decodable {
    let info: Info
    let results: [T]
}
