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
        cellentireview.heightAnchor.constraint(equalTo: cellentireview.widthAnchor, multiplier: 0.23).isActive = true
    }
    
    
}
