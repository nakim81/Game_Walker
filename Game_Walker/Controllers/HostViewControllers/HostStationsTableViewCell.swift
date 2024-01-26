//
//  HostStationsTableViewCell.swift
//  Game_Walker
//
//  Created by Jin Kim on 8/18/22.
//

import UIKit

class HostStationsTableViewCell: UITableViewCell {

    @IBOutlet weak var cellentireview: UIView!
    @IBOutlet weak var stationLabel: UILabel!

    func configureStationCell(stationName: String) {
        stationLabel.text = stationName
//        if let originalFont = stationLabel.font {
//            stationLabel.font = getFontForLanguage(font: originalFont.fontName, size: originalFont.pointSize)
//        }
        stationLabel.font = getFontForLanguage(font: stationLabel.font.fontName, size: stationLabel.font.pointSize)
        
        cellentireview.heightAnchor.constraint(equalTo: cellentireview.widthAnchor, multiplier: 0.23).isActive = true
        
    }
    
    
}
