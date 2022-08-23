//
//  RefereeFrame1.swift
//  Game_Walker
//
//  Created by Paul on 6/7/22.
//

import Foundation
import UIKit

class RegisterController: BaseViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var gamecodeTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    var pvp : Bool = true
    var station_name = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       
        
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        if let gamecode = gamecodeTextField.text, let name = usernameTextField.text {
            let newReferee = Referee(gamecode: gamecode, name: name, stationName: "", assigned: false)
            R.addReferee(gamecode, newReferee)
        }
        if pvp {
            performSegue(withIdentifier: "goToPVP", sender: self)
        }
        else {
            performSegue(withIdentifier: "goToPVE", sender: self)
        }
    }
}

//MARK: - UIUpdate
extension RegisterController: GetReferee {
    func getReferee(_ referee: Referee) {
        station_name = referee.stationName
    }
}
//MARK: - UIUpdate
extension RegisterController: GetStation {
    func getStation(_ station: Station) {
        if station_name == station.name {
            pvp = station.pvp
        }
    }
}
