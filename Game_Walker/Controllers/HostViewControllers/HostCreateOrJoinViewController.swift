//
//  HostCreateOrJoinViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 7/22/22.
//

import UIKit

class HostCreateOrJoinViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    func listen(_ _ : [String : Any]){
    }
    

    @IBAction func createButtonPressed(_ sender: UIButton) {
        let gc = String(Int.random(in: 100000 ... 999999))
        let host = Host(gamecode: gc)
        H.createGame(gc, host)
        UserData.gamecode = gc
        UserData.writeGamecode(gc, "gamecodestring")
        
        

//        UserDefaults.standard.set(gc, forKey: "gamecodestring")
    }
    


}
