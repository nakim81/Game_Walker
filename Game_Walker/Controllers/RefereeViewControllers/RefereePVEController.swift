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
    @IBOutlet weak var infoButton: UIButton!
    
    private var gameCode = UserData.readGamecode("gamecode")!
    private var referee = UserData.readReferee("referee")!
    private var host: Host = Host()
    private var team : Team = Team()
    private var teams : [Team] = [Team(name: "Simon Dominic", iconName: "iconDaisy")]
    private var stations : [Station] = [Station()]
    private var teamOrder : [Team] = [Team(name: "Simon Dominic", iconName: "iconDaisy")]
//    private var maxPoints : Bool = false
    private var max : String = ""
    private var round : Int = 1
    private var points : Int = 0
    
    private let audioPlayerManager = AudioPlayerManager()
    private let readAll = UIImage(named: "messageIcon")
    private let unreadSome = UIImage(named: "unreadMessage")
    private var messages: [String] = []
    
    override func viewDidLoad() {
        Task {
            stations = try await S.getStationList(gameCode)
            teams = try await T.getTeamList(gameCode)
            host = try await H.getHost(gameCode) ?? Host()
            max = UserData.readMax("max") ?? ""
            if max == "true" {
                winButton.image = UIImage(named: "Lose Gray Button")
                loseButton.image = UIImage(named: "Lose Yellow Button")
            } else if max == "false" {
                winButton.image = UIImage(named: "Win Blue Button")
                loseButton.image = UIImage(named: "Lose Gray Button")
            } else {
                winButton.image = UIImage(named: "Win Blue Button")
                loseButton.image = UIImage(named: "Lose Yellow Button")
            }
            callProtocols()
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
        if RefereeRankingPVEViewController.unread {
            self.messageButton.setImage(unreadSome, for: .normal)
            self.audioPlayerManager.playAudioFile(named: "message", withExtension: "wav")
        } else {
            self.messageButton.setImage(readAll, for: .normal)
        }
    }
    
    @objc func readAll(notification: Notification) {
        guard let unread = notification.userInfo?["unread"] as? Bool else {
            return
        }
        if unread {
            self.messageButton.setImage(self.unreadSome, for: .normal)
            self.audioPlayerManager.playAudioFile(named: "message", withExtension: "wav")
        } else {
            self.messageButton.setImage(self.readAll, for: .normal)
        }
    }
    
    @IBAction func messageButtonPressed(_ sender: Any) {
        showRefereeMessagePopUp(messages: RefereeRankingPVEViewController.localMessages)
    }
    
    @IBAction func leaveButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "toRegister", sender: self)
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        // Testing code for resetting max variable
        max = ""
        UserDefaults.standard.removeObject(forKey: "max")
        winButton.image = UIImage(named: "Win Blue Button")
        loseButton.image = UIImage(named: "Lose Yellow Button")
    }
    
    //MARK: - Buttons Pressed
    @objc func buttonTapped() {
        if self.team.number == 0 {
            alert(title: "The Team doesn't exist", message: "This is an invalid team.")
        } else {
            UserData.writeTeam(self.team, "Team")
            let popUpWindow = GivePointsController(team: UserData.readTeam("Team")!, gameCode: UserData.readGamecode("gamecode")!)
            self.present(popUpWindow, animated: true, completion: nil)
        }
    }
    
//MARK: - Overlay
    @IBAction func infoBtnPressed(_ sender: Any) {
        view.addSubview(shadeView)
        view.addSubview(buttonBorder)
        view.addSubview(closeBtn)
        view.addSubview(teamPointsLabel)
        view.addSubview(winButton)
        winButton.image = UIImage(named: "Win Blue Button")
        winButton.isUserInteractionEnabled = false
        view.addSubview(loseButton)
        loseButton.image = UIImage(named: "Lose Yellow Button")
        loseButton.isUserInteractionEnabled = false
        view.addSubview(explanationLabel)
        let overlayViewController = OverlayViewController()
        overlayViewController.modalPresentationStyle = .overFullScreen
        present(overlayViewController, animated: true, completion: nil)
        showOverlay()
        setupOverlayView()
    }
    
    private lazy var shadeView: UIView = {
        var view = UIView(frame: view.bounds)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        return view
    }()
    
    private lazy var closeBtn: UIImageView = {
        var view = UIImageView()
        view.image = UIImage(named: "icon _close_")
        view.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissOverlay))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    private lazy var buttonBorder: UIView = {
        var view = UIView()
        view.backgroundColor = .clear
        view.layer.borderWidth = 5.0
        view.layer.borderColor = UIColor(red: 40.0 / 255.0, green: 209.0 / 255.0, blue: 113.0 / 255.0, alpha: 1.0).cgColor
        view.layer.cornerRadius = 5.0
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Click to give points of the Team"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Bold", size: 13)
        view.addSubview(label)
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5).isActive = true
        return view
    }()
    
    private lazy var teamPointsLabel: UIView = {
        var view = UIView()
        view.backgroundColor = .clear
        view.layer.borderWidth = 5.0
        view.layer.borderColor = UIColor(red: 40.0 / 255.0, green: 209.0 / 255.0, blue: 113.0 / 255.0, alpha: 1.0).cgColor
        view.layer.cornerRadius = 5.0
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Team's total points"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Bold", size: 13)
        view.addSubview(label)
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5).isActive = true
        return view
    }()
    
    private lazy var explanationLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Click win to give points of standard station points"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Bold", size: 13)
        return label
    }()
    
    private func setupOverlayView() {
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        buttonBorder.translatesAutoresizingMaskIntoConstraints = false
        teamPointsLabel.translatesAutoresizingMaskIntoConstraints = false
        explanationLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeBtn.widthAnchor.constraint(equalToConstant: 44),
            closeBtn.heightAnchor.constraint(equalToConstant: 44),
            closeBtn.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 25),
            closeBtn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -25),
            
            buttonBorder.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            buttonBorder.topAnchor.constraint(equalTo: teamNumLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.03),
            buttonBorder.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.467),
            buttonBorder.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.467),
            
            teamPointsLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.370),
            teamPointsLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.0604),
            teamPointsLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            teamPointsLabel.topAnchor.constraint(equalTo: teamNameLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.05),
            
            explanationLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.80),
            explanationLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.0604),
            explanationLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            explanationLabel.topAnchor.constraint(equalTo: winButton.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.01)
        ])
    }
    
    @objc func dismissOverlay() {
        //shadeView.removeFromSuperview()
        buttonBorder.removeFromSuperview()
        teamPointsLabel.removeFromSuperview()
        closeBtn.removeFromSuperview()
        explanationLabel.removeFromSuperview()
        for border in circularBorders {
            border.removeFromSuperview()
        }
        for label in explanationLbls {
            label.removeFromSuperview()
        }
        winButton.isUserInteractionEnabled = true
        loseButton.isUserInteractionEnabled = true
        if max == "true" {
            winButton.image = UIImage(named: "Lose Gray Button")
            loseButton.image = UIImage(named: "Lose Yellow Button")
        } else if max == "false" {
            winButton.image = UIImage(named: "Win Blue Button")
            loseButton.image = UIImage(named: "Lose Gray Button")
        } else {
            winButton.image = UIImage(named: "Win Blue Button")
            loseButton.image = UIImage(named: "Lose Yellow Button")
        }
        explanationLbls.removeAll()
        circularBorders.removeAll()
    }
    
    var circularBorders: [UIView] = []
    var explanationLbls: [UILabel] = []
    
    private func showOverlay() {
        var index : Int = 0
        var tabBarTop: CGFloat = 0
        var componentPositions: [CGPoint] = []
        let explanationTexts = ["Remote your Station", "Ranking Status", "Timer & Station Info"]
        let colors = [UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1).cgColor, UIColor(red: 0.942, green: 0.71, blue: 0.114, alpha: 1).cgColor, UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1).cgColor]
        if let tabBarController = self.tabBarController {
            for viewController in tabBarController.viewControllers ?? [] {
                if let tabItem = viewController.tabBarItem {
                    if let tabItemView = tabItem.value(forKey: "view") as? UIView {
                        // Adding Circle Borders on Tab Bar Frame
                        let tabItemFrame = tabItemView.frame
                        let tabBarFrame = tabBarController.tabBar.frame
                        let centerXPosition = tabItemFrame.midX
                        let centerYPosition = tabBarFrame.midY
                        let circularBorder = UIView()
                        circularBorder.frame = CGRect(x: centerXPosition / 2, y: centerYPosition / 2, width: tabItemFrame.width * 0.45, height: tabItemFrame.width * 0.45)
                        circularBorder.layer.cornerRadius = tabItemFrame.width * 0.45 / 2
                        circularBorder.layer.borderWidth = 4.0
                        circularBorder.layer.borderColor = colors[index]
                        circularBorder.translatesAutoresizingMaskIntoConstraints = false
                        self.view.addSubview(circularBorder)
                        circularBorders.append(circularBorder)
                        // Adding Texts on Tab Bar Frame
                        let topAnchorPosition = tabItemFrame.minY + tabBarFrame.origin.y
                        if (tabBarTop == 0) {
                            tabBarTop = topAnchorPosition
                        }
                        componentPositions.append(CGPoint(x: centerXPosition, y: topAnchorPosition))
                        NSLayoutConstraint.activate([
                            circularBorder.centerXAnchor.constraint(equalTo: tabItemView.centerXAnchor),
                            circularBorder.centerYAnchor.constraint(equalTo: tabItemView.centerYAnchor),
                            circularBorder.widthAnchor.constraint(equalTo: tabItemView.widthAnchor, multiplier: 0.45),
                            circularBorder.heightAnchor.constraint(equalTo: tabItemView.widthAnchor, multiplier: 0.45)
                        ])
                        
                        let explanationLbl = UILabel()
                        explanationLbl.translatesAutoresizingMaskIntoConstraints = false
                        explanationLbl.text = explanationTexts[index]
                        explanationLbl.numberOfLines = 0
                        explanationLbl.textAlignment = .center
                        explanationLbl.textColor = .white
                        explanationLbl.font = UIFont(name: "Dosis-Bold", size: 15)
                        self.view.addSubview(explanationLbl)
                        explanationLbls.append(explanationLbl)
                        var maxWidth: CGFloat = 0
                        if (componentPositions[index].y >= tabBarTop) {
                            maxWidth = 75
                        } else {
                            maxWidth = 200
                        }
                        explanationLbl.widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth).isActive = true
                        NSLayoutConstraint.activate([
                            explanationLbl.centerXAnchor.constraint(equalTo: self.view.leadingAnchor, constant: componentPositions[index].x),
                            explanationLbl.bottomAnchor.constraint(equalTo: self.view.topAnchor, constant: componentPositions[index].y - 15)
                        ])
                        index += 1
                    }
                }
            }
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
        label.textColor = UIColor(red: 0.176, green: 0.176, blue: 0.208 , alpha: 1)
        label.numberOfLines = 2
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        return label
    }()
    
    private lazy var roundLabel: UILabel = {
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 149.17, height: 61)
        view.backgroundColor = .white
        view.textColor = UIColor(red: 0.176, green: 0.176, blue: 0.208 , alpha: 1)
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
        label.textColor = UIColor(red: 0.176, green: 0.176, blue: 0.208 , alpha: 1)
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
        label.textColor = UIColor(red: 0.176, green: 0.176, blue: 0.208 , alpha: 1)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private lazy var scoreLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 53))
        label.font = UIFont(name: "Dosis-Bold", size: fontSize(size: 50))
        label.text = "\(self.teamOrder[self.round - 1].points)"
        label.textColor = UIColor(red: 0.176, green: 0.176, blue: 0.208 , alpha: 1)
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
        if self.team.number == 0 {
            alert(title: "The Team doesn't exist", message: "This is an invalid team.")
        } else {
//            if !maxPoints {
//                Task {
//                    do {
//                        try await T.givePoints(gameCode, self.team.name, self.points)
//                    } catch GameWalkerError.serverError(let text){
//                        print(text)
//                        serverAlert(text)
//                        return
//                    }
//                }
//                maxPoints = true
//            }
            if max != "true" {
                Task {
                    do {
                        try await T.givePoints(gameCode, self.team.name, self.points)
                    } catch GameWalkerError.serverError(let text){
                        print(text)
                        serverAlert(text)
                        return
                    }
                }
                UserData.writeMax("true", "max")
                max = UserData.readMax("max")!
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
        if self.team.number == 0 {
            alert(title: "The Team doesn't exist", message: "This is an invalid team.")
        } else {
//            if maxPoints {
//                Task {
//                    do {
//                        try await T.givePoints(gameCode, self.team.name, -self.points)
//                    } catch GameWalkerError.serverError(let text){
//                        print(text)
//                        serverAlert(text)
//                        return
//                    }
//                    maxPoints = false
//                }
//            }
            if max == "true" {
                Task {
                    do {
                        try await T.givePoints(gameCode, self.team.name, -self.points)
                    } catch GameWalkerError.serverError(let text){
                        print(text)
                        serverAlert(text)
                        return
                    }
                }
                UserData.writeMax("false", "max")
                max = UserData.readMax("max")!
            }
            winButton.gestureRecognizers?.forEach { gestureRecognizer in
                gestureRecognizer.isEnabled = true
            }
            winButton.image = UIImage(named: "Win Blue Button")
            loseButton.gestureRecognizers?.forEach { gestureRecognizer in
                gestureRecognizer.isEnabled = false
            }
            loseButton.image = UIImage(named: "Lose Gray Button")
        }
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
            gameCodeLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: UIScreen.main.bounds.size.height * 0.035),
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
            if self.team.name == team.name {
                self.team = team
            }
        }
        scoreLabel.text = "\(self.team.points)"
    }
    
    func updateHost(_ host: Host) {
        if self.round != host.currentRound {
            roundLabel.text = "Round " + "\(host.currentRound)"
            teamNumLabel.text = "Team \(self.teamOrder[host.currentRound - 1].number)"
            iconButton.image = UIImage(named: self.teamOrder[host.currentRound - 1].iconName)
            teamNameLabel.text = "Team name is" + "\n" + "\(self.teamOrder[host.currentRound - 1].name)"
            scoreLabel.text = "\(self.teamOrder[host.currentRound - 1].points)"
            winButton.gestureRecognizers?.forEach { gestureRecognizer in
                gestureRecognizer.isEnabled = true
            }
            winButton.image = UIImage(named: "Win Blue Button")
            loseButton.gestureRecognizers?.forEach { gestureRecognizer in
                gestureRecognizer.isEnabled = true
            }
            loseButton.image = UIImage(named: "Lose Yellow Button")
            self.round = host.currentRound
            self.team = self.teamOrder[host.currentRound - 1]
            UserData.writeMax("", "max")
            max = UserData.readMax("max")!
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


