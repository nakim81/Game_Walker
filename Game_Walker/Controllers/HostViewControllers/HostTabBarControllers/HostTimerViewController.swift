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
    @IBOutlet weak var announcementBtn: UIButton!
    @IBOutlet weak var settingBtn: UIButton!
    private var messages: [String] = []
    
    private var timer = Timer()
    private var totalTime: Int = 0
    private var time: Int?
    private var seconds: Int = 0
    private var moveSeconds: Int = 0
    private var moving: Bool = true
    private var tapped: Bool = false
    private var round: Int = 1
    private var rounds: Int?
    private var isPaused = true
    private let play = UIImage(named: "Polygon 1")
    private let pause = UIImage(named: "Group 359")
    
    private var gameCode: String = UserData.readGamecode("gamecode") ?? ""
    
    private let timerCircle: UILabel = {
        var view = UILabel()
        view.clipsToBounds = true
        view.frame = CGRect(x: 0, y: 0, width: 256, height: 256)
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0.6
        view.layer.borderWidth = 15
        view.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        view.layer.cornerRadius = 130
        return view
    }()
    
    @objc func buttonTapped(_ gesture: UITapGestureRecognizer) {
        if !tapped {
            timerCircle.layer.borderColor = UIColor(red: 0.843, green: 0.502, blue: 0.976, alpha: 1).cgColor
            timerLabel.alpha = 0.0
            timeTypeLabel.alpha = 0.0
            roundLabel.alpha = 1.0
            totalTimeLabel.alpha = 1.0
            tapped = true
        } else {
            timerCircle.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
            timerLabel.alpha = 1.0
            timeTypeLabel.alpha = 1.0
            roundLabel.alpha = 0.0
            totalTimeLabel.alpha = 0.0
            tapped = false
        }
    }
    
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-Regular", size: 55)
        label.numberOfLines = 0
        return label
    }()
    
    private let timeTypeLabel: UILabel = {
        let label = UILabel()
        label.text = "Moving Time"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-Regular", size: 35)
        label.numberOfLines = 1
        return label
    }()
    
    private let roundLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-Regular", size: 35)
        label.numberOfLines = 1
        label.alpha = 0.0
        return label
    }()
    
    private let totalTimeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor(red: 0.843, green: 0.502, blue: 0.976, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.alpha = 0.0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        H.delegate_getHost = self
        H.getHost(gameCode)
        Task {
            try await Task.sleep(nanoseconds: 280_000_000)
            configureTimerLabel()
        }
    }
    
    @IBAction func announcementBtnPressed(_ sender: UIButton) {
        H.getHost(gameCode)
        showHostMessagePopUp(messages: messages)
    }

    @IBAction func settingBtnPressed(_ sender: UIButton) {
    }
    
    @IBAction func pauseOrPlayButtonPressed(_ sender: UIButton) {
        if isPaused {
            sender.setImage(pause, for: .normal)
            isPaused = false
            H.pause_resume_game(gameCode, isPaused)
        } else {
            sender.setImage(play, for: .normal)
            isPaused = true
            H.pause_resume_game(gameCode, isPaused)
        }
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let strongSelf = self else {
                return
            }
            if !strongSelf.isPaused {
                if strongSelf.rounds! < 1 {
                    timer.invalidate()
                }
                if strongSelf.time! < 1 {
                    if strongSelf.moving {
                        strongSelf.time = strongSelf.seconds
                        strongSelf.moving = false
                        strongSelf.timeTypeLabel.text = "Game Time"
                    } else {
                        strongSelf.time = strongSelf.moveSeconds
                        strongSelf.moving = true
                        strongSelf.timeTypeLabel.text = "Moving Time"
                        strongSelf.round += 1
                        strongSelf.roundLabel.text = "Round \(strongSelf.round)"
                    }
                }
                strongSelf.time! -= 1
                let minute = strongSelf.time!/60
                let second = strongSelf.time! % 60
                strongSelf.timerLabel.text = String(format:"%02i : %02i", minute, second)
                strongSelf.totalTime += 1
                let totalMinute = strongSelf.totalTime/60
                let totalSecond = strongSelf.totalTime % 60
                let attributedString = NSMutableAttributedString(string: "Total time\n", attributes: [NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: 20)])
                attributedString.append(NSAttributedString(string: String(format:"%02i : %02i", totalMinute, totalSecond), attributes: [NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: 15)]))
                strongSelf.totalTimeLabel.attributedText = attributedString
            }
        }
    }
    
    func configureTimerLabel(){
        self.view.addSubview(timerCircle)
        self.view.addSubview(timerLabel)
        self.view.addSubview(timeTypeLabel)
        self.view.addSubview(roundLabel)
        self.view.addSubview(totalTimeLabel)
        NSLayoutConstraint.activate([
            timerCircle.centerXAnchor.constraint(equalTo: self.view.layoutMarginsGuide.centerXAnchor),
            timerCircle.centerYAnchor.constraint(equalTo: self.view.layoutMarginsGuide.centerYAnchor, constant: -120),
            timerCircle.widthAnchor.constraint(equalToConstant: 260),
            timerCircle.heightAnchor.constraint(equalToConstant: 260),
            timerLabel.centerXAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.centerYAnchor, constant: 45),
            timerLabel.widthAnchor.constraint(equalToConstant: 179),
            timerLabel.heightAnchor.constraint(equalToConstant: 93),
            timeTypeLabel.centerXAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.centerXAnchor),
            timeTypeLabel.centerYAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.centerYAnchor, constant: -50),
            timeTypeLabel.widthAnchor.constraint(equalToConstant: 168),
            timeTypeLabel.heightAnchor.constraint(equalToConstant: 44),
            roundLabel.centerXAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.centerXAnchor),
            roundLabel.centerYAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.centerYAnchor, constant: -50),
            roundLabel.widthAnchor.constraint(equalToConstant: 155),
            roundLabel.heightAnchor.constraint(equalToConstant: 44),
            totalTimeLabel.centerXAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.centerXAnchor),
            totalTimeLabel.centerYAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.centerYAnchor, constant: 40),
            totalTimeLabel.widthAnchor.constraint(equalToConstant: 98),
            totalTimeLabel.heightAnchor.constraint(equalToConstant: 49)
        ])
        let minute = moveSeconds/60
        let second = moveSeconds % 60
        timerLabel.text = String(format:"%02i : %02i", minute, second)
        roundLabel.text = "Round \(round)"
        let totalMinute = totalTime/60
        let totalSecond = totalTime % 60
        let attributedString = NSMutableAttributedString(string: "Total time\n", attributes: [NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: 20)])
        attributedString.append(NSAttributedString(string: String(format:"%02i : %02i", totalMinute, totalSecond), attributes: [NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: 15)]))
        totalTimeLabel.attributedText = attributedString
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonTapped))
        timerCircle.addGestureRecognizer(tapGesture)
        timerCircle.isUserInteractionEnabled = true
        runTimer()
    }
}
//MARK: - UIUpdate
extension HostTimerViewController: GetHost {
    func getHost(_ host: Host) {
        self.time = host.movingTime
        self.seconds = host.gameTime
        self.moveSeconds = host.movingTime
        self.rounds = host.rounds
        self.messages = host.announcements
    }
}
