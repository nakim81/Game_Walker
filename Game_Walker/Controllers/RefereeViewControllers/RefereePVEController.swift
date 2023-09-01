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
    private var team : Team = Team()
    private var teams : [Team] = [Team()]
    private var teamOrder : [Team] = [Team()]
    
    private var points : Int = 0
    private var name : String = ""
    private var location : String = ""
    private var rule : String = ""
    
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let audioPlayerManager = AudioPlayerManager()
    private let readAll = UIImage(named: "announcement")
    private let unreadSome = UIImage(named: "unreadMessage")
    private var messages: [String] = []
    
    private var gameStart : Bool = false
    private var gameOver : Bool = false
    private var startTime : Int = 0
    private var pauseTime : Int = 0
    private var pausedTime : Int = 0
    private var timer = Timer()
    private var remainingTime: Int = 0
    private var time: Int?
    private var seconds: Int = 0
    private var moveSeconds: Int = 0
    private var moving: Bool = true
    private var round: Int = 1
    private var rounds: Int = 8
    private var isPaused = true
    private var t : Int = 0
    
    override func viewDidLoad() {
        callProtocols()
        T.getTeamList(gameCode)
        H.getHost(gameCode)
        H.listenHost(gameCode, onListenerUpdate: listen(_:))
        T.listenTeams(gameCode, onListenerUpdate: listen(_:))
        super.viewDidLoad()
    }

//MARK: - Messages
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
            self.messageButton.setImage(self.readAll, for: .normal)
        } else {
            self.messageButton.setImage(self.unreadSome, for: .normal)
            self.audioPlayerManager.playAudioFile(named: "message", withExtension: "wav")
        }
    }
    
//MARK: - Buttons Pressed
    @IBAction func stationinfoButtonPressed(_ sender: Any) {
        self.audioPlayerManager.playAudioFile(named: "green", withExtension: "wav")
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
        if self.team.number == 0 {
            alert(title: "The Team doesn't exist", message: "This is an invalid team.")
        } else {
            UserData.writeTeam(self.team, "Team")
            let popUpWindow = GivePointsController(team: UserData.readTeam("Team")!, gameCode: UserData.readGamecode("refereeGameCode")!)
            self.present(popUpWindow, animated: true, completion: nil)
        }
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
        let teamNameAttributedString = NSAttributedString(string: teamName, attributes: teamNameAttributes)
        attributedText.append(teamNameAttributedString)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 174, height: 78))
        label.backgroundColor = .white
        label.attributedText = attributedText
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private lazy var scoreLabel: UILabel = {
        let attributedText = NSMutableAttributedString()
        let score = "\(self.teamOrder[self.round - 1].points)"
        let scoreAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Bold", size: 50) ?? UIFont.boldSystemFont(ofSize: 50),
            .foregroundColor: UIColor.black
        ]
        let scoreAttributedString = NSAttributedString(string: score, attributes: scoreAttributes)
        attributedText.append(scoreAttributedString)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 53))
        label.backgroundColor = .white
        label.attributedText = attributedText
        label.numberOfLines = 3
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private lazy var winButton: UIImageView = {
        var view = UIImageView(frame: CGRect(x: 0, y: 0, width: 57, height: 13))
        view.image = UIImage(named: "Win Blue Button")
        var label = UILabel(frame: CGRect(x: 0, y: 0, width: 57, height: 13))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Win"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Bold", size: 13)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        view.addSubview(label)
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5).isActive = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(winButtonTapped))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    @objc func winButtonTapped() {
        //self.audioPlayerManager.playAudioFile(named: "point up", withExtension: "wav")
        Task {
            await T.givePoints(gameCode, self.team.name, self.points)
        }
        winButton.gestureRecognizers?.forEach { gestureRecognizer in
            gestureRecognizer.isEnabled = false
        }
        winButton.image = UIImage(named: "Lose Gray Button")
        loseButton.gestureRecognizers?.forEach { gestureRecognizer in
            gestureRecognizer.isEnabled = true
        }
        loseButton.image = UIImage(named: "Lose Yellow Button")
    }
    
    private lazy var loseButton: UIImageView = {
        var view = UIImageView(frame: CGRect(x: 0, y: 0, width: 57, height: 13))
        view.image = UIImage(named: "Lose Yellow Button")
        var label = UILabel(frame: CGRect(x: 0, y: 0, width: 57, height: 13))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Lose"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Bold", size: 13)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        view.addSubview(label)
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5).isActive = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(loseButtonTapped))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    @objc func loseButtonTapped() {
        //self.audioPlayerManager.playAudioFile(named: "point down", withExtension: "wav")
        winButton.gestureRecognizers?.forEach { gestureRecognizer in
            gestureRecognizer.isEnabled = true
        }
        winButton.image = UIImage(named: "Win Blue Button")
        loseButton.gestureRecognizers?.forEach { gestureRecognizer in
            gestureRecognizer.isEnabled = false
        }
        loseButton.image = UIImage(named: "Lose Gray Button")
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
        view.adjustsFontSizeToFitWidth = true
        view.minimumScaleFactor = 0.5
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
        let teamNameAttributedString = NSAttributedString(string: teamName, attributes: teamNameAttributes)
        attributedText.append(teamNameAttributedString)
        self.teamInfoLabel.attributedText = attributedText
    }
    
    func makeScoreLabel() {
        let attributedText = NSMutableAttributedString()
        let score = "\(self.teamOrder[self.round - 1].points)"
        let scoreAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Bold", size: 50) ?? UIFont.boldSystemFont(ofSize: 50),
            .foregroundColor: UIColor.black
        ]
        let scoreAttributedString = NSAttributedString(string: score, attributes: scoreAttributes)
        attributedText.append(scoreAttributedString)
        self.scoreLabel.attributedText = attributedText
    }
    
    func addSubviews() {
        self.view.addSubview(gameCodeLabel)
        self.view.addSubview(roundLabel)
        self.view.addSubview(iconButton)
        self.view.addSubview(teamInfoLabel)
        self.view.addSubview(scoreLabel)
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
        iconButton.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.467).isActive = true
        iconButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        iconButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.240).isActive = true
        
        teamInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        teamInfoLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.464).isActive = true
        teamInfoLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.1).isActive = true
        teamInfoLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        teamInfoLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.445).isActive = true
        
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.4).isActive = true
        scoreLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.0653).isActive = true
        scoreLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        scoreLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.542).isActive = true
        
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
                if strongSelf.remainingTime <= 5 {
                    strongSelf.audioPlayerManager.playAudioFile(named: "timer_end", withExtension: "wav")
                }
                if strongSelf.remainingTime <= 3 {
                    strongSelf.impactFeedbackGenerator.impactOccurred()
                }
                if strongSelf.time! < 1 {
                    if strongSelf.moving {
                        strongSelf.time = strongSelf.seconds
                        strongSelf.timerLabel.text = "Game Time  " + String(format:"%02i : %02i", strongSelf.time!/60, strongSelf.time! % 60)
                        strongSelf.moving = false
                    } else {
                        strongSelf.rounds -= 1
                        if strongSelf.rounds < 1 {
                            strongSelf.audioPlayerManager.stop()
                            timer.invalidate()
                        }
                        else {
                            strongSelf.time = strongSelf.moveSeconds
                            strongSelf.timerLabel.text = "Moving Time  " + String(format:"%02i : %02i", strongSelf.time!/60, strongSelf.time! % 60)
                            strongSelf.moving = true
                            strongSelf.winButton.gestureRecognizers?.forEach { gestureRecognizer in
                                gestureRecognizer.isEnabled = true
                            }
                            strongSelf.winButton.image = UIImage(named: "Win Blue Button")
                            strongSelf.loseButton.gestureRecognizers?.forEach { gestureRecognizer in
                                gestureRecognizer.isEnabled = true
                            }
                            strongSelf.loseButton.image = UIImage(named: "Lose Yellow Button")
                            // Testing Purpose
                            strongSelf.round += 1
                            strongSelf.roundLabel.text = "Round " + "\(strongSelf.round)"
                            strongSelf.team = strongSelf.teamOrder[strongSelf.round-1]
                            //
                            strongSelf.makeScoreLabel()
                            strongSelf.makeTeamInfoLabel()
                            strongSelf.iconButton.image = UIImage(named: strongSelf.teamOrder[strongSelf.round - 1].iconName)
                        }
                    }
                }
                else {
                    strongSelf.time! -= 1
                    strongSelf.remainingTime -= 1
                    let minute = strongSelf.time!/60
                    let second = strongSelf.time! % 60
                    if strongSelf.moving {
                        strongSelf.timerLabel.text = "Moving Time  " + String(format:"%02i : %02i", minute, second)
                    } else {
                        strongSelf.timerLabel.text = "Game Time  " + String(format:"%02i : %02i", minute, second)
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
        self.remainingTime = self.remainingTime - t
        self.rounds = self.rounds - self.round + 1
    }
    //MARK: - Score Update
    func updateScore() {
        for old_team in self.teamOrder {
            for updated_team in self.teams {
                if old_team.number == updated_team.number && old_team.points != updated_team.points {
                    if let index = self.teamOrder.firstIndex(where: { $0.number == old_team.number }) {
                        self.teamOrder[index] = updated_team
                    }
                    break;
                }
            }
        }
        self.team = self.teamOrder[self.round - 1]
        makeScoreLabel()
    }
}

//MARK: - Protocols
extension RefereePVEController: StationList, GetHost, TeamList, TeamUpdateListener, HostUpdateListener {
    func listOfStations(_ stations: [Station]) {
        for station in stations {
            if station.name == referee.stationName {
                self.teamOrder = station.teamOrder
                self.name = station.name
                self.location = station.place
                self.rule = station.description
                self.points = station.points
                break;
            }
        }
        updateScore()
        addSubviews()
        addConstraints()
    }
    
    func getHost(_ host: Host) {
        self.seconds = host.gameTime
        self.moveSeconds = host.movingTime
        self.startTime = host.startTimestamp
        self.isPaused = host.paused
        self.pauseTime = host.pauseTimestamp
        self.pausedTime = host.pausedTime
        self.rounds = host.rounds
        self.remainingTime = host.rounds * (host.gameTime + host.movingTime)
        self.round = host.currentRound
        self.messages = host.announcements
        calculateTime()
        runTimer()
    }
    
    func listOfTeams(_ teams: [Team]) {
        self.teams = teams
        S.getStationList(gameCode)
    }
    
    func updateTeams(_ teams: [Team]) {
        for team in teams {
            if self.team.name == team.name {
                self.team = team
            }
        }
        scoreLabel.text = "\(self.team.points)"
    }
    
    func updateHost(_ host: Host) {
        self.gameStart = host.gameStart
        self.gameOver = host.gameover
        self.isPaused = host.paused
        self.pauseTime = host.pauseTimestamp
        self.pausedTime = host.pausedTime
//        self.roundLabel.text = "Round \(host.currentRound)"
//        self.round = host.currentRound
    }
    
    func listen(_ _ : [String : Any]){
    }
    
    func callProtocols() {
        H.delegate_getHost = self
        H.delegates.append(self)
        S.delegate_stationList = self
        T.delegate_teamList = self
        T.delegates.append(self)
    }
}


