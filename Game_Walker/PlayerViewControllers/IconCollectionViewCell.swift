//
//  IconCollectionViewCell.swift
//  Game_Walker
//
//  Created by Noah Kim on 6/17/22.
//

import UIKit

class IconCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    var imageName: String?
    
    static let identifier = "IconCollectionViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setImage(with name: String) {
        imageView.image = UIImage(named: name)
        imageName = name
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "IconCollectionViewCell", bundle: nil)
    }

}
