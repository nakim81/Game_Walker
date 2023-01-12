//
//  RefereeFrame2_1.swift
//  Game_Walker
//
//  Created by 김현식 on 7/6/22.
//

import Foundation
import UIKit

class PVERefereeController: UIViewController {
    
    @IBOutlet weak var roundLabel: UILabel!
    @IBOutlet weak var scoreButton: UIButton!
    @IBOutlet weak var teamnameLabel: UILabel!
    @IBOutlet weak var teamscoreLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var ruleButton: UIButton!
    @IBOutlet weak var nextgameButton: UIButton!
    @IBOutlet weak var borderView: UIView!
    var round = 1
    var stationName = ""
    var index = 0
    var teamOrder : [Team] = []
    var timer: Timer?
    var seconds = 3600
    var time = 0
    var team1 : Team?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        H.delegate_getHost = self
        H.getHost(UserData.readGamecode("gamecode")!)
        //var testingHost = Host(gamecode: UserData.readReferee("Referee")!.gamecode, gameTime: 2000, movingTime: 10, rounds: 10, teams: 10, algorithm: [], duplicated: [], doubled: [], blanked: [], show_scoreboard: false, paused: false, announcements: [])
        //H.createGame(UserData.readReferee("Referee")!.gamecode, testingHost)
        //H.getHost(UserData.readReferee("Referee")!.gamecode)
        S.delegate_getStation = self
        var team1 = Team(gamecode: UserData.readReferee("Referee")!.gamecode, name: "Air", players: [], points: 20, currentStation: "testing", nextStation: "", iconName: "")
        var newStation = Station(name: "testing", pvp: true, points: 10, place: "", description: "", teamOrder: [team1])
        S.addStation(UserData.readReferee("Referee")!.gamecode, newStation)
        S.getStation(UserData.readReferee("Referee")!.gamecode, "testing")
        roundLabel.text = "Round 1"
        //scoreButton.setImage(UIImage(named: teamOrder[0].iconName), for: .normal)
        //teamnameLabel.text = teamOrder[0].name
        //teamscoreLabel.text = String(teamOrder[0].points)
        scoreButton.setImage(UIImage(named: "iconAir"), for: .normal)
        teamnameLabel.text = "Team 1"
        teamscoreLabel.text = "100"
        let myColor : UIColor = UIColor(red: 0.16, green: 0.82, blue: 0.44, alpha: 1.00)
        borderView.layer.borderColor = myColor.cgColor
        borderView.layer.borderWidth = 4.0
        timerLabel.text = "60:00"
        runTimer()
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(PVERefereeController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
            if seconds < 1 {
                self.timer?.invalidate()
            } else {
                seconds -= 1
                timerLabel.text = timeString(time: TimeInterval(seconds))
            }
    }
    
    func timeString(time:TimeInterval) -> String {
            let minutes = Int(time) / 60 % 60
            print(minutes)
            let seconds = Int(time) % 60
            return String(format:"%02i : %02i", minutes, seconds)
    }
    
    @IBAction func scoreButtonPressed(_ sender: UIButton) {
        UserData.writeTeam(team1!, "points")
        performSegue(withIdentifier: "givePoints", sender: self)
    }
    
    @IBAction func ruleButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToPVERule", sender: self)
    }
    
    @IBAction func nextgameButtonPressed(_ sender: UIButton) {
        round += 1
        roundLabel.text = "Round " + "\(round)"
        index += 1
        //scoreButton.setImage(UIImage(named: teamOrder[index].iconName), for: .normal)
        //teamnameLabel.text = teamOrder[index].name
        //teamscoreLabel.text = String(teamOrder[index].points)
        scoreButton.setImage(UIImage(named: "iconBear"), for: .normal)
        teamnameLabel.text = "GameWin"
        teamscoreLabel.text = String(1000)
        timerLabel.text = "60:00"
        
    }
}

//MARK: - UIUpdate
extension PVERefereeController: GetStation {
    func getStation(_ station: Station) {
        self.stationName = station.name
        self.teamOrder = station.teamOrder
    }
}
//MARK: - UIUpdate
extension PVERefereeController: GetHost {
    func getHost(_ host: Host) {
        print(host.gameTime)
        self.seconds = host.gameTime
    }
}
