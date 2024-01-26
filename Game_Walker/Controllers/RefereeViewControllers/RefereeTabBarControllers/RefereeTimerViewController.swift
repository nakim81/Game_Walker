//
//  RefereeTimerController.swift
//  Game_Walker
//
//  Created by 김현식 on 9/5/23.
//

import Foundation
import UIKit
import Dispatch

class RefereeTimerViewController: UIViewController {
    
    // Variables
    
    private var gameCode: String = UserData.readGamecode("gamecode") ?? ""
    private var referee: Referee = UserData.readReferee("referee") ?? Referee()
    private var station: Station?
    private var stations : [Station] = [Station()]
    private var host: Host = Host()
    private var pvp: Bool?
    
    private let readAll = UIImage(named: "messageIcon")
    private let unreadSome = UIImage(named: "unreadMessage")
    private let audioPlayerManager = AudioPlayerManager()
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)

    private var startTime : Int = 0
    private var pauseTime : Int = 0
    private var pausedTime : Int = 0
    private var timer: DispatchSourceTimer?
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
    
    //MARK: - View Life cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentStationInfoButton.setTitleColor(UIColor.white, for: .normal)
        addObservers()
        guard let items = self.navigationItem.rightBarButtonItems else {return}
        let unread = RefereeTabBarController.unread
        if unread {
            for barButtonItem in items {
                if let btn = barButtonItem.customView as? UIButton, btn.tag == 120 {
                    btn.setImage(self.unreadSome, for: .normal)
                    break
                }
            }
        } else {
            for barButtonItem in items {
                if let btn = barButtonItem.customView as? UIButton, btn.tag == 120 {
                    btn.setImage(self.readAll, for: .normal)
                    break
                }
            }
        }
        Task { @MainActor in
            host = try await H.getHost(gameCode) ?? Host()
            await setTime()
            await calculateOnly()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("sceneWillEnterForeground"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("sceneDidEnterBackground"), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureRefreshButton()
        configureNavigationBar()
        callProtocols()
        tabBarController?.navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - ETC
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(hostUpdate), name: .hostUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(readAll(notification:)), name: .readNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground(_:)), name: NSNotification.Name("sceneWillEnterForeground"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground(_:)), name: NSNotification.Name("sceneDidEnterBackground"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground(_:)), name: NSNotification.Name("stop"), object: nil)
    }
    
    func callProtocols() {
        Task {
            stations = try await S.getStationList(gameCode)
            host = try await H.getHost(gameCode) ?? Host()
            await setTime()
            calculateTime()
            configureTimerLabel()
            for station in stations {
                if station.name == referee.stationName {
                    self.station = station
                    self.pvp = station.pvp
                }
            }
        }
    }
    
    //MARK: - UI Elements
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("TIMER", comment: "")
        label.textColor = UIColor(red: 0.176, green: 0.176, blue: 0.208 , alpha: 1)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = getFontForLanguage(font: "GemunuLibre-SemiBold", size: fontSize(size: 50))
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var timerCircle: UILabel = {
        var view = UILabel()
        view.clipsToBounds = true
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 15 * UIScreen.main.bounds.size.width / 375
        view.layer.borderColor = UIColor(red: 0.176, green: 0.176, blue: 0.208, alpha: 0.6).cgColor
        view.layer.cornerRadius = 0.68 * UIScreen.main.bounds.size.width / 2.0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonTapped))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var timeTypeLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Moving Time", comment: "")
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = getFontForLanguage(font: "GemunuLibre-Bold", size: fontSize(size: 38))
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
        label.text = NSLocalizedString("Round 1", comment: "")
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = getFontForLanguage(font: "GemunuLibre-Bold", size: fontSize(size: 38))
        label.textColor = UIColor(red: 0.111, green: 0.525, blue: 0.044, alpha: 1)
        label.numberOfLines = 1
        label.alpha = 0.0
        return label
    }()
    
    private lazy var totalTimeLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString()
        let totaltimeAttributes: [NSAttributedString.Key: Any] = [
            .font: getFontForLanguage(font: "Dosis-Regular", size: fontSize(size: 30)),
            .foregroundColor: UIColor.black
        ]
        let totaltimeAttributedString = NSAttributedString(string: NSLocalizedString("TOTAL TIME", comment: "") + "\n", attributes: totaltimeAttributes)
        
        attributedText.append(totaltimeAttributedString)
        let timeAttributes: [NSAttributedString.Key: Any] = [
            .font: getFontForLanguage(font: "Dosis-Regular", size: fontSize(size: 25)),
            .foregroundColor: UIColor.black
        ]
        let timeAttributedString = NSAttributedString(string: "00:00", attributes: timeAttributes)
        attributedText.append(timeAttributedString)
        label.attributedText = attributedText
        label.textAlignment = .center
        label.textColor = UIColor(red: 0.111, green: 0.525, blue: 0.044, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.alpha = 0.0
        return label
    }()
    
    private lazy var currentStationInfoButton: UIButton = {
        var button = UIButton()
        button.setTitle(NSLocalizedString("Station Info", comment: ""), for: .normal)
        button.titleLabel?.font = getFontForLanguage(font: "GemunuLibre-Bold", size: fontSize(size: 20))
        button.setTitleColor(UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1), for: .normal)
        button.layer.backgroundColor = UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 1).cgColor
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(currentStationInfoButtonTapped), for: .touchUpInside)
        return button
    }()
    
    func configureRefreshButton() {
        let Button = UIBarButtonItem(image: UIImage(named: "refresh button")?.withRenderingMode(.alwaysTemplate) , style: .plain, target: self, action: #selector(RefreshPressed))
        Button.tintColor = UIColor(red: 0.18, green: 0.18, blue: 0.21, alpha: 1)
        navigationItem.leftBarButtonItem = Button
    }
    
    func configureTimerLabel(){
        self.view.addSubview(titleLabel)
        self.view.addSubview(timerCircle)
        self.view.addSubview(currentStationInfoButton)
        timerCircle.addSubview(timerLabel)
        timerCircle.addSubview(timeTypeLabel)
        timerCircle.addSubview(roundLabel)
        timerCircle.addSubview(totalTimeLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        timerCircle.translatesAutoresizingMaskIntoConstraints = false
        currentStationInfoButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant:  UIScreen.main.bounds.size.height * 0.15),
            titleLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.55),
            titleLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.076),
            
            timerCircle.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            timerCircle.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.028),
            timerCircle.widthAnchor.constraint(equalTo: timerCircle.heightAnchor),
            timerCircle.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.68),
            
            timerLabel.centerXAnchor.constraint(equalTo: timerCircle.layoutMarginsGuide.centerXAnchor),
            timerLabel.topAnchor.constraint(equalTo: timeTypeLabel.layoutMarginsGuide.bottomAnchor, constant: 0),
            timerLabel.widthAnchor.constraint(equalTo: timerCircle.widthAnchor, multiplier: 0.70),
            timerLabel.heightAnchor.constraint(equalTo: timerCircle.heightAnchor, multiplier: 0.36),
            
            timeTypeLabel.centerXAnchor.constraint(equalTo: timerCircle.layoutMarginsGuide.centerXAnchor),
            timeTypeLabel.topAnchor.constraint(equalTo: timerCircle.layoutMarginsGuide.topAnchor, constant: UIScreen.main.bounds.height * 0.09),
            timeTypeLabel.widthAnchor.constraint(equalTo: timerCircle.widthAnchor, multiplier: 0.9),
            timeTypeLabel.heightAnchor.constraint(equalTo: timerCircle.heightAnchor, multiplier: 0.17),
            
            roundLabel.centerXAnchor.constraint(equalTo: timerCircle.layoutMarginsGuide.centerXAnchor),
            roundLabel.topAnchor.constraint(equalTo: timerCircle.layoutMarginsGuide.topAnchor, constant: UIScreen.main.bounds.height * 0.084),
            roundLabel.widthAnchor.constraint(equalTo: timerCircle.widthAnchor, multiplier: 0.605),
            roundLabel.heightAnchor.constraint(equalTo: timerCircle.heightAnchor, multiplier: 0.17),
            
            totalTimeLabel.centerXAnchor.constraint(equalTo: timerCircle.layoutMarginsGuide.centerXAnchor),
            totalTimeLabel.topAnchor.constraint(equalTo: self.roundLabel.bottomAnchor, constant: UIScreen.main.bounds.height * 0.01),
            totalTimeLabel.widthAnchor.constraint(equalTo: timerCircle.widthAnchor, multiplier: 0.53),
            totalTimeLabel.heightAnchor.constraint(equalTo: timerCircle.heightAnchor, multiplier: 0.27),
            
            currentStationInfoButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            currentStationInfoButton.topAnchor.constraint(equalTo: timerCircle.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.05),
            currentStationInfoButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.45),
            currentStationInfoButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.068)
        ])
    }
    
    //MARK: - Overlay
    private func showOverlay() {
        let overlayViewController = RorTOverlayViewController()
        overlayViewController.modalPresentationStyle = .overFullScreen // Present it as overlay
        
        let explanationTexts = [
            NSLocalizedString("Station\nStatus", comment: ""),
            NSLocalizedString("Ranking\nStatus", comment: ""),
            NSLocalizedString("Timer &\nStation Info", comment: ""),
            NSLocalizedString("Tap to see what happens", comment: "")
        ]
        var componentPositions: [CGPoint] = []
        var componentFrames: [CGRect] = []
        let timerFrame = timerCircle.frame
        var tabBarTop: CGFloat = 0
        if let tabBarController = self.tabBarController {
            
            for viewController in tabBarController.viewControllers ?? [] {
                if let tabItem = viewController.tabBarItem {
                    
                    if let tabItemView = tabItem.value(forKey: "view") as? UIView {
                        let tabItemFrame = tabItemView.frame
                        
                        let centerXPosition = tabItemFrame.midX
                        
                        let tabBarFrame = tabBarController.tabBar.frame
                        let topAnchorPosition = tabItemFrame.minY + tabBarFrame.origin.y
                        tabBarTop = tabBarFrame.minY
                        componentFrames.append(tabItemFrame)
                        componentPositions.append(CGPoint(x: centerXPosition, y: topAnchorPosition))
                    }
                }
            }
        }
        componentPositions.append(CGPoint(x: timerFrame.midX, y: timerFrame.minY))
        componentFrames.append(timerFrame)
        if let leftButton = navigationItem.leftBarButtonItem {
            if let view = leftButton.value(forKey: "view") as? UIView {
                if let subview = view.subviews.first {
                    let subviewFrameInWindow = view.convert(subview.frame, to: nil)
                    let subviewX = subviewFrameInWindow.midX
                    let subviewY = subviewFrameInWindow.minY
                    componentPositions.append(CGPoint(x: subviewX, y: subviewY))
                    componentFrames.append(subviewFrameInWindow)
                }
            }
        }
        overlayViewController.configureGuide(componentFrames, componentPositions, UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 1).cgColor, explanationTexts, tabBarTop, "Timer", "referee")
        present(overlayViewController, animated: true, completion: nil)
    }
    
    //MARK: - Timer
    func startTimer() {
        let queue = DispatchQueue.global(qos: .background)
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer?.schedule(deadline: .now(), repeating: 1.0)
        timer?.setEventHandler { [weak self] in
            guard let strongSelf = self, !strongSelf.isPaused else {
                return
            }
            if strongSelf.totalTime == strongSelf.rounds * (strongSelf.seconds + strongSelf.moveSeconds) {
                strongSelf.audioPlayerManager.stop()
                strongSelf.timer?.cancel()
            }
            let interval = strongSelf.moveSeconds + strongSelf.seconds
            let timeRemainder = strongSelf.remainingTime % interval
            switch timeRemainder {
            case 300, 180, 60, 30, 10:
                strongSelf.audioPlayerManager.playAudioFile(named: "timer-warning", withExtension: "wav")
            case 5:
                strongSelf.audioPlayerManager.playAudioFile(named: "timer_end", withExtension: "wav")
            case 0...3:
                strongSelf.impactFeedbackGenerator.impactOccurred()
            default:
                break
            }
            
            if strongSelf.timer?.isCancelled == false {
                if strongSelf.time < 1 {
                    if strongSelf.moving {
                        strongSelf.time = strongSelf.seconds
                        strongSelf.moving = false
                        DispatchQueue.main.async {
                            strongSelf.timeTypeLabel.text = NSLocalizedString("Station Time", comment: "")
                            strongSelf.timerLabel.text = String(format:"%02i : %02i", strongSelf.time/60, strongSelf.time % 60)
                        }
                    } else {
                        strongSelf.time = strongSelf.moveSeconds
                        strongSelf.moving = true
                        DispatchQueue.main.async {
                            strongSelf.timeTypeLabel.text = NSLocalizedString("Moving Time", comment: "")
                            strongSelf.timerLabel.text = String(format:"%02i : %02i", strongSelf.time/60, strongSelf.time % 60)
                        }
                    }
                }
                strongSelf.time -= 1
                strongSelf.remainingTime -= 1
                let minute = strongSelf.time/60
                let second = strongSelf.time % 60
                DispatchQueue.main.async {
                    strongSelf.timerLabel.text = String(format:"%02i : %02i", minute, second)
                }
                strongSelf.totalTime += 1
                let totalMinute = strongSelf.totalTime/60
                let totalSecond = strongSelf.totalTime % 60
                
                let attributedString = NSMutableAttributedString(string: NSLocalizedString("TOTAL TIME", comment: "") + "\n", attributes:[NSAttributedString.Key.font: strongSelf.getFontForLanguage(font: "Dosis-Regular", size: strongSelf.fontSize(size: 30)) ?? UIFont(name: "Dosis-Regular", size: 30)!])
                attributedString.append(NSAttributedString(string: String(format:"%02i : %02i", totalMinute, totalSecond), attributes: [NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: strongSelf.fontSize(size: 25)) ?? UIFont(name: "Dosis-Regular", size: 25)!]))
                DispatchQueue.main.async {
                    strongSelf.totalTimeLabel.attributedText = attributedString
                }
            }
        }
        timer?.resume()
    }

    func stopTimer() {
        timer?.cancel()
        timer = nil
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
        self.remainingTime = (rounds * (seconds + moveSeconds)) - t
        let totalMinute = t/60
        let totalSecond = t % 60
        let attributedString = NSMutableAttributedString(string: NSLocalizedString("TOTAL TIME", comment: "") + "\n", attributes: [NSAttributedString.Key.font: getFontForLanguage(font: "Dosis-Regular", size: fontSize(size: 30)) ?? UIFont(name: "Dosis-Regular", size: fontSize(size: 30))!])
        attributedString.append(NSAttributedString(string: String(format:"%02i : %02i", totalMinute, totalSecond), attributes: [NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: fontSize(size: 25)) ?? UIFont(name: "Dosis-Regular", size: fontSize(size: 25))!]))
        self.totalTimeLabel.attributedText = attributedString
        self.round = quotient + 1
        if (moveSeconds + seconds) * self.rounds <= t  {
            self.timeTypeLabel.text = NSLocalizedString("Station Time", comment: "")
            self.timerLabel.text = String(format:"%02i : %02i", 0, 0)
            self.totalTime = (moveSeconds + seconds) * self.rounds
            let totalMinute = totalTime/60
            let totalSecond = totalTime % 60
            let attributedString = NSMutableAttributedString(string: NSLocalizedString("TOTAL TIME", comment: "") + "\n", attributes: [NSAttributedString.Key.font: getFontForLanguage(font: "Dosis-Regular", size: fontSize(size: 30)) ?? UIFont(name: "Dosis-Regular", size: fontSize(size: 30))!])
            attributedString.append(NSAttributedString(string: String(format:"%02i : %02i", totalMinute, totalSecond), attributes: [NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: fontSize(size: 25)) ?? UIFont(name: "Dosis-Regular", size: fontSize(size: 25))!]))
            self.totalTimeLabel.attributedText = attributedString
            self.round = self.rounds
            self.roundLabel.text = NSLocalizedString("Round", comment: "") + " \(self.rounds)"
        } else {
            self.roundLabel.text = NSLocalizedString("Round", comment: "") + " \(quotient + 1)"
            startTimer()
        }
    }
    
    func calculateOnly() async {
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
        self.remainingTime = (rounds * (seconds + moveSeconds)) - t
        let totalMinute = t/60
        let totalSecond = t % 60
        let attributedString = NSMutableAttributedString(string: NSLocalizedString("TOTAL TIME", comment: "") + "\n", attributes: [NSAttributedString.Key.font: getFontForLanguage(font: "Dosis-Regular", size: fontSize(size: 30)) ?? UIFont(name: "Dosis-Regular", size: fontSize(size: 30))!])
        attributedString.append(NSAttributedString(string: String(format:"%02i : %02i", totalMinute, totalSecond), attributes: [NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: fontSize(size: 25)) ?? UIFont(name: "Dosis-Regular", size: fontSize(size: 25))!]))
        self.totalTimeLabel.attributedText = attributedString
        self.round = quotient + 1
        if (moveSeconds + seconds) * self.rounds <= t  {
            self.timeTypeLabel.text = NSLocalizedString("Station Time", comment: "")
            self.timerLabel.text = String(format:"%02i : %02i", 0, 0)
            self.totalTime = (moveSeconds + seconds) * self.rounds
            let totalMinute = totalTime/60
            let totalSecond = totalTime % 60
            let attributedString = NSMutableAttributedString(string: NSLocalizedString("TOTAL TIME", comment: "") + "\n", attributes: [NSAttributedString.Key.font: getFontForLanguage(font: "Dosis-Regular", size: fontSize(size: 30)) ?? UIFont(name: "Dosis-Regular", size: fontSize(size: 30))!])
            attributedString.append(NSAttributedString(string: String(format:"%02i : %02i", totalMinute, totalSecond), attributes: [NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: fontSize(size: 25)) ?? UIFont(name: "Dosis-Regular", size: fontSize(size: 25))!]))
            self.totalTimeLabel.attributedText = attributedString
            self.round = self.rounds
            self.roundLabel.text = NSLocalizedString("Round", comment: "") + " \(self.rounds)"
        } else {
            self.roundLabel.text = NSLocalizedString("Round", comment: "") + " \(quotient + 1)"
        }
    }
    
    func setTime() async {
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
// MARK: - @objc
extension RefereeTimerViewController {
    
    @objc func hostUpdate(notification: Notification) {
        guard let host = notification.userInfo?["host"] as? Host else { return }
        roundLabel.text = NSLocalizedString("Round", comment: "") + " \(host.currentRound)"
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
        guard let items = self.navigationItem.rightBarButtonItems else { return }
        if unread {
            for barButtonItem in items {
                if let btn = barButtonItem.customView as? UIButton, btn.tag == 120 {
                    btn.setImage(self.unreadSome, for: .normal)
                    break
                }
            }
        } else {
            for barButtonItem in items {
                if let btn = barButtonItem.customView as? UIButton, btn.tag == 120 {
                    btn.setImage(self.readAll, for: .normal)
                    break
                }
            }
        }
    }
    
    @objc func appDidEnterBackground(_ notification:Notification) {
        stopTimer()
    }

    @objc func appWillEnterForeground(_ notification:Notification) {
        Task(priority: .high) { @MainActor in
            do {
                async let fetchedHost = H.getHost(gameCode) ?? Host()
                host = try await fetchedHost
                await self.setTime()
                await self.calculateOnly()
                self.startTimer()
            } catch GameWalkerError.invalidGamecode(let message) {
                print(message)
                gamecodeAlert(message)
                return
            } catch GameWalkerError.serverError(let message) {
                print(message)
                serverAlert(message)
                return
            }
        }
    }
    
    @objc func RefreshPressed() {
        Task(priority: .high) { @MainActor in
            do {
                async let fetchedHost = H.getHost(gameCode) ?? Host()
                host = try await fetchedHost
                await self.setTime()
                await self.calculateOnly()
            } catch GameWalkerError.invalidGamecode(let message) {
                print(message)
                gamecodeAlert(message)
                return
            } catch GameWalkerError.serverError(let message) {
                print(message)
                serverAlert(message)
                return
            }
        }
    }
    
    @objc func buttonTapped(_ gesture: UITapGestureRecognizer) {
        if !tapped {
            timerCircle.layer.borderColor = UIColor(red: 40.0 / 255.0, green: 209.0 / 255.0, blue: 113.0 / 255.0, alpha: 1.0).cgColor
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
    
    @objc func currentStationInfoButtonTapped(_ gesture: UITapGestureRecognizer) {
        self.audioPlayerManager.playAudioFile(named: "green", withExtension: "wav")
        guard let station = self.station else { return }
        showRefereeGameInfoPopUp(gameName: station.name, gameLocation: station.place, gamePoitns: String(station.points), gameRule: station.description)
    }
    
    @objc override func infoAction() {
        self.showOverlay()
    }
    
    @objc override func announceAction() {
        showMessagePopUp(messages: RefereeTabBarController.localMessages, role: "referee")
    }
}
