//
//  CharacterInfoCell.swift
//  RickMortyClient
//
//  Created by Vladimir Gonta on 22.03.2023.
//

import UIKit

class CharacterInfoCell: UITableViewCell {
    
    @IBOutlet var pictureView: UIImageView!
    // Last known location
    @IBOutlet var locationLabel: UILabel!
    // First seen in
    @IBOutlet var episodeLabel: UILabel!
    // Status
    @IBOutlet var statusLabel: UILabel!
    
    var item: (Character, Episode?)! {
        didSet {
            guard let (character, episode) = item else { return }
            
            locationLabel.text = character.location.name
            
            episodeLabel.text = episode?.name ?? "Loading..."
            
            statusLabel.text = (character.status == "Alive" ? "🟢" : "🔴") + character.status
            
            pictureView.kf.setImage(with: character.image)
        }
    }
}
