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
    @IBOutlet weak var announcementButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    
    private var messages: [String] = []
    
    private var timer = Timer()
    private var seconds: Int = 0
    private var time: Int?
    private var isPaused = true
    
    private var gameCode: String = UserData.readGamecode("gamecode") ?? ""
    private var stationName: String = UserData.readTeam("team")?.currentStation ?? ""
    
    private var gameName: String?
    private var gameLocation: String?
    private var gamePoints: String?
    private var refereeName: String?
    private var gameRule: String?
    
    private var nextGameName: String?
    private var nextGameLocation: String?
    private var nextGamePoints: String?
    private var nextRefereeName: String?
    private var nextGameRule: String?
    
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
        H.delegates.append(self)
        H.listenHost(gameCode, onListenerUpdate: listen(_:))
        Task {
            try await Task.sleep(nanoseconds: 280_000_000)
            print(seconds)
            configureTimerLabel()
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let strongSelf = self else {
                return
            }
            if strongSelf.seconds < 1 {
                timer.invalidate()
            }
            if !strongSelf.isPaused {
                strongSelf.seconds -= 1
                let minute = strongSelf.seconds/60
                let second = strongSelf.seconds % 60
                strongSelf.timerLabel.text = String(format:"%02i : %02i", minute, second)
            }
        }
    }
    
    @IBAction func gameInfoButtonPressed(_ sender: UIButton) {
        showGameInfoPopUp(gameName: gameName, gameLocation: gameLocation, gamePoitns: gamePoints, refereeName: "Tetris GOAT Noah", gameRule: gameRule)
    }
    
    @IBAction func nextGameButtonPressed(_ sender: UIButton) {
//        showGameInfoPopUp(gameName: nextGameName, gameLocation: nextGameLocation, gamePoitns: nextGamePoints, refereeName: nextRefereeName, gameRule: nextGameRule)
    }
    
    @IBAction func announcementButtonPressed(_ sender: UIButton) {
        H.getHost(gameCode)
        showMessagePopUp(messages: messages)
    }
    
    @IBAction func settingButtonPressed(_ sender: UIButton) {
    }
    
    func configureTimerLabel(){
        self.view.addSubview(timerLabel)
        NSLayoutConstraint.activate([
            timerLabel.centerXAnchor.constraint(equalTo: self.view.layoutMarginsGuide.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor, constant: 200),
            timerLabel.widthAnchor.constraint(equalToConstant: 260),
            timerLabel.heightAnchor.constraint(equalToConstant: 260)
        ])
        let minute = seconds/60
        let second = seconds % 60
        timerLabel.text = String(format:"%02i : %02i", minute, second)
    }
    
    func listen(_ _ : [String : Any]){
    }
}
//MARK: - UIUpdate
extension TimerViewController: GetStation, HostUpdateListener {
    func updateHost(_ host: Host) {
        self.seconds = host.gameTime
        self.messages = host.announcements
        self.isPaused = host.paused
        let minute = seconds / 60
        let second = seconds % 60
        timerLabel.text = String(format:"%02i : %02i", minute, second)
    }
    
    func getStation(_ station: Station) {
        self.gameName = station.name
        self.gameLocation = station.place
        self.gamePoints = String(station.points)
        self.refereeName = ""
        self.gameRule = station.description
    }
    
}
