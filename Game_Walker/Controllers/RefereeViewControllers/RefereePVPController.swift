//
//  RefereePVPController.swift
//  Game_Walker
//
//  Created by 김현식 on 1/30/23.
//

import Foundation
import UIKit

class RefereePVPController: UIViewController {
    
    @IBOutlet weak var leftscoreButton: UIButton!
    @IBOutlet weak var rightscoreButton: UIButton!
    @IBOutlet weak var stationinfoButton: UIButton!
    
    var round = 1
    var stationName = ""
    var index = 0
    var teamOrder : [Team] = []
    var timer: Timer?
    var seconds = 3600
    var time = 0
    var team1 : Team?
    var team2 : Team?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        H.delegate_getHost = self
        
        var team1 = Team(gamecode: UserData.readReferee("Referee")!.gamecode, name: "Air", players: [], points: 20, currentStation: "testing", nextStation: "", iconName: "")
        var team2 = Team(gamecode: UserData.readReferee("Referee")!.gamecode, name: "Bear", players: [], points: 20, currentStation: "testing2", nextStation: "", iconName: "")
        var newStation = Station(name: "testing", pvp: true, points: 20, place: "", description: "", teamOrder: [team1])
        var newStation2 = Station(name: "testing2", pvp: true, points: 20, place: "", description: "", teamOrder: [team2])
        
        S.addStation(UserData.readReferee("Referee")!.gamecode, newStation)
        S.getStation(UserData.readReferee("Referee")!.gamecode, "testing")
        S.addStation(UserData.readReferee("Referee")!.gamecode, newStation2)
        
        leftborderView.translatesAutoresizingMaskIntoConstraints = false
        leftborderView.widthAnchor.constraint(equalToConstant: 153).isActive = true
        leftborderView.heightAnchor.constraint(equalToConstant: 231.61).isActive = true
        leftborderView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 23).isActive = true
        leftborderView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 237).isActive = true
        
        rightborderView.translatesAutoresizingMaskIntoConstraints = false
        rightborderView.widthAnchor.constraint(equalToConstant: 153).isActive = true
        rightborderView.heightAnchor.constraint(equalToConstant: 231.61).isActive = true
        rightborderView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 23).isActive = true
        rightborderView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 237).isActive = true

        roundLabel.translatesAutoresizingMaskIntoConstraints = false
        roundLabel.widthAnchor.constraint(equalToConstant: 149.17).isActive = true
        roundLabel.heightAnchor.constraint(equalToConstant: 61).isActive = true
        roundLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        roundLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 151).isActive = true
        
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.widthAnchor.constraint(equalToConstant: 179).isActive = true
        timerLabel.heightAnchor.constraint(equalToConstant: 73).isActive = true
        timerLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        timerLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 500).isActive = true
    
        runTimer()
        
    }
    
    private lazy var leftborderView: UIView = {
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
    
    private lazy var leftteamNumber: UILabel = {
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 83.58, height: 28.76)
        view.backgroundColor = .white
        view.textColor = .black
        view.font = UIFont(name: "Dosis-SemiBold", size: 25)
        view.textAlignment = .center
        view.text = "Team " + "\(self.teamOrder[index].number)"
        return view
    }()
    
    private lazy var leftteamName: UILabel = {
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 174, height: 38)
        view.backgroundColor = .white
        view.textColor = .black
        view.font = UIFont(name: "Dosis-Regular", size: 25)
        view.textAlignment = .center
        view.text = teamOrder[index].name
        return view
    }()
    
    private lazy var rightborderView: UIView = {
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
    
    private lazy var rightteamNumber: UILabel = {
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 83.58, height: 28.76)
        view.backgroundColor = .white
        view.textColor = .black
        view.font = UIFont(name: "Dosis-SemiBold", size: 25)
        view.textAlignment = .center
        view.text = "Team " + "\(self.teamOrder[index].number)"
        return view
    }()
    
    private lazy var rightteamName: UILabel = {
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 174, height: 38)
        view.backgroundColor = .white
        view.textColor = .black
        view.font = UIFont(name: "Dosis-Regular", size: 25)
        view.textAlignment = .center
        view.text = teamOrder[index+1].name
        return view
    }()
    
    private lazy var roundLabel: UILabel = {
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 149.17, height: 61)
        view.backgroundColor = .white
        view.textColor = .black
        view.font = UIFont(name: "Dosis-SemiBold", size: 45)
        view.textAlignment = .center
        view.text = "Round " + "\(index + 1)"
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
            if seconds < 1 {
                index += 2
                leftteamNumber.text = "Team " + "\(self.teamOrder[index].number)"
                leftteamName.text = teamOrder[index].name
                rightteamNumber.text = "Team " + "\(self.teamOrder[index + 2].number)"
                rightteamName.text = teamOrder[index + 2].name
                roundLabel.text = "Round " + "\(index + 1)"
                //scoreLabel.text = "\(teamOrder[index].points)"
            } else {
                seconds -= 1
                timerLabel.text = timeString(time: TimeInterval(seconds))
            }
    }
    
    func timeString(time:TimeInterval) -> String {
            let minutes = Int(time) / 60 % 60
            let seconds = Int(time) % 60
            return String(format:"%02i : %02i", minutes, seconds)
    }
    
    @IBAction func leftscoreButtonPressed(_ sender: UIButton) {
        UserData.writeTeam(team1!, "points")
        performSegue(withIdentifier: "givePoints", sender: self)
    }
    
    @IBAction func rightscoreButtonPressed(_ sender: UIButton) {
        UserData.writeTeam(team2!, "points")
        performSegue(withIdentifier: "givePoints", sender: self)
    }
    
    @IBAction func stationinfoButtonPressed(_ sender: UIButton) {
        showRefereeGameInfoPopUp()
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
        self.time = host.gameTime
    }
}
