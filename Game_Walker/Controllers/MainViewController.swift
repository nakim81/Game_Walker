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
        
//        for i in 1...4 {
//            let gc = "\(i)\(i)\(i)\(i)\(i)\(i)"
//            //let gc = "888888"
//
//            let host1 = Host(gamecode: gc)
//
//            Task { @MainActor in
//                H.createGame(gc, host1)
//                for i in 1...8 {
//                    let team = Team(gamecode: gc, name: "Team \(i)", number: i)
//                    let uuid = UUID().uuidString
//                    let uuid2 = UUID().uuidString
//                    let station = Station(uuid: uuid2, name: "Station \(i)", pvp: false, points: i*10, place: "Room \(i)", description: "Fun * \(i)")
//                    let ref = Referee(uuid: uuid, gamecode: gc, name: "Referee \(i)",stationName: station.name, assigned: true)
//                    await T.addTeam(gc, team)
//                    try await R.addReferee(gc, ref, uuid)
//                    await S.saveStation(gc, station)
//                    await S.assignReferee(gc, station, ref)
//                    await H.addAnnouncement(gc, "Announcement \(i) \n This is announcement \(i)!")
//                }
//                let uuid = UUID().uuidString
//                let ref2 = Referee(uuid: uuid, gamecode: gc, name: "Referee unassigned", assigned: false)
//                try await R.addReferee(gc, ref2, uuid)
//
//                for i in 1...64 {
//                    let player = Player(gamecode: gc, name: "Player \(i)")
//                    let uuid = UUID().uuidString
//                    try await P.addPlayer(gc, player, uuid)
//                    let j = i%8 + 1
//                    await T.joinTeam(gc, "Team \(j)", player)
//                }
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


