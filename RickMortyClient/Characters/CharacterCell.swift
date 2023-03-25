//
//  CharacterCell.swift
//  RickMortyClient
//
//  Created by Vladimir Gonta on 21.03.2023.
//

import UIKit
import Kingfisher

class CharacterCell: UITableViewCell {
    
    @IBOutlet var pictureView: UIImageView!
    
    @IBOutlet var nameLabel: UILabel!
    // Last known location
    @IBOutlet var locationLabel: UILabel!
    // First seen in
    @IBOutlet var episodeLabel: UILabel!
    
    var item: (Character, Episode?)! {
        didSet {
            guard let (character, episode) = item else { return }
            
            nameLabel.text = character.name
            
            locationLabel.text = character.location.name
            
            episodeLabel.text = episode?.name ?? "Loading..."
            
            pictureView.kf.setImage(with: character.image)
        }
    }
}

extension UITableViewCell {
    class var id: String {
        String(describing: Self.self)
    }
}
