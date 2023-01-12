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
    private var teamList: [Team] = []
    
    override func viewDidLoad() {
        T.delegate_teamList = self
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        gamecodeTextField.delegate = self
        usernameTextField.delegate = self
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        gamecodeTextField.resignFirstResponder()
        usernameTextField.resignFirstResponder()
        if let gamecode: String = gamecodeTextField.text, let username: String = usernameTextField.text, !gamecode.isEmpty, !username.isEmpty {
            let newPlayer = Player(gamecode: gamecode, name: username)
            UserData.writePlayer(newPlayer, "player")
            
            UserDefaults.standard.set(gamecode, forKey: "gamecode")
            P.addPlayer(gamecode, newPlayer)
            

            performSegue(withIdentifier: "goToPF2VC", sender: self)
        } else {
            alert(title: "Woops", message: "Please enter all information to log in")
        }        
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
//MARK: - TeamProtocols
extension JoinGameViewController: TeamList {
    func listOfTeams(_ teams: [Team]) {
        self.teamList = teams
    }
}

