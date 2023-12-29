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
import SwiftUI

class MainViewController: UIViewController {
   
    @IBOutlet weak var gameWalkerImage: UIImageView!
    @IBOutlet weak var playerButton: UIButton!
    @IBOutlet weak var refereeButton: UIButton!
    @IBOutlet weak var hostButton: UIButton!
    @IBOutlet weak var testBtn: UIButton!
    
    private let audioPlayerManager = AudioPlayerManager()
    
    override func viewDidLoad() {
        if UserData.readUUID() == nil {
            UserData.writeUUID(UUID().uuidString)
        }
        if UserData.isHostConfirmed() == nil || UserData.isHostConfirmed() == false {
            UserData.confirmHost(false)
        }
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        configureNavBarItems()
        configureButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.audioPlayerManager.playAudioFile(named: "bgm", withExtension: "wav")
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
        UserDefaults.standard.removeObject(forKey: "standardstyle")
        UserData.writeUUID(UUID().uuidString)
        self.alert(title: "", message: "UUID: \(UserData.readUUID()), \(UserData.readPlayer("player")), \(UserData.readReferee("referee")), \(UserData.readReferee("referee")), \(UserData.readGamecode("gamecode")), \(UserData.readTeam("team"))")
        print(UserData.readUUID())
        print(UserData.readPlayer("player"))
        print(UserData.readReferee("referee"))
        print(UserData.readGamecode("gamecode"))
        print(UserData.readTeam("team"))
    }
    
    private func configureNavBarItems() {
        print("configuring nav bar items")
        
        let settingImage = UIImage(named: "settingIcon")
        let settingBtn = UIButton()
        settingBtn.setImage(settingImage, for: .normal)
        settingBtn.addTarget(self, action: #selector(settingApp), for: .touchUpInside)
        let setting = UIBarButtonItem(customView: settingBtn)
        
        let spacer = createSpacer()
        
        let infoImage = UIImage(named: "infoIcon")
        let infoBtn = UIButton()
        infoBtn.setImage(infoImage, for: .normal)
        infoBtn.addTarget(self, action: #selector(guide), for: .touchUpInside)
        let info = UIBarButtonItem(customView: infoBtn)

        self.navigationItem.rightBarButtonItems = [setting, spacer, info]
    }
    
    @objc func guide() {
        let componentPositions: [CGRect] = [playerButton.frame, refereeButton.frame, hostButton.frame, gameWalkerImage.frame]
        let layerList: [CALayer] = [playerButton.layer, refereeButton.layer, hostButton.layer]
        let explanationTexts = ["Join as a team member", "Allocate points and manage individual games", "Organize and oversee the entire event"]
        
        let overlayViewController = MainOverlayViewController()
        overlayViewController.modalPresentationStyle = .overFullScreen // Present it as overlay
        overlayViewController.configureGuide(componentPositions, layerList, explanationTexts)
        
        present(overlayViewController, animated: true, completion: nil)
    }
}


