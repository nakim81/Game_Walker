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
    
    private var gameCode = UserData.readGamecode("refereeGameCode")!
    private var referee = UserData.readReferee("Referee")!
    private var stationName = ""
    private var teams : [Team] = [Team(), Team()]
    private var teamOrder : [Team] = [Team(), Team()]
    private var teamA : Team = Team()
    private var teamB : Team = Team()
    private var index: Int = 0
    
    private var points : Int = 0
    private var name : String = ""
    private var location : String = ""
    private var rule : String = ""
    
    private var startTime : Int = 0
    private var pauseTime : Int = 0
    private var pausedTime : Int = 0
    private var timer = Timer()
    private var remainingTime: Int = 0
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
    
    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let audioPlayerManager = AudioPlayerManager()
    private let readAll = UIImage(named: "announcement")
    private let unreadSome = UIImage(named: "unreadMessage")
    private var messages: [String] = []
    
    //MARK: - Messages
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
        performSegue(withIdentifier: "toRegister", sender: self)
    }
    
    override func viewDidLoad() {
        callProtocols()
        H.getHost(gameCode)
        S.getStationList(gameCode)
        T.getTeamList(gameCode)
        H.listenHost(gameCode, onListenerUpdate: listen(_:))
        T.listenTeams(gameCode, onListenerUpdate: listen(_:))
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
    
    @objc func leftButtonTapped() {
        if self.teamA.number == 0 {
            alert(title: "", message: "The Team doesn't exist")
        } else {
            UserData.writeTeam(self.teamA, "Team")
            let popUpWindow = GivePointsController(team: UserData.readTeam("Team")!, gameCode: UserData.readGamecode("refereeGameCode")!)
            self.present(popUpWindow, animated: true, completion: nil)
        }
    }
    
    private lazy var leftIconButton: UIImageView = {
        var view = UIImageView(frame: CGRect(x: 0, y: 0, width: 175, height: 175))
        view.image = UIImage(named: teamOrder[index].iconName)
        view.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(leftButtonTapped))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    private lazy var leftTeamInfoLabel: UILabel = {
        let teamNumber = "Team \(self.teamOrder[index].number)"
        let teamName = self.teamOrder[index].name
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
        let teamNameAttributedString = NSAttributedString(string: teamName, attributes: teamNameAttributes)
        attributedText.append(teamNameAttributedString)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 174, height: 78))
        label.backgroundColor = .white
        label.attributedText = attributedText
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private lazy var leftWinButton: UIImageView = {
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(leftWinButtonTapped))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    @objc func leftWinButtonTapped() {
        //self.audioPlayerManager.playAudioFile(named: "point up", withExtension: "wav")
        Task {
            do {
                try await T.givePoints(gameCode, self.teamA.name, self.points)
            } catch ServerError.serverError(let text){
                print(text)
                serverAlert(text)
                return
            }
        }
        leftWinButton.gestureRecognizers?.forEach { gestureRecognizer in
            gestureRecognizer.isEnabled = false
        }
        leftWinButton.image = UIImage(named: "Lose Gray Button")
        leftLoseButton.gestureRecognizers?.forEach { gestureRecognizer in
            gestureRecognizer.isEnabled = true
        }
        leftLoseButton.image = UIImage(named: "Lose Yellow Button")
    }
    
    private lazy var leftLoseButton: UIImageView = {
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(leftLoseButtonTapped))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    @objc func leftLoseButtonTapped() {
        //self.audioPlayerManager.playAudioFile(named: "point down", withExtension: "wav")
        leftWinButton.gestureRecognizers?.forEach { gestureRecognizer in
            gestureRecognizer.isEnabled = true
        }
        leftWinButton.image = UIImage(named: "Lose Yellow Button")
        leftLoseButton.gestureRecognizers?.forEach { gestureRecognizer in
            gestureRecognizer.isEnabled = false
        }
        leftLoseButton.image = UIImage(named: "Lose Gray Button")
    }
    
    private lazy var leftScoreLabel: UILabel = {
        let attributedText = NSMutableAttributedString()
        let score = "\(self.teamOrder[self.round - 1].points)"
        let scoreAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Bold", size: 35) ?? UIFont.boldSystemFont(ofSize: 35),
            .foregroundColor: UIColor.black
        ]
        let scoreAttributedString = NSAttributedString(string: score, attributes: scoreAttributes)
        attributedText.append(scoreAttributedString)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 109.01, height: 40.12))
        label.backgroundColor = .white
        label.attributedText = attributedText
        label.numberOfLines = 3
        label.textAlignment = .center
        return label
    }()
    
    @objc func rightButtonTapped() {
        if self.teamB.number == 0 {
            alert(title: "", message: "The Team doesn't exist")
        } else {
            UserData.writeTeam(self.teamB, "Team")
            let popUpWindow = GivePointsController(team: UserData.readTeam("Team")!, gameCode: UserData.readGamecode("refereeGameCode")!)
            self.present(popUpWindow, animated: true, completion: nil)
        }
    }
    
    private lazy var rightIconButton: UIImageView = {
        var view = UIImageView(frame: CGRect(x: 0, y: 0, width: 175, height: 175))
        view.image = UIImage(named: teamOrder[index+1].iconName)
        view.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(rightButtonTapped))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    private lazy var rightTeamInfoLabel: UILabel = {
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
        let teamNameAttributedString = NSAttributedString(string: teamName, attributes: teamNameAttributes)
        attributedText.append(teamNameAttributedString)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 174, height: 139))
        label.backgroundColor = .white
        label.attributedText = attributedText
        label.numberOfLines = 3
        label.textAlignment = .center
        return label
    }()
    
    private lazy var rightWinButton: UIImageView = {
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(rightWinButtonTapped))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    @objc func rightWinButtonTapped() {
        //self.audioPlayerManager.playAudioFile(named: "point up", withExtension: "wav")
        Task {
            do {
                try await T.givePoints(gameCode, self.teamB.name, self.points)
            } catch ServerError.serverError(let text){
                print(text)
                serverAlert(text)
                return
            }
        }
        rightWinButton.gestureRecognizers?.forEach { gestureRecognizer in
            gestureRecognizer.isEnabled = false
        }
        rightWinButton.image = UIImage(named: "Lose Gray Button")
        rightLoseButton.gestureRecognizers?.forEach { gestureRecognizer in
            gestureRecognizer.isEnabled = true
        }
        rightLoseButton.image = UIImage(named: "Lose Yellow Button")
    }
    
    private lazy var rightLoseButton: UIImageView = {
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(rightLoseButtonTapped))
        label.addGestureRecognizer(tapGesture)
        label.isUserInteractionEnabled = true
        return view
    }()
    
    @objc func rightLoseButtonTapped() {
        //self.audioPlayerManager.playAudioFile(named: "point down", withExtension: "wav")
        rightWinButton.gestureRecognizers?.forEach { gestureRecognizer in
            gestureRecognizer.isEnabled = true
        }
        rightWinButton.image = UIImage(named: "Lose Yellow Button")
        rightLoseButton.gestureRecognizers?.forEach { gestureRecognizer in
            gestureRecognizer.isEnabled = false
        }
        rightLoseButton.image = UIImage(named: "Lose Gray Button")
    }
    
    private lazy var rightScoreLabel: UILabel = {
        let attributedText = NSMutableAttributedString()
        let score = "\(self.teamOrder[self.round].points)"
        let scoreAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Bold", size: 35) ?? UIFont.boldSystemFont(ofSize: 35),
            .foregroundColor: UIColor.black
        ]
        let scoreAttributedString = NSAttributedString(string: score, attributes: scoreAttributes)
        attributedText.append(scoreAttributedString)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 109.01, height: 40.12))
        label.backgroundColor = .white
        label.attributedText = attributedText
        label.numberOfLines = 3
        label.textAlignment = .center
        return label
    }()
    
    func makeLeftTeamInfoLabel() {
        let teamNumber = "Team \(self.teamOrder[2 * self.round - 2].number)"
        let teamName = self.teamOrder[2 * self.round - 2].name
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
        let teamNameAttributedString = NSAttributedString(string: teamName, attributes: teamNameAttributes)
        attributedText.append(teamNameAttributedString)
        self.leftTeamInfoLabel.attributedText = attributedText
    }
    
    func makeRightTeamInfoLabel() {
        let teamNumber = "Team \(self.teamOrder[2 * self.round - 1].number)"
        let teamName = self.teamOrder[2 * self.round - 1].name
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
        let teamNameAttributedString = NSAttributedString(string: teamName, attributes: teamNameAttributes)
        attributedText.append(teamNameAttributedString)
        self.rightTeamInfoLabel.attributedText = attributedText
    }
    
    func makeLeftScoreLabel() {
        let attributedText = NSMutableAttributedString()
        let score = "\(self.teamOrder[2 * self.round - 2].points)"
        let scoreAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Bold", size: 35) ?? UIFont.boldSystemFont(ofSize: 35),
            .foregroundColor: UIColor.black
        ]
        let scoreAttributedString = NSAttributedString(string: score, attributes: scoreAttributes)
        attributedText.append(scoreAttributedString)
        self.leftScoreLabel.attributedText = attributedText
    }
    
    func makeRightScoreLabel() {
        let attributedText = NSMutableAttributedString()
        let score = "\(self.teamOrder[2 * self.round - 1].points)"
        let scoreAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Bold", size: 35) ?? UIFont.boldSystemFont(ofSize: 35),
            .foregroundColor: UIColor.black
        ]
        let scoreAttributedString = NSAttributedString(string: score, attributes: scoreAttributes)
        attributedText.append(scoreAttributedString)
        self.rightScoreLabel.attributedText = attributedText
    }
    
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
    
    func addSubviews() {
        self.view.addSubview(gameCodeLabel)
        self.view.addSubview(roundLabel)
        self.view.addSubview(leftIconButton)
        self.view.addSubview(leftTeamInfoLabel)
        self.view.addSubview(leftWinButton)
        self.view.addSubview(leftLoseButton)
        self.view.addSubview(leftScoreLabel)
        self.view.addSubview(rightIconButton)
        self.view.addSubview(rightTeamInfoLabel)
        self.view.addSubview(rightWinButton)
        self.view.addSubview(rightLoseButton)
        self.view.addSubview(rightScoreLabel)
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
        
        leftIconButton.translatesAutoresizingMaskIntoConstraints = false
        leftIconButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.36).isActive = true
        leftIconButton.heightAnchor.constraint(equalTo: leftIconButton.widthAnchor, multiplier: 1).isActive = true
        leftIconButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: self.view.bounds.width * 0.0853).isActive = true
        leftIconButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.298).isActive = true
        
        leftTeamInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        leftTeamInfoLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.333).isActive = true
        leftTeamInfoLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.123).isActive = true
        leftTeamInfoLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: self.view.bounds.width * 0.107).isActive = true
        leftTeamInfoLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.475).isActive = true
        
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
        
        leftScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        leftScoreLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.291).isActive = true
        leftScoreLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.0493).isActive = true
        leftScoreLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: self.view.bounds.width * 0.12).isActive = true
        leftScoreLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.466).isActive = true
        
        rightIconButton.translatesAutoresizingMaskIntoConstraints = false
        rightIconButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.36).isActive = true
        rightIconButton.heightAnchor.constraint(equalTo: rightIconButton.widthAnchor, multiplier: 1).isActive = true
        rightIconButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: self.view.bounds.width * 0.555).isActive = true
        rightIconButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.298).isActive = true

        rightTeamInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        rightTeamInfoLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.333).isActive = true
        rightTeamInfoLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.123).isActive = true
        rightTeamInfoLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: self.view.bounds.width * 0.565).isActive = true
        rightTeamInfoLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.475).isActive = true

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
        
        rightScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        rightScoreLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.291).isActive = true
        rightScoreLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.0493).isActive = true
        rightScoreLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: self.view.bounds.width * 0.589).isActive = true
        rightScoreLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.466).isActive = true
        
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
                        strongSelf.time = strongSelf.moveSeconds
                        strongSelf.timerLabel.text = "Moving Time  " + String(format:"%02i : %02i", strongSelf.time!/60, strongSelf.time! % 60)
                        strongSelf.moving = true
                        strongSelf.index += 2
                        strongSelf.leftWinButton.gestureRecognizers?.forEach { gestureRecognizer in
                            gestureRecognizer.isEnabled = true
                        }
                        strongSelf.leftWinButton.image = UIImage(named: "Win Blue Button")
                        strongSelf.leftLoseButton.gestureRecognizers?.forEach { gestureRecognizer in
                            gestureRecognizer.isEnabled = true
                        }
                        strongSelf.leftLoseButton.image = UIImage(named: "Lose Yellow Button")
                        strongSelf.rightWinButton.gestureRecognizers?.forEach { gestureRecognizer in
                            gestureRecognizer.isEnabled = true
                        }
                        strongSelf.rightWinButton.image = UIImage(named: "Win Blue Button")
                        strongSelf.rightLoseButton.gestureRecognizers?.forEach { gestureRecognizer in
                            gestureRecognizer.isEnabled = true
                        }
                        strongSelf.rightLoseButton.image = UIImage(named: "Lose Yellow Button")
                        // Testing Purpose
                        strongSelf.round += 1
                        strongSelf.roundLabel.text = "Round " + "\(strongSelf.round)"
                        strongSelf.teamA = strongSelf.teamOrder[2 * strongSelf.round - 2]
                        strongSelf.teamB = strongSelf.teamOrder[2 * strongSelf.round - 1]
                        //
                        strongSelf.makeLeftScoreLabel()
                        strongSelf.makeLeftTeamInfoLabel()
                        strongSelf.leftIconButton.image = UIImage(named: strongSelf.teamOrder[strongSelf.index].iconName)
                        strongSelf.makeRightScoreLabel()
                        strongSelf.makeRightTeamInfoLabel()
                        strongSelf.rightIconButton.image = UIImage(named: strongSelf.teamOrder[strongSelf.index + 1].iconName)
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
        self.index = 2 * self.round - 2
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
        self.teamA = self.teamOrder[2 * self.round - 2]
        self.teamB = self.teamOrder[2 * self.round - 1]
        makeLeftScoreLabel()
        makeRightScoreLabel()
    }
}

//MARK: - Protocols
extension RefereePVPController: StationList, TeamList, GetHost, TeamUpdateListener, HostUpdateListener {
    func listOfStations(_ stations: [Station]) {
        for station in stations {
            if station.name == referee.stationName {
                self.teamOrder = station.teamOrder
                self.teamA = self.teamOrder[self.round - 1]
                self.teamB = self.teamOrder[self.round]
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
    
    func listOfTeams(_ teams: [Team]) {
        self.teams = teams
        S.getStationList(gameCode)
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
    
    func updateTeams(_ teams: [Team]) {
        for team in teams {
            if self.teamA.name == team.name {
                self.teamA = team
                leftScoreLabel.text = "\(self.teamA.points)"
            }
            if self.teamB.name == team.name {
                self.teamB = team
                rightScoreLabel.text = "\(self.teamB.points)"
            }
        }
    }
    
    func updateHost(_ host: Host) {
        self.isPaused = host.paused
        self.pauseTime = host.pauseTimestamp
        self.pausedTime = host.pausedTime
//        self.round = host.currentRound
//        self.roundLabel.text = "Round \(host.currentRound)"
        self.currentRound = host.currentRound
    }
    
    func callProtocols() {
        H.delegate_getHost = self
        H.delegates.append(self)
        S.delegate_stationList = self
        T.delegate_teamList = self
        T.delegates.append(self)
    }
    
    func listen(_ _ : [String : Any]){
    }
}



