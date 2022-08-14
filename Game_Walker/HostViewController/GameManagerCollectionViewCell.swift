//
//  GameManagerCollectionViewCell.swift
//  Game_Walker
//
//  Created by Jin Kim on 7/14/22.
//

import UIKit

class GameManagerCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var teamLabel: UILabel!
    @IBOutlet weak var hostLabel: UILabel!
    
    func configure(imageName: String, teamName: String, hostName: String) {
        imageView.image = UIImage(named: imageName)
        teamLabel.text = teamName
        hostLabel.text = hostName
    }
}
