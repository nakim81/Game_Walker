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
        if storedgamecode!.isEmpty {
            alert(title: "No Input",message:"You never created a game!")
        } else {
            if (!usestoredcode) {
                Task { @MainActor in
                    do {
                        let hostTemp = try await H.getHost(gamecode ?? "")
                        UserData.writeGamecode(gamecode!, "gamecode")
                        H.updateHost(_:_:)(gamecode!, hostTemp!)
                        

                        performSegue(withIdentifier: "goToPF2VC", sender: self)

                    } catch (let e) {
                        print(e)
                        gamecodeAlert("Gamecode is not Valid")
                        return
                    }
//                    performSegue(withIdentifier: "goToPF2VC", sender: self)
                }
            }

        }
    }
    
}

extension HostGameCodeViewController: UITextFieldDelegate {

}
