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
    private var number: Int = -1
    private var round: Int = 1
    private var rounds: Int?
    private var isPaused = true
    private var t : Int = 0
    
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let audioPlayerManager = AudioPlayerManager()
    private let play = UIImage(named: "Polygon 1")
    private let pause = UIImage(named: "Group 359")
    
    private var gameCode: String = UserData.readGamecode("gamecode") ?? ""
    private var gameStart : Bool = false
    private var ready : Bool {
        get {
            return UserDefaults.standard.bool(forKey: "readyKey")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "readyKey")
        }
    }
    private var gameOver : Bool = false
    private var segueCalled : Bool = false
    
    // MARK: - methods related to the view lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        Task {
            titleLabel.font = UIFont(name: "GemunuLibre-SemiBold", size: fontSize(size: 50))
            titleLabel.textColor = UIColor(red: 0.176, green: 0.176, blue: 0.208 , alpha: 1)
            do {
                host = try await H.getHost(gameCode) ?? Host()
                setSettings()
                if UserData.isStandardStyle() {
                    configureTimerLabel()
                } else {
                    pauseOrPlayButton.isHidden = true
                }
            } catch GameWalkerError.serverError(let message) {
                print(message)
                serverAlert(message)
                return
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(updateHostInfo), name: .hostUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTeamsInfo), name: .teamsUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addBackGroundTime(_:)), name: NSNotification.Name("sceneWillEnterForeground"), object: nil)
    }
    
    // MARK: - others
    @IBAction func endBtnPressed(_ sender: Any) {
        let endGamePopUp = EndGameViewController(announcement: NSLocalizedString("Do you really want to end this game?", comment: ""), source: "", gamecode: gameCode)
        endGamePopUp.delegate = self
        present(endGamePopUp, animated: true)
    }
    
    @IBAction func pauseOrPlayButtonPressed(_ sender: UIButton) {
        if !gameStart && ready {
            Task { @MainActor in
                do {
                    try await H.startGame(gameCode)
                } catch GameWalkerError.serverError(let text){
                    print(text)
                    serverAlert(text)
                    return
                }
                sender.setImage(pause, for: .normal)
            }
        }
        else if gameStart && ready {
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
        else {
            alert(title: NSLocalizedString("Teams are not ready yet!", comment: ""), message: NSLocalizedString("You don't have enough teams to start the game.", comment: ""))
        }
    }
    
    func setSettings() {
        self.number = host.teams
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
    
    
    // MARK: - overlay Guide view
    private func showOverlay() {
        let overlayViewController = RorTOverlayViewController()
        overlayViewController.modalPresentationStyle = .overFullScreen // Present it as overlay
        
        let explanationTexts = [
            NSLocalizedString("Ranking Status", comment: ""),
            NSLocalizedString("Timer & \n Start/End Game", comment: ""),
            NSLocalizedString("Click to see what happens", comment: "")
        ]
        var componentPositions: [CGPoint] = []
        var componentFrames: [CGRect] = []
        let timerFrame = timerCircle.frame
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
                        tabBarTop = tabBarFrame.minY
                        componentFrames.append(tabItemFrame)
                        componentPositions.append(CGPoint(x: centerXPosition, y: topAnchorPosition))
                    }
                }
            }
        }
        print(componentPositions)
        componentPositions.append(CGPoint(x: timerFrame.midX, y: timerFrame.minY))
        componentFrames.append(timerFrame)
        overlayViewController.configureGuide(componentFrames, componentPositions, UIColor(red: 0.843, green: 0.502, blue: 0.976, alpha: 1).cgColor, explanationTexts, tabBarTop, "Timer", "host")
        
        present(overlayViewController, animated: true, completion: nil)
    }
    //MARK: - UI Timer Elements
    
    private let timerCircle: UILabel = {
        var view = UILabel()
        view.clipsToBounds = true
        view.frame = CGRect()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 15 * UIScreen.main.bounds.size.width / 375
        view.layer.borderColor = UIColor(red: 0.176, green: 0.176, blue: 0.208, alpha: 0.6).cgColor
        view.layer.cornerRadius = 0.68 * UIScreen.main.bounds.size.width / 2.0
        return view
    }()
    
    private lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-Regular", size: fontSize(size: 55))
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var timeTypeLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Moving Time", comment: "")
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "GemunuLibre-Bold", size: fontSize(size: 38))
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var roundLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor(red: 0.535, green: 0.006, blue: 0.721, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "GemunuLibre-Bold", size: fontSize(size: 38))
        label.numberOfLines = 1
        label.alpha = 0.0
        return label
    }()
    
    private lazy var totalTimeLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString()
        let totaltimeAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Regular", size: fontSize(size: 30)) ?? UIFont.systemFont(ofSize: 13),
            .foregroundColor: UIColor.black
        ]
        let totaltimeAttributedString = NSAttributedString(string: NSLocalizedString("TOTAL TIME", comment: "") + "\n", attributes: totaltimeAttributes)
        attributedText.append(totaltimeAttributedString)
        let timeAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Regular", size: fontSize(size: 25)) ?? UIFont.systemFont(ofSize: 20),
            .foregroundColor: UIColor.black
        ]
        let timeAttributedString = NSAttributedString(string: "00:00", attributes: timeAttributes)
        attributedText.append(timeAttributedString)
        label.attributedText = attributedText
        label.textAlignment = .center
        label.textColor = UIColor(red: 0.535, green: 0.006, blue: 0.721, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.alpha = 0.0
        return label
    }()
    
    func configureTimerLabel() {
        self.view.addSubview(timerCircle)
        timerCircle.addSubview(timerLabel)
        timerCircle.addSubview(timeTypeLabel)
        timerCircle.addSubview(roundLabel)
        timerCircle.addSubview(totalTimeLabel)
        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.076),
            
            timerCircle.centerXAnchor.constraint(equalTo: self.view.layoutMarginsGuide.centerXAnchor),
            timerCircle.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: self.view.bounds.height * 0.028),
            timerCircle.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.68),
            timerCircle.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.68),
            
            timeTypeLabel.centerXAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.centerXAnchor),
            timeTypeLabel.topAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.topAnchor, constant: UIScreen.main.bounds.height * 0.09),
            timeTypeLabel.widthAnchor.constraint(equalTo: self.timerCircle.widthAnchor, multiplier: 0.9),
            timeTypeLabel.heightAnchor.constraint(equalTo: self.timerCircle.heightAnchor, multiplier: 0.17),
            
            timerLabel.centerXAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.centerXAnchor),
            timerLabel.topAnchor.constraint(equalTo: self.timeTypeLabel.layoutMarginsGuide.bottomAnchor, constant: 0),
            timerLabel.widthAnchor.constraint(equalTo: self.timerCircle.widthAnchor, multiplier: 0.70),
            timerLabel.heightAnchor.constraint(equalTo: self.timerCircle.heightAnchor, multiplier: 0.36),
            
            roundLabel.centerXAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.centerXAnchor),
            roundLabel.topAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.topAnchor, constant: UIScreen.main.bounds.height * 0.084),
            roundLabel.widthAnchor.constraint(equalTo: self.timerCircle.widthAnchor, multiplier: 0.605),
            roundLabel.heightAnchor.constraint(equalTo: self.timerCircle.heightAnchor, multiplier: 0.17),
            
            totalTimeLabel.centerXAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.centerXAnchor),
            totalTimeLabel.topAnchor.constraint(equalTo: self.roundLabel.bottomAnchor, constant: UIScreen.main.bounds.height * 0.01),
            totalTimeLabel.widthAnchor.constraint(equalTo: self.timerCircle.widthAnchor, multiplier: 0.53),
            totalTimeLabel.heightAnchor.constraint(equalTo: self.timerCircle.heightAnchor, multiplier: 0.27),
            
            pauseOrPlayButton.topAnchor.constraint(equalTo: timerCircle.bottomAnchor, constant: UIScreen.main.bounds.height * 0.049),
            endGameBtn.topAnchor.constraint(equalTo: pauseOrPlayButton.bottomAnchor, constant: UIScreen.main.bounds.height * 0.049)
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
                let interval = strongSelf.moveSeconds + strongSelf.seconds
                let timeRemainder = strongSelf.remainingTime % interval

                switch timeRemainder {
                case 300, 180, 60, 30, 10:
                    strongSelf.audioPlayerManager.playAudioFile(named: "timer-warning", withExtension: "wav")
                case 3...5:
                    strongSelf.audioPlayerManager.playAudioFile(named: "timer_end", withExtension: "wav")
                case 0...3:
                    strongSelf.impactFeedbackGenerator.impactOccurred()
                default:
                    break
                }
                if timer.isValid {
                    if strongSelf.time! < 1 {
                        if strongSelf.moving {
                            strongSelf.time = strongSelf.seconds
                            strongSelf.moving = false
                            strongSelf.timeTypeLabel.text = NSLocalizedString("Station Time", comment: "")
                            strongSelf.timerLabel.text = String(format:"%02i : %02i", strongSelf.time!/60, strongSelf.time! % 60)
                        } else {
                            strongSelf.time = strongSelf.moveSeconds
                            strongSelf.moving = true
                            strongSelf.timeTypeLabel.text = NSLocalizedString("Moving Time", comment: "")
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
                            strongSelf.roundLabel.text = NSLocalizedString("Round", comment: "") + " \(strongSelf.round)"
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
                    let attributedString = NSMutableAttributedString(string: NSLocalizedString("TOTAL TIME", comment: "") + "\n", attributes:[NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: strongSelf.fontSize(size: 30)) ?? UIFont(name: "Dosis-Regular", size: 30)!])
                    attributedString.append(NSAttributedString(string: String(format:"%02i : %02i", totalMinute, totalSecond), attributes: [NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: strongSelf.fontSize(size: 25)) ?? UIFont(name: "Dosis-Regular", size: 25)!]))
                    strongSelf.totalTimeLabel.attributedText = attributedString
                }
            } else {
                strongSelf.audioPlayerManager.stop()
            }
        }
    }
    
    func calculateTime() {
        if isPaused {
            t = pauseTime - startTime - pausedTime
        }
        else {
            t = Int(Date().timeIntervalSince1970) - startTime - pausedTime
        }
        let quotient = t/(moveSeconds + seconds)
        let remainder = t%(moveSeconds + seconds)
        if (remainder/moveSeconds) == 0 {
            self.timeTypeLabel.text = NSLocalizedString("Moving Time", comment: "")
            self.time = (moveSeconds - remainder%moveSeconds)
            self.moving = true
            let minute = (moveSeconds - remainder%moveSeconds)/60
            let second = (moveSeconds - remainder%moveSeconds) % 60
            self.timerLabel.text = String(format:"%02i : %02i", minute, second)
        }
        else {
            self.timeTypeLabel.text = NSLocalizedString("Station Time", comment: "")
            self.time = (seconds - remainder + moveSeconds)
            self.moving = false
            let minute = (seconds - remainder + moveSeconds)/60
            let second = (seconds - remainder + moveSeconds) % 60
            self.timerLabel.text = String(format:"%02i : %02i", minute, second)
        }
        self.totalTime = t
        self.remainingTime = (host.rounds) * (host.gameTime + host.movingTime) - t
        let totalMinute = t/60
        let totalSecond = t % 60
        let attributedString = NSMutableAttributedString(string: NSLocalizedString("TOTAL TIME", comment: "") + "\n", attributes: [NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: fontSize(size: 30)) ?? UIFont(name: "Dosis-Regular", size: fontSize(size: 30))!])
        attributedString.append(NSAttributedString(string: String(format:"%02i : %02i", totalMinute, totalSecond), attributes: [NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: fontSize(size: 25)) ?? UIFont(name: "Dosis-Regular", size: fontSize(size: 25))!]))
        self.totalTimeLabel.attributedText = attributedString
        self.round = quotient + 1
        Task {
            do {
                try await H.updateCurrentRound(gameCode, self.round)
                NotificationCenter.default.post(name: .roundUpdate, object: nil, userInfo: ["round":self.round])
            } catch GameWalkerError.serverError(let text){
                print(text)
                serverAlert(text)
                return
            }
        }
        if (moveSeconds + seconds) * self.rounds! <= t  {
            self.timeTypeLabel.text = NSLocalizedString("Station Time", comment: "")
            self.timerLabel.text = String(format:"%02i : %02i", 0, 0)
            self.totalTime = (moveSeconds + seconds) * self.rounds!
            let totalMinute = totalTime/60
            let totalSecond = totalTime % 60
            let attributedString = NSMutableAttributedString(string: NSLocalizedString("TOTAL TIME", comment: "") + "\n", attributes: [NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: fontSize(size: 30)) ?? UIFont(name: "Dosis-Regular", size: fontSize(size: 30))!])
            attributedString.append(NSAttributedString(string: String(format:"%02i : %02i", totalMinute, totalSecond), attributes: [NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: fontSize(size: 25)) ?? UIFont(name: "Dosis-Regular", size: fontSize(size: 25))!]))
            self.totalTimeLabel.attributedText = attributedString
            self.roundLabel.text = NSLocalizedString("Round", comment: "") + " \(self.rounds!)"
            pauseOrPlayButton.isHidden = true
        } else {
            self.roundLabel.text = NSLocalizedString("Round", comment: "") + " \(quotient + 1)"
            if gameStart {
                if isPaused {
                    pauseOrPlayButton.setImage(play, for: .normal)
                }
                else {
                    pauseOrPlayButton.setImage(pause, for: .normal)
                }
            }
            runTimer()
        }
    }
}
// MARK: - @objc
extension HostTimerViewController {
    @objc func updateHostInfo(notification: Notification) {
        guard let host = notification.userInfo?["host"] as? Host else { return }
        self.startTime = host.startTimestamp
        self.pauseTime = host.pauseTimestamp
        self.pausedTime = host.pausedTime
        self.isPaused = host.paused
        self.gameStart = host.gameStart
        self.number = host.teams
    }
    
    @objc func addBackGroundTime(_ notification:Notification) {
        timer.invalidate()
        calculateTime()
    }
    
    @objc override func announceAction() {
        showHostMessagePopUp(messages: HostRankingViewcontroller.messages)
    }
    
    @objc override func infoAction() {
        showOverlay()
    }
    
    @objc func updateTeamsInfo(notification: Notification) {
        guard let teams = notification.userInfo?["teams"] as? [Team] else { return }
        if teams.count == self.number {
            ready = true
        }
    }
    
    @objc func buttonTapped(_ gesture: UITapGestureRecognizer) {
        if !tapped {
            timerCircle.layer.borderColor = UIColor(red: 0.843, green: 0.502, blue: 0.976, alpha: 1).cgColor
            timerLabel.alpha = 0.0
            timeTypeLabel.alpha = 0.0
            roundLabel.alpha = 1.0
            totalTimeLabel.alpha = 1.0
            tapped = true
        } else {
            timerCircle.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6).cgColor
            timerLabel.alpha = 1.0
            timeTypeLabel.alpha = 1.0
            roundLabel.alpha = 0.0
            totalTimeLabel.alpha = 0.0
            tapped = false
        }
    }
}
// MARK: - ModalViewControllerDelegate
extension HostTimerViewController: ModalViewControllerDelegate {
    func modalViewControllerDidRequestPush() {
        self.showAwardPopUp("host")
    }
}
