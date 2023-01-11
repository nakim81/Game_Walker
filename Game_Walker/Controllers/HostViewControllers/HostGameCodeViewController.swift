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
    
    // This will be the game code entered by the user.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        gameCodeInput.delegate = self
        gameCodeInput.textAlignment = NSTextAlignment.center
    }
    
    @IBAction func joinButtonPressed(_ sender: UIButton) {
        let tempgamecode = gameCodeInput.text!
        if (tempgamecode.isEmpty) {
            alert(title: "No Input",message:"You haven't entered a code!")
        } else {
            UserData.readGamecode("gamecodestring")
//            UserDefaults.standard.data(forKey: "gamecodestring")
            self.performSegue(withIdentifier: "HostJoinSegue", sender: self)
        }
    }
    
}

extension HostGameCodeViewController: UITextFieldDelegate {

}

