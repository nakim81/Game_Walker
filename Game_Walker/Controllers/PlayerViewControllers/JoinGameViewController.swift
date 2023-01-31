//
//  PlayerFrame1.swift
//  Game_Walker
//
//  Created by Paul on 6/7/22.
//

import Foundation
import UIKit

class JoinGameViewController: BaseViewController {
    
    @IBOutlet weak var gamecodeTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        gamecodeTextField.delegate = self
        usernameTextField.delegate = self
        H.delegates.append(self)
        T.delegates.append(self)
        gamecodeTextField.keyboardType = .asciiCapableNumberPad
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        gamecodeTextField.resignFirstResponder()
        usernameTextField.resignFirstResponder()
        if let gamecode: String = gamecodeTextField.text, let username: String = usernameTextField.text, !gamecode.isEmpty, !username.isEmpty {
            let newPlayer = Player(gamecode: gamecode, name: username)
            UserData.writePlayer(newPlayer, "player")
            UserData.writeGamecode(gamecode, "gamecode")
            P.addPlayer(gamecode, newPlayer)
            H.listenHost(gamecode, onListenerUpdate: listen(_:))
            T.listenTeams(gamecode, onListenerUpdate: listen(_:))
            performSegue(withIdentifier: "goToPF2VC", sender: self)
        } else {
            alert(title: "Woops", message: "Please enter all information to log in")
        }        
    }

    func listen(_ _ : [String : Any]){
    }
}

// MARK: - UITextFieldDelegate
extension JoinGameViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == gamecodeTextField {
            usernameTextField.becomeFirstResponder()
        } else if textField == usernameTextField {
            nextButtonPressed(nextButton)
        }
        return true
    }
}

// MARK: - listener
extension JoinGameViewController: HostUpdateListener, TeamUpdateListener {
    func updateTeams(_ teams: [Team]) {
        
    }
    
    func updateHost(_ host: Host) {
        
    }
}
