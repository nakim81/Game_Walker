//
//  PlayerFrame4_3.swift
//  Game_Walker
//
//  Created by Noah Kim on 6/17/22.
//

import Foundation
import UIKit

class TimerViewController: UIViewController {
    
    @IBOutlet weak var gameInfoButton: UIButton!
    @IBOutlet weak var nextGameButton: UIButton!
    private var timer: Timer?
    private var seconds = 3600
    private var time = 0
    
    private var gameCode: String = UserData.readGamecode("gamecode") ?? ""
    private var stationName: String = UserData.readTeam("team")?.currentStation ?? ""
    
    private var gameName: String?
    private var gameLocation: String?
    private var gamePoints: String?
    private var refereeName: String?
    private var gameRule: String?
    
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.clipsToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-Regular", size: 55)
        label.numberOfLines = 0
        label.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        label.layer.borderWidth = 4
        label.layer.cornerRadius = 130
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        S.delegate_getStation = self
        S.getStation(gameCode, stationName)
        H.delegate_getHost = self
        H.getHost(gameCode)
        configureTimerLabel()
        runTimer()
    }
    
    @IBAction func gameInfoButtonPressed(_ sender: UIButton) {
        showPopUp("Tetris", "Noah's Macbook Air", "100", "Tetris GOAT Noah", "Try your best to beat Tetris GOAT Noah")
    }
    
    @IBAction func nextGameButtonPressed(_ sender: UIButton) {
        
    }
    
    func configureTimerLabel(){
        self.view.addSubview(timerLabel)
        NSLayoutConstraint.activate([
            timerLabel.centerXAnchor.constraint(equalTo: self.view.layoutMarginsGuide.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor, constant: 200),
            timerLabel.widthAnchor.constraint(equalToConstant: 260),
            timerLabel.heightAnchor.constraint(equalToConstant: 260)
        ])
        timerLabel.text = "00 : 00"
    }
    
    func runTimer() {
           timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(TimerViewController.updateTimer)), userInfo: nil, repeats: true)
    }
       
    @objc func updateTimer() {
        if seconds < 1 {
           self.timer?.invalidate()
        } else {
           seconds -= 1
           timerLabel.text = timeString(time: TimeInterval(seconds))
        }
    }
   
   func timeString(time:TimeInterval) -> String {
           let minutes = Int(time) / 60 % 60
           let seconds = Int(time) % 60
           return String(format:"%02i : %02i", minutes, seconds)
   }
    
}
//MARK: - UIUpdate
extension TimerViewController: GetHost, GetStation {
    func getHost(_ host: Host) {
        print(host.gameTime)
        self.seconds = host.gameTime
    }
    
    func getStation(_ station: Station) {
        self.gameName = station.name
        self.gameLocation = station.place
        self.gamePoints = String(station.points)
        self.refereeName = ""
        self.gameRule = station.description
    }
}
// MARK: - PopUpScreen
extension UIViewController {
    func showPopUp(_ gameName: String? = nil, _ gameLocation: String? = nil, _ gamePoitns: String? = nil, _ refereeName: String? = nil, _ gameRule: String? = nil, _ actionTitle: String = "Close", _ actionCompletion: (() -> Void)? = nil) {
        let popUpViewController = GameInfoViewController(gameName: gameName ?? "", gameLocation: gameLocation ?? "", gamePoints: gamePoitns ?? "", refereeName: refereeName ?? "", gameRule: gameRule ?? "")
        showPopUp(popUpViewController: popUpViewController, actionTitle: actionTitle, actionCompletion: actionCompletion)
    }
    
    private func showPopUp(popUpViewController: GameInfoViewController, actionTitle: String, actionCompletion: (() -> Void)?) {
        popUpViewController.addActionToButton(title: actionTitle, titleColor: .systemGray, backgroundColor: .secondarySystemBackground) {
            popUpViewController.dismiss(animated: false, completion: actionCompletion)
        }
        present(popUpViewController, animated: false, completion: nil)
    }
}
