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
    private let gameCode = UserData.readGamecode("gamecode") ?? ""
    
    private lazy var gameCodeLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 127, height: 42)
        let attributedText = NSMutableAttributedString()
        let gameCodeAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "GemunuLibre-Bold", size: 13) ?? UIFont.systemFont(ofSize: 13),
            .foregroundColor: UIColor.black
        ]
        let gameCodeAttributedString = NSAttributedString(string: "Game Code\n", attributes: gameCodeAttributes)
        attributedText.append(gameCodeAttributedString)
        let numberAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Bold", size: 20) ?? UIFont.systemFont(ofSize: 20),
            .foregroundColor: UIColor.black
        ]
        let numberAttributedString = NSAttributedString(string: gameCode, attributes: numberAttributes)
        attributedText.append(numberAttributedString)
        label.backgroundColor = .white
        label.attributedText = attributedText
        label.textColor = UIColor(red: 0, green: 0, blue: 0 , alpha: 1)
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = false
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavItem()
        configureGamecodeLabel()
        configureBtns()
    }
    
    private func configureBtns(){
        creatTeamButton.backgroundColor = UIColor(red: 0.21, green: 0.67, blue: 0.95, alpha: 1)
        creatTeamButton.layer.cornerRadius = 8
        joinTeamButton.backgroundColor = UIColor(red: 0.21, green: 0.67, blue: 0.95, alpha: 1)
        joinTeamButton.layer.cornerRadius = 8
    }
    
    private func configureGamecodeLabel() {
        view.addSubview(gameCodeLabel)
        NSLayoutConstraint.activate([
            gameCodeLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            gameCodeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: (self.navigationController?.navigationBar.frame.minY)!),
        ])
    }
    
    func configureNavItem() {
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(image: UIImage(named: "BackIcon"), style: .plain, target: self, action: #selector(back))
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
    @IBAction func testBtnPressed(_ sender: Any) {
        let startGameViewController = StartGameViewController(announcement: "Once the game is created, you won't be able to change the game settings", source: "", gamecode: gameCode)
        startGameViewController.delegate = self
        present(startGameViewController, animated: true)
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
