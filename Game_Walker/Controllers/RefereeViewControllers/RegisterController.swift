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
    private var storedGameCode = UserData.readGamecode("refereeGameCode") ?? ""
    private var storedRefereeName = UserData.readUsername("refereeName") ?? ""
    private var refereeUserID = UserData.readUUID()!
    private var storedStation: Station?
    private var pvp : Bool = false
    
    override func viewDidLoad() {
        callProtocols()
        super.viewDidLoad()
        gamecodeTextField.keyboardType = .asciiCapableNumberPad
        gamecodeTextField.delegate = self
        gamecodeTextField.placeholder = storedGameCode != "" ? storedGameCode : "game code #"
        usernameTextField.placeholder = storedRefereeName != "" ? storedRefereeName : "game id text"
        configureNavItem()
    }
    
    private func configureNavItem() {
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(image: UIImage(named: "back button 1"), style: .plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    @objc func back(sender: UIBarButtonItem) {
        performSegue(withIdentifier: "ToMainVC", sender: self)
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
        if let gameCode = gamecodeTextField.text, let name = usernameTextField.text {
            //Joining the game for the first time
            if storedGameCode.isEmpty && storedRefereeName.isEmpty {
                if !gameCode.isEmpty && !name.isEmpty {
                    let newReferee = Referee(uuid: refereeUserID, gamecode: gameCode, name: name, stationName: "", assigned: false)
                    Task {
                        do {
                            try await R.addReferee(gameCode, newReferee, refereeUserID)
                        } catch GamecodeError.invalidGamecode {
                            alert(title: "", message: "Invalid GameCode")
                            return
                        }
                        UserData.writeGamecode(gameCode, "refereeGameCode")
                        UserData.writeUsername(newReferee.name, "refereeName")
                        UserData.writeReferee(newReferee, "Referee")
                        performSegue(withIdentifier: "goToWait", sender: self)
                    }
                } else {
                    alert(title: "", message: "Please enter both game code and username.")
                }
            }
            // Rejoining the game.
            else if (gameCode.isEmpty || gameCode == storedGameCode) && (name.isEmpty || name == storedRefereeName) {
//                let oldReferee = UserData.readReferee("Referee")!
//                S.getStationList(gameCode)
//                Task.sleep(nanoseconds: 280_000_000)
//                if oldReferee.assigned {
//                    if self.pvp {
//                        performSegue(withIdentifier: "toPVP", sender: self)
//                    } else {
//                        performSegue(withIdentifier: "toPVE", sender: self)
//                    }
//                } else {
//                    performSegue(withIdentifier: "goToWait", sender: self)
//                }
            }
            // Leaving the game and entering a new game with the same name.
            else if (gameCode != storedGameCode) && (name.isEmpty || name == storedRefereeName) {
                let oldReferee = UserData.readReferee("Referee")!
                let newReferee = Referee(uuid: refereeUserID, gamecode: gameCode, name: name, stationName: oldReferee.stationName, assigned: oldReferee.assigned)
                Task { @MainActor in
                    do {
                        try await R.addReferee(gameCode, newReferee, refereeUserID)
                    } catch GamecodeError.invalidGamecode {
                        alert(title: "", message: "Invalid GameCode")
                        return
                    }
                }
                UserData.writeGamecode(gameCode, "refereeGameCode")
                UserData.writeUsername(newReferee.name, "refereeName")
                UserData.writeReferee(newReferee, "Referee")
                performSegue(withIdentifier: "goToWait", sender: self)
            }
            // Joining the game again with a new name.
            else if (gameCode.isEmpty || gameCode == storedGameCode) && (name != storedRefereeName) {
                let oldReferee = UserData.readReferee("Referee")!
                let newReferee = Referee(uuid: refereeUserID, gamecode: gameCode, name: name, stationName: oldReferee.stationName, assigned: oldReferee.assigned)
                Task { @MainActor in
                    do {
                        try await R.modifyName(gameCode, refereeUserID, name)
                    } catch GamecodeError.invalidGamecode {
                        alert(title: "", message: "Invalid GameCode")
                        return
                    }
                }
                UserData.writeGamecode(gameCode, "refereeGameCode")
                UserData.writeUsername(newReferee.name, "refereeName")
                UserData.writeReferee(newReferee, "Referee")
                S.getStationList(gameCode)
//                Task.sleep(nanoseconds: 280_000_000)
                if oldReferee.assigned {
                    if self.pvp {
                        performSegue(withIdentifier: "toPVP", sender: self)
                    } else {
                        performSegue(withIdentifier: "toPVE", sender: self)
                    }
                } else {
                    performSegue(withIdentifier: "goToWait", sender: self)
                }
            }
            //Joining a completely new game with a different name on the same machine.
            else {
                let newReferee = Referee(gamecode: gameCode, name: name, stationName: "", assigned: false)
                Task { @MainActor in
                    do {
                        try await R.addReferee(gameCode, newReferee, refereeUserID)
                    } catch GamecodeError.invalidGamecode {
                        alert(title: "", message: "Invalid GameCode")
                        return
                    }
                }
                performSegue(withIdentifier: "goToWait", sender: self)
            }
        }
    }
}
// MARK: - Protocols
extension RegisterController: StationList {
    func listOfStations(_ stations: [Station]) {
        for station in stations {
            if station.name == UserData.readReferee("Referee")!.stationName {
                self.pvp = station.pvp
            }
        }
    }
    
    func callProtocols() {
        S.delegate_stationList = self
    }
}

