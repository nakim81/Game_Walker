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
        self.hideKeyboardWhenTappedAround()
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
                R.addReferee(storedGameCode, newReferee, refereeUserID)
                performSegue(withIdentifier: "goToWait", sender: self)
            }
            // Joining the game for the first time.
            else if storedGameCode.isEmpty && storedRefereeName.isEmpty {
                if !gamecode.isEmpty && !name.isEmpty {
                    let newReferee = Referee(uuid: refereeUserID, gamecode: gamecode, name: name, stationName: "", assigned: false)
                    UserData.writeGamecode(gamecode, "refereeGamecode")
                    UserData.writeReferee(newReferee, "Referee")
                    UserData.writeUsername(newReferee.name, "refereeName")
                    R.addReferee(gamecode, newReferee, refereeUserID)
                    performSegue(withIdentifier: "goToWait", sender: self)
                } else {
                    alert(title: "", message: "Please enter both game code and username.")
                }
            }
            // Leaving the game and entering a new game.
            else if (gamecode != storedGameCode) && (name.isEmpty || name == storedRefereeName){
                let oldReferee = UserData.readReferee("Referee")!
                let newReferee = Referee(uuid: refereeUserID, gamecode: gamecode, name: storedRefereeName, stationName: "", assigned: false)
                firstly { () -> Promise<Void> in
                    return Promise<Void> { seal in
                        self.removeReferee(gamecode: storedGameCode, uuid: refereeUserID) {
                            seal.fulfill(())
                        }
                    }
                }
                .then {
                    return Promise<Void> { seal in
                        UserData.writeReferee(newReferee, "Referee")
                        self.addReferee(gamecode: gamecode, referee: newReferee, uuid: self.refereeUserID) {
                            seal.fulfill(())
                        }
                    }
                }
                .done {
                    self.performSegue(withIdentifier: "goToWait", sender: self)
                }
                .catch { error in
                    self.alert(title: "", message: "Error occurred while communicating with the server. Try again few seconds later!")
                }
            }
            // Joining the game again with a new name.
            else if (gamecode.isEmpty || gamecode == storedGameCode) && (name != storedRefereeName) {
                let oldReferee = UserData.readReferee("Referee")!
                let newReferee = Referee(uuid: refereeUserID, gamecode: gamecode, name: name, stationName: oldReferee.stationName, assigned: oldReferee.assigned)
                firstly { () -> Promise<Void> in
                    return Promise<Void> { seal in
                        UserData.writeReferee(newReferee, "Referee")
                        self.modifiyRefereeName(gamecode: gamecode, uuid: refereeUserID, name: name){
                            seal.fulfill(())
                        }
                    }
                }
                .done {
                    self.performSegue(withIdentifier: "goToWait", sender: self)
                }
                .catch { error in
                    self.alert(title: "", message: "Error occurred while communicating with the server. Try again few seconds later!")
                }
            }
            //Joining a completely new game with a different name on the same machine.
            else {
                let oldReferee = UserData.readReferee("Referee")!
                let newReferee = Referee(gamecode: gamecode, name: name, stationName: "", assigned: false)
                firstly { () -> Promise<Void> in
                    return Promise<Void> { seal in
                        self.removeReferee(gamecode: storedGameCode, uuid: refereeUserID) {
                            seal.fulfill(())
                        }
                    }
                }
                .then {
                    return Promise<Void> { seal in
                        UserData.writeReferee(newReferee, "Referee")
                        UserData.writeUsername(name, "refereeName")
                        self.addReferee(gamecode: gamecode, referee: newReferee, uuid: self.refereeUserID){
                            seal.fulfill(())
                        }
                    }
                }
                .done {
                    self.performSegue(withIdentifier: "goToWait", sender: self)
                }
                .catch { error in
                    self.alert(title: "", message: "Error occurred while communicating with the server. Try again few seconds later!")
                }
            }
        }
    }
}
// MARK: - Promise
extension RegisterController {
    func modifiyRefereeName(gamecode: String, uuid: String, name: String, completion: @escaping () -> Void) {
        R.modifyName(gamecode, uuid, name)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            completion()
        }
    }
    func removeReferee(gamecode: String, uuid: String, completion: @escaping () -> Void) {
        R.removeReferee(gamecode, uuid)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            completion()
        }
    }
    func addReferee(gamecode: String, referee: Referee, uuid: String, completion: @escaping () -> Void) {
        R.addReferee(gamecode, referee, uuid)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            completion()
        }
    }
    func loadStation(gamecode: String, stationName: String, completion: @escaping () -> Void) {
        S.getStation(gamecode, stationName)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            completion()
        }
    }
    func removeStation(gamecode: String, station: Station, completion: @escaping () -> Void) {
        S.removeStation(gamecode, station)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            completion()
        }
    }
    func addStation(gamecode: String, station: Station, completion: @escaping () -> Void) {
        S.addStation(gamecode, station)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            completion()
        }
    }
}
// MARK: - Protocol
extension RegisterController {
    func getStation(_ station: Station) {
        storedStation = station
    }
}
