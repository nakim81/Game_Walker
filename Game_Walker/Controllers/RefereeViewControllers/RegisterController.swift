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
        var teamOrder : [Team] = [Team(gamecode: "333333", name: "Simon Dominic1", number: 10, players: [], points: 0, currentStation: "testing", nextStation: "", iconName: "iconAir"), Team(gamecode: "333333", name: "Simon Dominic2", number: 11, players: [], points: 0, currentStation: "testing", nextStation: "", iconName: "iconBear"), Team(gamecode: "333333", name: "Simon Dominic3", number: 12, players: [], points: 0, currentStation: "testing", nextStation: "", iconName: "iconBlue"), Team(gamecode: "333333", name: "Simon Dominic4", number: 13, players: [], points: 0, currentStation: "testing", nextStation: "", iconName: "iconBoy"), Team(gamecode: "333333", name: "Simon Dominic5", number: 14, players: [], points: 0, currentStation: "testing", nextStation: "", iconName: "iconPenguin")]
        var test = Station(name: "testing", pvp: false, points: 0, place: "", referee: Referee(uuid: refereeUserID, gamecode: "333333", name: "Referee 1", stationName: "", assigned: false), description: "I am testing now.", teamOrder: teamOrder)
        Task { @MainActor in
            try await S.addStation("333333", test)
        }
        
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
