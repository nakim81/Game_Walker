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
    
    var host : Host?
    
    // This will be the game code entered by the user.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        gameCodeInput.delegate = self
        gameCodeInput.textAlignment = NSTextAlignment.center
        gameCodeInput.keyboardType = .asciiCapableNumberPad
        H.delegate_getHost = self
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func joinButtonPressed(_ sender: UIButton) {
//        let tempgamecode = gameCodeInput.text!
        let tempgamecode = UserData.readGamecode("gamecodestring")

        if tempgamecode!.isEmpty {
            alert(title: "No Input",message:"You haven't entered a code!")
        } else {
            H.getHost(tempgamecode!)
            self.performSegue(withIdentifier: "HostJoinSegue", sender: self)
        }
    }
    
}

extension HostGameCodeViewController: UITextFieldDelegate {

}

extension HostGameCodeViewController: GetHost {
    func getHost(_ host: Host) {
        self.host = host
        print("host protocol: could get host")
    }
}
