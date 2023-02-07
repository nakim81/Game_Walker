//
//  AlgorithmCollectionViewCell.swift
//  Game_Walker
//
//  Created by Jin Kim on 1/11/23.
//

import UIKit

class AlgorithmCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var algorithmCellBox: UIImageView!
    @IBOutlet weak var teamnumLabel: UILabel!
    
    static let identifier = "AlgorithmCollectionViewCell"
    
    func configureAlgorithmCell(cellteamnum:Int) {
        teamnumLabel.text = String(cellteamnum)
    }
}
