//
//  RefereeFrame1.swift
//  Game_Walker
//
//  Created by Paul on 6/7/22.
//

import Foundation
import UIKit
import PromiseKit

class RegisterController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var gamecodeTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    private var storedGameCode = UserData.readGamecode("refereeGamecode") ?? ""
    private var storedRefereeName = UserData.readUsername("refereeName") ?? ""
    private var refereeUserID = UserData.readUUID()!
    private var storedStation: Station?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gamecodeTextField.keyboardType = .asciiCapableNumberPad
        gamecodeTextField.delegate = self
        gamecodeTextField.placeholder = storedGameCode != "" ? storedGameCode : "game code #"
        usernameTextField.placeholder = storedRefereeName != "" ? storedRefereeName : "game id text"
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == gamecodeTextField {
            usernameTextField.becomeFirstResponder()
        }
        else if textField == usernameTextField {
            nextButtonPressed(nextButton)
        }
        return true
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        if let gamecode = gamecodeTextField.text, let name = usernameTextField.text {
            // Rejoining the game.
            if (gamecode.isEmpty || gamecode == storedGameCode) && (name.isEmpty || name == storedRefereeName) {
                let newReferee = Referee(uuid: refereeUserID, gamecode: storedGameCode, name: storedRefereeName, stationName: "", assigned: false)
                UserData.writeGamecode(storedGameCode, "refereeGamecode")
                UserData.writeReferee(newReferee, "Referee")
                UserData.writeUsername(newReferee.name, "refereeName")
                Task { @MainActor in
                    try await R.addReferee(storedGameCode, newReferee, refereeUserID)
                }
                performSegue(withIdentifier: "goToWait", sender: self)
            }
            // Joining the game for the first time.
            else if storedGameCode.isEmpty && storedRefereeName.isEmpty {
                if !gamecode.isEmpty && !name.isEmpty {
                    let newReferee = Referee(uuid: refereeUserID, gamecode: gamecode, name: name, stationName: "", assigned: false)
                    UserData.writeGamecode(gamecode, "refereeGamecode")
                    UserData.writeReferee(newReferee, "Referee")
                    UserData.writeUsername(newReferee.name, "refereeName")
                    Task { @MainActor in
                        try await R.addReferee(gamecode, newReferee, refereeUserID)
                    }
                    performSegue(withIdentifier: "goToWait", sender: self)
                } else {
                    alert(title: "", message: "Please enter both game code and username.")
                }
            }
            // Leaving the game and entering a new game.
            else if (gamecode != storedGameCode) && (name.isEmpty || name == storedRefereeName){
                let oldReferee = UserData.readReferee("Referee")!
                let newReferee = Referee(uuid: refereeUserID, gamecode: gamecode, name: storedRefereeName, stationName: "", assigned: false)
                Task { @MainActor in
                    R.removeReferee(storedGameCode, refereeUserID)
                    try await R.addReferee(gamecode, newReferee, refereeUserID)
                }
                performSegue(withIdentifier: "goToWait", sender: self)
            }
            // Joining the game again with a new name.
            else if (gamecode.isEmpty || gamecode == storedGameCode) && (name != storedRefereeName) {
                let oldReferee = UserData.readReferee("Referee")!
                let newReferee = Referee(uuid: refereeUserID, gamecode: gamecode, name: name, stationName: oldReferee.stationName, assigned: oldReferee.assigned)
                UserData.writeReferee(newReferee, "Referee")
                Task { @MainActor in
                    try await R.modifyName(gamecode, refereeUserID, name)
                }
                performSegue(withIdentifier: "goToWait", sender: self)
            }
            //Joining a completely new game with a different name on the same machine.
            else {
                let oldReferee = UserData.readReferee("Referee")!
                let newReferee = Referee(gamecode: gamecode, name: name, stationName: "", assigned: false)
                UserData.writeReferee(newReferee, "Referee")
                UserData.writeUsername(name, "refereeName")
                Task { @MainActor in
                    R.removeReferee(storedGameCode, refereeUserID)
                    try await R.addReferee(gamecode, newReferee, refereeUserID)
                }
                performSegue(withIdentifier: "goToWait", sender: self)
            }
        }
    }
}
