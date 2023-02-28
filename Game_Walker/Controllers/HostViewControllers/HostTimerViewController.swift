//
//  HostTimerViewController.swift
//  Game_Walker
//
//  Created by Noah Kim on 2/1/23.
//

import Foundation
import UIKit

class HostTimerViewController: UIViewController {
    
    @IBOutlet weak var pauseOrPlayButton: UIButton!
    private var messages: [String] = []
    
    private var timer = Timer()
    private var seconds: Int = 0
    private var moveSeconds: Int = 0
    private var rounds: Int?
    private var isPaused = true
    private let play = UIImage(named: "Polygon 1")
    private let pause = UIImage(named: "Group 359")
    
    private var gameCode: String = UserData.readGamecode("gamecode") ?? ""
    
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
        H.delegate_getHost = self
        H.getHost(gameCode)
        Task {
            try await Task.sleep(nanoseconds: 280_000_000)
            print(seconds)
            configureTimerLabel()
        }
    }
    
    @IBAction func pauseOrPlayButtonPressed(_ sender: UIButton) {
        if isPaused {
            sender.setImage(pause, for: .normal)
            isPaused = false
            H.pause_resume_Game(gameCode)
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
        } else {
            sender.setImage(play, for: .normal)
            timer.invalidate()
            isPaused = true
            H.pause_resume_Game(gameCode)
//            H.setTimer(gameCode, seconds, moveSeconds, rounds ?? 0)
        }
    }
    func configureTimerLabel(){
        self.view.addSubview(timerLabel)
        NSLayoutConstraint.activate([
            timerLabel.centerXAnchor.constraint(equalTo: self.view.layoutMarginsGuide.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: self.view.layoutMarginsGuide.centerYAnchor, constant: -120),
            timerLabel.widthAnchor.constraint(equalToConstant: 260),
            timerLabel.heightAnchor.constraint(equalToConstant: 260)
        ])
        let minute = seconds/60
        let second = seconds % 60
        timerLabel.text = String(format:"%02i : %02i", minute, second)
    }
}
//MARK: - UIUpdate
extension HostTimerViewController: GetHost {
    func getHost(_ host: Host) {
        self.seconds = host.gameTime
        self.moveSeconds = host.movingTime
        self.rounds = host.rounds
    }
}
