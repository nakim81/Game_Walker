//
//  AlgCollectionViewCell.swift
//  Game_Walker
//
//  Created by Jin Kim on 9/22/23.
//

import UIKit

class AlgCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var cellImageView: UIImageView!
    
    private var selectedCellBoxImage = UIImage(named: "cellselected 1" )
    private var originalCellBoxImage = UIImage(named: "celloriginal")
    private var emptyCellBoxImage = UIImage(named: "emptycell")
    private var redWarningBoxImage = UIImage(named: "red-warning")
    private var purpleWarningBoxImage = UIImage(named: "purple-warning")
    private var blueWarningBoxImage = UIImage(named: "blue-warning 1")
    private var yellowWarningBoxImage = UIImage(named: "yellow-warning")
    private var orangeWarningBoxImage = UIImage(named: "orange-warning")
    var visible : Bool = true
    var warningColor : String = ""
    var hasWarning : Bool = false
    var hasPvpYellowWarning : Bool = false
    var hasPvpBlueWarning : Bool = false
    var hasYellowWarning : Bool = false
    var hasPurpleWarning : Bool = false
    var number : Int?

    var yellowPvpIndexPaths = Set<IndexPath>()
    var bluePvpIndexPaths = Set<IndexPath>()
    
    static let identifier = "AlgCollectionViewCell"
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        numberLabel.adjustsFontSizeToFitWidth = true
    }
    
    func configureTestCell1() {
//        self.contentView.backgroundColor = UIColor.purple
    }
    func configureTestCell2() {
//        self.contentView.backgroundColor = UIColor.orange
    }
    
    
    func configureAlgorithmNormalCell(cellteamnum : Int) {
        
        numberLabel.text = String(cellteamnum)
        number = cellteamnum
        cellImageView.image = originalCellBoxImage
        numberLabel.textColor = UIColor.black
        isUserInteractionEnabled = true
        yellowPvpIndexPaths.removeAll()
        bluePvpIndexPaths.removeAll()
    }
    
    
    
    func changeRed() {
        numberLabel.textColor = UIColor.red
        warningColor = "red"
        hasWarning = true
    }
    
    func makeCellSelected() {
        cellImageView.image = selectedCellBoxImage
        numberLabel.textColor = UIColor(red: 138/255, green: 138/255, blue: 138/255, alpha: 1.0)

    }
    
    func makeCellImageOriginal() {
        cellImageView.image = originalCellBoxImage
    }
    
    func makeCellOriginal() {
        numberLabel.textColor = UIColor.black
        cellImageView.image = originalCellBoxImage
        isUserInteractionEnabled = true
        hasWarning = false
        hasPvpYellowWarning = false
        hasPvpBlueWarning = false
        warningColor = ""
        yellowPvpIndexPaths.removeAll()
        bluePvpIndexPaths.removeAll()
    }
    
    func makeCellInvisible() {
        cellImageView.image = emptyCellBoxImage
        visible = false
        isUserInteractionEnabled = false
        numberLabel.text = ""
        warningColor = ""
        hasWarning = false
        hasPvpYellowWarning = false
        hasPvpBlueWarning = false
    }
    
    func makeCellEmpty() {
        numberLabel.text = ""
        warningColor = ""
        hasWarning = false
        cellImageView.image = originalCellBoxImage
        hasPvpYellowWarning = false
        hasPvpBlueWarning = false
    }
    
    func makeRedWarning() {
        //same team in same column
        cellImageView.image = redWarningBoxImage
        numberLabel.textColor = UIColor.white
        hasWarning = true
        warningColor = "red"
    }
    
    func makeBlueWarning() {
        //same team in same row
        cellImageView.image = blueWarningBoxImage
        numberLabel.textColor = UIColor.white
        hasWarning = true
        hasPvpBlueWarning = true
        warningColor = "blue"
    }
    
    func makeYellowWarning() {
        cellImageView.image = yellowWarningBoxImage
        numberLabel.textColor = UIColor.white
        hasWarning = false
        warningColor = "yellow"
    }
    
    func makePurpleWarning() {
        cellImageView.image = purpleWarningBoxImage
        numberLabel.textColor = UIColor.white
        hasWarning = true
        warningColor = "purple"
    }
    

}
