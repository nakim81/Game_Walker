//
//  RefereeFrame1.swift
//  Game_Walker
//
//  Created by Paul on 6/7/22.
//

import Foundation
import UIKit

class RegisterController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var gamecodeTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    private var storedGamecode = UserData.readGamecode("refereeGamecode") ?? ""
    private var storedRefereename = UserData.readUsername("refereeName") ?? ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        gamecodeTextField.keyboardType = .asciiCapableNumberPad
        gamecodeTextField.delegate = self
        gamecodeTextField.placeholder = storedGamecode != "" ? storedGamecode : "game code #"
        usernameTextField.placeholder = storedRefereename != "" ? storedRefereename : "game id text"
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == gamecodeTextField {
            usernameTextField.becomeFirstResponder() 
        }
        return true
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        if let gamecode = gamecodeTextField.text, let name = usernameTextField.text {
            if (gamecode.isEmpty || gamecode == storedGamecode) && (name.isEmpty || name == storedRefereename) {
                let newReferee = Referee(gamecode: storedGamecode, name: storedRefereename, stationName: "", assigned: false)
                R.addReferee(storedGamecode, newReferee)
                UserData.writeGamecode(storedGamecode, "refereeGamecode")
                UserData.writeReferee(newReferee, "Referee")
                UserData.writeUsername(newReferee.name, "refereeName")
                performSegue(withIdentifier: "goToWait", sender: self)
            }
            else if storedGamecode.isEmpty && storedRefereename.isEmpty {
                let newReferee = Referee(gamecode: gamecode, name: name, stationName: "", assigned: false)
                R.addReferee(gamecode, newReferee)
                UserData.writeGamecode(gamecode, "refereeGamecode")
                UserData.writeReferee(newReferee, "Referee")
                UserData.writeUsername(newReferee.name, "refereeName")
                performSegue(withIdentifier: "goToWait", sender: self)
            }
            else {
                self.alert(title: "", message: "Error occurred while communicating with the server. Try again few seconds later!")
            }
        }
    }
}

