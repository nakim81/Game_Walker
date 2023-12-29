//
//  HostGameCodeViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 7/21/22.
//

import UIKit

class HostGameCodeViewController: UIViewController {

    @IBOutlet weak var gameCodeInput: UITextField!
    @IBOutlet weak var joinButton: UIButton!
    var dontTriggerSegue = true
    private var storedgamecode = UserData.readGamecode("gamecode")
    private var gamecode = UserData.readGamecode("gamecode")
    
    private var usestoredcode = true
    private var gameDidEnd = false
    
    private var gameCodeError = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        gameCodeInput.delegate = self
        gameCodeInput.textAlignment = NSTextAlignment.center
        gameCodeInput.keyboardType = .asciiCapableNumberPad
//        H.delegate_getHost = self

        gameCodeInput.placeholder = storedgamecode
        configureSimpleNavBar()
    }
    
    func setGameCode() {
        let gameCodeText = gameCodeInput.text
        print(gameCodeText , " this is what is entered")

        if (gameCodeText != storedgamecode && gameCodeText != "") {
            gamecode = gameCodeText
            usestoredcode = false
        } else {
            gamecode = storedgamecode
            usestoredcode = true
            if let gamecode = gamecode {
                gameCodeError = false
                print("Game code error is false")
            } else {
                gameCodeError = true
                print("Game code error is true")
            }
        }
    }
    
    @IBAction func joinButtonPressed(_ sender: UIButton) {
        setGameCode()
        guard let userGamecodeInput = gameCodeInput.text else {
            return
        }
        if storedgamecode!.isEmpty && userGamecodeInput.isEmpty {
            alert(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("No Game Exists!", comment: ""))
        } else {
            if (!usestoredcode) {
                Task { @MainActor in
                    do {
                        let hostTemp = try await H.getHost(userGamecodeInput)
                        let isStandard = hostTemp?.standardStyle ?? true
                        gameDidEnd = hostTemp?.gameover ?? false
                        
                        if !isStandard {
                            UserData.writeGamecode(gamecode!, "gamecode")
                            performSegue(withIdentifier: "GameAlreadyStartedSegue", sender: self)
                            return
                        }
                        
                        if !(hostTemp?.confirmCreated ?? true) {
                            UserData.writeGamecode(gamecode!, "gamecode")
                            performSegue(withIdentifier: "HostJoinSegue", sender: self)
                            
                        } else {
                            if UserData.isHostConfirmed() ?? false {
                                UserData.writeGamecode(gamecode!, "gamecode")
                                if gameDidEnd { // host is confirmed and game has already ended
                                    self.showAwardPopUp("host")
                                    
                                } else {
                                    performSegue(withIdentifier: "GameAlreadyStartedSegue", sender: self)
                                }
                            } else{
                                alert(title: "", message: NSLocalizedString("Invalid Host!", comment: ""))
                            }
                        }
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
                Task { @MainActor in
                    do {
                        let hostTemp = try await H.getHost(gamecode!)
                        let isStandard = hostTemp?.standardStyle ?? true
                        gameDidEnd = hostTemp?.gameover ?? false
                        
                        if !isStandard {
                            UserData.writeGamecode(gamecode!, "gamecode")
                            performSegue(withIdentifier: "GameAlreadyStartedSegue", sender: self)
                            return
                        }
                        if !(hostTemp?.confirmCreated ?? true) {
                            UserData.writeGamecode(gamecode!, "gamecode")
                            performSegue(withIdentifier: "HostJoinSegue", sender: self)
                        } else {
                            if UserData.isHostConfirmed() ?? false {
                                UserData.writeGamecode(gamecode!, "gamecode")
                                if gameDidEnd { // host is confirmed and game has already ended
                                    self.showAwardPopUp("host")
                                    
                                } else {
                                    performSegue(withIdentifier: "GameAlreadyStartedSegue", sender: self)
                                }
                            } else{
                                alert(title: "", message: NSLocalizedString("Invalid Host!", comment: ""))
                            }
                        }

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
            }
        }
    }
    
}

extension HostGameCodeViewController: UITextFieldDelegate {

}
