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
    
    private var storedGameCode = UserData.readGamecode("gamecode") ?? ""
    private var gamecode = UserData.readGamecode("gamecode") ?? ""
    private var currentPlayer = UserData.readPlayer("player") ?? nil
    private var useStoredCode = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        setUpTextFields()
        configureNavItem()
    }
    
    private func setDelegates() {
        H.delegates.append(self)
        T.delegates.append(self)
    }
    
    private func setUpTextFields() {
        gamecodeTextField.delegate = self
        usernameTextField.delegate = self
        gamecodeTextField.keyboardType = .asciiCapableNumberPad
        gamecodeTextField.placeholder = storedGameCode != "" ? storedGameCode : "gamecode"
        usernameTextField.placeholder = currentPlayer != nil ? currentPlayer?.name : "username"
        self.hideKeyboardWhenTappedAround()
    }
    
    private func configureNavItem() {
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(image: UIImage(named: "back button 1"), style: .plain, target: self, action: #selector(CreateOrJoinTeamViewController.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    @objc func back(sender: UIBarButtonItem) {
        performSegue(withIdentifier: "ToMainVC", sender: self)
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        setGameCode()
        print(storedGameCode)
//        if storedGameCode == "" || !useStoredCode {
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
//        } else {
//
//        }
    }
    
    private func setGameCode() {
        guard let gameCodeText = gamecodeTextField.text else {return}

        if (gameCodeText != storedGameCode && gameCodeText != "") {
            gamecode = gameCodeText
            UserData.writeGamecode(gamecode, "gamecode")
            useStoredCode = false
            storedGameCode = ""
        } else {
            gamecode = storedGameCode
            useStoredCode = true
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
