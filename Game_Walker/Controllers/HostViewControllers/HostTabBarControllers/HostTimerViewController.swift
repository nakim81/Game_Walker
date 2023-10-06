////
////  HostTimerViewController.swift
////  Game_Walker
////
////  Created by Noah Kim on 2/1/23.


import Foundation
import UIKit
import AVFoundation

class HostTimerViewController: UIViewController {
    
    @IBOutlet weak var pauseOrPlayButton: UIButton!
    @IBOutlet weak var announcementBtn: UIButton!
    @IBOutlet weak var settingBtn: UIButton!
    @IBOutlet weak var infoBtn: UIButton!
    
    @IBOutlet weak var endGameBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    private var host : Host = Host()
    private var startTime : Int = 0
    private var pauseTime : Int = 0
    private var pausedTime : Int = 0
    private var timer = Timer()
    private var remainingTime: Int = 0
    private var totalTime: Int = 0
    private var time: Int?
    private var seconds: Int = 0
    private var moveSeconds: Int = 0
    private var moving: Bool = true
    private var tapped: Bool = false
    private var round: Int = 1
    private var rounds: Int?
    private var isPaused = true
    private var t : Int = 0
    
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let audioPlayerManager = AudioPlayerManager()
    private let play = UIImage(named: "Polygon 1")
    private let pause = UIImage(named: "Group 359")
    private let end = UIImage(named: "Game End Button")
    
    private var gameCode: String = UserData.readGamecode("gamecode") ?? ""
    private var gameStart : Bool = false
    private var gameOver : Bool = false
    private var segueCalled : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            titleLabel.font = UIFont(name: "GemunuLibre-SemiBold", size: 50)
            callProtocols()
            host = try await H.getHost(gameCode) ?? Host()
            setSettings()
            configureTimerLabel()
        }
    }
    
    @IBAction func announcementBtnPressed(_ sender: UIButton) {
        // Testing Case for Resetting Time DB
        if timer.isValid {
            timer.invalidate()
        }
        Task {
            do {
                try await H.startGame(gameCode)
            } catch GameWalkerError.serverError(let text){
                print(text)
                serverAlert(text)
                return
            }
            do {
                try await H.pause_resume_game(gameCode)
            } catch GameWalkerError.serverError(let text){
                print(text)
                serverAlert(text)
                return
            }
            do {
                try await H.updatePausedTime(gameCode, 0)
            } catch GameWalkerError.serverError(let text){
                print(text)
                serverAlert(text)
                return
            }
            do {
                try await H.updateCurrentRound(gameCode, 1)
            } catch GameWalkerError.serverError(let text){
                print(text)
                serverAlert(text)
                return
            }
            pauseOrPlayButton.isHidden = false
            pauseOrPlayButton.setImage(UIImage(named: "GameStartButton"), for: .normal)
            calculateTime()
        }
        showHostMessagePopUp(messages: HostRankingViewcontroller.messages)
    }

    @IBAction func settingBtnPressed(_ sender: UIButton) {
    }
    
    @IBAction func infoBtnPressed(_ sender: UIButton) {
        showOverlay()
    }
    
    @IBAction func endBtnPressed(_ sender: Any) {
        showEndGamePopUp(announcement: "Do you really want to end this game?", source: "", gamecode: gameCode)
    }
    
    @IBAction func pauseOrPlayButtonPressed(_ sender: UIButton) {
        if !gameStart {
            Task { @MainActor in
                do {
                    try await H.startGame(gameCode)
                } catch GameWalkerError.serverError(let text){
                    print(text)
                    serverAlert(text)
                    return
                }
                sender.setImage(pause, for: .normal)
                isPaused = !isPaused
                do {
                    try await H.pause_resume_game(gameCode)
                } catch GameWalkerError.serverError(let text){
                    print(text)
                    serverAlert(text)
                    return
                }
            }
        }
        else {
            if isPaused {
                sender.setImage(pause, for: .normal)
            }
            else {
                sender.setImage(play, for: .normal)
            }
            isPaused = !isPaused
            Task { @MainActor in
                do {
                    try await H.pause_resume_game(gameCode)
                } catch GameWalkerError.serverError(let text){
                    print(text)
                    serverAlert(text)
                    return
                }
            }
        }
    }
    
    private func showOverlay() {
        let overlayViewController = OverlayViewController()
        overlayViewController.modalPresentationStyle = .overFullScreen // Present it as overlay
        
        let explanationTexts = ["Check to see what happens when you click this circle", "Ranking", "Timer"]
        var componentPositions: [CGPoint] = []
        let component1Frame = timerCircle.frame
        componentPositions.append(CGPoint(x: component1Frame.midX, y: component1Frame.midY))
        var tabBarTop: CGFloat = 0
        if let tabBarController = self.tabBarController {
            // Loop through each view controller in the tab bar controller
            for viewController in tabBarController.viewControllers ?? [] {
                if let tabItem = viewController.tabBarItem {
                    // Access the tab bar item of the current view controller
                    if let tabItemView = tabItem.value(forKey: "view") as? UIView {
                        let tabItemFrame = tabItemView.frame
                        // Calculate centerX position
                        let centerXPosition = tabItemFrame.midX
                        // Calculate topAnchor position based on tab bar's frame
                        let tabBarFrame = tabBarController.tabBar.frame
                        let topAnchorPosition = tabItemFrame.minY + tabBarFrame.origin.y
                        if (tabBarTop == 0) {
                            tabBarTop = topAnchorPosition
                        }
                        componentPositions.append(CGPoint(x: centerXPosition, y: topAnchorPosition))
                    }
                }
            }
        }
        print(componentPositions)
        overlayViewController.showExplanationLabels(explanationTexts: explanationTexts, componentPositions: componentPositions, numberOfLabels: 3, tabBarTop: tabBarTop)
        
        present(overlayViewController, animated: true, completion: nil)
    }

    //MARK: - UI Timer Elements
    private lazy var gameCodeLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 127, height: 42)
        let attributedText = NSMutableAttributedString()
        let gameCodeAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Bold", size: 13) ?? UIFont.systemFont(ofSize: 13),
            .foregroundColor: UIColor.black
        ]
        let gameCodeAttributedString = NSAttributedString(string: "Game Code\n", attributes: gameCodeAttributes)
        attributedText.append(gameCodeAttributedString)
        let numberAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Bold", size: 20) ?? UIFont.systemFont(ofSize : 20),
            .foregroundColor: UIColor.black
        ]
        let numberAttributedString = NSAttributedString(string: gameCode, attributes: numberAttributes)
        attributedText.append(numberAttributedString)
        label.backgroundColor = .white
        label.attributedText = attributedText
        label.textColor = UIColor(red: 0, green: 0, blue: 0 , alpha: 1)
        label.numberOfLines = 2
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        return label
    }()
    
    private let timerCircle: UILabel = {
        var view = UILabel()
        view.clipsToBounds = true
        view.frame = CGRect(x: 0, y: 0, width: 256, height: 256)
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0.6
        view.layer.borderWidth = 15
        view.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        view.layer.cornerRadius = 0.68 * UIScreen.main.bounds.size.width / 2.0
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
    
    func configureTimerLabel(){
//        self.view.addSubview(gameCodeLabel)
        self.view.addSubview(timerCircle)
        self.view.addSubview(timerLabel)
        self.view.addSubview(timeTypeLabel)
        self.view.addSubview(roundLabel)
        self.view.addSubview(totalTimeLabel)
        NSLayoutConstraint.activate([
//            gameCodeLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
//            gameCodeLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: UIScreen.main.bounds.size.height * 0.05),
//            gameCodeLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.2),
//            gameCodeLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.08),
            
            timerCircle.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            timerCircle.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: self.view.bounds.height * 0.05),
            timerCircle.widthAnchor.constraint(equalTo: timerCircle.heightAnchor),
            timerCircle.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.68),
            
            timerLabel.centerXAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.centerXAnchor),
            timerLabel.topAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.topAnchor, constant: self.timerCircle.bounds.height * 0.39),
            timerLabel.widthAnchor.constraint(equalTo: self.timerCircle.widthAnchor, multiplier: 0.70),
            timerLabel.heightAnchor.constraint(equalTo: self.timerCircle.heightAnchor, multiplier: 0.36),
            
            timeTypeLabel.centerXAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.centerXAnchor),
            timeTypeLabel.topAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.topAnchor, constant: self.timerCircle.bounds.height * 0.29),
            timeTypeLabel.widthAnchor.constraint(equalTo: self.timerCircle.widthAnchor, multiplier: 0.656),
            timeTypeLabel.heightAnchor.constraint(equalTo: self.timerCircle.heightAnchor, multiplier: 0.17),
            
            roundLabel.centerXAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.centerXAnchor),
            roundLabel.topAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.topAnchor, constant: self.timerCircle.bounds.height * 0.32),
            roundLabel.widthAnchor.constraint(equalTo: self.timerCircle.widthAnchor, multiplier: 0.605),
            roundLabel.heightAnchor.constraint(equalTo: self.timerCircle.heightAnchor, multiplier: 0.17),
            
            totalTimeLabel.centerXAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.centerXAnchor),
            totalTimeLabel.topAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.topAnchor, constant: self.timerCircle.bounds.height * 0.547),
            totalTimeLabel.widthAnchor.constraint(equalTo: self.timerCircle.widthAnchor, multiplier: 0.38),
            totalTimeLabel.heightAnchor.constraint(equalTo: self.timerCircle.heightAnchor, multiplier: 0.19)
        ])
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonTapped))
        timerCircle.addGestureRecognizer(tapGesture)
        timerCircle.isUserInteractionEnabled = true
        calculateTime()
    }
    
    //MARK: - Timer Algorithm
    func runTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let strongSelf = self else {
                return
            }
            if !strongSelf.isPaused {
                if strongSelf.totalTime == strongSelf.rounds!*(strongSelf.seconds + strongSelf.moveSeconds) {
                    strongSelf.audioPlayerManager.stop()
                    strongSelf.pauseOrPlayButton.isHidden = true
                    timer.invalidate()
                }
                if strongSelf.remainingTime <= 5 {
                    strongSelf.audioPlayerManager.playAudioFile(named: "timer_end", withExtension: "wav")
                }
                if strongSelf.remainingTime <= 3 {
                    strongSelf.impactFeedbackGenerator.impactOccurred()
                }
                if timer.isValid {
                    if strongSelf.time! < 1 {
                        if strongSelf.moving {
                            strongSelf.time = strongSelf.seconds
                            strongSelf.moving = false
                            strongSelf.timeTypeLabel.text = "Game Time"
                            strongSelf.timerLabel.text = String(format:"%02i : %02i", strongSelf.time!/60, strongSelf.time! % 60)
                        } else {
                            strongSelf.time = strongSelf.moveSeconds
                            strongSelf.moving = true
                            strongSelf.timeTypeLabel.text = "Moving Time"
                            strongSelf.timerLabel.text = String(format:"%02i : %02i", strongSelf.time!/60, strongSelf.time! % 60)
                            strongSelf.round += 1
                            Task {
                                do {
                                    try await H.updateCurrentRound(strongSelf.gameCode, strongSelf.round)
                                } catch GameWalkerError.serverError(let text){
                                    print(text)
                                    strongSelf.serverAlert(text)
                                    return
                                }
                            }
                            strongSelf.roundLabel.text = "Round \(strongSelf.round)"
                        }
                    }
                    strongSelf.time! -= 1
                    strongSelf.remainingTime -= 1
                    let minute = strongSelf.time!/60
                    let second = strongSelf.time! % 60
                    strongSelf.timerLabel.text = String(format:"%02i : %02i", minute, second)
                    strongSelf.totalTime += 1
                    let totalMinute = strongSelf.totalTime/60
                    let totalSecond = strongSelf.totalTime % 60
                    let attributedString = NSMutableAttributedString(string: "Total time\n", attributes:[NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: 20) ?? UIFont(name: "Dosis-Regular", size: 20)!])
                        attributedString.append(NSAttributedString(string: String(format:"%02i : %02i", totalMinute, totalSecond), attributes: [NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: 15) ?? UIFont(name: "Dosis-Regular", size: 15)!]))
                    strongSelf.totalTimeLabel.attributedText = attributedString
                }
            }
        }
    }
    
    func calculateTime() {
        if isPaused {
            t = pauseTime - startTime - pausedTime
        }
        else {
            if pausedTime != 0 {
                t = Int(Date().timeIntervalSince1970) - startTime - pausedTime
            }
            else {
                t = 0
            }
        }
        let quotient = t/(moveSeconds + seconds)
        let remainder = t%(moveSeconds + seconds)
        if (remainder/moveSeconds) == 0 {
            self.timeTypeLabel.text = "Moving Time"
            self.time = (moveSeconds - remainder)
            self.moving = true
            let minute = (moveSeconds - remainder)/60
            let second = (moveSeconds - remainder) % 60
            self.timerLabel.text = String(format:"%02i : %02i", minute, second)
        }
        else {
            self.timeTypeLabel.text = "Game Time"
            self.time = (seconds - remainder)
            self.moving = false
            let minute = (seconds - remainder)/60
            let second = (seconds - remainder) % 60
            self.timerLabel.text = String(format:"%02i : %02i", minute, second)
        }
        self.totalTime = t
        self.remainingTime = (host.rounds) * (host.gameTime + host.movingTime) - t
        let totalMinute = t/60
        let totalSecond = t % 60
        let attributedString = NSMutableAttributedString(string: "Total time\n", attributes: [NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: 20) ?? UIFont(name: "Dosis-Regular", size: 20)!])
        attributedString.append(NSAttributedString(string: String(format:"%02i : %02i", totalMinute, totalSecond), attributes: [NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: 15) ?? UIFont(name: "Dosis-Regular", size: 15)!]))
        self.totalTimeLabel.attributedText = attributedString
        self.round = quotient + 1
        Task {
            do {
                try await H.updateCurrentRound(gameCode, self.round)
            } catch GameWalkerError.serverError(let text){
                print(text)
                serverAlert(text)
                return
            }
        }
        if (moveSeconds + seconds) * self.rounds! <= t  {
            self.timeTypeLabel.text = "Game Time"
            self.timerLabel.text = String(format:"%02i : %02i", 0, 0)
            self.totalTime = (moveSeconds + seconds) * self.rounds!
            let totalMinute = totalTime/60
            let totalSecond = totalTime % 60
            let attributedString = NSMutableAttributedString(string: "Total time\n", attributes: [NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: 20) ?? UIFont(name: "Dosis-Regular", size: 20)!])
            attributedString.append(NSAttributedString(string: String(format:"%02i : %02i", totalMinute, totalSecond), attributes: [NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: 15) ?? UIFont(name: "Dosis-Regular", size: 15)!]))
            self.totalTimeLabel.attributedText = attributedString
            self.roundLabel.text = "Round \(self.rounds!)"
            pauseOrPlayButton.isHidden = true
        } else {
            self.roundLabel.text = "Round \(quotient + 1)"
            runTimer()
        }
    }
}
//MARK: - Protocol
extension HostTimerViewController: HostUpdateListener {
    func updateHost(_ host: Host) {
        self.startTime = host.startTimestamp
        self.pauseTime = host.pauseTimestamp
        self.pausedTime = host.pausedTime
        self.isPaused = host.paused
        self.gameStart = host.gameStart
    }
    
    func listen(_ _ : [String : Any]){
    }
    
    func callProtocols() {
        H.delegates.append(self)
        H.listenHost(gameCode, onListenerUpdate: listen(_:))
    }
    
    func setSettings() {
        self.seconds = host.gameTime
        self.moveSeconds = host.movingTime
        self.startTime = host.startTimestamp
        self.isPaused = host.paused
        self.pauseTime = host.pauseTimestamp
        self.pausedTime = host.pausedTime
        self.rounds = host.rounds
        self.remainingTime = (host.rounds) * (host.gameTime + host.movingTime)
        self.round = host.currentRound
        self.gameStart = host.gameStart
        self.gameOver = host.gameover
    }
}

