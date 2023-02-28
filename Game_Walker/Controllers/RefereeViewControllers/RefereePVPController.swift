//
//  RefereePVPController.swift
//  Game_Walker
//
//  Created by 김현식 on 1/30/23.
//

import Foundation
import UIKit

class RefereePVPController: UIViewController {
    
    @IBOutlet weak var stationinfoButton: UIButton!
    @IBOutlet weak var annnouncementButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    var stationName = ""
    var index = 0
    var round = 1
    var teamOrder : [Team] = [Team(gamecode: UserData.readReferee("Referee")!.gamecode, name: "Girl", number: 1, players: [], points: 10, currentStation: "testing2", nextStation: "", iconName: "iconGirl"), Team(gamecode: UserData.readReferee("Referee")!.gamecode, name: "Boy", number: 2, players: [], points: 10, currentStation: "testing2", nextStation: "", iconName: "iconBoy")]
    var timer: Timer?
    var seconds : Int?
    var teamA : Team?
    var teamB : Team?
    
    override func viewDidLoad() {
        H.delegate_getHost = self
        S.delegate_getStation = self
        T.delegate_getTeam = self
        T.delegates.append(self)
        T.listenTeams(UserData.readGamecode("gamecode")!, onListenerUpdate: listen(_:))
        H.getHost(UserData.readGamecode("gamecode")!)
        self.teamA = self.teamOrder[index]
        self.teamB = self.teamOrder[index+1]
        S.getStation(UserData.readReferee("Referee")!.gamecode, "testing2")
        super.viewDidLoad()
        self.view.addSubview(roundLabel)
        self.view.addSubview(leftcontainerView)
        self.view.addSubview(lefticonButton)
        self.view.addSubview(leftteamNumber)
        self.view.addSubview(leftteamName)
        self.view.addSubview(leftscoreLabel)
        self.view.addSubview(rightcontainerView)
        self.view.addSubview(righticonButton)
        self.view.addSubview(rightteamNumber)
        self.view.addSubview(rightteamName)
        self.view.addSubview(timerLabel)
        self.view.addSubview(rightscoreLabel)

        roundLabel.translatesAutoresizingMaskIntoConstraints = false
        roundLabel.widthAnchor.constraint(equalToConstant: 149.17).isActive = true
        roundLabel.heightAnchor.constraint(equalToConstant: 61).isActive = true
        roundLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        roundLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 151).isActive = true
        
        leftcontainerView.translatesAutoresizingMaskIntoConstraints = false
        leftcontainerView.widthAnchor.constraint(equalToConstant: 153).isActive = true
        leftcontainerView.heightAnchor.constraint(equalToConstant: 238).isActive = true
        leftcontainerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 23).isActive = true
        leftcontainerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 237).isActive = true
        
        lefticonButton.translatesAutoresizingMaskIntoConstraints = false
        lefticonButton.widthAnchor.constraint(equalToConstant: 135).isActive = true
        lefticonButton.heightAnchor.constraint(equalToConstant: 135).isActive = true
        lefticonButton.centerXAnchor.constraint(equalTo: leftcontainerView.centerXAnchor).isActive = true
        lefticonButton.topAnchor.constraint(equalTo: leftcontainerView.topAnchor, constant: 5).isActive = true
        
        leftteamNumber.translatesAutoresizingMaskIntoConstraints = false
        leftteamNumber.widthAnchor.constraint(equalToConstant: 83.58).isActive = true
        leftteamNumber.heightAnchor.constraint(equalToConstant: 28.76).isActive = true
        leftteamNumber.centerXAnchor.constraint(equalTo: leftcontainerView.centerXAnchor).isActive = true
        leftteamNumber.topAnchor.constraint(equalTo: leftcontainerView.topAnchor, constant: 145.51).isActive = true
        
        leftteamName.translatesAutoresizingMaskIntoConstraints = false
        leftteamName.widthAnchor.constraint(equalToConstant: 126.45).isActive = true
        leftteamName.heightAnchor.constraint(equalToConstant: 28.76).isActive = true
        leftteamName.centerXAnchor.constraint(equalTo: leftcontainerView.centerXAnchor).isActive = true
        leftteamName.topAnchor.constraint(equalTo: leftcontainerView.topAnchor, constant: 167.46).isActive = true
        
        leftscoreLabel.translatesAutoresizingMaskIntoConstraints = false
        leftscoreLabel.widthAnchor.constraint(equalToConstant: 109.01).isActive = true
        leftscoreLabel.heightAnchor.constraint(equalToConstant: 40.12).isActive = true
        leftscoreLabel.centerXAnchor.constraint(equalTo: leftcontainerView.centerXAnchor).isActive = true
        leftscoreLabel.topAnchor.constraint(equalTo: leftcontainerView.topAnchor, constant: 191.88).isActive = true
        
        rightcontainerView.translatesAutoresizingMaskIntoConstraints = false
        rightcontainerView.widthAnchor.constraint(equalToConstant: 153).isActive = true
        rightcontainerView.heightAnchor.constraint(equalToConstant: 238).isActive = true
        rightcontainerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 199).isActive = true
        rightcontainerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 237).isActive = true
        
        righticonButton.translatesAutoresizingMaskIntoConstraints = false
        righticonButton.widthAnchor.constraint(equalToConstant: 135).isActive = true
        righticonButton.heightAnchor.constraint(equalToConstant: 135).isActive = true
        righticonButton.centerXAnchor.constraint(equalTo: rightcontainerView.centerXAnchor).isActive = true
        righticonButton.topAnchor.constraint(equalTo: rightcontainerView.topAnchor, constant: 5).isActive = true
        
        rightteamNumber.translatesAutoresizingMaskIntoConstraints = false
        rightteamNumber.widthAnchor.constraint(equalToConstant: 83.58).isActive = true
        rightteamNumber.heightAnchor.constraint(equalToConstant: 28.76).isActive = true
        rightteamNumber.centerXAnchor.constraint(equalTo: rightcontainerView.centerXAnchor).isActive = true
        rightteamNumber.topAnchor.constraint(equalTo: rightcontainerView.topAnchor, constant: 145.51).isActive = true
        
        rightteamName.translatesAutoresizingMaskIntoConstraints = false
        rightteamName.widthAnchor.constraint(equalToConstant: 126.45).isActive = true
        rightteamName.heightAnchor.constraint(equalToConstant: 28.76).isActive = true
        rightteamName.centerXAnchor.constraint(equalTo: rightcontainerView.centerXAnchor).isActive = true
        rightteamName.topAnchor.constraint(equalTo: rightcontainerView.topAnchor, constant: 167.46).isActive = true
        
        rightscoreLabel.translatesAutoresizingMaskIntoConstraints = false
        rightscoreLabel.widthAnchor.constraint(equalToConstant: 109.01).isActive = true
        rightscoreLabel.heightAnchor.constraint(equalToConstant: 40.12).isActive = true
        rightscoreLabel.centerXAnchor.constraint(equalTo: rightcontainerView.centerXAnchor).isActive = true
        rightscoreLabel.topAnchor.constraint(equalTo: rightcontainerView.topAnchor, constant: 191.88).isActive = true

        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.widthAnchor.constraint(equalToConstant: 179).isActive = true
        timerLabel.heightAnchor.constraint(equalToConstant: 73).isActive = true
        timerLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        timerLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 500).isActive = true
    
        runTimer()
        
    }
    
    private lazy var leftcontainerView: UIView = {
        var view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 153, height: 231.61)
        view.backgroundColor = .white
        var border = UIView()
        border.bounds = view.bounds.insetBy(dx: -5, dy: -5)
        border.center = view.center
        view.addSubview(border)
        view.bounds = view.bounds.insetBy(dx: -5, dy: -5)
        border.layer.borderWidth = 5
        border.layer.borderColor = UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 0.5).cgColor
        return border
    }()
    
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
    
    private lazy var rightcontainerView: UIView = {
        var view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 153, height: 231.61)
        view.backgroundColor = .white
        var border = UIView()
        border.bounds = view.bounds.insetBy(dx: -5, dy: -5)
        border.center = view.center
        view.addSubview(border)
        view.bounds = view.bounds.insetBy(dx: -5, dy: -5)
        border.layer.borderWidth = 5
        border.layer.borderColor = UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 0.5).cgColor
        return border
    }()
    
    private lazy var righticonButton: UIButton = {
        var button = UIButton(frame: CGRect(x: 0, y: 0, width: 175, height: 175))
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: teamOrder[index+1].iconName), for: .normal)
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
        view.text = "Team " + "\(self.teamOrder[index+1].number)"
        return view
    }()
    
    private lazy var rightteamName: UILabel = {
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 174, height: 38)
        view.backgroundColor = .white
        view.textColor = .black
        view.font = UIFont(name: "Dosis-Regular", size: 15)
        view.textAlignment = .center
        view.text = teamOrder[index+1].name
        return view
    }()
    
    private lazy var rightscoreLabel: UILabel = {
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 150, height: 53)
        view.backgroundColor = .white
        view.textColor = .black
        view.font = UIFont(name: "Dosis-Bold", size: 35)
        view.textAlignment = .center
        view.text = "\(teamOrder[index+1].points)"
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
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(RefereePVPController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
            if seconds! < 1 {
                H.getHost(UserData.readGamecode("gamecode")!)
                T.getTeam(UserData.readGamecode("gamecode")!, UserData.readTeam("points")!.name)
                round += 1
                index += 2
                lefticonButton.setImage(UIImage(named: teamOrder[index].iconName), for: .normal)
                leftteamNumber.text = "Team " + "\(self.teamOrder[index].number)"
                leftteamName.text = teamOrder[index].name
                leftscoreLabel.text = "\(teamOrder[index].points)"
                righticonButton.setImage(UIImage(named: teamOrder[index + 1].iconName), for: .normal)
                rightteamNumber.text = "Team " + "\(self.teamOrder[index + 1].number)"
                rightteamName.text = teamOrder[index + 1].name
                rightscoreLabel.text = "\(teamOrder[index + 1].points)"
                roundLabel.text = "Round " + "\(round)"
            } else {
                seconds! -= 1
                T.getTeam(UserData.readGamecode("gamecode")!, UserData.readTeam("points")!.name)
                timerLabel.text = timeString(time: TimeInterval(seconds!))
            }
    }
    
    func timeString(time:TimeInterval) -> String {
            let minutes = Int(time) / 60 % 60
            let seconds = Int(time) % 60
            return String(format:"%02i : %02i", minutes, seconds)
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
        showRefereeMessagePopUp()
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        
    }
    
    func listen(_ _ : [String : Any]){
    }
    
    
}

//MARK: - UIUpdate
extension RefereePVPController: GetStation {
    func getStation(_ station: Station) {
        self.stationName = station.name
        self.teamOrder = station.teamOrder
    }
}
//MARK: - UIUpdate
extension RefereePVPController: GetHost {
    func getHost(_ host: Host) {
        self.seconds = host.gameTime
    }
}
//MARK: - UIUpdate
extension RefereePVPController: GetTeam {
    func getTeam(_ team: Team) {
        if team.name == leftteamName.text {
            leftscoreLabel.text = "\(team.points)"
        }
        else {
            rightscoreLabel.text = "\(team.points)"
        }
    }
}
// MARK: - listener
extension RefereePVPController: TeamUpdateListener {
    func updateTeams(_ teams: [Team]) {
    }
}

