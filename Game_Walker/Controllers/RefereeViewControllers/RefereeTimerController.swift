//
//  RefereeTimerController.swift
//  Game_Walker
//
//  Created by 김현식 on 9/5/23.
//

import Foundation
import UIKit

class RefereeTimerController: BaseViewController {
    
    // Variables
    private var gameCode: String = UserData.readGamecode("gamecode") ?? ""
    private var referee: Referee = UserData.readReferee("referee") ?? Referee()
    private var stations: [Station] = [Station()]
    private var host: Host = Host()
    
    private var messages: [String] = []
    private let readAll = UIImage(named: "messageIcon")
    private let unreadSome = UIImage(named: "unreadMessage")
    private let audioPlayerManager = AudioPlayerManager()
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    
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
    
    override func viewDidLoad() {
        Task {
            callProtocols()
            stations = try await S.getStationList(gameCode)
            host = try await H.getHost(gameCode) ?? Host()
            setSettings()
            configureTimerLabel()
            calculateTime()
        }
        super.viewDidLoad()
    }
    
    //MARK: - UI Elements
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
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "TIMER"
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "GemunuLibre-SemiBold", size: fontSize(size: 50)) ?? UIFont(name: "Dosis-SemiBold", size: fontSize(size: 50))
        label.numberOfLines = 1
        return label
    }()
    
    
    private lazy var timerCircle: UILabel = {
        var view = UILabel()
        view.clipsToBounds = true
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0.6
        view.layer.borderWidth = 15
        view.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        view.layer.cornerRadius = 0.68 * UIScreen.main.bounds.size.width / 2.0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonTapped))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    @objc func buttonTapped(_ gesture: UITapGestureRecognizer) {
        if !tapped {
            timerCircle.layer.borderColor = UIColor(red: 40.0 / 255.0, green: 209.0 / 255.0, blue: 113.0 / 255.0, alpha: 1.0).cgColor
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
    
    private lazy var timeTypeLabel: UILabel = {
        let label = UILabel()
        label.text = "Moving Time"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "GemunuLibre-Bold", size: fontSize(size: 38)) ?? UIFont(name: "Dosis-Bold", size: fontSize(size: 38))
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "00 : 00"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-Regular", size: fontSize(size: 55))
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var roundLabel: UILabel = {
        let label = UILabel()
        label.text = "Round 1"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "GemunuLibre-Bold", size: fontSize(size: 38)) ?? UIFont(name: "Dosis-Bold", size: fontSize(size: 38))
        label.textColor = UIColor(red: 28.0 / 255.0, green: 134.0 / 255.0, blue: 11.0 / 255.0, alpha: 1.0)
        label.numberOfLines = 1
        label.alpha = 0.0
        return label
    }()
    
    private lazy var totalTimeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor(red: 0.843, green: 0.502, blue: 0.976, alpha: 1)
        label.text = "TOTAL TIME" + "\n" + "00:00"
        label.textColor = UIColor(red: 28.0 / 255.0, green: 134.0 / 255.0, blue: 11.0 / 255.0, alpha: 1.0)
        label.font = UIFont(name: "Dosis-Regular", size: fontSize(size: 30))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.alpha = 0.0
        return label
    }()
    
    private lazy var currentStationInfoButton: UIImageView = {
        var view = UIImageView()
        view.image = UIImage(named: "RefereeCurrentStationInfo")
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(currentStationInfoButtonTapped))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    @objc func currentStationInfoButtonTapped(_ gesture: UITapGestureRecognizer) {
        self.audioPlayerManager.playAudioFile(named: "green", withExtension: "wav")
        findStation()
    }
    
    func configureTimerLabel(){
        self.view.addSubview(gameCodeLabel)
        self.view.addSubview(titleLabel)
        self.view.addSubview(timerCircle)
        self.view.addSubview(currentStationInfoButton)
        timerCircle.addSubview(timerLabel)
        timerCircle.addSubview(timeTypeLabel)
        timerCircle.addSubview(roundLabel)
        timerCircle.addSubview(totalTimeLabel)
        gameCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        timerCircle.translatesAutoresizingMaskIntoConstraints = false
        currentStationInfoButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gameCodeLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            gameCodeLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: UIScreen.main.bounds.size.height * 0.05),
            gameCodeLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.2),
            gameCodeLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.08),
            
            titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: gameCodeLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.005),
            titleLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.55),
            titleLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.08),
            
            timerCircle.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            timerCircle.topAnchor.constraint(equalTo: self.view.topAnchor, constant: UIScreen.main.bounds.size.height * 0.27),
            timerCircle.widthAnchor.constraint(equalTo: timerCircle.heightAnchor),
            timerCircle.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.68),
            
            timerLabel.centerXAnchor.constraint(equalTo: timerCircle.layoutMarginsGuide.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: timerCircle.layoutMarginsGuide.centerYAnchor, constant: 0.07 * UIScreen.main.bounds.size.width),
            timerLabel.widthAnchor.constraint(equalTo: timerCircle.widthAnchor, multiplier: 0.70),
            timerLabel.heightAnchor.constraint(equalTo: timerCircle.heightAnchor, multiplier: 0.36),
            
            timeTypeLabel.centerXAnchor.constraint(equalTo: timerCircle.layoutMarginsGuide.centerXAnchor),
            timeTypeLabel.centerYAnchor.constraint(equalTo: timerCircle.layoutMarginsGuide.centerYAnchor, constant: -0.07 * UIScreen.main.bounds.size.width),
            timeTypeLabel.widthAnchor.constraint(equalTo: timerCircle.widthAnchor, multiplier: 0.9),
            timeTypeLabel.heightAnchor.constraint(equalTo: timerCircle.heightAnchor, multiplier: 0.17),
            
            roundLabel.centerXAnchor.constraint(equalTo: timerCircle.layoutMarginsGuide.centerXAnchor),
            roundLabel.centerYAnchor.constraint(equalTo: timerCircle.layoutMarginsGuide.centerYAnchor, constant: -0.15 * UIScreen.main.bounds.size.width),
            roundLabel.widthAnchor.constraint(equalTo: timerCircle.widthAnchor, multiplier: 0.605),
            roundLabel.heightAnchor.constraint(equalTo: timerCircle.heightAnchor, multiplier: 0.17),
            
            totalTimeLabel.centerXAnchor.constraint(equalTo: timerCircle.layoutMarginsGuide.centerXAnchor),
            totalTimeLabel.centerYAnchor.constraint(equalTo: timerCircle.layoutMarginsGuide.centerYAnchor, constant: 0.07 * UIScreen.main.bounds.size.width),
            totalTimeLabel.widthAnchor.constraint(equalTo: timerCircle.widthAnchor, multiplier: 0.7),
            totalTimeLabel.heightAnchor.constraint(equalTo: timerCircle.heightAnchor, multiplier: 0.4),
            
            currentStationInfoButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            currentStationInfoButton.topAnchor.constraint(equalTo: timerCircle.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.05),
            currentStationInfoButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.45),
            currentStationInfoButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.068)
        ])
    }
    
    func fontSize(size: CGFloat) -> CGFloat {
        let size_formatter = size/390
        let result = UIScreen.main.bounds.size.width * size_formatter
        return result
    }
    
    func findStation() {
        for station in stations {
            if station.name == referee.stationName {
                showRefereeGameInfoPopUp(gameName: station.name, gameLocation: station.place, gamePoitns: String(station.points), gameRule: station.description)
            }
        }
    }
    
    //MARK: - Overlay
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
        overlayViewController.configureGuide(componentFrames, componentPositions, UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 1).cgColor, explanationTexts, tabBarTop, "Timer")
        
        present(overlayViewController, animated: true, completion: nil)
    }
    
    //MARK: - Timer
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
                            strongSelf.timeTypeLabel.text = "Game Time"
                            strongSelf.timerLabel.text = String(format:"%02i : %02i", strongSelf.time/60, strongSelf.time % 60)
                        } else {
                            strongSelf.time = strongSelf.moveSeconds
                            strongSelf.moving = true
                            strongSelf.timeTypeLabel.text = "Moving Time"
                            strongSelf.timerLabel.text = String(format:"%02i : %02i", strongSelf.time/60, strongSelf.time % 60)
                            strongSelf.round += 1
                            strongSelf.roundLabel.text = "Round \(strongSelf.round)"
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
        let totalMinute = t/60
        let totalSecond = t % 60
        let attributedString = NSMutableAttributedString(string: "Total time\n", attributes: [NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: 20) ?? UIFont(name: "Dosis-Regular", size: 20)!])
        attributedString.append(NSAttributedString(string: String(format:"%02i : %02i", totalMinute, totalSecond), attributes: [NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: 15) ?? UIFont(name: "Dosis-Regular", size: 15)!]))
        self.totalTimeLabel.attributedText = attributedString
        self.round = quotient + 1
        if (moveSeconds + seconds) * self.rounds <= t  {
            self.timeTypeLabel.text = "Game Time"
            self.timerLabel.text = String(format:"%02i : %02i", 0, 0)
            self.totalTime = (moveSeconds + seconds) * self.rounds
            let totalMinute = totalTime/60
            let totalSecond = totalTime % 60
            let attributedString = NSMutableAttributedString(string: "Total time\n", attributes: [NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: 20) ?? UIFont(name: "Dosis-Regular", size: 20)!])
            attributedString.append(NSAttributedString(string: String(format:"%02i : %02i", totalMinute, totalSecond), attributes: [NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: 15) ?? UIFont(name: "Dosis-Regular", size: 15)!]))
            self.totalTimeLabel.attributedText = attributedString
            self.roundLabel.text = "Round \(self.rounds)"
        } else {
            self.roundLabel.text = "Round \(quotient + 1)"
            runTimer()
        }
    }
}
//MARK: - Protocol
extension RefereeTimerController: HostUpdateListener {
    func updateHost(_ host: Host) {
        self.round = host.currentRound
        self.pauseTime = host.pauseTimestamp
        self.pausedTime = host.pausedTime
        self.startTime = host.startTimestamp
        self.isPaused = host.paused
    }
    
    func listen(_ _ : [String : Any]){
    }
    
    func callProtocols() {
        H.delegates.append(self)
        Task {
            stations = try await S.getStationList(gameCode)
            host = try await H.getHost(gameCode) ?? Host()
        }
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
        self.remainingTime = host.rounds * (host.gameTime + host.movingTime)
        self.round = host.currentRound
    }
}
