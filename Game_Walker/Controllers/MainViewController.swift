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
    
    private let audioPlayerManager = AudioPlayerManager()
    private var soundEnabled : Bool = UserData.getUserSoundPreference() ?? true

    override func viewDidLoad() {
        if UserData.readUUID() == nil {
            UserData.writeUUID(UUID().uuidString)
        }
        if UserData.isHostConfirmed() == nil || UserData.isHostConfirmed() == false {
            UserData.confirmHost(false)
        }
        if UserData.getUserSoundPreference() == nil {
            UserData.setUserSoundPreference(true)
            soundEnabled = true
        }
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        configureNavButtons()
        configureButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if soundEnabled {
            self.audioPlayerManager.playAudioFile(named: "bgm", withExtension: "wav")
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        if self.audioPlayerManager.isPlaying() {
            self.audioPlayerManager.stop()
        }
    }

    private func configureButtons(){
        playerButton.layer.cornerRadius = 10
        playerButton.layer.borderWidth = 3
        playerButton.layer.borderColor = UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1).cgColor
        if let originalFont = playerButton.titleLabel?.font {
            playerButton.titleLabel?.font = getFontForLanguage(font: originalFont.fontName, size: originalFont.pointSize)
        }
        
        refereeButton.layer.cornerRadius = 10
        refereeButton.layer.borderWidth = 3
        refereeButton.layer.borderColor = UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 1).cgColor
        if let originalFont = refereeButton.titleLabel?.font {
            refereeButton.titleLabel?.font = getFontForLanguage(font: originalFont.fontName, size: originalFont.pointSize)
        }

        
        hostButton.layer.cornerRadius = 10
        hostButton.layer.borderWidth = 3
        hostButton.layer.borderColor = UIColor(red: 0.843, green: 0.502, blue: 0.976, alpha: 1).cgColor
        if let originalFont = hostButton.titleLabel?.font {
            hostButton.titleLabel?.font = getFontForLanguage(font: originalFont.fontName, size: originalFont.pointSize)
        }
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

    private func configureNavButtons() {
        let infoImage = UIImage(named: "infoIcon")
        let infoBtn = UIButton()
        infoBtn.setImage(infoImage, for: .normal)
        infoBtn.addTarget(self, action: #selector(guide), for: .touchUpInside)
        let info = UIBarButtonItem(customView: infoBtn)

        let soundImage = UIImage(named: "sound-icon-on")
        let soundImageOff = UIImage(named: "sound-icon-off")
        let soundButton = UIButton()
        if soundEnabled {
            soundButton.setImage(soundImage, for: .normal)
        } else {
            soundButton.setImage(soundImageOff, for: .normal)
        }
        soundButton.addTarget(self, action: #selector(soundButtonTapped), for: .touchUpInside)
        let sound = UIBarButtonItem(customView: soundButton)
        self.navigationItem.rightBarButtonItems = [info, sound]
    }


    @objc func soundButtonTapped(_ sender: UIButton) {
        soundEnabled = !soundEnabled
        UserData.setUserSoundPreference(soundEnabled)
        if !soundEnabled{
            sender.setImage(UIImage(named: "sound-icon-off"), for: .normal)
            if audioPlayerManager.isPlaying() {
                self.audioPlayerManager.stop()
            }
        } else {
            sender.setImage(UIImage(named: "sound-icon-on"), for: .normal)
            if !audioPlayerManager.isPlaying() {
                self.audioPlayerManager.playAudioFile(named: "bgm", withExtension: "wav")
            }
        }
    }

    @objc func guide() {
        let componentPositions: [CGRect] = [playerButton.frame, refereeButton.frame, hostButton.frame, gameWalkerImage.frame]
        let layerList: [CALayer] = [playerButton.layer, refereeButton.layer, hostButton.layer]
        let explanationTexts = [
            NSLocalizedString("Join as a Team Member", comment: ""),
            NSLocalizedString("Allocate points and manage individual Stations", comment: ""),
            NSLocalizedString("Organize and oversee the entire Game Event", comment: "")
        ]

        let overlayViewController = MainOverlayViewController()
        overlayViewController.modalPresentationStyle = .overFullScreen // Present it as overlay
        overlayViewController.configureGuide(componentPositions, layerList, explanationTexts)
        
        present(overlayViewController, animated: true, completion: nil)
    }
}
