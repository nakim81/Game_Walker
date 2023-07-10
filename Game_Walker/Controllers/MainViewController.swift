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
    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var settingBtn: UIButton!
    
    override func viewDidLoad() {
        if UserData.readUUID() == nil {
            UserData.writeUUID(UUID().uuidString)
        }
      //  UserData.writeUUID(UUID().uuidString)
        
        let gc = "281063"
        let player1 = Player(gamecode: gc, name: "Player 1")
        let player2 = Player(gamecode: gc, name: "Player 2")
        let player3 = Player(gamecode: gc, name: "Player 3")
        let team1 = Team(gamecode: gc, name: "Team1", number: 1, players: [], points: 10, currentStation: "", nextStation: "", iconName: "")
        let team2 = Team(gamecode: gc, name: "Team2", number: 2, players: [], points: 20, currentStation: "", nextStation: "", iconName: "")
        let team3 = Team(gamecode: gc, name: "Team3", number: 3, players: [], points: 30, currentStation: "", nextStation: "", iconName: "")
        
        Task { @MainActor in
            try await P.addPlayer(gc, player1, UUID().uuidString)
            try await P.addPlayer(gc, player2, UUID().uuidString)
            try await P.addPlayer(gc, player3, UUID().uuidString)
            try await T.addTeam(gc, team1)
            try await T.addTeam(gc, team2)
            try await T.addTeam(gc, team3)
            try await T.joinTeam(gc, "Team1", player1)
            try await T.joinTeam(gc, "Team2", player2)
            try await T.joinTeam(gc, "Team3", player3)
        }
        super.viewDidLoad()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func infoBtnPressed(_ sender: UIButton) {
        showInfoPopUp()
    }
    
    @IBAction func settingBtnPressed(_ sender: UIButton) {

    }
    
    
}


