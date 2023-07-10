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
    var selectedCellBox = UIImage(named: "cellselected 1" )
    var originalCellBox = UIImage(named: "celloriginal")
    
    
    static let identifier = "AlgorithmCollectionViewCell"
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

        algorithmCellBox.contentMode = .center
        teamnumLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            teamnumLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            teamnumLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        teamnumLabel.adjustsFontSizeToFitWidth = true
    }
    
    func configureAlgorithmNormalCell(cellteamnum : Int) {
        
        teamnumLabel.text = String(cellteamnum)
    }
    
    
    func changeRed() {
        teamnumLabel.textColor = UIColor.red
    }
    
    func makeCellSelected() {
        algorithmCellBox.image = selectedCellBox
        teamnumLabel.textColor = UIColor(red: 138/255, green: 138/255, blue: 138/255, alpha: 1.0)

    }
    
    func makeCellOriginal() {
        teamnumLabel.textColor = UIColor.black
        algorithmCellBox.image = originalCellBox
    }
}
