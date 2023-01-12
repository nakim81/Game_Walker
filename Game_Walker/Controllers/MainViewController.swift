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

class MainViewController: BaseViewController {
   
    @IBOutlet weak var playerButton: UIButton!
    @IBOutlet weak var refereeButton: UIButton!
    @IBOutlet weak var hostButton: UIButton!
    @IBOutlet weak var Test: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func TestPressed(_ sender: UIButton) {
        let newPlayerA = Player(gamecode: "371764", name: "A")
        let newPlayerB = Player(gamecode: "371764", name: "B")
        let newPlayerC = Player(gamecode: "371764", name: "C")
//        let newTeam = Team(name: "Team3", players: [newPlayer], points: 50, currentStation: "", nextStation: "", iconName: "iconBoy")
        P.addPlayer("371764", newPlayerA)
        P.addPlayer("371764", newPlayerB)
        P.addPlayer("371764", newPlayerC)
//        T.addTeam("371764", newTeam)
        T.joinTeam("371764", "Team1", newPlayerA)
        T.joinTeam("371764", "Team2", newPlayerB)
        T.joinTeam("371764", "Team3", newPlayerC)
        
        
    }
    
}


