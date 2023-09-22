//
//  ManualAlgorithmCollectionViewCell.swift
//  Game_Walker
//
//  Created by Jin Kim on 9/21/23.
//
//
//import UIKit
//
//class ManualAlgorithmCollectionViewCell: UICollectionViewCell {
//    static let identifier = "ManualAlgorithmCollectionViewCell"
//    
//    private var selectedCellBoxImage = UIImage(named: "cellselected 1" )
//    private var originalCellBoxImage = UIImage(named: "celloriginal")
//    private var emptyCellBoxImage = UIImage(named: "emptycell")
//    private var redWarningBoxImage = UIImage(named: "red-warning")
//    private var purpleWarningBoxImage = UIImage(named: "purple-warning")
//    private var blueWarningBoxImage = UIImage(named: "blue-warning 1")
//    private var yellowWarningBoxImage = UIImage(named: "yellow-warning")
//    private var orangeWarningBoxImage = UIImage(named: "orange-warning")
//    var visible : Bool = true
//    var warningColor : String = ""
//    var hasWarning : Bool = false
//    var hasPvpYellowWarning : Bool = false
//    var hasPvpBlueWarning : Bool = false
//    var hasYellowWarning : Bool = false
//    var hasPurpleWarning : Bool = false
//    var number : Int?
//
//    var yellowPvpIndexPaths = Set<IndexPath>()
//    var bluePvpIndexPaths = Set<IndexPath>()
//    
//
//    let cellImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .center
//        imageView.clipsToBounds = true
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        return imageView
//    }()
//    
//    let labelView: UILabel = {
//        let label = UILabel()
//        label.textAlignment = .center
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.adjustsFontSizeToFitWidth = true
//        return label
//    }()
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        configureSubviews()
//    }
//    
//    private func configureSubviews() {
//        print("configuring subviews")
//        contentView.addSubview(cellImageView)
//        contentView.addSubview(labelView)
//
//        NSLayoutConstraint.activate([
//            cellImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
//            cellImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            cellImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            cellImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//        ])
//        
//
//        NSLayoutConstraint.activate([
//            labelView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            labelView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            labelView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.4),
//        ])
//    }
//    
//
////cell configuration
//    func configureAlgorithmNormalCell(cellteamnum : Int) {
//        
//        labelView.text = String(cellteamnum)
//        number = cellteamnum
//        cellImageView.image = originalCellBoxImage
//        labelView.textColor = UIColor.black
//        isUserInteractionEnabled = true
//        yellowPvpIndexPaths.removeAll()
//        bluePvpIndexPaths.removeAll()
//    }
//    
//    
//    
//    func changeRed() {
//        labelView.textColor = UIColor.red
//        warningColor = "red"
//        hasWarning = true
//    }
//    
//    func makeCellSelected() {
//        cellImageView.image = selectedCellBoxImage
//        labelView.textColor = UIColor(red: 138/255, green: 138/255, blue: 138/255, alpha: 1.0)
//
//    }
//    
//    func makeCellImageOriginal() {
//        cellImageView.image = originalCellBoxImage
//    }
//    
//    func makeCellOriginal() {
//        labelView.textColor = UIColor.black
//        cellImageView.image = originalCellBoxImage
//        isUserInteractionEnabled = true
//        hasWarning = false
//        hasPvpYellowWarning = false
//        hasPvpBlueWarning = false
//        warningColor = ""
//        yellowPvpIndexPaths.removeAll()
//        bluePvpIndexPaths.removeAll()
//    }
//    
//    func makeCellInvisible() {
//        cellImageView.image = emptyCellBoxImage
//        visible = false
//        isUserInteractionEnabled = false
//        labelView.text = ""
//        warningColor = ""
//        hasWarning = false
//        hasPvpYellowWarning = false
//        hasPvpBlueWarning = false
//    }
//    
//    func makeCellEmpty() {
//        labelView.text = ""
//        warningColor = ""
//        hasWarning = false
//        cellImageView.image = originalCellBoxImage
//        hasPvpYellowWarning = false
//        hasPvpBlueWarning = false
//    }
//    
//    func makeRedWarning() {
//        //same team in same column
//        cellImageView.image = redWarningBoxImage
//        labelView.textColor = UIColor.white
//        hasWarning = true
//        warningColor = "red"
//    }
//    
//    func makeBlueWarning() {
//        //same team in same row
//        cellImageView.image = blueWarningBoxImage
//        labelView.textColor = UIColor.white
//        hasWarning = true
//        hasPvpBlueWarning = true
//        warningColor = "blue"
//    }
//    
//    func makeYellowWarning() {
//        cellImageView.image = yellowWarningBoxImage
//        labelView.textColor = UIColor.white
//        hasWarning = false
//        warningColor = "yellow"
//    }
//    
//    func makePurpleWarning() {
//        cellImageView.image = purpleWarningBoxImage
//        labelView.textColor = UIColor.white
//        hasWarning = true
//        warningColor = "purple"
//    }
//    
//    
//
//}
