//
//  HostGameCodeViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 7/21/22.
//

import UIKit

class HostGameCodeViewController: BaseViewController {

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
        if storedgamecode!.isEmpty {
            alert(title: "No Input",message:"You never created a game!")
        } else {
            if (!usestoredcode) {
                Task { @MainActor in
                    do {
                        guard let hostTemp = try await H.getHost(gamecode ?? "") else {
                            gamecodeAlert("Gamecode is not Valid")
                            return
                        }
                        UserData.writeGamecode(gamecode!, "gamecode")
                        H.updateHost(_:_:)(gamecode!, hostTemp)
                        if hostTemp.gameStart {
                            performSegue(withIdentifier: "GameAlreadyStartedSegue", sender: self)
                        } else {
                            performSegue(withIdentifier: "HostJoinSegue", sender: self)
                        }

                    }
                }
            } else {
                Task { @MainActor in
                    do {
                        guard let hostTemp = try await H.getHost(gamecode ?? "") else {
                            gamecodeAlert("Gamecode is not Valid")
                            return
                        }
                        if hostTemp.gameStart {
                            performSegue(withIdentifier: "GameAlreadyStartedSegue", sender: self)
                        } else {
                            performSegue(withIdentifier: "HostJoinSegue", sender: self)
                        }
                    }
                }
            }
        }
    }
    
}

extension HostGameCodeViewController: UITextFieldDelegate {

}
