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
    @IBOutlet weak var leaveButton: UIButton!
    
    private var gameCode = UserData.readGamecode("refereeGameCode")!
    private var referee = UserData.readReferee("Referee")!
    private var team : Team?
    private var teamOrder : [Team] = [Team(gamecode: "333333", name: "Dok2", number: 1, players: [], points: 0, stationOrder: [0], iconName: "iconDaisy"),Team(gamecode: "333333", name: "ABCDEFGHIJKLMNOP", number: 2, players: [], points: 0, stationOrder: [0], iconName: "iconBoy"),
                                      Team(gamecode: "333333", name: "Simon Dominic", number: 3, players: [], points: 0, stationOrder: [0], iconName: "iconGirl"),
                                      Team(gamecode: "333333", name: "Driver", number: 4, players: [], points: 0, stationOrder: [0], iconName: "iconAir")]
    
    private var stationUuid : String = ""
    private var points : Int = 0
    private var name : String = ""
    private var location : String = ""
    private var rule : String = ""
    
    private let readAll = UIImage(named: "announcement")
    private let unreadSome = UIImage(named: "unreadMessage")
    private var messages: [String] = []
    
    private var startTime : Int = 0
    private var pauseTime : Int = 0
    private var pausedTime : Int = 0
    private var timer = Timer()
    private var totalTime: Int = 0
    private var time: Int?
    private var seconds: Int = 100
    private var moveSeconds: Int = 50
    private var moving: Bool = true
    private var tapped: Bool = false
    private var round: Int = 1
    private var rounds: Int = 8
    private var isPaused = true
    private var currentRound : Int = 0
    private var t : Int = 0

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
        showRefereeGameInfoPopUp(gameName: self.name, gameLocation: self.location, gamePoitns: String(self.points), gameRule: self.rule)
    }
    
    @IBAction func messageButtonPressed(_ sender: Any) {
        showRefereeMessagePopUp(messages: RefereeRankingPVEViewController.messages)
    }
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func leaveButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "toRegister", sender: self)
    }
        
    @objc func buttonTapped() {
        UserData.writeTeam(self.team!, "Team")
        let popUpWindow = GivePointsController(team: UserData.readTeam("Team")!, gameCode: UserData.readGamecode("refereeGamecode")!)
        self.present(popUpWindow, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        callProtocols()
        H.getHost(gameCode)
        H.listenHost(gameCode, onListenerUpdate: listen(_:))
        S.getStationList(gameCode)
        T.listenTeams(gameCode, onListenerUpdate: listen(_:))
        self.team = self.teamOrder[self.round - 1]
        addSubviews()
        addConstraints()
        calculateTime()
        runTimer()
        super.viewDidLoad()
    }

//MARK: - UI elements
    
    private lazy var iconButton: UIImageView = {
        var view = UIImageView(frame: CGRect(x: 0, y: 0, width: 175, height: 175))
        view.image = UIImage(named: self.teamOrder[self.round - 1].iconName)
        view.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonTapped))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    private lazy var teamInfoLabel: UILabel = {
        let teamNumber = "Team \(self.teamOrder[self.round - 1].number)"
        let teamName = self.teamOrder[self.round - 1].name
        let score = "\(self.teamOrder[self.round - 1].points)"
        let attributedText = NSMutableAttributedString()
        let teamNumberAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-SemiBold", size: 25) ?? UIFont.systemFont(ofSize: 25),
            .foregroundColor: UIColor.black
        ]
        let teamNumberAttributedString = NSAttributedString(string: teamNumber + "\n", attributes: teamNumberAttributes)
        attributedText.append(teamNumberAttributedString)
        let teamNameAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Regular", size: 25) ?? UIFont.systemFont(ofSize: 25),
            .foregroundColor: UIColor.black
        ]
        let teamNameAttributedString = NSAttributedString(string: teamName + "\n", attributes: teamNameAttributes)
        attributedText.append(teamNameAttributedString)
        let scoreAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Bold", size: 50) ?? UIFont.boldSystemFont(ofSize: 50),
            .foregroundColor: UIColor.black
        ]
        let scoreAttributedString = NSAttributedString(string: score, attributes: scoreAttributes)
        attributedText.append(scoreAttributedString)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 174, height: 139))
        label.backgroundColor = .white
        label.attributedText = attributedText
        label.numberOfLines = 3
        label.textAlignment = .center
        return label
    }()
    
    private lazy var winButton: UILabel = {
        var label = UILabel(frame: CGRect(x: 0, y: 0, width: 57, height: 13))
        label.layer.cornerRadius = 20
        label.backgroundColor = .blue
        label.text = "Win"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Bold", size: 13)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(winButtonTapped))
        label.addGestureRecognizer(tapGesture)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    @objc func winButtonTapped() {
        Task {
            await T.givePoints(gameCode, self.team!.name, self.points)
        }
        winButton.isEnabled = false
        winButton.backgroundColor = .gray
        loseButton.isEnabled = true
        loseButton.backgroundColor = .yellow
    }
    
    private lazy var loseButton: UILabel = {
        var label = UILabel(frame: CGRect(x: 0, y: 0, width: 57, height: 13))
        label.layer.cornerRadius = 20
        label.backgroundColor = .yellow
        label.text = "Lose"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Bold", size: 13)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(loseButtonTapped))
        label.addGestureRecognizer(tapGesture)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    @objc func loseButtonTapped() {
        winButton.backgroundColor = .blue
        winButton.isEnabled = true
        loseButton.backgroundColor = .gray
        loseButton.isEnabled = false
    }
    
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
        view.font = UIFont(name: "Dosis-Regular", size: 25)
        view.textAlignment = .center
        view.text = "Moving Time" + String(format:"%02i : %02i", self.moveSeconds/60, self.moveSeconds % 60)
        view.numberOfLines = 0
        return view
    }()
    
    private lazy var gameCodeLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 127, height: 31)
        let attributedText = NSMutableAttributedString()
        let gameCodeAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Bold", size: 15) ?? UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor.black
        ]
        let gameCodeAttributedString = NSAttributedString(string: "Game Code" + "\n", attributes: gameCodeAttributes)
        attributedText.append(gameCodeAttributedString)
        let numberAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Bold", size: 10) ?? UIFont.systemFont(ofSize: 25),
            .foregroundColor: UIColor.black
        ]
        let numberAttributedString = NSAttributedString(string: gameCode, attributes: numberAttributes)
        attributedText.append(numberAttributedString)
        label.backgroundColor = .white
        label.attributedText = attributedText
        label.textColor = UIColor(red: 0, green: 0, blue: 0 , alpha: 1)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    func makeTeamInfoLabel() {
        let teamNumber = "Team \(self.teamOrder[self.round - 1].number)"
        let teamName = self.teamOrder[self.round - 1].name
        let score = "\(self.teamOrder[self.round - 1].points)"
        let attributedText = NSMutableAttributedString()
        let teamNumberAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-SemiBold", size: 25) ?? UIFont.systemFont(ofSize: 25),
            .foregroundColor: UIColor.black
        ]
        let teamNumberAttributedString = NSAttributedString(string: teamNumber + "\n", attributes: teamNumberAttributes)
        attributedText.append(teamNumberAttributedString)
        let teamNameAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Regular", size: 25) ?? UIFont.systemFont(ofSize: 25),
            .foregroundColor: UIColor.black
        ]
        let teamNameAttributedString = NSAttributedString(string: teamName + "\n", attributes: teamNameAttributes)
        attributedText.append(teamNameAttributedString)
        let scoreAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Bold", size: 50) ?? UIFont.boldSystemFont(ofSize: 50),
            .foregroundColor: UIColor.black
        ]
        let scoreAttributedString = NSAttributedString(string: score, attributes: scoreAttributes)
        attributedText.append(scoreAttributedString)
        self.teamInfoLabel.attributedText = attributedText
    }
    
    func addSubviews() {
        self.view.addSubview(gameCodeLabel)
        self.view.addSubview(roundLabel)
        self.view.addSubview(iconButton)
        self.view.addSubview(teamInfoLabel)
        self.view.addSubview(winButton)
        self.view.addSubview(loseButton)
        self.view.addSubview(timerLabel)
    }
    
    func addConstraints() {
        gameCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        gameCodeLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        gameCodeLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.0541).isActive = true
        gameCodeLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.04).isActive = true
        gameCodeLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.2).isActive = true
        
        roundLabel.translatesAutoresizingMaskIntoConstraints = false
        roundLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.579).isActive = true
        roundLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.0751).isActive = true
        roundLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        roundLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.124).isActive = true
        
        iconButton.translatesAutoresizingMaskIntoConstraints = false
        iconButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.467).isActive = true
        iconButton.heightAnchor.constraint(equalTo: iconButton.widthAnchor, multiplier: 1).isActive = true
        iconButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        iconButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.246).isActive = true
        
        teamInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        teamInfoLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.464).isActive = true
        teamInfoLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.159).isActive = true
        teamInfoLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        teamInfoLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.470).isActive = true
        
        winButton.translatesAutoresizingMaskIntoConstraints = false
        winButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.176).isActive = true
        winButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.032).isActive = true
        winButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: self.view.bounds.width * 0.315).isActive = true
        winButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.619).isActive = true
        
        loseButton.translatesAutoresizingMaskIntoConstraints = false
        loseButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.176).isActive = true
        loseButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.032).isActive = true
        loseButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: self.view.bounds.width * 0.525).isActive = true
        loseButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.619).isActive = true
        
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.477).isActive = true
        timerLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.0394).isActive = true
        timerLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        timerLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.70).isActive = true
    }
    
//MARK: - Timer
    func runTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let strongSelf = self else {
                return
            }
            if !strongSelf.isPaused {
                if strongSelf.rounds < 1 {
                    strongSelf.playMusic()
                    timer.invalidate()
                }
                if strongSelf.time! < 1 {
                    if strongSelf.moving {
                        strongSelf.time = strongSelf.seconds
                        strongSelf.timerLabel.text = "Game Time  " + String(format:"%02i : %02i", strongSelf.time!/60, strongSelf.time! % 60)
                        strongSelf.moving = false
                    } else {
                        strongSelf.time = strongSelf.moveSeconds
                        strongSelf.timerLabel.text = "Moving Time  " + String(format:"%02i : %02i", strongSelf.time!/60, strongSelf.time! % 60)
                        strongSelf.moving = true
                        strongSelf.roundLabel.text = "Round \(strongSelf.round)"
                        strongSelf.iconButton.image = UIImage(named: strongSelf.teamOrder[strongSelf.round - 1].iconName)
                        strongSelf.makeTeamInfoLabel()
                        strongSelf.rounds -= 1
                    }
                }
                else {
                    strongSelf.time! -= 1
                    let minute = strongSelf.time!/60
                    let second = strongSelf.time! % 60
                    if strongSelf.moving {
                        strongSelf.timerLabel.text = "Game Time  " + String(format:"%02i : %02i", minute, second)
                        strongSelf.roundLabel.text = "Round \(strongSelf.round)"
                        strongSelf.iconButton.image = UIImage(named: strongSelf.teamOrder[strongSelf.round - 1].iconName)
                        strongSelf.makeTeamInfoLabel()
                    } else {
                        strongSelf.timerLabel.text = "Moving Time  " + String(format:"%02i : %02i", minute, second)
                        strongSelf.roundLabel.text = "Round \(strongSelf.round)"
                        strongSelf.iconButton.image = UIImage(named: strongSelf.teamOrder[strongSelf.round - 1].iconName)
                        strongSelf.makeTeamInfoLabel()
                    }
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
        let remainder = t%(moveSeconds + seconds)
        if (remainder/moveSeconds) == 0 {
            self.time = (moveSeconds - remainder)
            self.moving = true
            let minute = (moveSeconds - remainder)/60
            let second = (moveSeconds - remainder) % 60
            self.timerLabel.text = "Moving Time  " + String(format:"%02i : %02i", minute, second)
        }
        else {
            self.time = (seconds - remainder)
            self.moving = false
            let minute = (seconds - remainder)/60
            let second = (seconds - remainder) % 60
            self.timerLabel.text = "Game Time  " + String(format:"%02i : %02i", minute, second)
        }
        self.rounds = self.rounds - self.round
    }
}

//MARK: - Protocols
extension RefereePVEController: GetStation, StationList, GetHost, TeamUpdateListener, HostUpdateListener {
    func getStation(_ station: Station) {
        self.teamOrder = station.teamOrder
        self.name = station.name
        self.location = station.place
        self.rule = station.description
        self.points = station.points
    }
    
    func listOfStations(_ stations: [Station]) {
        for station in stations {
            if station.name == referee.stationName {
                self.stationUuid = station.uuid
                S.getStation(gameCode, station.uuid)
            }
        }
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
        let teamNumber = "Team \(self.teamOrder[self.round - 1].number)"
        let teamName = self.teamOrder[self.round - 1].name
        let score = "\(self.team!.points)"
        let attributedText = NSMutableAttributedString()
        let teamNumberAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-SemiBold", size: 25) ?? UIFont.systemFont(ofSize: 25),
            .foregroundColor: UIColor.black
        ]
        let teamNumberAttributedString = NSAttributedString(string: teamNumber + "\n", attributes: teamNumberAttributes)
        attributedText.append(teamNumberAttributedString)
        let teamNameAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Regular", size: 25) ?? UIFont.systemFont(ofSize: 25),
            .foregroundColor: UIColor.black
        ]
        let teamNameAttributedString = NSAttributedString(string: teamName + "\n", attributes: teamNameAttributes)
        attributedText.append(teamNameAttributedString)
        let scoreAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Bold", size: 50) ?? UIFont.boldSystemFont(ofSize: 50),
            .foregroundColor: UIColor.black
        ]
        let scoreAttributedString = NSAttributedString(string: score, attributes: scoreAttributes)
        attributedText.append(scoreAttributedString)
        self.teamInfoLabel.attributedText = attributedText
        
    }
    
    func updateHost(_ host: Host) {
        self.isPaused = host.paused
        self.pauseTime = host.pauseTimestamp
        self.pausedTime = host.pausedTime
        self.round = host.currentRound
        self.roundLabel.text = "Round \(host.currentRound)"
        self.currentRound = host.currentRound
    }
    
    func listen(_ _ : [String : Any]){
    }
    
    func callProtocols() {
        H.delegate_getHost = self
        H.delegates.append(self)
        S.delegate_getStation = self
        S.delegate_stationList = self
        T.delegates.append(self)
    }
}


