//
//  RefereePVPController.swift
//  Game_Walker
//
//  Created by 김현식 on 1/30/23.
//

import Foundation
import UIKit
import AVFoundation

class RefereePVPController: BaseViewController {
    
    @IBOutlet weak var stationinfoButton: UIButton!
    @IBOutlet weak var annnouncementButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    private var gameCode = UserData.readGamecode("refereeGamecode")!
    private var referee = UserData.readReferee("Referee")!
    private var stationName = ""
    private var teamOrder : [Team] = []
    private var teamA : Team?
    private var teamB : Team?
    private var index: Int = 0
    
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
    
    private let readAll = UIImage(named: "announcement")
    private let unreadSome = UIImage(named: "unreadMessage")
    private var messages: [String] = []
    
    //MARK: - Music Playing
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
            self.annnouncementButton.setImage(readAll, for: .normal)
        } else {
            self.annnouncementButton.setImage(unreadSome, for: .normal)
        }
    }
    
    @objc func readAll(notification: Notification) {
        guard let isRead = notification.userInfo?["isRead"] as? Bool else {
            return
        }
        if isRead {
//            self.announcementButton.setImage(self.readAll, for: .normal)
        } else {
//            self.announcementButton.setImage(self.unreadSome, for: .normal)
        }
    }
    
    override func viewDidLoad() {
        callProtocols()
        H.getHost(gameCode)
        H.listenHost(gameCode, onListenerUpdate: listen(_:))
        S.getStation(gameCode, referee.stationName)
        T.listenTeams(gameCode, onListenerUpdate: listen(_:))
        self.teamA = self.teamOrder[self.round - 1]
        self.teamB = self.teamOrder[self.round]
        addSubviews()
        addConstraints()
        calculateTime()
        runTimer()
        super.viewDidLoad()
    }

    //MARK: - UI elements
    private lazy var lefticonButton: UIButton = {
        var button = UIButton(frame: CGRect(x: 0, y: 0, width: 175, height: 175))
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: teamOrder[index].iconName), for: .normal)
        button.addTarget(self, action: #selector(leftbuttonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var leftteamNumber: UILabel = {
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 83.58, height: 28.76)
        view.backgroundColor = .white
        view.textColor = .black
        view.font = UIFont(name: "Dosis-SemiBold", size: 15)
        view.textAlignment = .center
        view.text = "Team " + "\(self.teamOrder[index].number)"
        return view
    }()
    
    private lazy var leftteamName: UILabel = {
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 174, height: 38)
        view.backgroundColor = .white
        view.textColor = .black
        view.font = UIFont(name: "Dosis-Regular", size: 15)
        view.textAlignment = .center
        view.text = teamOrder[index].name
        return view
    }()
    
    private lazy var leftscoreLabel: UILabel = {
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 150, height: 53)
        view.backgroundColor = .white
        view.textColor = .black
        view.font = UIFont(name: "Dosis-Bold", size: 35)
        view.textAlignment = .center
        view.text = "\(teamOrder[index].points)"
        return view
    }()
    
    private lazy var righticonButton: UIButton = {
        var button = UIButton(frame: CGRect(x: 0, y: 0, width: 175, height: 175))
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: teamOrder[index + 1].iconName), for: .normal)
        button.addTarget(self, action: #selector(rightbuttonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var rightteamNumber: UILabel = {
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 83.58, height: 28.76)
        view.backgroundColor = .white
        view.textColor = .black
        view.font = UIFont(name: "Dosis-SemiBold", size: 15)
        view.textAlignment = .center
        view.text = "Team " + "\(self.teamOrder[index + 1].number)"
        return view
    }()
    
    private lazy var rightteamName: UILabel = {
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 174, height: 38)
        view.backgroundColor = .white
        view.textColor = .black
        view.font = UIFont(name: "Dosis-Regular", size: 15)
        view.textAlignment = .center
        view.text = teamOrder[index + 1].name
        return view
    }()
    
    private lazy var rightscoreLabel: UILabel = {
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 150, height: 53)
        view.backgroundColor = .white
        view.textColor = .black
        view.font = UIFont(name: "Dosis-Bold", size: 35)
        view.textAlignment = .center
        view.text = "\(teamOrder[index + 1].points)"
        return view
    }()
    
    private lazy var roundLabel: UILabel = {
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 149.17, height: 61)
        view.backgroundColor = .white
        view.textColor = .black
        view.font = UIFont(name: "Dosis-SemiBold", size: 45)
        view.textAlignment = .center
        view.text = "Round " + "\(round)"
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
        self.view.addSubview(lefticonButton)
        self.view.addSubview(leftteamNumber)
        self.view.addSubview(leftteamName)
        self.view.addSubview(leftscoreLabel)
        self.view.addSubview(righticonButton)
        self.view.addSubview(rightteamNumber)
        self.view.addSubview(rightteamName)
        self.view.addSubview(timerLabel)
        self.view.addSubview(rightscoreLabel)
    }
    
    func addConstraints() {
//        roundLabel.translatesAutoresizingMaskIntoConstraints = false
//        roundLabel.widthAnchor.constraint(equalToConstant: 149.17).isActive = true
//        roundLabel.heightAnchor.constraint(equalToConstant: 61).isActive = true
//        roundLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
//        roundLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 151).isActive = true
//        lefticonButton.translatesAutoresizingMaskIntoConstraints = false
//        lefticonButton.widthAnchor.constraint(equalToConstant: 135).isActive = true
//        lefticonButton.heightAnchor.constraint(equalToConstant: 135).isActive = true
//        lefticonButton.centerXAnchor.constraint(equalTo: leftcontainerView.centerXAnchor).isActive = true
//        lefticonButton.topAnchor.constraint(equalTo: leftcontainerView.topAnchor, constant: 5).isActive = true
//        leftteamNumber.translatesAutoresizingMaskIntoConstraints = false
//        leftteamNumber.widthAnchor.constraint(equalToConstant: 83.58).isActive = true
//        leftteamNumber.heightAnchor.constraint(equalToConstant: 28.76).isActive = true
//        leftteamNumber.centerXAnchor.constraint(equalTo: leftcontainerView.centerXAnchor).isActive = true
//        leftteamNumber.topAnchor.constraint(equalTo: leftcontainerView.topAnchor, constant: 145.51).isActive = true
//        leftteamName.translatesAutoresizingMaskIntoConstraints = false
//        leftteamName.widthAnchor.constraint(equalToConstant: 126.45).isActive = true
//        leftteamName.heightAnchor.constraint(equalToConstant: 28.76).isActive = true
//        leftteamName.centerXAnchor.constraint(equalTo: leftcontainerView.centerXAnchor).isActive = true
//        leftteamName.topAnchor.constraint(equalTo: leftcontainerView.topAnchor, constant: 167.46).isActive = true
//        leftscoreLabel.translatesAutoresizingMaskIntoConstraints = false
//        leftscoreLabel.widthAnchor.constraint(equalToConstant: 109.01).isActive = true
//        leftscoreLabel.heightAnchor.constraint(equalToConstant: 40.12).isActive = true
//        leftscoreLabel.centerXAnchor.constraint(equalTo: leftcontainerView.centerXAnchor).isActive = true
//        leftscoreLabel.topAnchor.constraint(equalTo: leftcontainerView.topAnchor, constant:191.88).isActive = true
//        righticonButton.translatesAutoresizingMaskIntoConstraints = false
//        righticonButton.widthAnchor.constraint(equalToConstant: 135).isActive = true
//        righticonButton.heightAnchor.constraint(equalToConstant: 135).isActive = true
//        righticonButton.centerXAnchor.constraint(equalTo: rightcontainerView.centerXAnchor).isActive = true
//        righticonButton.topAnchor.constraint(equalTo: rightcontainerView.topAnchor, constant: 5).isActive = true
//        rightteamNumber.translatesAutoresizingMaskIntoConstraints = false
//        rightteamNumber.widthAnchor.constraint(equalToConstant: 83.58).isActive = true
//        rightteamNumber.heightAnchor.constraint(equalToConstant: 28.76).isActive = true
//        rightteamNumber.centerXAnchor.constraint(equalTo: rightcontainerView.centerXAnchor).isActive = true
//        rightteamNumber.topAnchor.constraint(equalTo: rightcontainerView.topAnchor, constant: 145.51).isActive = true
//        rightteamName.translatesAutoresizingMaskIntoConstraints = false
//        rightteamName.widthAnchor.constraint(equalToConstant: 126.45).isActive = true
//        rightteamName.heightAnchor.constraint(equalToConstant: 28.76).isActive = true
//        rightteamName.centerXAnchor.constraint(equalTo: rightcontainerView.centerXAnchor).isActive = true
//        rightteamName.topAnchor.constraint(equalTo: rightcontainerView.topAnchor, constant: 167.46).isActive = true
//        rightscoreLabel.translatesAutoresizingMaskIntoConstraints = false
//        rightscoreLabel.widthAnchor.constraint(equalToConstant: 109.01).isActive = true
//        rightscoreLabel.heightAnchor.constraint(equalToConstant: 40.12).isActive = true
//        rightscoreLabel.centerXAnchor.constraint(equalTo: rightcontainerView.centerXAnchor).isActive = true
//        rightscoreLabel.topAnchor.constraint(equalTo: rightcontainerView.topAnchor, constant: 191.88).isActive = true
//        timerLabel.translatesAutoresizingMaskIntoConstraints = false
//        timerLabel.widthAnchor.constraint(equalToConstant: 179).isActive = true
//        timerLabel.heightAnchor.constraint(equalToConstant: 73).isActive = true
//        timerLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
//        timerLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 575).isActive = true
//        timetypeLabel.translatesAutoresizingMaskIntoConstraints = false
//        timetypeLabel.widthAnchor.constraint(equalToConstant: 168).isActive = true
//        timetypeLabel.heightAnchor.constraint(equalToConstant: 44).isActive = true
//        timetypeLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
//        timetypeLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 520).isActive = true
    }
    
    @objc func leftbuttonTapped() {
        UserData.writeTeam(teamA!, "points")
        performSegue(withIdentifier: "givePointsPVP", sender: self)
    }
    
    @objc func rightbuttonTapped() {
        UserData.writeTeam(teamB!, "points")
        performSegue(withIdentifier: "givePointsPVP", sender: self)
    }
    
    @IBAction func stationinfoButtonPressed(_ sender: UIButton) {
        showRefereeGameInfoPopUp()
    }
    
    @IBAction func annoucmentButtonPressed(_ sender: UIButton) {
        showRefereeMessagePopUp(messages: RefereeRankingPVEViewController.messages)
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        
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
                        strongSelf.rounds! -= 1
                        strongSelf.index += 2
                        strongSelf.lefticonButton.setImage(UIImage(named: strongSelf.teamOrder[strongSelf.index].iconName), for: .normal)
                        strongSelf.leftteamNumber.text = "Team " + "\(strongSelf.teamOrder[strongSelf.index].number)"
                        strongSelf.leftteamName.text = strongSelf.teamOrder[strongSelf.index].name
                        strongSelf.leftscoreLabel.text = "\(strongSelf.teamOrder[strongSelf.index].points)"
                        strongSelf.righticonButton.setImage(UIImage(named: strongSelf.teamOrder[strongSelf.index + 1].iconName), for: .normal)
                        strongSelf.rightteamNumber.text = "Team " + "\(strongSelf.teamOrder[strongSelf.index + 1].number)"
                        strongSelf.rightteamName.text = strongSelf.teamOrder[strongSelf.index + 1].name
                        strongSelf.rightscoreLabel.text = "\(strongSelf.teamOrder[strongSelf.index + 1].points)"
                        strongSelf.roundLabel.text = "Round " + "\(strongSelf.round)"
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
}

//MARK: - Protocols
extension RefereePVPController: GetStation, GetHost, TeamUpdateListener, HostUpdateListener {
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
            if self.teamA!.name == team.name {
                self.teamA! = team
                leftscoreLabel.text = "\(self.teamA!.points)"
            }
            if self.teamB!.name == team.name {
                self.teamB! = team
                rightscoreLabel.text = "\(self.teamB!.points)"
            }
        }
    }
    
    func updateHost(_ host: Host) {
        self.isPaused = host.paused
        self.pauseTime = host.pauseTimestamp
        self.pausedTime = host.pausedTime
        self.round = host.currentRound
        self.roundLabel.text = "Round \(host.currentRound)"
        self.currentRound = host.currentRound
    }
    
    func callProtocols() {
        H.delegate_getHost = self
        H.delegates.append(self)
        S.delegate_getStation = self
        T.delegates.append(self)
    }
    
    func listen(_ _ : [String : Any]){
    }
}



