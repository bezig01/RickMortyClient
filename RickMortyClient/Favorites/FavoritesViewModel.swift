//
//  FavoritesViewModel.swift
//  RickMortyClient
//
//  Created by Vladimir Gonta on 24.03.2023.
//

import Foundation
import RxRelay
import UIKit.UIApplication

class FavoritesViewModel {
    
    let itemsRelay = BehaviorRelay<[Favorite]>(value: [])
    
    init() {
        
        fetchFavorites()
    }
    
    private func fetchFavorites() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let favorites = appDelegate.fetchFavorites()
        
        itemsRelay.accept(favorites)
    }
}
