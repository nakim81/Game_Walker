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
    private var selectedCellBoxImage = UIImage(named: "cellselected 1" )
    private var originalCellBoxImage = UIImage(named: "celloriginal")
    private var emptyCellBoxImage = UIImage(named: "emptycell")
    private var redWarningBoxImage = UIImage(named: "red-warning")
    private var purpleWarningBoxImage = UIImage(named: "purple-warning")
    private var blueWarningBoxImage = UIImage(named: "blue-warning")
    private var visible : Bool = true
    
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
        algorithmCellBox.image = selectedCellBoxImage
        teamnumLabel.textColor = UIColor(red: 138/255, green: 138/255, blue: 138/255, alpha: 1.0)

    }
    
    func makeCellOriginal() {
        teamnumLabel.textColor = UIColor.black
        algorithmCellBox.image = originalCellBoxImage
        isUserInteractionEnabled = true
    }
    
    func makeCellInvisible() {
        algorithmCellBox.image = emptyCellBoxImage
        visible = false
        isUserInteractionEnabled = false
        teamnumLabel.text = ""
    }
    
    func makeCellEmpty() {
        teamnumLabel.text = ""
    }
    
    func makeRedWarning() {
        //same team in same column
        algorithmCellBox.image = redWarningBoxImage
        teamnumLabel.textColor = UIColor.white
    }
    
    func makeBlueWarning() {
        //same team in same row
        algorithmCellBox.image = blueWarningBoxImage
        teamnumLabel.textColor = UIColor.white
    }
}
