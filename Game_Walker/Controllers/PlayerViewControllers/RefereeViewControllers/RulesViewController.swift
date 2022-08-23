//
//  RefereeFrame3_3.swift
//  Game_Walker
//
//  Created by 김현식 on 7/10/22.
//

import Foundation
import UIKit

class RulesViewController: UIViewController {
    
    @IBOutlet weak var gamenameLabel: UITextField!
    @IBOutlet weak var gamepointsLabel: UITextField!
    @IBOutlet weak var gamelocationLabel: UITextField!
    @IBOutlet weak var rulesLabel: UITextField!
    var stationName = ""
    var points = 0
    var place = ""
    var explanation = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        gamenameLabel.text = stationName
        gamepointsLabel.text = String(points)
        gamelocationLabel.text = place
        rulesLabel.text = explanation
        // Do any additional setup after loading the view.
        
    }
}

//MARK: - UIUpdate
extension RulesViewController: GetStation {
    func getStation(_ station: Station) {
        stationName = station.name
        points = station.points
        place = station.place
        explanation = station.description
    }
}
