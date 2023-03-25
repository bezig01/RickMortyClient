//
//  FavoriteCell.swift
//  RickMortyClient
//
//  Created by Vladimir Gonta on 25.03.2023.
//

import UIKit
import Kingfisher

class FavoriteCell: UICollectionViewCell {
    
    var item: Favorite! {
        didSet {
            guard let item,
                  let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            
            nameLabel.text = item.characterName
            
            episodeLabel.text = item.episodeName
            
            pictureView.kf.setImage(with: appDelegate.fileURL(Int(item.characterID)))
        }
    }
    
    @IBOutlet var containerView: UIView!
    
    @IBOutlet var pictureView: UIImageView!
    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var episodeLabel: UILabel!
    
    private lazy var shadowLayer: CAShapeLayer! = {
        let shadowLayer = CAShapeLayer()
        shadowLayer.fillColor = UIColor.white.cgColor
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = .zero
        shadowLayer.shadowOpacity = 1
        shadowLayer.shadowRadius = 2
        layer.insertSublayer(shadowLayer, at: 0)
        return shadowLayer
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        shadowLayer.path = UIBezierPath(roundedRect: containerView.frame, cornerRadius: 10).cgPath
    }
}

extension UICollectionViewCell {
    class var id: String {
        String(describing: Self.self)
    }
}
