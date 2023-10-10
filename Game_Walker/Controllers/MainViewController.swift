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
import AVFoundation

class MainViewController: BaseViewController {
   
    @IBOutlet weak var gameWalkerImage: UIImageView!
    @IBOutlet weak var playerButton: UIButton!
    @IBOutlet weak var refereeButton: UIButton!
    @IBOutlet weak var hostButton: UIButton!
    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var settingBtn: UIButton!
    @IBOutlet weak var testBtn: UIButton!
    
    private let audioPlayerManager = AudioPlayerManager()
    
    override func viewDidLoad() {
        if UserData.readUUID() == nil {
            UserData.writeUUID(UUID().uuidString)
        }
//        UserData.writeGamecode("111111", "gamecode")
//        UserDefaults.standard.removeObject(forKey: "team")
//        UserDefaults.standard.removeObject(forKey: "gamecode")
//        UserDefaults.standard.removeObject(forKey: "username")
//        for i in 1...4 {
//            let gc = "\(i)\(i)\(i)\(i)\(i)\(i)"
//            //let gc = "888888"
//
//            let host1 = Host(gamecode: "111111")
//
//           Task { @MainActor in
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
//                    let announcement = Announcement(uuid: UUID().uuidString, content: "Announcement\(i)", timestamp: getCurrentDateTime(), readStatus: false)
//                    try await H.addAnnouncement("111111", announcement)
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
//        var teams : Team?
//        Task {
//            teams = try await T.getTeam("333333", "Team 1")
//            print(teams)
//        }
        
        
        super.viewDidLoad()
        configureButtons()
        self.audioPlayerManager.playAudioFile(named: "bgm", withExtension: "wav")
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func configureButtons(){
        playerButton.layer.cornerRadius = 10
        playerButton.layer.borderWidth = 3
        playerButton.layer.borderColor = UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1).cgColor
        refereeButton.layer.cornerRadius = 10
        refereeButton.layer.borderWidth = 3
        refereeButton.layer.borderColor = UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 1).cgColor
        hostButton.layer.cornerRadius = 10
        hostButton.layer.borderWidth = 3
        hostButton.layer.borderColor = UIColor(red: 0.843, green: 0.502, blue: 0.976, alpha: 1).cgColor
        testBtn.layer.cornerRadius = 10
        testBtn.layer.borderWidth = 3
        testBtn.layer.borderColor = UIColor.systemBlue.cgColor
        settingBtn.tintColor = UIColor(red: 0.267, green: 0.659, blue: 0.906, alpha: 1)
    }
    
    @IBAction func playerBtnPressed(_ sender: Any) {
        self.audioPlayerManager.playAudioFile(named: "blue", withExtension: "wav")
        performSegue(withIdentifier: "goToPlayer", sender: self)
    }
    
    @IBAction func refereeBtnPressed(_ sender: Any) {
        self.audioPlayerManager.playAudioFile(named: "green", withExtension: "wav")
        performSegue(withIdentifier: "goToReferee", sender: self)
    }
    
    @IBAction func hostBtnPressed(_ sender: Any) {
        self.audioPlayerManager.playAudioFile(named: "purple", withExtension: "wav")
        performSegue(withIdentifier: "goToHost", sender: self)
    }
    
    @IBAction func testBtnPressed(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: "gamecode")
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "referee")
        UserDefaults.standard.removeObject(forKey: "player")
        UserDefaults.standard.removeObject(forKey: "team")
        UserData.writeUUID(UUID().uuidString)
        self.alert(title: "", message: "UUID: \(UserData.readUUID()), \(UserData.readPlayer("player")), \(UserData.readReferee("referee")), \(UserData.readReferee("referee")), \(UserData.readGamecode("gamecode")), \(UserData.readTeam("team"))")
        print(UserData.readUUID())
        print(UserData.readPlayer("player"))
        print(UserData.readReferee("referee"))
        print(UserData.readGamecode("gamecode"))
        print(UserData.readTeam("team"))
    }
    
    @IBAction func infoBtnPressed(_ sender: UIButton) {
        let componentPositions: [CGRect] = [playerButton.frame, refereeButton.frame, hostButton.frame, gameWalkerImage.frame]
        let layerList: [CALayer] = [playerButton.layer, refereeButton.layer, hostButton.layer]
        let explanationTexts = ["Join as a team member", "Allocate points and manage individual games", "Organize and oversee the entire event"]
        showOverlay(componentPositions, layerList, explanationTexts)
    }
    
    @IBAction func settingBtnPressed(_ sender: UIButton) {

    }
    
    private func showOverlay(_ componentList: [CGRect], _ layerList: [CALayer], _ explanationTexts: [String]){
        let overlayViewController = MainOverlayViewController()
        overlayViewController.modalPresentationStyle = .overFullScreen // Present it as overlay
        
        overlayViewController.configureGuide(componentList, layerList, explanationTexts)
        
        present(overlayViewController, animated: true, completion: nil)
    }
}


