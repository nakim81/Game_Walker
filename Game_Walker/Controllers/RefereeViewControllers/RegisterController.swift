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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        if let gamecode = gamecodeTextField.text, let name = usernameTextField.text {
            let newReferee = Referee(gamecode: gamecode, name: name, stationName: "", assigned: false)
            R.addReferee(gamecode, newReferee)
            UserData.writeReferee(newReferee, "Referee")
        }
        performSegue(withIdentifier: "goToWait", sender: self)
    }
}


