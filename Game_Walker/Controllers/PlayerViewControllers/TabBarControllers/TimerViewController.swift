//
//  PlayerFrame4_3.swift
//  Game_Walker
//
//  Created by Noah Kim on 6/17/22.
//

import Foundation
import UIKit
import AVFoundation

class TimerViewController: BaseViewController {

    @IBOutlet weak var gameInfoButton: UIButton!
    @IBOutlet weak var nextGameButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    private var messages: [String] = []
    
    private let readAll = UIImage(named: "messageIcon")
    private let unreadSome = UIImage(named: "unreadMessage")
    
    private var host : Host = Host()
    private var team : Team = Team()
    private var stations : [Station] = [Station()]
    private var startTime : Int = 0
    private var pauseTime : Int = 0
    private var pausedTime : Int = 0
    private var timer = Timer()
    private var remainingTime: Int = 0
    private var totalTime: Int = 0
    private var time: Int = 0
    private var seconds: Int = 0
    private var moveSeconds: Int = 0
    private var moving: Bool = true
    private var tapped: Bool = false
    private var round: Int = 1
    private var rounds: Int = 8
    private var isPaused = true
    private var t : Int = 0
    
    private var gameCode: String = UserData.readGamecode("gamecode") ?? ""
    private var stationOrder : [Int] = []
    
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
    
    private let audioPlayerManager = AudioPlayerManager()
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
// MARK: - UI components
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
    
    private lazy var timeTypeLabel: UILabel = {
        let label = UILabel()
        label.text = "Moving Time"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "GemunuLibre-Bold", size: fontSize(size: 38))
        label.textColor = .black
        label.numberOfLines = 1
        return label
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
    
    private lazy var roundLabel: UILabel = {
        let label = UILabel()
        label.text = "Round 1"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(red: 0.006, green: 0.45, blue: 0.721, alpha: 1)
        label.textAlignment = .center
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
        let totaltimeAttributedString = NSAttributedString(string: "GAME TIME\n", attributes: totaltimeAttributes)
        attributedText.append(totaltimeAttributedString)
        let timeAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Regular", size: fontSize(size: 25)) ?? UIFont.systemFont(ofSize: 20),
            .foregroundColor: UIColor.black
        ]
        let timeAttributedString = NSAttributedString(string: "00:00", attributes: timeAttributes)
        attributedText.append(timeAttributedString)
        label.attributedText = attributedText
        label.textAlignment = .center
        label.textColor = UIColor(red: 0.006, green: 0.45, blue: 0.721, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.alpha = 0.0
        return label
    }()
    
    private lazy var currentStationInfoButton: UIButton = {
        var button = UIButton()
        button.setTitle("Current Station Info", for: .normal)
        button.titleLabel?.font = UIFont(name: "GemunuLibre-Bold", size: fontSize(size: 20))
        button.setTitleColor(UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1), for: .normal)
        button.layer.backgroundColor = UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1).cgColor
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(currentStationInfoButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func currentStationInfoButtonTapped(_ gesture: UITapGestureRecognizer) {
        self.audioPlayerManager.playAudioFile(named: "blue", withExtension: "wav")
        findStation()
        showGameInfoPopUp(gameName: gameName, gameLocation: gameLocation, gamePoitns: gamePoints, refereeName: refereeName, gameRule: gameRule)
    }
    
    private lazy var nextStationInfoButton: UIButton = {
        var button = UIButton()
        button.setTitle("Next Station Info", for: .normal)
        button.titleLabel?.font = UIFont(name: "GemunuLibre-Bold", size: fontSize(size: 20))
        button.setTitleColor(UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1), for: .normal)
        button.layer.backgroundColor = UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1).cgColor
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(nextStationInfoButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func nextStationInfoButtonTapped(_ gesture: UITapGestureRecognizer) {
        self.audioPlayerManager.playAudioFile(named: "blue", withExtension: "wav")
        if round == rounds {
            alert(title: "Warning", message: "You are in your last round!")
        }
        else {
            findStation()
            showGameInfoPopUp(gameName: nextGameName, gameLocation: nextGameLocation, gamePoitns: nextGamePoints, refereeName: nextRefereeName, gameRule: nextGameRule)
        }
    }
    
    private lazy var gameCodeLabel: UILabel = {
        let label = UILabel()
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
// MARK: - View Life Cycle methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
        if TeamViewController.unread {
            if let items = self.navigationItem.rightBarButtonItems {
                items[2].image = self.unreadSome
            }
        } else {
            if let items = self.navigationItem.rightBarButtonItems {
                items[2].image = self.readAll
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        Task { @MainActor in
            gameInfoButton.removeFromSuperview()
            nextGameButton.removeFromSuperview()
            callProtocols()
            host = try await H.getHost(gameCode) ?? Host()
            team = try await T.getTeam(gameCode, UserData.readTeam("team")?.name ?? "") ?? Team()
            stations = try await S.getStationList(gameCode)
            setSettings()
            configureTimerLabel()
        }
        titleLabel.textColor = UIColor(red: 0.176, green: 0.176, blue: 0.208 , alpha: 1)
        titleLabel.font = UIFont(name: "GemunuLibre-SemiBold", size: fontSize(size: 50))
        tabBarController?.navigationController?.isNavigationBarHidden = true
    }
    
// MARK: - others
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(readAll(notification:)), name: .readNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playSound), name: .announceNoti, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hostUpdate), name: .hostUpdate, object: nil)
    }
    
    @IBAction func gameInfoButtonPressed(_ sender: UIButton) {
        self.audioPlayerManager.playAudioFile(named: "blue", withExtension: "wav")
        findStation()
        showGameInfoPopUp(gameName: gameName, gameLocation: gameLocation, gamePoitns: gamePoints, refereeName: refereeName, gameRule: gameRule)
    }
    
    @IBAction func nextGameButtonPressed(_ sender: UIButton) {
        self.audioPlayerManager.playAudioFile(named: "blue", withExtension: "wav")
        if round == rounds {
            alert(title: "Warning", message: "You are in your last round!")
        }
        else {
            findStation()
            showGameInfoPopUp(gameName: nextGameName, gameLocation: nextGameLocation, gamePoitns: nextGamePoints, refereeName: nextRefereeName, gameRule: nextGameRule)
        }
    }
    
    func setSettings() {
        self.seconds = host.gameTime
        self.moveSeconds = host.movingTime
        self.startTime = host.startTimestamp
        self.isPaused = host.paused
        self.pauseTime = host.pauseTimestamp
        self.pausedTime = host.pausedTime
        self.rounds = host.rounds
        self.remainingTime = host.rounds * (host.gameTime + host.movingTime)
        self.round = host.currentRound
    }
      
    // MARK: - overlay Guide view
    private func showOverlay() {
        let overlayViewController = RorTOverlayViewController()
        overlayViewController.modalPresentationStyle = .overFullScreen // Present it as overlay
        
        let explanationTexts = ["Team Members", "Ranking Status", "Timer & Station Info", "Click to see what happens"]
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
        overlayViewController.configureGuide(componentFrames, componentPositions, UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1).cgColor, explanationTexts, tabBarTop, "Timer", "player")
        
        present(overlayViewController, animated: true, completion: nil)
    }
    // MARK: - Timer
    func findStation() {
        if round == rounds {
            for station in self.stations {
                if station.number == self.team.stationOrder[round - 1] {
                    self.gameName = station.name
                    self.gameLocation = station.place
                    self.gamePoints = String(station.points)
                    self.refereeName = station.referee!.name
                    self.gameRule = station.description
                }
            }
        }
        else {
            for station in self.stations {
                if station.number == self.team.stationOrder[round - 1] {
                    self.gameName = station.name
                    self.gameLocation = station.place
                    self.gamePoints = String(station.points)
                    self.refereeName = station.referee!.name
                    self.gameRule = station.description
                }
                else if station.number == self.team.stationOrder[round] {
                    self.nextGameName = station.name
                    self.nextGameLocation = station.place
                    self.nextGamePoints = String(station.points)
                    self.nextRefereeName = station.referee!.name
                    self.nextGameRule = station.description
                }
            }
        }
    }
    
    func configureTimerLabel() {
        self.view.addSubview(timerCircle)
        timerCircle.addSubview(timerLabel)
        timerCircle.addSubview(timeTypeLabel)
        timerCircle.addSubview(roundLabel)
        timerCircle.addSubview(totalTimeLabel)
        self.view.addSubview(currentStationInfoButton)
        self.view.addSubview(nextStationInfoButton)
        currentStationInfoButton.translatesAutoresizingMaskIntoConstraints = false
        nextStationInfoButton.translatesAutoresizingMaskIntoConstraints = false
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
            
            currentStationInfoButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            currentStationInfoButton.topAnchor.constraint(equalTo: timerCircle.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.05),
            currentStationInfoButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.45),
            currentStationInfoButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.068),
            
            nextStationInfoButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            nextStationInfoButton.topAnchor.constraint(equalTo: currentStationInfoButton.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.05),
            nextStationInfoButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.45),
            nextStationInfoButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.068)
        ])
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonTapped))
        timerCircle.addGestureRecognizer(tapGesture)
        timerCircle.isUserInteractionEnabled = true
        calculateTime()
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let strongSelf = self else {
                return
            }
            if !strongSelf.isPaused {
                if strongSelf.totalTime == strongSelf.rounds * (strongSelf.seconds + strongSelf.moveSeconds) {
                    strongSelf.audioPlayerManager.stop()
                    timer.invalidate()
                }
                if strongSelf.remainingTime == 10 {
                    strongSelf.audioPlayerManager.playAudioFile(named: "timer-warning", withExtension: "wav")
                }
                if strongSelf.remainingTime == 9 {
                    strongSelf.audioPlayerManager.stop()
                }
                if strongSelf.remainingTime <= 5 {
                    strongSelf.audioPlayerManager.playAudioFile(named: "timer_end", withExtension: "wav")
                }
                if strongSelf.remainingTime <= 3 {
                    strongSelf.impactFeedbackGenerator.impactOccurred()
                }
                if timer.isValid {
                    if strongSelf.time < 1 {
                        if strongSelf.moving {
                            strongSelf.time = strongSelf.seconds
                            strongSelf.moving = false
                            strongSelf.timeTypeLabel.text = "Station Time"
                            strongSelf.timerLabel.text = String(format:"%02i : %02i", strongSelf.time/60, strongSelf.time % 60)
                        } else {
                            strongSelf.time = strongSelf.moveSeconds
                            strongSelf.moving = true
                            strongSelf.timeTypeLabel.text = "Moving Time"
                            strongSelf.timerLabel.text = String(format:"%02i : %02i", strongSelf.time/60, strongSelf.time % 60)
                        }
                    }
                    strongSelf.time -= 1
                    strongSelf.remainingTime -= 1
                    let minute = strongSelf.time/60
                    let second = strongSelf.time % 60
                    strongSelf.timerLabel.text = String(format:"%02i : %02i", minute, second)
                    strongSelf.totalTime += 1
                    let totalMinute = strongSelf.totalTime/60
                    let totalSecond = strongSelf.totalTime % 60
                    let attributedString = NSMutableAttributedString(string: "GAME TIME\n", attributes:[NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: strongSelf.fontSize(size: 30)) ?? UIFont(name: "Dosis-Regular", size: 30)!])
                    attributedString.append(NSAttributedString(string: String(format:"%02i : %02i", totalMinute, totalSecond), attributes: [NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: strongSelf.fontSize(size: 25)) ?? UIFont(name: "Dosis-Regular", size: 25)!]))
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
            t = Int(Date().timeIntervalSince1970) - startTime - pausedTime
        }
        let quotient = t/(moveSeconds + seconds)
        let remainder = t%(moveSeconds + seconds)
        if (remainder/moveSeconds) == 0 {
            self.timeTypeLabel.text = "Moving Time"
            self.time = (moveSeconds - remainder%moveSeconds)
            self.moving = true
            let minute = (moveSeconds - remainder%moveSeconds)/60
            let second = (moveSeconds - remainder%moveSeconds) % 60
            self.timerLabel.text = String(format:"%02i : %02i", minute, second)
        }
        else {
            self.timeTypeLabel.text = "Station Time"
            self.time = (seconds - remainder%moveSeconds)
            self.moving = false
            let minute = (seconds - remainder%moveSeconds)/60
            let second = (seconds - remainder%moveSeconds) % 60
            self.timerLabel.text = String(format:"%02i : %02i", minute, second)
        }
        self.totalTime = t
        self.remainingTime = (rounds * (seconds + moveSeconds)) - t
        let totalMinute = t/60
        let totalSecond = t % 60
        let attributedString = NSMutableAttributedString(string: "GAME TIME\n", attributes: [NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: fontSize(size: 30)) ?? UIFont(name: "Dosis-Regular", size: fontSize(size: 30))!])
        attributedString.append(NSAttributedString(string: String(format:"%02i : %02i", totalMinute, totalSecond), attributes: [NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: fontSize(size: 25)) ?? UIFont(name: "Dosis-Regular", size: fontSize(size: 25))!]))
        self.totalTimeLabel.attributedText = attributedString
        self.round = quotient + 1
        if (moveSeconds + seconds) * self.rounds <= t  {
            self.timeTypeLabel.text = "Station Time"
            self.timerLabel.text = String(format:"%02i : %02i", 0, 0)
            self.totalTime = (moveSeconds + seconds) * self.rounds
            let totalMinute = totalTime/60
            let totalSecond = totalTime % 60
            let attributedString = NSMutableAttributedString(string: "GAME TIME\n", attributes: [NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: fontSize(size: 30)) ?? UIFont(name: "Dosis-Regular", size: fontSize(size: 30))!])
            attributedString.append(NSAttributedString(string: String(format:"%02i : %02i", totalMinute, totalSecond), attributes: [NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: fontSize(size: 25)) ?? UIFont(name: "Dosis-Regular", size: fontSize(size: 25))!]))
            self.totalTimeLabel.attributedText = attributedString
            self.roundLabel.text = "Round \(self.rounds)"
        } else {
            self.roundLabel.text = "Round \(quotient + 1)"
            runTimer()
        }
    }
}
// MARK: - @objc
extension TimerViewController {
    
    @objc func hostUpdate(notification: Notification) {
        guard let host = notification.userInfo?["host"] as? Host else { return }
      
        roundLabel.text = "Round \(host.currentRound)"  
        self.round = host.currentRound
        self.pauseTime = host.pauseTimestamp
        self.pausedTime = host.pausedTime
        self.startTime = host.startTimestamp
        self.isPaused = host.paused
    }
    
    @objc func readAll(notification: Notification) {
        guard let unread = notification.userInfo?["unread"] as? Bool else {
            return
        }
        if unread {
            if let items = self.navigationItem.rightBarButtonItems {
                items[2].image = self.unreadSome
            }
        } else {
            if let items = self.navigationItem.rightBarButtonItems {
                items[2].image = self.readAll
            }
        }
    }
    
    @objc func playSound() {
        self.audioPlayerManager.playAudioFile(named: "message", withExtension: "wav")
    }
    
    @objc func buttonTapped(_ gesture: UITapGestureRecognizer) {
        if !tapped {
            timerCircle.layer.borderColor = UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1).cgColor
            timerLabel.alpha = 0.0
            timeTypeLabel.alpha = 0.0
            roundLabel.alpha = 1.0
            totalTimeLabel.alpha = 1.0
            tapped = true
        } else {
            timerCircle.layer.borderColor = UIColor(red: 0.176, green: 0.176, blue: 0.208, alpha: 0.6).cgColor
            timerLabel.alpha = 1.0
            timeTypeLabel.alpha = 1.0
            roundLabel.alpha = 0.0
            totalTimeLabel.alpha = 0.0
            tapped = false
        }
    }
    
    @objc override func infoAction() {
        self.showOverlay()
    
    @objc override func announceAction() {
        showMessagePopUp(messages: TeamViewController.localMessages)
    }
    
    @objc func announceUpdate(notification: Notification) {
        guard let host = notification.userInfo?["host"] as? Host else { return }
        // if some announcements were deleted from the server
        if TeamViewController.localMessages.count > host.announcements.count {
            removeAnnouncementsNotInHost(from: &TeamViewController.localMessages, targetArray: host.announcements)
            NotificationCenter.default.post(name: .newDataNotif, object: nil, userInfo: nil)
        } else {
            // compare server announcements and local announcements
            for announcement in host.announcements {
                let ids: [String] = TeamViewController.localMessages.map({ $0.uuid })
                // new announcements
                if !ids.contains(announcement.uuid) {
                    TeamViewController.localMessages.append(announcement)
                    self.audioPlayerManager.playAudioFile(named: "message", withExtension: "wav")
                    NotificationCenter.default.post(name: .announceNoti, object: nil, userInfo: nil)
                } else {
                    // modified announcements
                    if let localIndex = TeamViewController.localMessages.firstIndex(where: {$0.uuid == announcement.uuid}) {
                        if TeamViewController.localMessages[localIndex].content != announcement.content {
                            TeamViewController.localMessages[localIndex].content = announcement.content
                            TeamViewController.localMessages[localIndex].readStatus = false
                            self.audioPlayerManager.playAudioFile(named: "message", withExtension: "wav")
                            NotificationCenter.default.post(name: .announceNoti, object: nil, userInfo: nil)
                        }
                    }
                }
                
            }
        }
    }
}
