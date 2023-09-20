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
    
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var leaveButton: UIButton!
    
    private var gameCode = UserData.readGamecode("refereeGameCode")!
    private var referee = UserData.readReferee("Referee")!
    private var host: Host = Host()
    private var team : Team = Team()
    private var teams : [Team] = [Team(name: "Simon Dominic", iconName: "iconDaisy")]
    private var stations : [Station] = [Station()]
    private var teamOrder : [Team] = [Team(name: "Simon Dominic", iconName: "iconDaisy")]
    private var round : Int = 1
    private var points : Int = 0
    
    private let audioPlayerManager = AudioPlayerManager()
    private let readAll = UIImage(named: "announcement")
    private let unreadSome = UIImage(named: "unreadMessage")
    private var messages: [String] = []
    
    override func viewDidLoad() {
        Task {
            callProtocols()
            stations = try await S.getStationList2(gameCode)
            teams = try await T.getTeamList2(gameCode)
            host = try await H.getHost2(gameCode) ?? Host()
            getTeamOrder()
            updateScore()
            addSubviews()
            addConstraints()
        }
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
    private lazy var gameCodeLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 127, height: 42)
        let attributedText = NSMutableAttributedString()
        let gameCodeAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "GemunuLibre-Bold", size: 13) ?? UIFont.systemFont(ofSize: fontSize(size: 13)),
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
        label.numberOfLines = 2
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        return label
    }()
    
    private lazy var roundLabel: UILabel = {
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 149.17, height: 61)
        view.backgroundColor = .white
        view.textColor = .black
        view.font = UIFontMetrics.default.scaledFont(for: UIFont(name: "Dosis-SemiBold", size: fontSize(size: 50)) ?? UIFont.systemFont(ofSize: fontSize(size: 50)))
        view.textAlignment = .center
        view.text = "Round " + "\(self.round)"
        view.adjustsFontForContentSizeCategory = true
        return view
    }()
    
    private lazy var iconButton: UIImageView = {
        var view = UIImageView(frame: CGRect(x: 0, y: 0, width: 175, height: 175))
        view.image = UIImage(named: self.teamOrder[self.round - 1].iconName)
        view.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonTapped))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    private lazy var teamNumLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 115, height: 38))
        label.backgroundColor = .white
        label.textColor = .black
        label.font = UIFont(name: "Dosis-SemiBold", size: fontSize(size: 25))
        label.text = "Team \(self.teamOrder[self.round - 1].number)"
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    private lazy var teamNameLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 45))
        label.backgroundColor = .white
        label.font = UIFont(name: "Dosis-Regular", size: fontSize(size: 25))
        label.text = "Team name is" + "\n" + "\(self.teamOrder[self.round - 1].name)"
        label.textColor = .black
        label.numberOfLines = 2
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private lazy var scoreLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 53))
        label.font = UIFont(name: "Dosis-Bold", size: fontSize(size: 50))
        label.text = "\(self.teamOrder[self.round - 1].points)"
        label.textColor = .black
        label.backgroundColor = .white
        label.numberOfLines = 1
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private lazy var winButton: UIImageView = {
        var view = UIImageView(frame: CGRect(x: 0, y: 0, width: 57, height: 13))
        view.image = UIImage(named: "Win Blue Button")
        var label = UILabel(frame: CGRect(x: 0, y: 0, width: 57, height: 13))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "WIN"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "GemunuLibre-Bold", size: 13) ?? UIFont(name: "Dosis-Bold", size: 13)
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
            do {
                try await T.givePoints(gameCode, self.team.name, self.points)
            } catch ServerError.serverError(let text){
                print(text)
                serverAlert(text)
                return
            }
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
        label.text = "LOSE"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "GemunuLibre-Bold", size: 13) ?? UIFont(name: "Dosis-Bold", size: 13)
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
    
    func fontSize(size: CGFloat) -> CGFloat {
        let size_formatter = size/390
        let result = UIScreen.main.bounds.size.width * size_formatter
        return result
    }
    
    func addSubviews() {
        self.view.addSubview(gameCodeLabel)
        self.view.addSubview(roundLabel)
        self.view.addSubview(teamNumLabel)
        self.view.addSubview(iconButton)
        self.view.addSubview(teamNameLabel)
        self.view.addSubview(scoreLabel)
        self.view.addSubview(winButton)
        self.view.addSubview(loseButton)
    }
    
    func addConstraints() {
        gameCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        roundLabel.translatesAutoresizingMaskIntoConstraints = false
        teamNumLabel.translatesAutoresizingMaskIntoConstraints = false
        iconButton.translatesAutoresizingMaskIntoConstraints = false
        teamNameLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        winButton.translatesAutoresizingMaskIntoConstraints = false
        loseButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gameCodeLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            gameCodeLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: UIScreen.main.bounds.size.height * 0.05),
            gameCodeLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.2),
            gameCodeLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.08),
            
            roundLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            roundLabel.topAnchor.constraint(equalTo: gameCodeLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.002),
            roundLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.579),
            roundLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.0751),
            
            teamNumLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            teamNumLabel.topAnchor.constraint(equalTo: roundLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.01),
            teamNumLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.295),
            teamNumLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.045),
            
            iconButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            iconButton.topAnchor.constraint(equalTo: teamNumLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.03),
            iconButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.467),
            iconButton.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.467),
            
            teamNameLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            teamNameLabel.topAnchor.constraint(equalTo: iconButton.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.005),
            teamNameLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.492),
            teamNameLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.12),
            
            scoreLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.370),
            scoreLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.0604),
            scoreLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            scoreLabel.topAnchor.constraint(equalTo: teamNameLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.05),
            
            winButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.176),
            winButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.032),
            winButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: UIScreen.main.bounds.size.width * 0.315),
            winButton.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 5),
            
            loseButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.176),
            loseButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.032),
            loseButton.leadingAnchor.constraint(equalTo: winButton.trailingAnchor, constant: 5),
            loseButton.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 5)
        ])
    }
    
    //MARK: - Update Score
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
        scoreLabel.text = "\(self.team.points)"
    }
    
    //MARK: - Get TeamOrder
    func getTeamOrder() {
        for station in stations {
            if station.name == referee.stationName {
                self.teamOrder = station.teamOrder
                self.points = station.points
                break;
            }
        }
    }
}

//MARK: - Protocols
extension RefereePVEController: TeamUpdateListener, HostUpdateListener {
    func updateTeams(_ teams: [Team]) {
        for team in teams {
            if self.team.name == team.name {
                self.team = team
            }
        }
        scoreLabel.text = "\(self.team.points)"
    }
    
    func updateHost(_ host: Host) {
        roundLabel.text = "Round " + "\(host.currentRound)"
        teamNumLabel.text = "Team \(self.teamOrder[host.currentRound - 1].number)"
        iconButton.image = UIImage(named: self.teamOrder[host.currentRound - 1].iconName)
        teamNameLabel.text = "Team name is" + "/n" + "\(self.teamOrder[host.currentRound - 1].name)"
        if self.round != host.currentRound {
            winButton.gestureRecognizers?.forEach { gestureRecognizer in
                gestureRecognizer.isEnabled = true
            }
            winButton.image = UIImage(named: "Win Blue Button")
            loseButton.gestureRecognizers?.forEach { gestureRecognizer in
                gestureRecognizer.isEnabled = true
            }
            loseButton.image = UIImage(named: "Lose Yellow Button")
            self.round = host.currentRound
        }
    }
    
    func listen(_ _ : [String : Any]){
        
    }
    
    func callProtocols() {
        T.delegates.append(self)
        H.delegates.append(self)
        T.listenTeams(gameCode, onListenerUpdate: listen(_:))
        H.listenHost(gameCode, onListenerUpdate: listen(_:))
    }
}


