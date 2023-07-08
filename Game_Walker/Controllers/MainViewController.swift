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
        
//        let gc = "999999"
//        let host1 = Host(gamecode: gc)
//
//        Task { @MainActor in
//            try await H.createGame(gc, host1)
//            for i in 1...8 {
//                let team = Team(gamecode: gc, name: "Team \(i)")
//                let uuid = UUID().uuidString
//                let ref = Referee(uuid: uuid, gamecode: gc, name: "Referee \(i)")
//                let station = Station(name: "Station \(i)", pvp: false, points: i*10, place: "Room \(i)", referee: ref, description: "Fun * \(i)")
//                try await T.addTeam(gc, team)
//                try await R.addReferee(gc, ref, uuid)
//                try await S.addStation(gc, station)
//                try await H.addAnnouncement(gc, "Announcement \(i) \n This is announcement \(i)!")
//            }
//            for i in 1...64 {
//                let player = Player(gamecode: gc, name: "Player \(i)")
//                try await P.addPlayer(gc, player, UUID().uuidString)
//                let j = i%8 + 1
//                try await T.joinTeam(gc, "Team \(j)", player)
//            }
//        }

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


