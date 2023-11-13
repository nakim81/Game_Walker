//
//  PlayerFrame1.swift
//  Game_Walker
//
//  Created by Paul on 6/7/22.
//

import Foundation
import UIKit

class JoinGameViewController: BaseViewController {
    
    @IBOutlet weak var gamecodeLbl: UILabel!
    @IBOutlet weak var gamecodeTextField: UITextField!
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    private let audioPlayerManager = AudioPlayerManager()
    
    private var storedGameCode = UserData.readGamecode("gamecode") ?? ""
    private var storedUsername = UserData.readUsername("username") ?? ""
    private var storedPlayer = UserData.readPlayer("player") ?? nil
    private var storedTeamName = UserData.readTeam("team")?.name ?? ""
    private let standardStyle = UserData.isStandardStyle()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureSettingBtn()
        configureBackButton()
        configureTitleLabel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    private func setUp() {
        gamecodeTextField.delegate = self
        usernameTextField.delegate = self
        gamecodeTextField.translatesAutoresizingMaskIntoConstraints = false
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        gamecodeTextField.keyboardType = .asciiCapableNumberPad
        gamecodeTextField.placeholder = storedGameCode != "" ? storedGameCode : "gamecode"
        usernameTextField.placeholder = storedUsername != "" ? storedUsername : "username"
        gamecodeTextField.layer.borderWidth = 3
        gamecodeTextField.layer.borderColor = UIColor.black.cgColor
        gamecodeTextField.layer.cornerRadius = 10
        usernameTextField.layer.borderWidth = 3
        usernameTextField.layer.borderColor = UIColor.black.cgColor
        usernameTextField.layer.cornerRadius = 10
        gamecodeLbl.font = UIFont(name: "GemunuLibre-SemiBold", size: fontSize(size: 40))
        usernameLbl.font = UIFont(name: "GemunuLibre-SemiBold", size: fontSize(size: 40))
        
        nextButton.backgroundColor = UIColor(red: 0.21, green: 0.67, blue: 0.95, alpha: 1)
        nextButton.layer.cornerRadius = 8
    }
    
    private func configureNavItem() {
        self.navigationItem.hidesBackButton = true
        let backButtonImage = UIImage(named: "BackIcon")?.withRenderingMode(.alwaysTemplate)
        let newBackButton = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(back))
        newBackButton.tintColor = UIColor(red: 0.18, green: 0.18, blue: 0.21, alpha: 1)
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    @objc func back(sender: UIBarButtonItem) {
        performSegue(withIdentifier: "ToMainVC", sender: self)
    }
    
    @objc func setting(sender: UIBarButtonItem) {
        
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        self.audioPlayerManager.playAudioFile(named: "blue", withExtension: "wav")
        
        let savedGameCode = UserData.readGamecode("gamecode") ?? ""
        let savedUserName = UserData.readUsername("username") ?? ""
        var player = UserData.readPlayer("player") ?? Player(gamecode: "", name: "")
        
        guard let gamecode = gamecodeTextField.text else { return }
        guard let username = usernameTextField.text else { return }
        guard let uuid = UserData.readUUID() else { return }
        
        if gamecode.isEmpty && username.isEmpty {
            if !savedGameCode.isEmpty && !savedUserName.isEmpty {
                if (UserData.readTeam("team") != nil) {
                    // User wants to join the game with the stored game code, username, and player object
                    performSegue(withIdentifier: "ResumeGameSegue", sender: self)
                } else {
                    // User chooses between creating or joining a team
                    performSegue(withIdentifier: "goToPF2VC", sender: self)
                }
            } else {
                alert(title: "", message: "Please enter gamecode and username")
                return
            }
        } else if gamecode == savedGameCode && username == savedUserName {
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
                // Create a new player object for the new game
                player = Player(gamecode: gamecode, name: username)
                
                // Join the game
                Task { @MainActor in
                    // Try await P.addPlayer(gamecode, player, uuid)
                    do {
                        try await P.addPlayer(gamecode, player, uuid)
                        UserData.writeGamecode(gamecode, "gamecode")
                        UserData.writeUsername(username, "username")
                        UserData.writePlayer(player, "player")
                        performSegue(withIdentifier: "goToPF2VC", sender: self)
                    } catch GameWalkerError.invalidGamecode(let message) {
                        print(message)
                        gamecodeAlert(message)
                        return
                    } catch GameWalkerError.serverError(let message) {
                        print(message)
                        serverAlert(message)
                        return
                    }

                }
            } else {
                // Invalid input
                alert(title: "", message: "Please enter both game code and username.")
                return
            }
            
        } else if (gamecode != savedGameCode) && (username.isEmpty || username == savedUserName) {
            Task { @MainActor in
                if let team = UserData.readTeam("team") {
                    do {
                        try await T.leaveTeam(savedGameCode, team.name, player)
                    } catch GameWalkerError.serverError(let message) {
                        print(message)
                        serverAlert(message)
                        return
                    }
                }
                P.removePlayer(savedGameCode, uuid)
                player = Player(gamecode: gamecode, name: savedUserName)
                do{
                    try await P.addPlayer(gamecode, player, uuid)
                    UserData.writeGamecode(gamecode, "gamecode")
                    UserData.writePlayer(player, "player")
                    self.performSegue(withIdentifier: "goToPF2VC", sender: self)
                } catch GameWalkerError.invalidGamecode(let message) {
                    print(message)
                    gamecodeAlert(message)
                    return
                } catch GameWalkerError.serverError(let message) {
                    print(message)
                    serverAlert(message)
                    return
                }
            }
        } else if (gamecode.isEmpty || gamecode == savedGameCode) && username != savedUserName {
            Task { @MainActor in
                do {
                    try await P.modifyName(savedGameCode, uuid, username)
                    player = Player(gamecode: gamecode, name: username)
                    UserData.writePlayer(player, "player")
                    UserData.writeUsername(username, "username")
                } catch GameWalkerError.invalidGamecode(let message) {
                    print(message)
                    gamecodeAlert(message)
                    return
                } catch GameWalkerError.serverError(let message) {
                    print(message)
                    serverAlert(message)
                    return
                }
                if (UserData.readTeam("team") != nil) {
                    self.performSegue(withIdentifier: "ResumeGameSegue", sender: self)
                } else {
                    self.performSegue(withIdentifier: "goToPF2VC", sender: self)
                }
            }
        } else if (!savedGameCode.isEmpty || gamecode == savedGameCode) && savedUserName.isEmpty {
            if let username = usernameTextField.text {
                Task {@MainActor in
                    let player = Player(gamecode: savedGameCode, name: username)
                    UserData.writePlayer(player, "player")
                    UserData.writeUsername(username, "username")
                    UserData.writeGamecode(savedGameCode, "gamecode")
                    do {
                        try await P.addPlayer(savedGameCode, player, uuid)
                        self.performSegue(withIdentifier: "goToPF2VC", sender: self)
                    } catch GameWalkerError.invalidGamecode(let message) {
                        print(message)
                        gamecodeAlert(message)
                        return
                    } catch GameWalkerError.serverError(let message) {
                        print(message)
                        serverAlert(message)
                        return
                    }
                }
            } else {
                alert(title: "", message: "Please enter username")
                return
            }
        } else if gamecode != savedGameCode && username != savedUserName {
            Task {@MainActor in
                if let team = UserData.readTeam("team") {
                    do {
                        try await T.leaveTeam(savedGameCode, team.name, player)
                    } catch GameWalkerError.serverError(let message) {
                        print(message)
                        serverAlert(message)
                        return
                    }
                }
                P.removePlayer(savedGameCode, uuid)
                player = Player(gamecode: gamecode, name: username)
                do {
                    try await P.addPlayer(gamecode, player, uuid)
                    UserData.writeGamecode(gamecode, "gamecode")
                    UserData.writeUsername(username, "username")
                    UserData.writePlayer(player, "player")
                    self.performSegue(withIdentifier: "goToPF2VC", sender: self)
                } catch GameWalkerError.invalidGamecode(let message) {
                    print(message)
                    gamecodeAlert(message)
                    return
                } catch GameWalkerError.serverError(let message) {
                    print(message)
                    serverAlert(message)
                    return
                }
            }
        } else {
            alert(title: "", message: "Invalid Input!")
            return
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tabBarController = segue.destination as? PlayerTabBarController {
            // Determine the value of "standardStyle" (true or false)

            // Pass the "standardStyle" value to the tab bar controller
            tabBarController.standardStyle = self.standardStyle
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
