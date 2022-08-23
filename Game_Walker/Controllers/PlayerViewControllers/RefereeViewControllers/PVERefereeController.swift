//
//  RefereeFrame2_1.swift
//  Game_Walker
//
//  Created by 김현식 on 7/6/22.
//

import Foundation
import UIKit

class PVERefereeController: UIViewController {
    
    @IBOutlet weak var roundLabel: UILabel!
    @IBOutlet weak var scoreButton: UIButton!
    @IBOutlet weak var teamnameLabel: UILabel!
    @IBOutlet weak var teamscoreLabel: UILabel!
    @IBOutlet weak var ruleButton: UIButton!
    @IBOutlet weak var nextgameButton: UIButton!
    var round = 1
    var stationName = ""
    var index = 0
    var teamOrder : [Team] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roundLabel.text = "Round 1"
        scoreButton.setImage(UIImage(named: teamOrder[0].iconName), for: .normal)
        teamnameLabel.text = teamOrder[0].name
        teamscoreLabel.text = String(teamOrder[0].points)
    
    }
    
    @IBAction func scoreButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToPVEScore", sender: self)
    }
    
    @IBAction func ruleButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToPVERule", sender: self)
    }
    
    @IBAction func nextgameButtonPressed(_ sender: UIButton) {
        round += 1
        roundLabel.text = "Round " + "\(round)"
        index += 1
        scoreButton.setImage(UIImage(named: teamOrder[index].iconName), for: .normal)
        teamnameLabel.text = teamOrder[index].name
        teamscoreLabel.text = String(teamOrder[index].points)
    }
}

//MARK: - UIUpdate
extension PVERefereeController: GetStation {
    func getStation(_ station: Station) {
        stationName = station.name
        teamOrder = station.teamOrder
    }
}
