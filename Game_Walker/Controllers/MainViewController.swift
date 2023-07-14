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
//
//        let gc = "123456"
//        let host1 = Host(gamecode: gc)
//        var uuids: [String] = []
//
//        Task { @MainActor in
//            H.createGame(gc, host1)
//            for i in 1...8 {
//                let team = Team(gamecode: gc, name: "Team \(i)")
//                let uuid = UUID().uuidString
//                let ref = Referee(uuid: uuid, gamecode: gc, name: "Referee \(i)")
//                let station = Station(name: "Station \(i)", pvp: false, points: i*10, place: "Room \(i)", referee: ref, description: "Fun * \(i)")
//                await T.addTeam(gc, team)
//                try await R.addReferee(gc, ref, uuid)
//                await S.addStation(gc, station)
//                await H.addAnnouncement(gc, "Announcement \(i) \n This is announcement \(i)!")
//            }
//            for i in 1...64 {
//                let player = Player(gamecode: gc, name: "Player \(i)")
//                let uuid = UUID().uuidString
//                uuids.append(uuid)
//                try await P.addPlayer(gc, player, uuid)
//                let j = i%8 + 1
//                await T.joinTeam(gc, "Team \(j)", player)
//            }
//
//            for i in 0...63 {
//                P.removePlayer(gc, uuids[i])
//            }
//
//            do{
//                try await P.addPlayer("123456", Player(), UUID().uuidString)
//            } catch GamecodeError.invalidGamecode(let errorMessage) {
//                alert(title: "Invalid Gamecode", message: errorMessage)
//            }
//
//            do{
//                try await P.modifyName("123456", "asdfsaf", UUID().uuidString)
//            } catch GamecodeError.invalidGamecode(let errorMessage) {
//                alert(title: "Invalid Gamecode", message: errorMessage)
//            }
//
//            do{
//                try await R.addReferee("123456", Referee(), UUID().uuidString)
//            } catch GamecodeError.invalidGamecode(let errorMessage) {
//                alert(title: "Invalid Gamecode", message: errorMessage)
//            }
//
//            do{
//                try await R.modifyName("12326262", "dasfsdf", UUID().uuidString)
//            } catch GamecodeError.invalidGamecode(let errorMessage) {
//                alert(title: "Invalid Gamecode", message: errorMessage)
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


