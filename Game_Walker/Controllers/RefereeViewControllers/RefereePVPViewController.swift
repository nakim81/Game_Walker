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
    
    @IBOutlet weak var annnouncementButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var leaveButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    
    private var gameCode = UserData.readGamecode("gamecode")!
    private var referee = UserData.readReferee("referee")!
    private var host: Host = Host()
    private var teams : [Team] = [Team(name: "Simon Dominic", iconName: "iconDaisy"), Team(name: "Simon Dominic", iconName: "iconDaisy")]
    private var stations : [Station] = [Station()]
    private var teamOrder : [Team] = [Team(name: "Simon Dominic", iconName: "iconDaisy"), Team(name: "Simon Dominic", iconName: "iconDaisy")]
    private var maxPointsA : Bool = false
    private var maxPointsB : Bool = false
    private var maxA : String = ""
    private var maxB : String = ""
    private var teamA : Team = Team(name: "Simon Dominic", iconName: "iconDaisy")
    private var teamB : Team = Team(name: "Simon Dominic", iconName: "iconDaisy")
    private var round: Int = 1
    
    private var points : Int = 0
    private var name : String = ""
    private var location : String = ""
    private var rule : String = ""
    
    private let audioPlayerManager = AudioPlayerManager()
    private let readAll = UIImage(named: "messageIcon")
    private let unreadSome = UIImage(named: "unreadMessage")
    private var messages: [String] = []
    
    private var awardViewControllerPresented = false
    
    override func viewDidLoad() {
        Task {
            stations = try await S.getStationList(gameCode)
            teams = try await T.getTeamList(gameCode)
            host = try await H.getHost(gameCode) ?? Host()
            maxA = UserData.readMax("maxA") ?? ""
            maxB = UserData.readMax("maxB") ?? ""
            if maxA == "true" {
                leftWinButton.image = UIImage(named: "Lose Gray Button")
                leftLoseButton.image = UIImage(named: "Lose Yellow Button")
            } else if maxA == "false" {
                leftWinButton.image = UIImage(named: "Win Blue Button")
                leftLoseButton.image = UIImage(named: "Lose Gray Button")
            } else {
                leftWinButton.image = UIImage(named: "Win Blue Button")
                leftLoseButton.image = UIImage(named: "Lose Yellow Button")
            }
            if maxB == "true" {
                rightWinButton.image = UIImage(named: "Lose Gray Button")
                rightLoseButton.image = UIImage(named: "Lose Yellow Button")
            } else if maxB == "false" {
                rightWinButton.image = UIImage(named: "Win Blue Button")
                rightLoseButton.image = UIImage(named: "Lose Gray Button")
            } else {
                rightWinButton.image = UIImage(named: "Win Blue Button")
                rightLoseButton.image = UIImage(named: "Lose Yellow Button")
            }
            callProtocols()
            getTeamOrder()
            updateScore()
            addSubviews()
            addConstraints()
        }
        super.viewDidLoad()
    }
    
//    func setTeamOrder() {
//        var pvp_count : Int = 0
//        var column_number_index : Int = 0
//        var teamNumOrder : [Int] = []
//        var teamOrder : [Team] = []
//        Task {@MainActor in
//            stationList = try await S.getStationList(gameCode)
//            teams = try await T.getTeamList(gameCode)
//            for station in self.stationList {
//                if referee.name == station.referee?.name {
//                    self.station = station
//                }
//                if referee.stationName == station.name {
//                    self.station = station
//                }
//                if station.pvp == true {
//                    pvp_count += 1
//                }
//            }
//            if self.station.pvp {
//                column_number_index = 2 * station.number - 2
//                let left = self.algorithm.map({ $0[column_number_index] })
//                let right = self.algorithm.map({ $0[column_number_index + 1] })
//                var right_index : Int = 0
//                for left_index in left {
//                    teamNumOrder.append(left_index)
//                    teamNumOrder.append(right[right_index])
//                    right_index += 1
//                }
//            }
//            else {
//                column_number_index = 2 * pvp_count + station.number - pvp_count - 1
//                teamNumOrder = self.algorithm.map({ $0[column_number_index] })
//            }
//            for team_num in teamNumOrder {
//                if team_num == 0 {
//                    teamOrder.append(Team())
//                }
//                for team in self.teams {
//                    if team_num == team.number {
//                        teamOrder.append(team)
//                    }
//                }
//            }
//            self.updatedTeamOrder = teamOrder
//            do {
//                try await S.updateTeamOrder(gameCode, self.station.uuid, self.updatedTeamOrder)
//            }
//            catch GameWalkerError.serverError(let message) {
//                print(message)
//                serverAlert(message)
//                return
//            }
//            self.pvpAssigned = true
//            if self.station.pvp {
//                self.performSegue(withIdentifier: "goToPVP", sender: self)
//            }
//            else {
//                self.performSegue(withIdentifier: "goToPVE", sender: self)
//            }
//        }
//    }
    
    //MARK: - Messages
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(readAll(notification:)), name: RefereeRankingPVPViewController.notificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sound), name: RefereeRankingPVPViewController.notificationName2, object: nil)
        if RefereeRankingPVPViewController.unread {
            self.annnouncementButton.setImage(unreadSome, for: .normal)
        } else {
            self.annnouncementButton.setImage(readAll, for: .normal)
        }
    }
    
    @objc func readAll(notification: Notification) {
        guard let unread = notification.userInfo?["unread"] as? Bool else {
            return
        }
        if unread {
            self.annnouncementButton.setImage(self.unreadSome, for: .normal)
        } else {
            self.annnouncementButton.setImage(self.readAll, for: .normal)
        }
    }
    

    @objc func sound() {
        self.audioPlayerManager.playAudioFile(named: "message", withExtension: "wav")
    }
  
    @IBAction func annoucmentButtonPressed(_ sender: UIButton) {
        showRefereeMessagePopUp(messages: RefereeRankingPVEViewController.localMessages)
    }
    
    @IBAction func leaveButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "toRegister", sender: self)
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
    }

    //MARK: - UI elements
    private lazy var gameCodeLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 127, height: 42)
        let attributedText = NSMutableAttributedString()
        let gameCodeAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "GemunuLibre-Bold", size: fontSize(size: 13)) ?? UIFont(name: "Dosis-Bold", size: fontSize(size: 13)),
            .foregroundColor: UIColor.black
        ]
        let gameCodeAttributedString = NSAttributedString(string: "Game Code\n", attributes: gameCodeAttributes)
        attributedText.append(gameCodeAttributedString)
        let numberAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Bold", size: fontSize(size: 20)) ?? UIFont.systemFont(ofSize: fontSize(size: 20)),
            .foregroundColor: UIColor.black
        ]
        let numberAttributedString = NSAttributedString(string: gameCode, attributes: numberAttributes)
        attributedText.append(numberAttributedString)
        label.backgroundColor = .white
        label.attributedText = attributedText
        label.textColor = UIColor(red: 0.176, green: 0.176, blue: 0.208 , alpha: 1)
        label.numberOfLines = 2
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        return label
    }()
    
    private lazy var roundLabel: UILabel = {
        var view = UILabel()
        view.backgroundColor = .white
        view.textColor = UIColor(red: 0.176, green: 0.176, blue: 0.208 , alpha: 1)
        view.font = UIFont(name: "GemunuLibre-SemiBold", size: fontSize(size: 50)) ?? UIFont(name: "Dosis-SemiBold", size: fontSize(size: 50))
        view.textAlignment = .center
        view.text = "Round " + "\(round)"
        view.adjustsFontForContentSizeCategory = true
        return view
    }()
    
    @objc func leftButtonTapped() {
        if self.teamA.number == 0 {
            alert(title: "", message: "The Team doesn't exist")
        } else {
            UserData.writeTeam(self.teamA, "Team")
            let popUpWindow = GivePointsController(team: UserData.readTeam("Team")!, gameCode: UserData.readGamecode("gamecode")!)
            self.present(popUpWindow, animated: true, completion: nil)
        }
    }
    
    private lazy var leftIconButton: UIImageView = {
        var view = UIImageView(frame: CGRect(x: 0, y: 0, width: 175, height: 175))
        view.image = UIImage(named: teamOrder[2 * self.round - 2].iconName)
        view.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(leftButtonTapped))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    private lazy var leftTeamNumLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.textColor = UIColor(red: 0.176, green: 0.176, blue: 0.208 , alpha: 1)
        label.font = UIFont(name: "Dosis-SemiBold", size: fontSize(size: 25))
        label.text = "Team \(self.teamOrder[2 * self.round - 2].number)"
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    private lazy var leftTeamNameLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.font = UIFont(name: "Dosis-Regular", size: fontSize(size: 18))
        label.text = "Team name is" + "\n" + "\(self.teamOrder[2 * self.round - 2].name)"
        label.textColor = UIColor(red: 0.176, green: 0.176, blue: 0.208 , alpha: 1)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private lazy var leftWinButton: UIImageView = {
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(leftWinButtonTapped))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    @objc func leftWinButtonTapped() {
        //self.audioPlayerManager.playAudioFile(named: "point up", withExtension: "wav")
        if self.teamA.number == 0 {
            alert(title: "The Team doesn't exist", message: "This is an invalid team.")
        } else {
            if maxA != "true" {
                Task {
                    do {
                        try await T.givePoints(gameCode, self.teamA.name, self.points)
                    } catch GameWalkerError.serverError(let text){
                        print(text)
                        serverAlert(text)
                        return
                    }
                }
                UserData.writeMax("true", "maxA")
                maxA = UserData.readMax("maxA")!
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
    }
    
    private lazy var leftLoseButton: UIImageView = {
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(leftLoseButtonTapped))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    @objc func leftLoseButtonTapped() {
        //self.audioPlayerManager.playAudioFile(named: "point down", withExtension: "wav")
        if self.teamA.number == 0 {
            alert(title: "The Team doesn't exist", message: "This is an invalid team.")
        } else {
            if maxA == "true" {
                Task {
                    do {
                        try await T.givePoints(gameCode, self.teamA.name, -self.points)
                    } catch GameWalkerError.serverError(let text){
                        print(text)
                        serverAlert(text)
                        return
                    }
                }
                UserData.writeMax("false", "maxA")
                maxA = UserData.readMax("maxA")!
            }
            leftWinButton.gestureRecognizers?.forEach { gestureRecognizer in
                gestureRecognizer.isEnabled = false
            }
            leftWinButton.image = UIImage(named: "Lose Gray Button")
            leftLoseButton.gestureRecognizers?.forEach { gestureRecognizer in
                gestureRecognizer.isEnabled = true
            }
            leftLoseButton.image = UIImage(named: "Lose Yellow Button")
            leftWinButton.gestureRecognizers?.forEach { gestureRecognizer in
                gestureRecognizer.isEnabled = true
            }
            leftWinButton.image = UIImage(named: "Win Blue Button")
            leftLoseButton.gestureRecognizers?.forEach { gestureRecognizer in
                gestureRecognizer.isEnabled = false
            }
            leftLoseButton.image = UIImage(named: "Lose Gray Button")
        }
    }
    
    private lazy var leftScoreLabel: UILabel = {
        let attributedText = NSMutableAttributedString()
        let score = "\(self.teamOrder[2 * self.round - 2].points)"
        let scoreAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Bold", size: 35) ?? UIFont.boldSystemFont(ofSize: 35),
            .foregroundColor: UIColor(red: 0.176, green: 0.176, blue: 0.208 , alpha: 1)
        ]
        let scoreAttributedString = NSAttributedString(string: score, attributes: scoreAttributes)
        attributedText.append(scoreAttributedString)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 109.01, height: 40.12))
        label.backgroundColor = .white
        label.attributedText = attributedText
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    @objc func rightButtonTapped() {
        if self.teamB.number == 0 {
            alert(title: "", message: "The Team doesn't exist")
        } else {
            UserData.writeTeam(self.teamB, "Team")
            let popUpWindow = GivePointsController(team: UserData.readTeam("Team")!, gameCode: UserData.readGamecode("gamecode")!)
            self.present(popUpWindow, animated: true, completion: nil)
        }
    }
    
    private lazy var rightIconButton: UIImageView = {
        var view = UIImageView(frame: CGRect(x: 0, y: 0, width: 175, height: 175))
        view.image = UIImage(named: teamOrder[2 * self.round - 1].iconName)
        view.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(rightButtonTapped))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    private lazy var rightTeamNumLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 115, height: 38))
        label.backgroundColor = .white
        label.textColor = UIColor(red: 0.176, green: 0.176, blue: 0.208 , alpha: 1)
        label.font = UIFont(name: "Dosis-SemiBold", size: fontSize(size: 25))
        label.text = "Team \(self.teamOrder[2 * self.round - 1].number)"
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    private lazy var rightTeamNameLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 45))
        label.backgroundColor = .white
        label.font = UIFont(name: "Dosis-Regular", size: fontSize(size: 18))
        label.text = "Team name is" + "\n" + "\(self.teamOrder[2 * self.round - 1].name)"
        label.textColor = UIColor(red: 0.176, green: 0.176, blue: 0.208 , alpha: 1)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private lazy var rightWinButton: UIImageView = {
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(rightWinButtonTapped))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    @objc func rightWinButtonTapped() {
        //self.audioPlayerManager.playAudioFile(named: "point up", withExtension: "wav")
        if self.teamB.number == 0 {
            alert(title: "The Team doesn't exist", message: "This is an invalid team.")
        } else {
            if maxB != "true" {
                Task {
                    do {
                        try await T.givePoints(gameCode, self.teamB.name, self.points)
                    } catch GameWalkerError.serverError(let text){
                        print(text)
                        serverAlert(text)
                        return
                    }
                }
                UserData.writeMax("true", "maxB")
                maxB = UserData.readMax("maxB")!
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
    }
    
    private lazy var rightLoseButton: UIImageView = {
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(rightLoseButtonTapped))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    @objc func rightLoseButtonTapped() {
        //self.audioPlayerManager.playAudioFile(named: "point down", withExtension: "wav")
        if self.teamB.number == 0 {
            alert(title: "The Team doesn't exist", message: "This is an invalid team.")
        } else {
            if maxB == "true" {
                Task {
                    do {
                        try await T.givePoints(gameCode, self.teamB.name, -self.points)
                    } catch GameWalkerError.serverError(let text){
                        print(text)
                        serverAlert(text)
                        return
                    }
                }
                UserData.writeMax("false", "maxB")
                maxB = UserData.readMax("maxB")!
            }
            rightWinButton.gestureRecognizers?.forEach { gestureRecognizer in
                gestureRecognizer.isEnabled = true
            }
            rightWinButton.image = UIImage(named: "Win Blue Button")
            rightLoseButton.gestureRecognizers?.forEach { gestureRecognizer in
                gestureRecognizer.isEnabled = false
            }
            rightLoseButton.image = UIImage(named: "Lose Gray Button")
        }
    }
    
    private lazy var rightScoreLabel: UILabel = {
        let attributedText = NSMutableAttributedString()
        let score = "\(self.teamOrder[self.round].points)"
        let scoreAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Bold", size: 35) ?? UIFont.boldSystemFont(ofSize: 35),
            .foregroundColor: UIColor(red: 0.176, green: 0.176, blue: 0.208 , alpha: 1)
        ]
        let scoreAttributedString = NSAttributedString(string: score, attributes: scoreAttributes)
        attributedText.append(scoreAttributedString)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 109.01, height: 40.12))
        label.backgroundColor = .white
        label.attributedText = attributedText
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    func addSubviews() {
        self.view.addSubview(gameCodeLabel)
        self.view.addSubview(roundLabel)
        self.view.addSubview(leftTeamNumLabel)
        self.view.addSubview(leftIconButton)
        self.view.addSubview(leftTeamNameLabel)
        self.view.addSubview(leftWinButton)
        self.view.addSubview(leftLoseButton)
        self.view.addSubview(leftScoreLabel)
        self.view.addSubview(rightTeamNumLabel)
        self.view.addSubview(rightIconButton)
        self.view.addSubview(rightTeamNameLabel)
        self.view.addSubview(rightWinButton)
        self.view.addSubview(rightLoseButton)
        self.view.addSubview(rightScoreLabel)
    }
    
    func addConstraints() {
        gameCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        roundLabel.translatesAutoresizingMaskIntoConstraints = false
        leftTeamNumLabel.translatesAutoresizingMaskIntoConstraints = false
        leftIconButton.translatesAutoresizingMaskIntoConstraints = false
        leftTeamNameLabel.translatesAutoresizingMaskIntoConstraints = false
        leftWinButton.translatesAutoresizingMaskIntoConstraints = false
        leftLoseButton.translatesAutoresizingMaskIntoConstraints = false
        leftScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        rightTeamNumLabel.translatesAutoresizingMaskIntoConstraints = false
        rightIconButton.translatesAutoresizingMaskIntoConstraints = false
        rightTeamNameLabel.translatesAutoresizingMaskIntoConstraints = false
        rightWinButton.translatesAutoresizingMaskIntoConstraints = false
        rightLoseButton.translatesAutoresizingMaskIntoConstraints = false
        rightScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gameCodeLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            gameCodeLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: UIScreen.main.bounds.size.height * 0.035),
            gameCodeLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.2),
            gameCodeLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.08),
            
            roundLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            roundLabel.topAnchor.constraint(equalTo: gameCodeLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.002),
            roundLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.579),
            roundLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.0751),
            
            leftTeamNumLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: UIScreen.main.bounds.size.width * 0.125),
            leftTeamNumLabel.topAnchor.constraint(equalTo: roundLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.04),
            leftTeamNumLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.295),
            leftTeamNumLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.045),
            
            leftIconButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.36),
            leftIconButton.heightAnchor.constraint(equalTo: leftIconButton.widthAnchor, multiplier: 1),
            leftIconButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: UIScreen.main.bounds.size.width * 0.0853),
            leftIconButton.topAnchor.constraint(equalTo: leftTeamNumLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.02),
            
            leftTeamNameLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.4),
            leftTeamNameLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.06),
            leftTeamNameLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: UIScreen.main.bounds.size.width * 0.07),
            leftTeamNameLabel.topAnchor.constraint(equalTo: leftIconButton.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.03),
            
            leftScoreLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.291),
            leftScoreLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.0493),
            leftScoreLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: UIScreen.main.bounds.size.width * 0.12),
            leftScoreLabel.topAnchor.constraint(equalTo: leftTeamNameLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.06),
            
            leftWinButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.176),
            leftWinButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.032),
            leftWinButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: UIScreen.main.bounds.size.width * 0.09),
            leftWinButton.topAnchor.constraint(equalTo: leftScoreLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.0001),
            
            leftLoseButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.176),
            leftLoseButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.032),
            leftLoseButton.leadingAnchor.constraint(equalTo: leftWinButton.trailingAnchor, constant: UIScreen.main.bounds.size.width * 0.001),
            leftLoseButton.topAnchor.constraint(equalTo: leftScoreLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.0001),
            
            rightTeamNumLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -UIScreen.main.bounds.size.width * 0.125),
            rightTeamNumLabel.topAnchor.constraint(equalTo: roundLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.04),
            rightTeamNumLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.295),
            rightTeamNumLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.045),
            
            rightIconButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.36),
            rightIconButton.heightAnchor.constraint(equalTo: rightIconButton.widthAnchor, multiplier: 1),
            rightIconButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -UIScreen.main.bounds.size.width * 0.0853),
            rightIconButton.topAnchor.constraint(equalTo: rightTeamNumLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.02),
            
            rightTeamNameLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.4),
            rightTeamNameLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.06),
            rightTeamNameLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -UIScreen.main.bounds.size.width * 0.07),
            rightTeamNameLabel.topAnchor.constraint(equalTo: rightIconButton.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.03),
            
            rightScoreLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.291),
            rightScoreLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.0493),
            rightScoreLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -UIScreen.main.bounds.size.width * 0.12),
            rightScoreLabel.topAnchor.constraint(equalTo: rightTeamNameLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.06),
            
            rightWinButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.176),
            rightWinButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.032),
            rightWinButton.trailingAnchor.constraint(equalTo: rightLoseButton.leadingAnchor, constant: -UIScreen.main.bounds.size.width * 0.001),
            rightWinButton.topAnchor.constraint(equalTo: rightScoreLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.0001),
            
            rightLoseButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.176),
            rightLoseButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.032),
            rightLoseButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -UIScreen.main.bounds.size.width * 0.09),
            rightLoseButton.topAnchor.constraint(equalTo: rightScoreLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.0001)
        ])
    }
    
    //MARK: - Overlay
    @IBAction func infoButtonPressed(_ sender: Any) {
        showOverlay()
    }
    
    private func showOverlay() {
        let overlayViewController = RefereePVPGuideViewController()
        overlayViewController.modalPresentationStyle = .overFullScreen
        let explanationTexts = ["Remote your Station", "Ranking Status", "Timer & Station Info"]
        var componentPositions: [CGPoint] = []
        var componentFrames: [CGRect] = []
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
        let components = [leftIconButton, leftWinButton, leftLoseButton, leftScoreLabel, rightIconButton, rightWinButton, rightLoseButton, rightScoreLabel]
        for component in components {
            let frame = CGRect(x: component.frame.minX, y: component.frame.minY, width: component.frame.width, height: component.frame.height)
            let position = CGPoint(x: component.frame.minX, y: component.frame.minY)
            componentFrames.append(frame)
            componentPositions.append(position)
        }
        overlayViewController.configureGuide(componentFrames, componentPositions, explanationTexts, tabBarTop)
        present(overlayViewController, animated: true, completion: nil)
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
extension RefereePVPController: TeamUpdateListener, HostUpdateListener {
    func updateTeams(_ teams: [Team]) {
        for old_team in self.teamOrder {
            for team in teams {
                if old_team.number == team.number && old_team.points != team.points {
                    if let index = self.teamOrder.firstIndex(where: { $0.number == old_team.number }) {
                        self.teamOrder[index] = team
                    }
                    break;
                }
            }
        }
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
        if host.gameover && !awardViewControllerPresented {
            showAwardPopUp()
            self.awardViewControllerPresented = true
            return
        }
//        if host.gameStart {
//            borderView.removeFromSuperview()
//            self.view.addSubview(teamNumLabel)
//            self.view.addSubview(iconButton)
//            self.view.addSubview(teamNameLabel)
//        }
        if self.round != host.currentRound {
            roundLabel.text = "Round " + "\(host.currentRound)"
            leftTeamNumLabel.text = "Team \(self.teamOrder[2 * host.currentRound - 2].number)"
            leftIconButton.image = UIImage(named: self.teamOrder[2 * host.currentRound - 2].iconName)
            leftTeamNameLabel.text = "Team name is" + "\n" + "\(self.teamOrder[2 * host.currentRound - 2].name)"
            leftScoreLabel.text = "\(self.teamOrder[2 * host.currentRound - 2].points)"
            rightTeamNumLabel.text = "Team \(self.teamOrder[2 * host.currentRound - 1].number)"
            rightIconButton.image = UIImage(named: self.teamOrder[2 * host.currentRound - 1].iconName)
            rightTeamNameLabel.text = "Team name is" + "\n" + "\(self.teamOrder[2 * host.currentRound - 1].name)"
            rightScoreLabel.text = "\(self.teamOrder[2 * host.currentRound - 1].points)"
            leftWinButton.gestureRecognizers?.forEach { gestureRecognizer in
                gestureRecognizer.isEnabled = true
            }
            leftWinButton.image = UIImage(named: "Win Blue Button")
            leftLoseButton.gestureRecognizers?.forEach { gestureRecognizer in
                gestureRecognizer.isEnabled = true
            }
            leftLoseButton.image = UIImage(named: "Lose Yellow Button")
            rightWinButton.gestureRecognizers?.forEach { gestureRecognizer in
                gestureRecognizer.isEnabled = true
            }
            rightWinButton.image = UIImage(named: "Win Blue Button")
            rightLoseButton.gestureRecognizers?.forEach { gestureRecognizer in
                gestureRecognizer.isEnabled = true
            }
            rightLoseButton.image = UIImage(named: "Lose Yellow Button")
            self.round = host.currentRound
            self.teamA = self.teamOrder[2 * host.currentRound - 2]
            self.teamB = self.teamOrder[2 * host.currentRound - 1]
            UserData.writeMax("", "maxA")
            maxA = UserData.readMax("maxA")!
            UserData.writeMax("", "maxB")
            maxB = UserData.readMax("maxB")!
        }
    }
    
    func callProtocols() {
        T.delegates.append(self)
        H.delegates.append(self)
        T.listenTeams(gameCode, onListenerUpdate: listen(_:))
        H.listenHost(gameCode, onListenerUpdate: listen(_:))
    }
    
    func listen(_ _ : [String : Any]){
    }
}



