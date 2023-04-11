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
    private var storedGameCode = UserData.readGamecode("gamecode") ?? ""
    private var storedRefereename = UserData.readUsername("refereename") ?? ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        gamecodeTextField.keyboardType = .asciiCapableNumberPad
        gamecodeTextField.delegate = self
        gamecodeTextField.placeholder = storedGameCode != "" ? storedGameCode : "gamecode"
        usernameTextField.placeholder = storedRefereename != "" ? storedRefereename : "refereename"
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == gamecodeTextField {
            usernameTextField.becomeFirstResponder() 
        }
        return true
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        if let gamecode = gamecodeTextField.text, let name = usernameTextField.text {
            let newReferee = Referee(gamecode: gamecode, name: name, stationName: "", assigned: false)
            R.addReferee(gamecode, newReferee)
            UserData.writeGamecode(gamecode, "gamecode")
            UserData.writeReferee(newReferee, "Referee")
            UserData.writeUsername(newReferee.name, "refereename")
        }
    }
}

