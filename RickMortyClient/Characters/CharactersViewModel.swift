//
//  CharactersViewModel.swift
//  RickMortyClient
//
//  Created by Vladimir Gonta on 21.03.2023.
//

import Foundation
import RxSwift
import RxRelay
import Differentiator

enum SectionItem {
    case character(Character)
    case characters([Character])
}

extension SectionItem: SectionModelType {
    var items: [Character] {
        switch self {
        case .character(let item):
            return [item]
        case .characters(let items):
            return items
        }
    }
    
    init(original: SectionItem, items: [Character]) {
        self = original
    }
}

class CharactersViewModel {
    
    private let provider = RickAndMortyAPIProvider()
    
    
    let sectionsRelay = BehaviorRelay<[SectionItem]>(value: [])
    var sections: [SectionItem] = [] {
        didSet {
            sectionsRelay.accept(sections)
        }
    }
    
    let itemsRelay = BehaviorRelay<[Character]>(value: [])
    var items: [Character] = [] {
        didSet {
            itemsRelay.accept(items)
        }
    }
    
    var episodes: [Int: Episode] = [:]
    
    let errorRelay = PublishRelay<Error?>()
    private var error: Error? {
        didSet {
            errorRelay.accept(error)
        }
    }
    
    private var page = 1
    
    var selectedItem: Character? {
        didSet {
            guard let selectedItem else { return }
            sections = [.character(selectedItem)]
        }
    }
    
    var hasNextPage: Bool {
        selectedItem == nil
    }
    
    func fetchNextPage() {
        
        provider.getItemsList(page: page) { [weak self] (result: Result<ItemsList<Character>, Error>) in
            guard let self else { return }
            switch result {
            case .success(let list):
                self.items = self.items + list.results
                self.sections = [.characters(self.items)]
                self.fetchEpisodes(list.results)
                self.page = self.page + 1
            case .failure(let error):
                self.error = error
            }
        }
    }
    
    func fetchEpisodes(_ items: [Character]) {
        
        let items = items
            .compactMap { ($0.id, $0.episode.first?.lastPathComponent) as? (Int, String) }
            .compactMap { ($0.0, Int($0.1)) as? (Int, Int) }
        
        let episodeIds = Set(items.map { $0.1 })
        
        provider.getItem(id: Array(episodeIds)) { [weak self] (result: Result<[Episode], Error>) in
            guard let self else { return }
            switch result {
            case .success(let episodes):
                for (id, episodeId) in items {
                    if let episode = episodes.first(where: { $0.id == episodeId }) {
                        self.episodes[id] = episode
                    }
                }
                self.items = self.items
                self.sections = self.sections
                
            case .failure(let error):
                self.error = error
            }
        }
    }
    
    private func fetchEpisodeUsers(_ episode: Episode) {
        
        let items = episode.characters.compactMap { Int($0.lastPathComponent) }
        
        let userIds = Set(items)
        
        provider.getItem(id: Array(userIds)) { [weak self] (result: Result<[Character], Error>) in
            guard let self else { return }
            switch result {
            case .success(let items):
                self.items = items
                self.sections = self.sections + [.characters(items)]
                
            case .failure(let error):
                self.error = error
            }
        }
    }
    
    func fetchLocationUsers(_ location: Character.Location) {
        guard let value = URL(string: location.url)?.lastPathComponent,
              let locationId = Int(value) else { return }
        
        provider.getItem(id: [locationId]) { [weak self] (result: Result<[Location], Error>) in
            switch result {
            case .success(let items):
                guard let location = items.first else { return }
                let items = location.residents.compactMap { $0.lastPathComponent }
                    .compactMap { Int($0) }
                
                let characterIds = Set(items)
                self?.provider.getItem(id: Array(characterIds)) { (result: Result<[Character], Error>) in
                    guard let self else { return }
                    switch result {
                    case .success(let items):
                        self.items = items
                        self.sections = self.sections + [.characters(items)]
                        self.fetchEpisodes(items)
                        
                    case .failure(let error):
                        self.error = error
                    }
                }
                
            case .failure(let error):
                self?.error = error
            }
        }
    }
}
