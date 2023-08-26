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
    @IBOutlet weak var leaveButton: UIButton!
    
    
    private var gameCode = UserData.readGamecode("refereeGamecode")!
    private var referee = UserData.readReferee("Referee")!
    private var stationName = ""
    private var teamOrder : [Team] = [Team(gamecode: "333333", name: "Dok2", number: 1, players: [], points: 0, stationOrder: [0], iconName: "iconDaisy"),Team(gamecode: "333333", name: "ABCDEF", number: 2, players: [], points: 0, stationOrder: [0], iconName: "iconBoy"),
                                      Team(gamecode: "333333", name: "Simon Dominic", number: 3, players: [], points: 0, stationOrder: [0], iconName: "iconGirl"),
                                      Team(gamecode: "333333", name: "Driver", number: 4, players: [], points: 0, stationOrder: [0], iconName: "iconAir")]
    private var teamA : Team?
    private var teamB : Team?
    private var index: Int = 0
    
    private var stationUuid : String = ""
    private var points : Int = 0
    private var name : String = ""
    private var location : String = ""
    private var rule : String = ""
    
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
    
    private let readAll = UIImage(named: "announcement")
    private let unreadSome = UIImage(named: "unreadMessage")
    private var messages: [String] = []
    
    //MARK: - Music Playing
    var audioPlayer: AVAudioPlayer?
    private let audioPlayerManager = AudioPlayerManager()
    
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
            self.annnouncementButton.setImage(self.readAll, for: .normal)
        } else {
            self.annnouncementButton.setImage(self.unreadSome, for: .normal)
            self.audioPlayerManager.playAudioFile(named: "message", withExtension: "wav")
        }
    }
    
    @IBAction func leaveButtonPressed(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        callProtocols()
        H.getHost(gameCode)
        H.listenHost(gameCode, onListenerUpdate: listen(_:))
        S.getStationList(gameCode)
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
    
    @objc func leftbuttonTapped() {
        UserData.writeTeam(self.teamA!, "Team")
        let popUpWindow = GivePointsController(team: UserData.readTeam("Team")!, gameCode: UserData.readGamecode("refereeGamecode")!)
        self.present(popUpWindow, animated: true, completion: nil)
    }
    
    private lazy var lefticonButton: UIImageView = {
        var view = UIImageView(frame: CGRect(x: 0, y: 0, width: 175, height: 175))
        view.image = UIImage(named: teamOrder[index].iconName)
        view.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(leftbuttonTapped))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    private lazy var leftteamInfoLabel: UILabel = {
        let teamNumber = "Team \(self.teamOrder[index].number)"
        let teamName = self.teamOrder[index].name
        let score = "\(self.teamOrder[index].points)"
        let attributedText = NSMutableAttributedString()
        let teamNumberAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-SemiBold", size: 15) ?? UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor.black
        ]
        let teamNumberAttributedString = NSAttributedString(string: teamNumber + "\n", attributes: teamNumberAttributes)
        attributedText.append(teamNumberAttributedString)
        let teamNameAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor.black
        ]
        let teamNameAttributedString = NSAttributedString(string: teamName + "\n", attributes: teamNameAttributes)
        attributedText.append(teamNameAttributedString)
        let scoreAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Bold", size: 35) ?? UIFont.boldSystemFont(ofSize: 35),
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
    
    private lazy var leftWinButton: UIButton = {
        var button = UIButton(frame: CGRect(x: 0, y: 0, width: 57, height: 13))
        button.setTitle("Win", for: .normal)
        button.titleLabel?.font = UIFont(name: "Dosis-Bold", size: 13)
        button.titleLabel?.textColor = .white
        button.setImage(UIImage(named: "Win Blue Button"), for: .normal)
        button.addTarget(self, action: #selector(leftWinButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func leftWinButtonTapped() {
        Task {
            await T.givePoints(gameCode, self.teamA!.name, self.points)
        }
        leftWinButton.isEnabled = false
        leftLoseButton.isEnabled = false
    }
    
    private lazy var leftLoseButton: UIButton = {
        var button = UIButton(frame: CGRect(x: 0, y: 0, width: 57, height: 13))
        button.setTitle("Win", for: .normal)
        button.titleLabel?.font = UIFont(name: "Dosis-Bold", size: 13)
        button.titleLabel?.textColor = .white
        button.setImage(UIImage(named: "Lose Gray Button"), for: .normal)
        button.addTarget(self, action: #selector(leftWinButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func leftLoseButtonTapped() {
        leftWinButton.isEnabled = false
        leftLoseButton.isEnabled = false
    }
    
    @objc func rightbuttonTapped() {
        UserData.writeTeam(self.teamB!, "Team")
        let popUpWindow = GivePointsController(team: UserData.readTeam("Team")!, gameCode: UserData.readGamecode("refereeGamecode")!)
        self.present(popUpWindow, animated: true, completion: nil)
    }
    
    private lazy var righticonButton: UIImageView = {
        var view = UIImageView(frame: CGRect(x: 0, y: 0, width: 175, height: 175))
        view.image = UIImage(named: teamOrder[index+1].iconName)
        view.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(rightbuttonTapped))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    private lazy var rightteamInfoLabel: UILabel = {
        let teamNumber = "Team \(self.teamOrder[index + 1].number)"
        let teamName = self.teamOrder[index + 1].name
        let score = "\(self.teamOrder[index + 1].points)"
        let attributedText = NSMutableAttributedString()
        let teamNumberAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-SemiBold", size: 15) ?? UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor.black
        ]
        let teamNumberAttributedString = NSAttributedString(string: teamNumber + "\n", attributes: teamNumberAttributes)
        attributedText.append(teamNumberAttributedString)
        let teamNameAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor.black
        ]
        let teamNameAttributedString = NSAttributedString(string: teamName + "\n", attributes: teamNameAttributes)
        attributedText.append(teamNameAttributedString)
        let scoreAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Bold", size: 35) ?? UIFont.boldSystemFont(ofSize: 35),
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
    
    private lazy var rightWinButton: UIButton = {
        var button = UIButton(frame: CGRect(x: 0, y: 0, width: 57, height: 13))
        button.setTitle("Win", for: .normal)
        button.titleLabel?.font = UIFont(name: "Dosis-Bold", size: 13)
        button.titleLabel?.textColor = .white
        button.setImage(UIImage(named: "Lose Yellow Button"), for: .normal)
        button.addTarget(self, action: #selector(rightWinButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func rightWinButtonTapped() {
        Task {
            await T.givePoints(gameCode, self.teamB!.name, self.points)
        }
        rightWinButton.isEnabled = false
        rightLoseButton.isEnabled = false
    }
    
    private lazy var rightLoseButton: UIButton = {
        var button = UIButton(frame: CGRect(x: 0, y: 0, width: 57, height: 13))
        button.setTitle("Lose", for: .normal)
        button.titleLabel?.font = UIFont(name: "Dosis-Bold", size: 13)
        button.titleLabel?.textColor = .black
        button.setImage(UIImage(named: "Lose Gray Button"), for: .normal)
        button.addTarget(self, action: #selector(rightLoseButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func rightLoseButtonTapped() {
        rightWinButton.isEnabled = false
        rightLoseButton.isEnabled = false
    }
    
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
    
    func addSubviews() {
        self.view.addSubview(gameCodeLabel)
        self.view.addSubview(roundLabel)
        self.view.addSubview(lefticonButton)
        self.view.addSubview(leftteamInfoLabel)
        self.view.addSubview(leftWinButton)
        self.view.addSubview(leftLoseButton)
        self.view.addSubview(righticonButton)
        self.view.addSubview(rightteamInfoLabel)
        self.view.addSubview(rightWinButton)
        self.view.addSubview(rightLoseButton)
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
        roundLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.186).isActive = true
        
        lefticonButton.translatesAutoresizingMaskIntoConstraints = false
        lefticonButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.36).isActive = true
        lefticonButton.heightAnchor.constraint(equalTo: lefticonButton.widthAnchor, multiplier: 1).isActive = true
        lefticonButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: self.view.bounds.width * 0.0853).isActive = true
        lefticonButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.298).isActive = true
        
        leftteamInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        leftteamInfoLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.333).isActive = true
        leftteamInfoLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.123).isActive = true
        leftteamInfoLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: self.view.bounds.width * 0.107).isActive = true
        leftteamInfoLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.471).isActive = true
        
        leftWinButton.translatesAutoresizingMaskIntoConstraints = false
        leftWinButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.176).isActive = true
        leftWinButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.032).isActive = true
        leftWinButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: self.view.bounds.width * 0.079).isActive = true
        leftWinButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.590).isActive = true
        
        leftLoseButton.translatesAutoresizingMaskIntoConstraints = false
        leftLoseButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.176).isActive = true
        leftLoseButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.032).isActive = true
        leftLoseButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: self.view.bounds.width * 0.269).isActive = true
        leftLoseButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.590).isActive = true
        
        righticonButton.translatesAutoresizingMaskIntoConstraints = false
        righticonButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.36).isActive = true
        righticonButton.heightAnchor.constraint(equalTo: righticonButton.widthAnchor, multiplier: 1).isActive = true
        righticonButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: self.view.bounds.width * 0.555).isActive = true
        righticonButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.298).isActive = true

        rightteamInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        rightteamInfoLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.333).isActive = true
        rightteamInfoLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.123).isActive = true
        rightteamInfoLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: self.view.bounds.width * 0.565).isActive = true
        rightteamInfoLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.471).isActive = true

        rightWinButton.translatesAutoresizingMaskIntoConstraints = false
        rightWinButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.176).isActive = true
        rightWinButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.032).isActive = true
        rightWinButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: self.view.bounds.width * 0.550).isActive = true
        rightWinButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.590).isActive = true

        rightLoseButton.translatesAutoresizingMaskIntoConstraints = false
        rightLoseButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.176).isActive = true
        rightLoseButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.032).isActive = true
        rightLoseButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: self.view.bounds.width * 0.735).isActive = true
        rightLoseButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.590).isActive = true
        
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.477).isActive = true
        timerLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.0394).isActive = true
        timerLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        timerLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.70).isActive = true
    }
    
    @IBAction func stationinfoButtonPressed(_ sender: UIButton) {
        showRefereeGameInfoPopUp(gameName: self.name, gameLocation: self.location, gamePoitns: String(self.points), gameRule: self.rule)
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
                        strongSelf.rounds -= 1
                        strongSelf.index += 2
                        strongSelf.lefticonButton.image = UIImage(named: strongSelf.teamOrder[strongSelf.index].iconName)
                        strongSelf.righticonButton.image = UIImage(named: strongSelf.teamOrder[strongSelf.index + 1].iconName)
                        strongSelf.roundLabel.text = "Round " + "\(strongSelf.round)"
                    }
                }
                strongSelf.time! -= 1
                let minute = strongSelf.time!/60
                let second = strongSelf.time! % 60
                if strongSelf.moving {
                    strongSelf.timerLabel.text = "Game Time  " + String(format:"%02i : %02i", minute, second)
                } else {
                    strongSelf.timerLabel.text = "Moving Time  " + String(format:"%02i : %02i", minute, second)
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
            self.timerLabel.text = String(format:"%02i : %02i", minute, second)
        }
        else {
            
            self.time = (seconds - remainder)
            self.moving = false
            let minute = (seconds - remainder)/60
            let second = (seconds - remainder) % 60
            self.timerLabel.text = String(format:"%02i : %02i", minute, second)
        }
        self.rounds = self.rounds - self.round
    }
}

//MARK: - Protocols
extension RefereePVPController: GetStation, StationList, GetHost, TeamUpdateListener, HostUpdateListener {
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
            if self.teamA!.name == team.name {
                self.teamA! = team
                //leftscoreLabel.text = "\(self.teamA!.points)"
            }
            if self.teamB!.name == team.name {
                self.teamB! = team
                //rightscoreLabel.text = "\(self.teamB!.points)"
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



