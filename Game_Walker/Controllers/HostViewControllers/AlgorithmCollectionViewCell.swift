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
    private var blueWarningBoxImage = UIImage(named: "blue-warning 1")
    private var yellowWarningBoxImage = UIImage(named: "yellow-warning 1")
    private var orangeWarningBoxImage = UIImage(named: "orange-warning")
    var visible : Bool = true
    var warningColor : String = ""
    var hasWarning : Bool = false
    var hasPvpWarning : Bool = false
    var number : Int?

    var affiliatedIndexPaths = Set<IndexPath>()
    
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
        number = cellteamnum
    }
    
    
    func changeRed() {
        teamnumLabel.textColor = UIColor.red
        warningColor = "red"
        hasWarning = true
    }
    
    func makeCellSelected() {
        algorithmCellBox.image = selectedCellBoxImage
        teamnumLabel.textColor = UIColor(red: 138/255, green: 138/255, blue: 138/255, alpha: 1.0)

    }
    
    func makeCellImageOriginal() {
        algorithmCellBox.image = originalCellBoxImage
    }
    
    func makeCellOriginal() {
        teamnumLabel.textColor = UIColor.black
        algorithmCellBox.image = originalCellBoxImage
        isUserInteractionEnabled = true
        hasWarning = false
        hasPvpWarning = false
        warningColor = ""
        affiliatedIndexPaths.removeAll()
    }
    
    func makeCellInvisible() {
        algorithmCellBox.image = emptyCellBoxImage
        visible = false
        isUserInteractionEnabled = false
        teamnumLabel.text = ""
        warningColor = ""
        hasWarning = false
        hasPvpWarning = false
    }
    
    func makeCellEmpty() {
        teamnumLabel.text = ""
        warningColor = ""
        hasWarning = false
        algorithmCellBox.image = originalCellBoxImage
        hasPvpWarning = false
    }
    
    func makeRedWarning() {
        //same team in same column
        algorithmCellBox.image = redWarningBoxImage
        teamnumLabel.textColor = UIColor.white
        hasWarning = true
        warningColor = "red"
    }
    
    func makeBlueWarning() {
        //same team in same row
        algorithmCellBox.image = blueWarningBoxImage
        teamnumLabel.textColor = UIColor.white
        hasWarning = true
        warningColor = "blue"
    }
    
    func makeOrangeWarning() {
        algorithmCellBox.image = orangeWarningBoxImage
        teamnumLabel.textColor = UIColor.white
        hasWarning = true
        warningColor = "orange"
    }
    
    func makeYellowWarning() {
        algorithmCellBox.image = yellowWarningBoxImage
        teamnumLabel.textColor = UIColor.white
        hasWarning = false
        hasPvpWarning = true
        warningColor = "yellow"
    }
    
    func makePurpleWarning() {
        algorithmCellBox.image = purpleWarningBoxImage
        teamnumLabel.textColor = UIColor.white
        hasWarning = true
        warningColor = "purple"
    }
    
    func addIndexPathsToCell(_ indexPathSet: Set<IndexPath>) {
        if !affiliatedIndexPaths.isEmpty {
            affiliatedIndexPaths.formUnion(indexPathSet)
        } else {
            affiliatedIndexPaths = indexPathSet
        }
    }
}
