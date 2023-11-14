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

        if (gameCodeText != storedgamecode && gameCodeText != "") {
            gamecode = gameCodeText
            usestoredcode = false
        } else {
            gamecode = storedgamecode
            usestoredcode = true
        }
    }
    
    @IBAction func joinButtonPressed(_ sender: UIButton) {
        setGameCode()
        //FIX:- need to fix this logic
        guard let userGamecodeInput = gameCodeInput.text else {
            return
        }
        if storedgamecode!.isEmpty && userGamecodeInput.isEmpty {
            alert(title: "No Input",message:"You never created a game!")
        } else {
            if (!usestoredcode) {
                Task { @MainActor in
                    do {
                        let hostTemp = try await H.getHost(userGamecodeInput)
                        let isStandard = hostTemp?.standardStyle ?? true
                        
                        if !isStandard {
                            UserData.writeGamecode(userGamecodeInput, "gamecode")
                            H.updateHost(_:_:)(userGamecodeInput, hostTemp!)
                            performSegue(withIdentifier: "GameAlreadyStartedSegue", sender: self)
                            return
                        }
                        
                        if !(hostTemp?.confirmCreated ?? true) {
                            UserData.writeGamecode(userGamecodeInput, "gamecode")
                            H.updateHost(_:_:)(userGamecodeInput, hostTemp!)
                            performSegue(withIdentifier: "HostJoinSegue", sender: self)
                            
                        } else {
                            if UserData.isHostConfirmed() ?? false {
                                UserData.writeGamecode(userGamecodeInput, "gamecode")
                                H.updateHost(_:_:)(userGamecodeInput, hostTemp!)
                                performSegue(withIdentifier: "GameAlreadyStartedSegue", sender: self)
                            } else{
                                alert(title: "", message: "Invalid Host!")
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
                        
                        if !isStandard {
                            UserData.writeGamecode(userGamecodeInput, "gamecode")
                            H.updateHost(_:_:)(userGamecodeInput, hostTemp!)
                            performSegue(withIdentifier: "GameAlreadyStartedSegue", sender: self)
                            return
                        }
                        if !(hostTemp?.confirmCreated ?? true) {
                            performSegue(withIdentifier: "HostJoinSegue", sender: self)
                        } else {
                            if UserData.isHostConfirmed() ?? false {
                                performSegue(withIdentifier: "GameAlreadyStartedSegue", sender: self)
                            } else{
                                print("userdata host confirmed: ", UserData.isHostConfirmed())
                                alert(title: "", message: "Invalid Host!")
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
