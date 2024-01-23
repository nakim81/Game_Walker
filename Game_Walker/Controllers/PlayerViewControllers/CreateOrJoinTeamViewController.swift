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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        configureSimpleNavBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        configureBtns()
    }

    private func configureBtns(){
        creatTeamButton.backgroundColor = UIColor(red: 0.21, green: 0.67, blue: 0.95, alpha: 1)
        creatTeamButton.layer.cornerRadius = 8
        joinTeamButton.backgroundColor = UIColor(red: 0.21, green: 0.67, blue: 0.95, alpha: 1)
        joinTeamButton.layer.cornerRadius = 8
    }
    
    @IBAction func creatTeamButtonPressed(_ sender: UIButton) {
        self.audioPlayerManager.playAudioFile(named: "blue", withExtension: "wav")
        performSegue(withIdentifier: "goToPF3_1VC", sender: self)
    }
    
    @IBAction func joinTeamButtonPressed(_ sender: UIButton) {
        self.audioPlayerManager.playAudioFile(named: "blue", withExtension: "wav")
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
