//
//  StationTableViewCell.swift
//  Game_Walker
//
//  Created by Jin Kim on 7/14/22.
//

import UIKit

class StationTableViewCell: UITableViewCell {

    @IBOutlet weak var stationLabel: UILabel!
    
    func configure(stationName: String) {
        stationLabel.text = stationName
    }
    
}
