//
//  PlayerFrame2.swift
//  Game_Walker
//
//  Created by Noah Kim on 6/15/22.
//

import Foundation
import UIKit


class CreateOrJoinTeamViewController: UIViewController {
    
    @IBOutlet weak var creatTeamButton: UIButton!
    @IBOutlet weak var joinTeamButton: UIButton!
    
    private let audioPlayerManager = AudioPlayerManager()
    private let gameCode = UserData.readGamecode("gamecode") ?? ""

    private var soundEnabled: Bool = UserData.getUserSoundPreference() ?? true

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        configureSettings()
        configureBackButton()
        configureTitleLabel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        configureBtns()
    }

    private func configureSettings() {
        configureSettingBtn()
        NotificationCenter.default.addObserver(self, selector: #selector(applyChangedSettings), name: Notification.Name("SettingsChanged"), object: nil)
    }

    @objc private func applyChangedSettings(_ notification: Notification) {
            if let userInfo = notification.userInfo {
                if let settingsData = userInfo["settingsData"] as? (Bool, Bool) {
                    soundEnabled = settingsData.0
                }
            }
    }

    private func configureBtns(){
        creatTeamButton.backgroundColor = UIColor(red: 0.21, green: 0.67, blue: 0.95, alpha: 1)
        creatTeamButton.layer.cornerRadius = 8
        joinTeamButton.backgroundColor = UIColor(red: 0.21, green: 0.67, blue: 0.95, alpha: 1)
        joinTeamButton.layer.cornerRadius = 8
    }
    
    func configureNavItem() {
        self.navigationItem.hidesBackButton = true
        let backButtonImage = UIImage(named: "BackIcon")?.withRenderingMode(.alwaysTemplate)
        let newBackButton = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(back))
        newBackButton.tintColor = UIColor(red: 0.18, green: 0.18, blue: 0.21, alpha: 1)
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    @objc func back(sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToJoinGameVC", sender: self)
    }
    
    @IBAction func creatTeamButtonPressed(_ sender: UIButton) {
        if soundEnabled {
            self.audioPlayerManager.playAudioFile(named: "blue", withExtension: "wav")
        }
        performSegue(withIdentifier: "goToPF3_1VC", sender: self)
    }
    
    @IBAction func joinTeamButtonPressed(_ sender: UIButton) {
        if soundEnabled {
            self.audioPlayerManager.playAudioFile(named: "blue", withExtension: "wav")
        }
        performSegue(withIdentifier: "goToPF3_2VC", sender: self)
    }
    
    @IBAction func unwindToCorJ(_ segue: UIStoryboardSegue) {
        
    }
}
// MARK: - ModalViewProtocol
extension CreateOrJoinTeamViewController: ModalViewControllerDelegate {
    func modalViewControllerDidRequestPush() {
        pushTabBarController()
    }
    
    private func pushTabBarController() {
        let storyboard = UIStoryboard(name: "Host", bundle: nil)
        if let tabBarController = storyboard.instantiateViewController(withIdentifier: "HostTabBarController") as? UITabBarController {
            tabBarController.selectedIndex = 0
            navigationController?.pushViewController(tabBarController, animated: true)
        }
    }
}

