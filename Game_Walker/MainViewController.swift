//
//  ViewController.swift
//  Game_Walker
//
//  Created by Paul on 6/7/22.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift

class MainViewController: UIViewController {
    
    @IBOutlet weak var playerButton: UIButton!
    @IBOutlet weak var refereeButton: UIButton!
    @IBOutlet weak var hostButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        K.Database.delegates.append(self)
        K.Database.setupRequest(gamecode: "880027", player: Player(gamecode: "880027", name: "Player1"), request: .addPlayer)
        K.Database.setupRequest(gamecode: "880027", player: Player(gamecode: "880027", name: "Player2"), request: .addPlayer)

    }
    
    @IBAction func hostButtonPressed(_ sender: Any) {
    }
    
    func listen(_ _ : [String : Any]){
    }

}

//MARK: - UIUpdate
extension MainViewController: DataUpdateListener {
    func onDataUpdate(_ host: Host) {
        //host로 하고 싶은거 하셈
//        scoreLabel.text = host.score
//        nextPlaceLabel.text = host.nextPlaceLabel
        print("Gamecode: \(host.gamecode)")
        
    }
    
}

