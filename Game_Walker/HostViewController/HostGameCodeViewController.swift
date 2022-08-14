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
    var gamecode = "";
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        gameCodeInput.delegate = self
    }
    
    @IBAction func joinButtonPressed(_ sender: UIButton) {
        let tempgamecode = gameCodeInput.text!
        if (gamecode.isEmpty) {
            alert(title: "No Input",message:"You haven't entered a code!")
        } else {
            K.gamecode = tempgamecode
            K.Database.readHost(gamecode: K.gamecode, onListenerUpdate: listen(_:))
            
        }
    }
    
}

extension HostGameCodeViewController: UITextFieldDelegate {

}

extension HostGameCodeViewController: DataUpdateListener {
    func onDataUpdate(_ host: Host) {
    }
}

func listen(_ _ : [String : Any]){
}
