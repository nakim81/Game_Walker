//
//  PlayerFrame2.swift
//  Game_Walker
//
//  Created by Noah Kim on 6/15/22.
//

import Foundation
import UIKit


class CreateOrJoinTeamViewController: BaseViewController {
    
    @IBOutlet weak var creatTeamButton: UIButton!
    @IBOutlet weak var joinTeamButton: UIButton!
    
    private let audioPlayerManager = AudioPlayerManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavItem()
    }
    
    func configureNavItem() {
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(image: UIImage(named: "back button 1"), style: .plain, target: self, action: #selector(CreateOrJoinTeamViewController.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    @objc func back(sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToJoinGameVC", sender: self)
    }
    
    @IBAction func creatTeamButtonPressed(_ sender: UIButton) {
        self.audioPlayerManager.playAudioFile(named: "blue", withExtension: "wav")
        performSegue(withIdentifier: "goToPF3_1VC", sender: self)
    }
    
    @IBAction func joinTeamButtonPressed(_ sender: UIButton) {
        self.audioPlayerManager.playAudioFile(named: "blue", withExtension: "wav")
        performSegue(withIdentifier: "goToPF3_2VC", sender: self)
    }
}
