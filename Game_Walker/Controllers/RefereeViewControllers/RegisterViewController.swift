//
//  RefereeFrame1.swift
//  Game_Walker
//
//  Created by Paul on 6/7/22.
//

import Foundation
import UIKit


class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var gamecodeTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var gamecodeLbl: UILabel!
    @IBOutlet weak var usernameLbl: UILabel!
    
    private var storedGameCode = UserData.readGamecode("gamecode") ?? ""
    private var storedRefereeName = UserData.readUsername("username") ?? ""
    private var refereeUserID = UserData.readUUID()!
    private var stations : [Station] = []
    private var isSeguePerformed = false
    private var pvp : Bool?
    private var host : Host = Host()
    private let audioPlayerManager = AudioPlayerManager()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        storedGameCode = UserData.readGamecode("gamecode") ?? ""
        storedRefereeName = UserData.readUsername("username") ?? ""
        setUp()
        configureNavItem()
        configureTitleLabel()
    }
    
    override func viewDidLoad() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        setUp()
        super.viewDidLoad()
    }
    
    private func setUp() {
        gamecodeTextField.delegate = self
        usernameTextField.delegate = self
        gamecodeTextField.translatesAutoresizingMaskIntoConstraints = false
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        gamecodeTextField.keyboardType = .asciiCapableNumberPad
        gamecodeTextField.placeholder = storedGameCode != "" ? storedGameCode : NSLocalizedString("gamecode", comment: "")
        usernameTextField.placeholder = storedRefereeName != "" ? storedRefereeName : NSLocalizedString("username", comment: "")
        gamecodeTextField.layer.borderWidth = 3
        gamecodeTextField.layer.borderColor = UIColor.black.cgColor
        gamecodeTextField.layer.cornerRadius = 10
        usernameTextField.layer.borderWidth = 3
        usernameTextField.layer.borderColor = UIColor.black.cgColor
        usernameTextField.layer.cornerRadius = 10
        gamecodeLbl.font = getFontForLanguage(font: "GemunuLibre-SemiBold", size: fontSize(size: 40))
        usernameLbl.font = getFontForLanguage(font: "GemunuLibre-SemiBold", size: fontSize(size: 40))
        nextButton.backgroundColor = UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 1)
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
        performSegue(withIdentifier: "toMainVC", sender: self)
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
        self.audioPlayerManager.playAudioFile(named: "green", withExtension: "wav")
        Task {
            if (UserData.getUserRole() == nil || UserData.getUserRole() == "referee") {
                if let gameCode = gamecodeTextField.text, let name = usernameTextField.text {
                    if gameCode.isEmpty && name.isEmpty {
                        if !storedGameCode.isEmpty && !storedRefereeName.isEmpty {
                            if gamecodeTextField.text! == "" && gamecodeTextField.placeholder! != "" {
                                do {
                                    host = try await H.getHost(gamecodeTextField.placeholder!) ?? Host()
                                } catch GameWalkerError.invalidGamecode(let message) {
                                    print(message)
                                    gamecodeAlert(message)
                                    return
                                } catch GameWalkerError.serverError(let message) {
                                    print(message)
                                    serverAlert(message)
                                    return
                                }
                            } else {
                                do {
                                    host = try await H.getHost(gamecodeTextField.text!) ?? Host()
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
                            if host.standardStyle == false {
                                alert(title: NSLocalizedString("Point Style", comment: ""), message: NSLocalizedString("There is no Referee in point style.", comment: ""))
                                return
                            } else {
                                let oldReferee = UserData.readReferee("referee")!
                                if oldReferee.assigned {
                                    performSegue(withIdentifier: "toPVE", sender: self)
                                } else {
                                    performSegue(withIdentifier: "goToWait", sender: self)
                                }
                            }
                        } else {
                            alert(title: NSLocalizedString("Woops!", comment: ""), message: NSLocalizedString("Please enter both gamecode and username.", comment: ""))
                            return
                        }
                    } else if gameCode == storedGameCode && name == storedRefereeName {
                        if gamecodeTextField.text! == "" && gamecodeTextField.placeholder! != "" {
                            do {
                                host = try await H.getHost(gamecodeTextField.placeholder!) ?? Host()
                            } catch GameWalkerError.invalidGamecode(let message) {
                                print(message)
                                gamecodeAlert(message)
                                return
                            } catch GameWalkerError.serverError(let message) {
                                print(message)
                                serverAlert(message)
                                return
                            }
                        } else {
                            do {
                                host = try await H.getHost(gamecodeTextField.text!) ?? Host()
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
                        if host.standardStyle == false {
                            alert(title: NSLocalizedString("Point Style", comment: ""), message: NSLocalizedString("There is no Referee in point style.", comment: ""))
                            return
                        } else {
                            let oldReferee = UserData.readReferee("referee")!
                            if oldReferee.assigned {
                                performSegue(withIdentifier: "toPVE", sender: self)
                            } else {
                                performSegue(withIdentifier: "goToWait", sender: self)
                            }
                        }
                    } else if storedGameCode.isEmpty && storedRefereeName.isEmpty {
                        if !gameCode.isEmpty && !name.isEmpty {
                            if gamecodeTextField.text! == "" && gamecodeTextField.placeholder! != "" {
                                do {
                                    host = try await H.getHost(gamecodeTextField.placeholder!) ?? Host()
                                } catch GameWalkerError.invalidGamecode(let message) {
                                    print(message)
                                    gamecodeAlert(message)
                                    return
                                } catch GameWalkerError.serverError(let message) {
                                    print(message)
                                    serverAlert(message)
                                    return
                                }
                            } else {
                                do {
                                    host = try await H.getHost(gamecodeTextField.text!) ?? Host()
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
                            if host.standardStyle == false {
                                alert(title: NSLocalizedString("Point Style", comment: ""), message: NSLocalizedString("There is no Referee in point style.", comment: ""))
                                return
                            } else {

                                let newReferee = Referee(uuid: refereeUserID, gamecode: gameCode, name: name, stationName: "", assigned: false)
                                Task { @MainActor in
                                    do {
                                        try await R.addReferee(gameCode, newReferee, refereeUserID)
                                    } catch GameWalkerError.invalidGamecode(let message) {
                                        print(message)
                                        gamecodeAlert(message)
                                        return
                                    } catch GameWalkerError.serverError(let message) {
                                        print(message)
                                        serverAlert(message)
                                        return
                                    }
                                    UserData.writeGamecode(gameCode, "gamecode")
                                    UserData.writeUsername(name, "username")
                                    UserData.writeReferee(newReferee, "referee")
                                    UserData.setUserRole("referee")
                                    UserDefaults.standard.removeObject(forKey: "max")
                                    UserDefaults.standard.removeObject(forKey: "maxA")
                                    UserDefaults.standard.removeObject(forKey: "maxB")
                                    performSegue(withIdentifier: "goToWait", sender: self)
                                }
                            }
                        } else {
                            alert(title: NSLocalizedString("Woops!", comment: ""), message: NSLocalizedString("Please enter both gamecode and username.", comment: ""))
                            return
                        }
                    } else if (gameCode != storedGameCode) && (name.isEmpty || name == storedRefereeName) {
                        if gamecodeTextField.text! == "" && gamecodeTextField.placeholder! != "" {
                            do {
                                host = try await H.getHost(gamecodeTextField.placeholder!) ?? Host()
                            } catch GameWalkerError.invalidGamecode(let message) {
                                print(message)
                                gamecodeAlert(message)
                                return
                            } catch GameWalkerError.serverError(let message) {
                                print(message)
                                serverAlert(message)
                                return
                            }
                        } else {
                            do {
                                host = try await H.getHost(gamecodeTextField.text!) ?? Host()
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
                        if host.standardStyle == false {
                            alert(title: NSLocalizedString("Point Style", comment: ""), message: NSLocalizedString("There is no Referee in point style.", comment: ""))
                            return
                        } else {
                            let newReferee = Referee(uuid: refereeUserID, gamecode: gameCode, name: storedRefereeName, stationName: "", assigned: false)
                            Task { @MainActor in
                                do {
                                    try await R.addReferee(gameCode, newReferee, refereeUserID)
                                } catch GameWalkerError.invalidGamecode(let message) {
                                    print(message)
                                    gamecodeAlert(message)
                                    return
                                } catch GameWalkerError.serverError(let message) {
                                    print(message)
                                    serverAlert(message)
                                    return
                                }
                                UserData.writeGamecode(gameCode, "gamecode")
                                UserData.writeUsername(storedRefereeName, "username")
                                UserData.writeReferee(newReferee, "referee")
                                UserData.setUserRole("referee")
                                UserDefaults.standard.removeObject(forKey: "max")
                                UserDefaults.standard.removeObject(forKey: "maxA")
                                UserDefaults.standard.removeObject(forKey: "maxB")
                                performSegue(withIdentifier: "goToWait", sender: self)
                            }
                        }
                    } else if (gameCode.isEmpty || gameCode == storedGameCode ) && name != storedRefereeName {
                        if gamecodeTextField.text! == "" && gamecodeTextField.placeholder! != "" {
                            do {
                                host = try await H.getHost(gamecodeTextField.placeholder!) ?? Host()
                            } catch GameWalkerError.invalidGamecode(let message) {
                                print(message)
                                gamecodeAlert(message)
                                return
                            } catch GameWalkerError.serverError(let message) {
                                print(message)
                                serverAlert(message)
                                return
                            }
                        } else {
                            do {
                                host = try await H.getHost(gamecodeTextField.text!) ?? Host()
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
                        if host.standardStyle == false {
                            alert(title: NSLocalizedString("Point Style", comment: ""), message: NSLocalizedString("There is no Referee in point style.", comment: ""))
                            return
                        } else {
                            let oldReferee = UserData.readReferee("referee")!
                            let newReferee = Referee(uuid: refereeUserID, gamecode: storedGameCode, name: name, stationName: oldReferee.stationName, assigned: oldReferee.assigned)
                            Task { @MainActor in
                                do {
                                    try await R.modifyName(storedGameCode, refereeUserID, name)
                                } catch GameWalkerError.serverError(let message) {
                                    print(message)
                                    serverAlert(message)
                                    return
                                }
                                UserData.writeGamecode(storedGameCode, "gamecode")
                                UserData.writeUsername(name, "username")
                                UserData.writeReferee(newReferee, "referee")
                                UserData.setUserRole("referee")
                                UserDefaults.standard.removeObject(forKey: "max")
                                UserDefaults.standard.removeObject(forKey: "maxA")
                                UserDefaults.standard.removeObject(forKey: "maxB")
                                if newReferee.assigned {
                                    performSegue(withIdentifier: "toPVE", sender: self)
                                } else {
                                    performSegue(withIdentifier: "goToWait", sender: self)
                                }
                            }
                        }
                    } else if gameCode != storedGameCode  && name != storedRefereeName {
                        if gamecodeTextField.text! == "" && gamecodeTextField.placeholder! != "" {
                            do {
                                host = try await H.getHost(gamecodeTextField.placeholder!) ?? Host()
                            } catch GameWalkerError.invalidGamecode(let message) {
                                print(message)
                                gamecodeAlert(message)
                                return
                            } catch GameWalkerError.serverError(let message) {
                                print(message)
                                serverAlert(message)
                                return
                            }
                        } else {
                            do {
                                host = try await H.getHost(gamecodeTextField.text!) ?? Host()
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
                        if host.standardStyle == false {
                            alert(title: NSLocalizedString("Point Style", comment: ""), message: NSLocalizedString("There is no Referee in point style.", comment: ""))
                            return
                        } else {
                            let newReferee = Referee(uuid: refereeUserID, gamecode: gameCode, name: name, stationName: "", assigned: false)
                            Task { @MainActor in
                                do {
                                    try await R.addReferee(gameCode, newReferee, refereeUserID)
                                } catch GameWalkerError.invalidGamecode(let message) {
                                    print(message)
                                    gamecodeAlert(message)
                                    return
                                } catch GameWalkerError.serverError(let message) {
                                    print(message)
                                    serverAlert(message)
                                    return
                                }
                                UserData.writeGamecode(gameCode, "gamecode")
                                UserData.writeUsername(name, "username")
                                UserData.writeReferee(newReferee, "referee")
                                UserData.setUserRole("referee")
                                UserDefaults.standard.removeObject(forKey: "max")
                                UserDefaults.standard.removeObject(forKey: "maxA")
                                UserDefaults.standard.removeObject(forKey: "maxB")
                                performSegue(withIdentifier: "goToWait", sender: self)
                            }
                        }
                    } else {
                        alert(title: NSLocalizedString("Woops!", comment: ""), message: NSLocalizedString("Invalid Input.", comment: ""))
                        return
                    }
                }
            } else {
                if let gameCode = gamecodeTextField.text, let name = usernameTextField.text {
                    if gameCode.isEmpty && name.isEmpty {
                        if !storedGameCode.isEmpty && !storedRefereeName.isEmpty {
                            if gamecodeTextField.text! == "" && gamecodeTextField.placeholder! != "" {
                                do {
                                    host = try await H.getHost(gamecodeTextField.placeholder!) ?? Host()
                                } catch GameWalkerError.invalidGamecode(let message) {
                                    print(message)
                                    gamecodeAlert(message)
                                    return
                                } catch GameWalkerError.serverError(let message) {
                                    print(message)
                                    serverAlert(message)
                                    return
                                }
                            } else {
                                do {
                                    host = try await H.getHost(gamecodeTextField.text!) ?? Host()
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
                            if host.standardStyle == false {
                                alert(title: NSLocalizedString("Point Style", comment: ""), message: NSLocalizedString("There is no Referee in point style.", comment: ""))
                                return
                            } else {
                                if UserData.getUserRole() == "host" {
                                    alert(title: NSLocalizedString("Woops!", comment: ""), message: NSLocalizedString("You cannot change roles while the game is in progress.", comment: ""))
                                    return
                                } else {
                                    if host.confirmCreated {
                                        alert(title: NSLocalizedString("Woops!", comment: ""), message: NSLocalizedString("You cannot change roles while the game is in progress.", comment: ""))
                                        return
                                    } else  {
                                        let newReferee = Referee(uuid: refereeUserID, gamecode: storedGameCode, name: storedRefereeName, stationName: "", assigned: false)
                                        Task { @MainActor in
                                            do {
                                                try await R.addReferee(storedGameCode, newReferee, refereeUserID)
                                            } catch GameWalkerError.invalidGamecode(let message) {
                                                print(message)
                                                gamecodeAlert(message)
                                                return
                                            } catch GameWalkerError.serverError(let message) {
                                                print(message)
                                                serverAlert(message)
                                                return
                                            }
                                            UserData.writeGamecode(storedGameCode, "gamecode")
                                            UserData.writeUsername(newReferee.name, "username")
                                            UserData.writeReferee(newReferee, "referee")
                                            UserData.setUserRole("referee")
                                            UserDefaults.standard.removeObject(forKey: "max")
                                            UserDefaults.standard.removeObject(forKey: "maxA")
                                            UserDefaults.standard.removeObject(forKey: "maxB")
                                            performSegue(withIdentifier: "goToWait", sender: self)
                                        }
                                    }
                                }
                            }
                        } else {
                            alert(title: NSLocalizedString("Woops!", comment: ""), message: NSLocalizedString("Please enter both gamecode and username.", comment: ""))
                            return
                        }
                    } else if gameCode == storedGameCode && name == storedRefereeName {
                        if gamecodeTextField.text! == "" && gamecodeTextField.placeholder! != "" {
                            do {
                                host = try await H.getHost(gamecodeTextField.placeholder!) ?? Host()
                            } catch GameWalkerError.invalidGamecode(let message) {
                                print(message)
                                gamecodeAlert(message)
                                return
                            } catch GameWalkerError.serverError(let message) {
                                print(message)
                                serverAlert(message)
                                return
                            }
                        } else {
                            do {
                                host = try await H.getHost(gamecodeTextField.text!) ?? Host()
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
                        if host.standardStyle == false {
                            alert(title: NSLocalizedString("Point Style", comment: ""), message: NSLocalizedString("There is no Referee in point style.", comment: ""))
                            return
                        } else {
                            if UserData.getUserRole() == "host" {
                                alert(title: NSLocalizedString("Woops!", comment: ""), message: NSLocalizedString("You cannot change roles while the game is in progress.", comment: ""))
                                return
                            } else {
                                if host.confirmCreated {
                                    alert(title: NSLocalizedString("Woops!", comment: ""), message: NSLocalizedString("You cannot change roles while the game is in progress.", comment: ""))
                                    return
                                } else  {
                                    let oldReferee = UserData.readReferee("referee")!
                                    if oldReferee.assigned {
                                        performSegue(withIdentifier: "toPVE", sender: self)
                                    } else {
                                        performSegue(withIdentifier: "goToWait", sender: self)
                                    }
                                }
                            }
                        }
                    } else if (!storedGameCode.isEmpty || gameCode == storedGameCode) && storedRefereeName.isEmpty {
                        if name.isEmpty {
                            alert(title: NSLocalizedString("Woops!", comment: ""), message: NSLocalizedString("Please enter username.", comment: ""))
                            return
                        } else {
                            if gamecodeTextField.text! == "" && gamecodeTextField.placeholder! != "" {
                                do {
                                    host = try await H.getHost(gamecodeTextField.placeholder!) ?? Host()
                                } catch GameWalkerError.invalidGamecode(let message) {
                                    print(message)
                                    gamecodeAlert(message)
                                    return
                                } catch GameWalkerError.serverError(let message) {
                                    print(message)
                                    serverAlert(message)
                                    return
                                }
                            } else {
                                do {
                                    host = try await H.getHost(gamecodeTextField.text!) ?? Host()
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
                            if host.standardStyle == false {
                                alert(title: NSLocalizedString("Point Style", comment: ""), message: NSLocalizedString("There is no Referee in point style.", comment: ""))
                                return
                            } else {
                                if UserData.getUserRole() == "host" {
                                    if gameCode.isEmpty {
                                        alert(title: NSLocalizedString("Woops!", comment: ""), message: NSLocalizedString("You cannot change roles while the game is in progress.", comment: ""))
                                        return
                                    } else {
                                        if storedGameCode != gameCode {
                                            let newReferee = Referee(uuid: refereeUserID, gamecode: gameCode, name: name, stationName: "", assigned: false)
                                            Task { @MainActor in
                                                do {
                                                    try await R.addReferee(gameCode, newReferee, refereeUserID)
                                                } catch GameWalkerError.invalidGamecode(let message) {
                                                    print(message)
                                                    gamecodeAlert(message)
                                                    return
                                                } catch GameWalkerError.serverError(let message) {
                                                    print(message)
                                                    serverAlert(message)
                                                    return
                                                }
                                                UserData.writeGamecode(gameCode, "gamecode")
                                                UserData.writeUsername(newReferee.name, "username")
                                                UserData.writeReferee(newReferee, "referee")
                                                UserData.setUserRole("referee")
                                                UserDefaults.standard.removeObject(forKey: "max")
                                                UserDefaults.standard.removeObject(forKey: "maxA")
                                                UserDefaults.standard.removeObject(forKey: "maxB")
                                                performSegue(withIdentifier: "goToWait", sender: self)
                                            }
                                        } else {
                                            alert(title: NSLocalizedString("Woops!", comment: ""), message: NSLocalizedString("You cannot change roles while the game is in progress.", comment: ""))
                                            return
                                        }
                                    }
                                } else {
                                    if host.confirmCreated {
                                        alert(title: NSLocalizedString("Woops!", comment: ""), message: NSLocalizedString("You cannot change roles while the game is in progress.", comment: ""))
                                        return
                                    } else  {
                                        let newReferee = Referee(uuid: refereeUserID, gamecode: gameCode, name: name, stationName: "", assigned: false)
                                        Task { @MainActor in
                                            do {
                                                try await R.addReferee(gameCode, newReferee, refereeUserID)
                                            } catch GameWalkerError.invalidGamecode(let message) {
                                                print(message)
                                                gamecodeAlert(message)
                                                return
                                            } catch GameWalkerError.serverError(let message) {
                                                print(message)
                                                serverAlert(message)
                                                return
                                            }
                                            UserData.writeGamecode(gameCode, "gamecode")
                                            UserData.writeUsername(newReferee.name, "username")
                                            UserData.writeReferee(newReferee, "referee")
                                            UserData.setUserRole("referee")
                                            UserDefaults.standard.removeObject(forKey: "max")
                                            UserDefaults.standard.removeObject(forKey: "maxA")
                                            UserDefaults.standard.removeObject(forKey: "maxB")
                                            performSegue(withIdentifier: "goToWait", sender: self)
                                        }
                                    }
                                }
                            }
                        }
                    } else if storedGameCode.isEmpty && storedRefereeName.isEmpty {
                        if !gameCode.isEmpty && !name.isEmpty {
                            if gamecodeTextField.text! == "" && gamecodeTextField.placeholder! != "" {
                                do {
                                    host = try await H.getHost(gamecodeTextField.placeholder!) ?? Host()
                                } catch GameWalkerError.invalidGamecode(let message) {
                                    print(message)
                                    gamecodeAlert(message)
                                    return
                                } catch GameWalkerError.serverError(let message) {
                                    print(message)
                                    serverAlert(message)
                                    return
                                }
                            } else {
                                do {
                                    host = try await H.getHost(gamecodeTextField.text!) ?? Host()
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
                            if host.standardStyle == false {
                                alert(title: NSLocalizedString("Point Style", comment: ""), message: NSLocalizedString("There is no Referee in point style.", comment: ""))
                                return
                            } else {
                                if UserData.getUserRole() == "host" {
                                    if storedGameCode != gameCode {
                                        let newReferee = Referee(uuid: refereeUserID, gamecode: gameCode, name: name, stationName: "", assigned: false)
                                        Task { @MainActor in
                                            do {
                                                try await R.addReferee(gameCode, newReferee, refereeUserID)
                                            } catch GameWalkerError.invalidGamecode(let message) {
                                                print(message)
                                                gamecodeAlert(message)
                                                return
                                            } catch GameWalkerError.serverError(let message) {
                                                print(message)
                                                serverAlert(message)
                                                return
                                            }
                                            UserData.writeGamecode(gameCode, "gamecode")
                                            UserData.writeUsername(name, "username")
                                            UserData.writeReferee(newReferee, "referee")
                                            UserData.setUserRole("referee")
                                            UserDefaults.standard.removeObject(forKey: "max")
                                            UserDefaults.standard.removeObject(forKey: "maxA")
                                            UserDefaults.standard.removeObject(forKey: "maxB")
                                            performSegue(withIdentifier: "goToWait", sender: self)
                                        }
                                    } else {
                                        alert(title: NSLocalizedString("Woops!", comment: ""), message: NSLocalizedString("You cannot change roles while the game is in progress.", comment: ""))
                                        return
                                    }
                                } else {
                                    if host.confirmCreated {
                                        alert(title: NSLocalizedString("Woops!", comment: ""), message: NSLocalizedString("You cannot change roles while the game is in progress.", comment: ""))
                                        return
                                    } else  {
                                        let newReferee = Referee(uuid: refereeUserID, gamecode: gameCode, name: name, stationName: "", assigned: false)
                                        Task { @MainActor in
                                            do {
                                                try await R.addReferee(gameCode, newReferee, refereeUserID)
                                            } catch GameWalkerError.invalidGamecode(let message) {
                                                print(message)
                                                gamecodeAlert(message)
                                                return
                                            } catch GameWalkerError.serverError(let message) {
                                                print(message)
                                                serverAlert(message)
                                                return
                                            }
                                            UserData.writeGamecode(gameCode, "gamecode")
                                            UserData.writeUsername(name, "username")
                                            UserData.writeReferee(newReferee, "referee")
                                            UserData.setUserRole("referee")
                                            UserDefaults.standard.removeObject(forKey: "max")
                                            UserDefaults.standard.removeObject(forKey: "maxA")
                                            UserDefaults.standard.removeObject(forKey: "maxB")
                                            performSegue(withIdentifier: "goToWait", sender: self)
                                        }
                                    }
                                }
                            }
                        } else {
                            alert(title: NSLocalizedString("Woops!", comment: ""), message: NSLocalizedString("Please enter both gamecode and username.", comment: ""))
                            return
                        }
                    } else if (gameCode != storedGameCode ) && (name.isEmpty || name == storedRefereeName) {
                        if gamecodeTextField.text! == "" && gamecodeTextField.placeholder! != "" {
                            do {
                                host = try await H.getHost(gamecodeTextField.placeholder!) ?? Host()
                            } catch GameWalkerError.invalidGamecode(let message) {
                                print(message)
                                gamecodeAlert(message)
                                return
                            } catch GameWalkerError.serverError(let message) {
                                print(message)
                                serverAlert(message)
                                return
                            }
                        } else {
                            do {
                                host = try await H.getHost(gamecodeTextField.text!) ?? Host()
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
                        if host.standardStyle == false {
                            alert(title: NSLocalizedString("Point Style", comment: ""), message: NSLocalizedString("There is no Referee in point style.", comment: ""))
                            return
                        } else {
                            if UserData.getUserRole() == "host" {
                                if storedGameCode != gameCode {
                                    let newReferee = Referee(uuid: refereeUserID, gamecode: gameCode, name: storedRefereeName, stationName: "", assigned: false)
                                    Task { @MainActor in
                                        do {
                                            try await R.addReferee(gameCode, newReferee, refereeUserID)
                                        } catch GameWalkerError.invalidGamecode(let message) {
                                            print(message)
                                            gamecodeAlert(message)
                                            return
                                        } catch GameWalkerError.serverError(let message) {
                                            print(message)
                                            serverAlert(message)
                                            return
                                        }
                                        UserData.writeGamecode(gameCode, "gamecode")
                                        UserData.writeUsername(storedRefereeName, "username")
                                        UserData.writeReferee(newReferee, "referee")
                                        UserData.setUserRole("referee")
                                        UserDefaults.standard.removeObject(forKey: "max")
                                        UserDefaults.standard.removeObject(forKey: "maxA")
                                        UserDefaults.standard.removeObject(forKey: "maxB")
                                        performSegue(withIdentifier: "goToWait", sender: self)
                                    }
                                } else {
                                    alert(title: NSLocalizedString("Woops!", comment: ""), message: NSLocalizedString("You cannot change roles while the game is in progress.", comment: ""))
                                    return
                                }
                            } else {
                                if host.confirmCreated {
                                    alert(title: NSLocalizedString("Woops!", comment: ""), message: NSLocalizedString("You cannot change roles while the game is in progress.", comment: ""))
                                    return
                                } else  {
                                    let newReferee = Referee(uuid: refereeUserID, gamecode: gameCode, name: storedRefereeName, stationName: "", assigned: false)
                                    Task { @MainActor in
                                        do {
                                            try await R.addReferee(gameCode, newReferee, refereeUserID)
                                        } catch GameWalkerError.invalidGamecode(let message) {
                                            print(message)
                                            gamecodeAlert(message)
                                            return
                                        } catch GameWalkerError.serverError(let message) {
                                            print(message)
                                            serverAlert(message)
                                            return
                                        }
                                        UserData.writeGamecode(gameCode, "gamecode")
                                        UserData.writeUsername(storedRefereeName, "username")
                                        UserData.writeReferee(newReferee, "referee")
                                        UserData.setUserRole("referee")
                                        UserDefaults.standard.removeObject(forKey: "max")
                                        UserDefaults.standard.removeObject(forKey: "maxA")
                                        UserDefaults.standard.removeObject(forKey: "maxB")
                                        performSegue(withIdentifier: "goToWait", sender: self)
                                    }
                                }
                            }
                        }
                    } else if (gameCode.isEmpty || gameCode == storedGameCode ) && name != storedRefereeName {
                        if gamecodeTextField.text! == "" && gamecodeTextField.placeholder! != "" {
                            do {
                                host = try await H.getHost(gamecodeTextField.placeholder!) ?? Host()
                            } catch GameWalkerError.invalidGamecode(let message) {
                                print(message)
                                gamecodeAlert(message)
                                return
                            } catch GameWalkerError.serverError(let message) {
                                print(message)
                                serverAlert(message)
                                return
                            }
                        } else {
                            do {
                                host = try await H.getHost(gamecodeTextField.text!) ?? Host()
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
                        if host.standardStyle == false {
                            alert(title: NSLocalizedString("Point Style", comment: ""), message: NSLocalizedString("There is no Referee in point style.", comment: ""))
                            return
                        } else {
                            if UserData.getUserRole() == "host" {
                                alert(title: NSLocalizedString("Woops!", comment: ""), message: NSLocalizedString("You cannot change roles while the game is in progress.", comment: ""))
                                return
                            } else {
                                if host.confirmCreated {
                                    alert(title: NSLocalizedString("Woops!", comment: ""), message: NSLocalizedString("You cannot change roles while the game is in progress.", comment: ""))
                                    return
                                } else  {
                                    if name.isEmpty {
                                        let newReferee = Referee(uuid: refereeUserID, gamecode: storedGameCode, name: storedRefereeName, stationName: "", assigned: false)
                                        Task { @MainActor in
                                            do {
                                                try await R.addReferee(storedGameCode, newReferee, refereeUserID)
                                            } catch GameWalkerError.invalidGamecode(let message) {
                                                print(message)
                                                gamecodeAlert(message)
                                                return
                                            } catch GameWalkerError.serverError(let message) {
                                                print(message)
                                                serverAlert(message)
                                                return
                                            }
                                            UserData.writeGamecode(storedGameCode, "gamecode")
                                            UserData.writeUsername(storedRefereeName, "username")
                                            UserData.writeReferee(newReferee, "referee")
                                            UserData.setUserRole("referee")
                                            UserDefaults.standard.removeObject(forKey: "max")
                                            UserDefaults.standard.removeObject(forKey: "maxA")
                                            UserDefaults.standard.removeObject(forKey: "maxB")
                                            performSegue(withIdentifier: "goToWait", sender: self)
                                        }
                                    } else {
                                        let newReferee = Referee(uuid: refereeUserID, gamecode: storedGameCode, name: name, stationName: "", assigned: false)
                                        Task { @MainActor in
                                            do {
                                                try await R.addReferee(storedGameCode, newReferee, refereeUserID)
                                            } catch GameWalkerError.invalidGamecode(let message) {
                                                print(message)
                                                gamecodeAlert(message)
                                                return
                                            } catch GameWalkerError.serverError(let message) {
                                                print(message)
                                                serverAlert(message)
                                                return
                                            }
                                            UserData.writeGamecode(storedGameCode, "gamecode")
                                            UserData.writeUsername(name, "username")
                                            UserData.writeReferee(newReferee, "referee")
                                            UserData.setUserRole("referee")
                                            UserDefaults.standard.removeObject(forKey: "max")
                                            UserDefaults.standard.removeObject(forKey: "maxA")
                                            UserDefaults.standard.removeObject(forKey: "maxB")
                                            performSegue(withIdentifier: "goToWait", sender: self)
                                        }
                                    }
                                }
                            }
                        }
                    } else if gameCode != storedGameCode  && name != storedRefereeName {
                        if gamecodeTextField.text! == "" && gamecodeTextField.placeholder! != "" {
                            do {
                                host = try await H.getHost(gamecodeTextField.placeholder!) ?? Host()
                            } catch GameWalkerError.invalidGamecode(let message) {
                                print(message)
                                gamecodeAlert(message)
                                return
                            } catch GameWalkerError.serverError(let message) {
                                print(message)
                                serverAlert(message)
                                return
                            }
                        } else {
                            do {
                                host = try await H.getHost(gamecodeTextField.text!) ?? Host()
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
                        if host.standardStyle == false {
                            alert(title: NSLocalizedString("Point Style", comment: ""), message: NSLocalizedString("There is no Referee in point style.", comment: ""))
                            return
                        } else {
                            if UserData.getUserRole() == "host" {
                                if storedGameCode != gameCode {
                                    let newReferee = Referee(uuid: refereeUserID, gamecode: gameCode, name: name, stationName: "", assigned: false)
                                    Task { @MainActor in
                                        do {
                                            try await R.addReferee(gameCode, newReferee, refereeUserID)
                                        } catch GameWalkerError.invalidGamecode(let message) {
                                            print(message)
                                            gamecodeAlert(message)
                                            return
                                        } catch GameWalkerError.serverError(let message) {
                                            print(message)
                                            serverAlert(message)
                                            return
                                        }
                                        UserData.writeGamecode(gameCode, "gamecode")
                                        UserData.writeUsername(name, "username")
                                        UserData.writeReferee(newReferee, "referee")
                                        UserData.setUserRole("referee")
                                        UserDefaults.standard.removeObject(forKey: "max")
                                        UserDefaults.standard.removeObject(forKey: "maxA")
                                        UserDefaults.standard.removeObject(forKey: "maxB")
                                        performSegue(withIdentifier: "goToWait", sender: self)
                                    }
                                } else {
                                    alert(title: NSLocalizedString("Woops!", comment: ""), message: NSLocalizedString("You cannot change roles while the game is in progress.", comment: ""))
                                    return
                                }
                            } else {
                                if host.confirmCreated {
                                    alert(title: NSLocalizedString("Woops!", comment: ""), message: NSLocalizedString("You cannot change roles while the game is in progress.", comment: ""))
                                    return
                                } else  {
                                    let newReferee = Referee(uuid: refereeUserID, gamecode: gameCode, name: name, stationName: "", assigned: false)
                                    Task { @MainActor in
                                        do {
                                            try await R.addReferee(gameCode, newReferee, refereeUserID)
                                        } catch GameWalkerError.invalidGamecode(let message) {
                                            print(message)
                                            gamecodeAlert(message)
                                            return
                                        } catch GameWalkerError.serverError(let message) {
                                            print(message)
                                            serverAlert(message)
                                            return
                                        }
                                        UserData.writeGamecode(gameCode, "gamecode")
                                        UserData.writeUsername(name, "username")
                                        UserData.writeReferee(newReferee, "referee")
                                        UserData.setUserRole("referee")
                                        UserDefaults.standard.removeObject(forKey: "max")
                                        UserDefaults.standard.removeObject(forKey: "maxA")
                                        UserDefaults.standard.removeObject(forKey: "maxB")
                                        performSegue(withIdentifier: "goToWait", sender: self)
                                    }
                                }
                            }
                        }
                    } else {
                        alert(title: NSLocalizedString("Woops!", comment: ""), message: NSLocalizedString("Invalid Input.", comment: ""))
                        return
                    }
                }
            }
        }
    }
}
