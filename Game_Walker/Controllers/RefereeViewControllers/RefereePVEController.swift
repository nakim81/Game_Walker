//
//  RefereePVEController.swift
//  Game_Walker
//
//  Created by 김현식 on 1/27/23.
//

import Foundation
import UIKit
import AVFoundation

class RefereePVEController: BaseViewController {
    
    @IBOutlet weak var stationinfoButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    private var stationName = ""
    private var gameCode = UserData.readGamecode("refereeGamecode")!
    private var referee = UserData.readReferee("Referee")!

    private var team : Team?
    private var teamOrder : [Team] = [Team(gamecode: "333333", name: "Dok2", number: 100, players: [], points: 0, stationOrder: [0], iconName: "iconCutApple")]
    
    private let readAll = UIImage(named: "announcement")
    private let unreadSome = UIImage(named: "unreadMessage")
    private var messages: [String] = []
    
    private var startTime : Int = 0
    private var pauseTime : Int = 0
    private var pausedTime : Int = 0
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
    private var currentRound : Int = 0
    private var t : Int = 0
    
    var audioPlayer: AVAudioPlayer?

    func playMusic() {
        guard let soundURL = Bundle.main.url(forResource: "timer_end", withExtension: "wav") else {
            print("Background music file not found.")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.numberOfLoops = 2
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Failed to play background music: \(error.localizedDescription)")
        }
    }
    
    func stopMusic() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(readAll(notification:)), name: RefereeRankingPVEViewController.notificationName, object: nil)
        if RefereeRankingPVEViewController.read {
            self.messageButton.setImage(readAll, for: .normal)
        } else {
            self.messageButton.setImage(unreadSome, for: .normal)
        }
    }
    
    @objc func readAll(notification: Notification) {
        guard let isRead = notification.userInfo?["isRead"] as? Bool else {
            return
        }
        if isRead {
            //self.announcementButton.setImage(self.readAll, for: .normal)
        } else {
            //self.announcementButton.setImage(self.unreadSome, for: .normal)
        }
    }
    
    @IBAction func stationinfoButtonPressed(_ sender: Any) {
        showRefereeGameInfoPopUp()
    }
    
    @IBAction func messageButtonPressed(_ sender: Any) {
        showRefereeMessagePopUp(messages: RefereeRankingPVEViewController.messages)
    }
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
        
    }
        
    @objc func buttonTapped() {
        UserData.writeTeam(self.team!, "Team")
        let popUpWindow = GivePointsController(team: UserData.readTeam("Team")!, gameCode: UserData.readGamecode("refereeGamecode")!)
        self.present(popUpWindow, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        H.delegate_getHost = self
        H.delegates.append(self)
        S.delegate_getStation = self
        T.delegates.append(self)
        
        H.getHost(gameCode)
        H.listenHost(gameCode, onListenerUpdate: listen(_:))
        S.getStation(gameCode, referee.stationName)
        T.listenTeams(gameCode, onListenerUpdate: listen(_:))
        
        self.team = self.teamOrder[self.round - 1]
        self.addSubviews()
        self.addConstraints()
        calculateTime()
        runTimer()
        super.viewDidLoad()
    }
//MARK: - UI elements
    private lazy var borderView: UIView = {
        var view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 211, height: 306)
        view.backgroundColor = .white
        var border = UIView()
        border.bounds = view.bounds.insetBy(dx: -5, dy: -5)
        border.center = view.center
        view.addSubview(border)
        view.bounds = view.bounds.insetBy(dx: -5, dy: -5)
        border.layer.borderWidth = 5
        border.layer.borderColor = UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 0.5).cgColor
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonTapped))
        border.addGestureRecognizer(tapGesture)
        border.isUserInteractionEnabled = true
        return view
    }()

    private lazy var iconButton: UIButton = {
        var button = UIButton(frame: CGRect(x: 0, y: 0, width: 175, height: 175))
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: self.teamOrder[self.round - 1].iconName), for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var teamNumber: UILabel = {
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 115, height: 38)
        view.backgroundColor = .white
        view.textColor = .black
        view.font = UIFont(name: "Dosis-SemiBold", size: 25)
        view.textAlignment = .center
        view.text = "Team " + "\(self.teamOrder[self.round - 1].number)"
        return view
    }()
    
    private lazy var teamName: UILabel = {
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 174, height: 38)
        view.backgroundColor = .white
        view.textColor = .black
        view.font = UIFont(name: "Dosis-Regular", size: 25)
        view.textAlignment = .center
        view.text = self.teamOrder[self.round - 1].name
        return view
    }()
    
    private lazy var scoreLabel: UILabel = {
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 150, height: 53)
        view.backgroundColor = .white
        view.textColor = .black
        view.font = UIFont(name: "Dosis-Bold", size: 50)
        view.textAlignment = .center
        view.text = "\(self.teamOrder[self.round - 1].points)"
        return view
    }()
    
    private lazy var roundLabel: UILabel = {
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 149.17, height: 61)
        view.backgroundColor = .white
        view.textColor = .black
        view.font = UIFont(name: "Dosis-SemiBold", size: 45)
        view.textAlignment = .center
        view.text = "Round " + "\(self.round)"
        return view
    }()
    
    private lazy var timerLabel: UILabel = {
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 179, height: 53)
        view.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        view.font = UIFont(name: "Dosis-Regular", size: 55)
        view.textAlignment = .center
        return view
    }()
    
    private lazy var timetypeLabel: UILabel = {
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 151, height: 44)
        view.backgroundColor = .white
        view.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        view.font = UIFont(name: "Dosis-Regular", size: 35)
        view.textAlignment = .center
        view.text = "Moving Time"
        return view
    }()
    
    func addSubviews() {
        self.view.addSubview(roundLabel)
        self.view.addSubview(borderView)
        self.view.addSubview(iconButton)
        self.view.addSubview(teamNumber)
        self.view.addSubview(teamName)
        self.view.addSubview(timerLabel)
        self.view.addSubview(scoreLabel)
        self.view.addSubview(timetypeLabel)
    }
    
    func addConstraints() {
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.widthAnchor.constraint(equalToConstant: 211).isActive = true
        borderView.heightAnchor.constraint(equalToConstant: 306).isActive = true
        borderView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        borderView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 187).isActive = true
        iconButton.translatesAutoresizingMaskIntoConstraints = false
        iconButton.widthAnchor.constraint(equalToConstant: 175).isActive = true
        iconButton.heightAnchor.constraint(equalToConstant: 175).isActive = true
        iconButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        iconButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 200).isActive = true
        teamNumber.translatesAutoresizingMaskIntoConstraints = false
        teamNumber.widthAnchor.constraint(equalToConstant: 115).isActive = true
        teamNumber.heightAnchor.constraint(equalToConstant: 38).isActive = true
        teamNumber.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        teamNumber.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 382).isActive = true
        teamName.translatesAutoresizingMaskIntoConstraints = false
        teamName.widthAnchor.constraint(equalToConstant: 174).isActive = true
        teamName.heightAnchor.constraint(equalToConstant: 38).isActive = true
        teamName.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        teamName.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 411).isActive = true
        roundLabel.translatesAutoresizingMaskIntoConstraints = false
        roundLabel.widthAnchor.constraint(equalToConstant: 149.17).isActive = true
        roundLabel.heightAnchor.constraint(equalToConstant: 61).isActive = true
        roundLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        roundLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 101).isActive = true
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.widthAnchor.constraint(equalToConstant: 179).isActive = true
        timerLabel.heightAnchor.constraint(equalToConstant: 73).isActive = true
        timerLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        timerLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 575).isActive = true
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        scoreLabel.heightAnchor.constraint(equalToConstant: 53).isActive = true
        scoreLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        scoreLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 440).isActive = true
        timetypeLabel.translatesAutoresizingMaskIntoConstraints = false
        timetypeLabel.widthAnchor.constraint(equalToConstant: 168).isActive = true
        timetypeLabel.heightAnchor.constraint(equalToConstant: 44).isActive = true
        timetypeLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        timetypeLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 520).isActive = true
    }
    
//MARK: - Timer
    func runTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let strongSelf = self else {
                return
            }
            if !strongSelf.isPaused {
                if strongSelf.rounds! < 1 {
                    strongSelf.playMusic()
                    timer.invalidate()
                }
                if strongSelf.time! < 1 {
                    if strongSelf.moving {
                        strongSelf.time = strongSelf.seconds
                        strongSelf.moving = false
                        strongSelf.timetypeLabel.text = "Game Time"
                    } else {
                        strongSelf.time = strongSelf.moveSeconds
                        strongSelf.moving = true
                        strongSelf.timetypeLabel.text = "Moving Time"
                        strongSelf.teamNumber.text = "Team " + "\(strongSelf.teamOrder[strongSelf.round - 1].number)"
                        strongSelf.roundLabel.text = "Round \(strongSelf.round)"
                        strongSelf.rounds! -= 1
                    }
                }
                strongSelf.time! -= 1
                let minute = strongSelf.time!/60
                let second = strongSelf.time! % 60
                strongSelf.timerLabel.text = String(format:"%02i : %02i", minute, second)
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
        let remainder = t%(moveSeconds + seconds)
        if (remainder/moveSeconds) == 0 {
            self.timetypeLabel.text = "Moving Time"
            self.time = (moveSeconds - remainder)
            self.moving = true
            let minute = (moveSeconds - remainder)/60
            let second = (moveSeconds - remainder) % 60
            self.timerLabel.text = String(format:"%02i : %02i", minute, second)
        }
        else {
            self.timetypeLabel.text = "Game Time"
            self.time = (seconds - remainder)
            self.moving = false
            let minute = (seconds - remainder)/60
            let second = (seconds - remainder) % 60
            self.timerLabel.text = String(format:"%02i : %02i", minute, second)
        }
        self.rounds! = self.rounds! - self.round
    }
    
    func listen(_ _ : [String : Any]){
    }
    
}

//MARK: - Protocols
extension RefereePVEController: GetStation, GetHost, TeamUpdateListener, HostUpdateListener {
    func getStation(_ station: Station) {
        self.stationName = station.name
        self.teamOrder = station.teamOrder
    }
    
    func getHost(_ host: Host) {
        self.seconds = host.gameTime
        self.moveSeconds = host.movingTime
        self.startTime = host.startTimestamp
        self.isPaused = host.paused
        self.pauseTime = host.pauseTimestamp
        self.pausedTime = host.pausedTime
        self.rounds = host.rounds
        self.round = host.currentRound
        self.messages = host.announcements
    }
    
    func updateTeams(_ teams: [Team]) {
        for team in teams {
            if self.team!.name == team.name {
                self.team! = team
            }
        }
        scoreLabel.text = "\(self.team!.points)"
    }
    
    func updateHost(_ host: Host) {
        self.isPaused = host.paused
        self.pauseTime = host.pauseTimestamp
        self.pausedTime = host.pausedTime
        self.round = host.currentRound
        self.roundLabel.text = "Round \(host.currentRound)"
        self.currentRound = host.currentRound
    }
}


