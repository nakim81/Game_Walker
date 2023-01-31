//
//  RefereeFrame2_2.swift
//  Game_Walker
//
//  Created by 김현식 on 7/6/22.
//

import Foundation
import UIKit

class PVPRefereeController: UIViewController {
    
    @IBOutlet weak var roundLabel: UILabel!
    @IBOutlet weak var scoreButton1: UIButton!
    @IBOutlet weak var teamnameLabel: UILabel!
    @IBOutlet weak var scoreLabel1: UILabel!
    @IBOutlet weak var scoreButton2: UIButton!
    @IBOutlet weak var teamnameLabel2: UILabel!
    @IBOutlet weak var scoreLabel2: UILabel!
    @IBOutlet weak var ruleButton: UIButton!
    @IBOutlet weak var nextgameButton: UIButton!
    @IBOutlet weak var borderView1: UIView!
    @IBOutlet weak var borderView2: UIView!
    @IBOutlet weak var timerLabel: UILabel!
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
        roundLabel.text = "Round 1"
        H.delegate_getHost = self
        //H.getHost("101874")
        //scoreButton1.setImage(UIImage(named: teamOrder[0].iconName), for: .normal)
        //teamnameLabel.text = teamOrder[0].name
        //scoreLabel1.text = String(teamOrder[0].points)
        //scoreButton2.setImage(UIImage(named: teamOrder[1].iconName), for: .normal)
        //teamnameLabel2.text = teamOrder[1].name
        //scoreLabel2.text = String(teamOrder[1].points)
        var team1 = Team(gamecode: UserData.readReferee("Referee")!.gamecode, name: "Air", players: [], points: 20, currentStation: "testing", nextStation: "", iconName: "")
        var team2 = Team(gamecode: UserData.readReferee("Referee")!.gamecode, name: "Bear", players: [], points: 20, currentStation: "testing2", nextStation: "", iconName: "")
        var newStation = Station(name: "testing", pvp: true, points: 20, place: "", description: "", teamOrder: [team1])
        var newStation2 = Station(name: "testing2", pvp: true, points: 20, place: "", description: "", teamOrder: [team2])
        S.addStation(UserData.readReferee("Referee")!.gamecode, newStation)
        S.getStation(UserData.readReferee("Referee")!.gamecode, "testing")
        S.addStation(UserData.readReferee("Referee")!.gamecode, newStation2)
        S.getStation(UserData.readReferee("Referee")!.gamecode, "testing2")
        scoreButton1.setImage(UIImage(named: "iconAir"), for: .normal)
        teamnameLabel.text = "Team 1"
        scoreLabel1.text = "20"
        scoreButton2.setImage(UIImage(named: "iconBear"), for: .normal)
        teamnameLabel2.text = "Team 2"
        scoreLabel2.text = "20"
        let myColor : UIColor = UIColor(red: 0.16, green: 0.82, blue: 0.44, alpha: 1.00)
        borderView1.layer.borderColor = myColor.cgColor
        borderView1.layer.borderWidth = 4.0
        borderView2.layer.borderColor = myColor.cgColor
        borderView2.layer.borderWidth = 4.0
        timerLabel.text = ""
        runTimer()
        
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(RefereePVPController.updateTimer)), userInfo: nil, repeats: true)
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
            print(seconds)
            return String(format:"%02i : %02i", minutes, seconds)
    }
    
    @IBAction func scoreButton1Pressed(_ sender: UIButton) {
        UserData.writeTeam(team1!, "points")
        performSegue(withIdentifier: "givePoints", sender: self)
    }
    
    @IBAction func scoreButton2Pressed(_ sender: UIButton) {
        UserData.writeTeam(team2!, "points")
        performSegue(withIdentifier: "givePoints", sender: self)
    }
    
    @IBAction func ruleButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToPVPRule", sender: self)
    }
    
    @IBAction func nextGamePressed(_ sender: UIButton) {
        round += 1
        roundLabel.text = "Round " + "\(round)"
        index += 2
        scoreButton1.setImage(UIImage(named: teamOrder[index].iconName), for: .normal)
        teamnameLabel.text = teamOrder[index].name
        scoreLabel1.text = String(teamOrder[index].points)
        scoreButton2.setImage(UIImage(named: teamOrder[index + 1].iconName), for: .normal)
        teamnameLabel2.text = teamOrder[index + 1].name
        scoreLabel2.text = String(teamOrder[index + 1].points)
    }
}
//MARK: - UIUpdate
extension PVPRefereeController: GetStation {
    func getStation(_ station: Station) {
        self.stationName = station.name
        self.teamOrder = station.teamOrder
    }
}
//MARK: - UIUpdate
extension PVPRefereeController: GetHost {
    func getHost(_ host: Host) {
        self.time = host.gameTime
    }
}
