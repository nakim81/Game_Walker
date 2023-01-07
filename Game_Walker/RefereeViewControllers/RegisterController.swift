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
    var assigned : Bool = false
    var station_name = ""
    var gamecode_save = ""
    var referee_name = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       
        
    }
    
    func listen(_ _ : [String : Any]){
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        if let gamecode = gamecodeTextField.text, let name = usernameTextField.text {
            let newReferee = Referee(gamecode: gamecode, name: name, stationName: "", assigned: false)
            R.addReferee(gamecode, newReferee)
            RefereeData.gamecode_save = gamecode
            RefereeData.referee_name = name
            RefereeData.referee = newReferee
        }
        performSegue(withIdentifier: "goToWait", sender: self)
    }
}

//MARK: - UIUpdate
extension RegisterController: GetReferee {
    func getReferee(_ referee: Referee) {
        assigned = referee.assigned
    }
}

//MARK: - UIUpdate
extension RegisterController: GetStation {
    func getStation(_ station: Station) {
        station_name = station.name
    }
}

