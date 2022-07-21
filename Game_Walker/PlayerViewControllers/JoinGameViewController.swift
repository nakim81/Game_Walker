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
        
        // Do any additional setup after loading the view.
        K.Database.delegates.append(self)
        gamecodeTextField.delegate = self
        usernameTextField.delegate = self
    }
    

    @IBAction func nextButtonPressed(_ sender: UIButton) {
        
        gamecodeTextField.resignFirstResponder()
        usernameTextField.resignFirstResponder()

        if let gamecode: String = gamecodeTextField.text, let username: String = usernameTextField.text, !gamecode.isEmpty, !username.isEmpty {
            K.Database.readHost(gamecode: gamecode, onListenerUpdate: listen(_:))
            let newPlayer = Player(gamecode: gamecode, name: username)
            UserData.player = newPlayer
            K.Database.setupRequest(gamecode: newPlayer.gamecode, player: newPlayer, referee: nil, team: nil, station: nil, gameTime: nil, movingTime: nil, rounds: nil, request: .addPlayer)

            performSegue(withIdentifier: "goToPF2VC", sender: self)
        } else {
            alert(title: "Woops", message: "Please enter all information to log in")
        }        
    }
    
    func listen(_ _ : [String : Any]){
    }


}

//MARK: - UIUpdate
extension JoinGameViewController: DataUpdateListener {
    func onDataUpdate(_ host: Host) {
        //host로 하고 싶은거 하셈
//        scoreLabel.text = host.score
//        nextPlaceLabel.text = host.nextPlaceLabel
        print("Size of Players \(host.players.count)")
        
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

