//
//  PlayerFrame1.swift
//  Game_Walker
//
//  Created by Paul on 6/7/22.
//

import Foundation
import UIKit
import PromiseKit

class JoinGameViewController: BaseViewController {
    
    @IBOutlet weak var gamecodeTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    private var storedGameCode = UserData.readGamecode("gamecode") ?? ""
    private var storedUsername = UserData.readUsername("username") ?? ""
    private var storedPlayer = UserData.readPlayer("player") ?? nil
    private var storedTeamName = UserData.readTeam("team")?.name ?? ""
    
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
        usernameTextField.placeholder = storedUsername != "" ? storedUsername : "username"
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
        let savedGameCode = UserData.readGamecode("gamecode") ?? ""
        let savedUserName = UserData.readUsername("username") ?? ""
        var player = UserData.readPlayer("player") ?? Player(gamecode: savedGameCode, name: savedUserName)
        
        guard let gamecode = gamecodeTextField.text else { return }
        guard let username = usernameTextField.text else { return }
        guard let uuid = UserData.readUUID() else { return }
        
        if (gamecode.isEmpty || gamecode == savedGameCode) && (username.isEmpty || username == savedUserName) {
            
            if (UserData.readTeam("team") != nil) {
                // User wants to join the game with the stored game code, username, and player object
                performSegue(withIdentifier: "ResumeGameSegue", sender: self)
            } else {
                // User chooses between creating or joining a team
                performSegue(withIdentifier: "goToPF2VC", sender: self)
            }
        } else if savedGameCode.isEmpty && savedUserName.isEmpty {
            
            // User is joining a new game
            if !gamecode.isEmpty && !username.isEmpty {
                // Save the game code and username to user defaults
                UserData.writeGamecode(gamecode, "gamecode")
                UserData.writeUsername(username, "username")

                // Create a new player object for the new game
                player = Player(gamecode: gamecode, name: username)
                UserData.writePlayer(player, "player")
                
                // Join the game
                Task { @MainActor in
                    //try await P.addPlayer(gamecode, player, uuid)
                }
                performSegue(withIdentifier: "goToPF2VC", sender: self)
            } else {
                // Invalid input
                alert(title: "", message: "Please enter both game code and username.")
            }
            
        } else if (gamecode != savedGameCode) && (username.isEmpty || username == savedUserName) {
            Task { @MainActor in
                if (UserData.readTeam("team") != nil) {
                    try await T.leaveTeam(savedGameCode, savedUserName, player)
                }
                P.removePlayer(savedGameCode, uuid)
                UserData.writeGamecode(gamecode, "gamecode")
                player = Player(gamecode: gamecode, name: savedUserName)
                UserData.writePlayer(player, "player")
                try await P.addPlayer(gamecode, player, uuid)
                self.performSegue(withIdentifier: "goToPF2VC", sender: self)
            }
            //self.alert(title: "", message: "Error occurred while communicating with the server. Try again few seconds later!")
        } else if (gamecode.isEmpty || gamecode == savedGameCode) && username != savedUserName {
            Task { @MainActor in
                try await P.modifyName(savedGameCode, uuid, username)
                player = Player(gamecode: gamecode, name: username)
                UserData.writePlayer(player, "player")
                UserData.writeUsername(username, "username")
                if (UserData.readTeam("team") != nil) {
                    self.performSegue(withIdentifier: "ResumeGameSegue", sender: self)
                } else {
                    self.performSegue(withIdentifier: "goToPF2VC", sender: self)
                }
            }
            //self.alert(title: "", message: "Error occurred while modifying username")
        } else if gamecode != savedGameCode && username != savedUserName {
            Task {@MainActor in
                if UserData.readTeam("team") != nil {
                    try await T.leaveTeam(savedGameCode, savedUserName, player)
                }
                P.removePlayer(savedGameCode, uuid)
                UserData.writeGamecode(gamecode, "gamecode")
                UserData.writeUsername(username, "username")
                player = Player(gamecode: gamecode, name: username)
                UserData.writePlayer(player, "player")
                try await P.addPlayer(gamecode, player, uuid)
                self.performSegue(withIdentifier: "goToPF2VC", sender: self)
            }
            //self.alert(title: "", message: "Error occurred while communicating with the server. Try again few seconds later!")
        } else {
            alert(title: "", message: "Invalid Input!")
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
