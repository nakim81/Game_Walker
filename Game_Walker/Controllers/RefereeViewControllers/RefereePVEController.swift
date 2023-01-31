//
//  RefereePVEController.swift
//  Game_Walker
//
//  Created by 김현식 on 1/27/23.
//

import Foundation
import UIKit

class RefereePVEController: UIViewController {
    
    @IBOutlet weak var stationinfoButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var iconscoreButton: UIButton!
    var stationName = ""
    var seconds : Int?
    var timer : Timer?
    var index = 0
    var team : Team?
    var teamOrder : [Team] = [Team(gamecode: UserData.readReferee("Referee")!.gamecode, name: "Air", number: 1, players: [], points: 10, currentStation: "testing", nextStation: "", iconName: "iconAir")]
    
    override func viewDidLoad() {
        H.delegate_getHost = self
        S.delegate_getStation = self
        S.getStation(UserData.readReferee("Referee")!.gamecode, "testing")
        H.getHost(UserData.readGamecode("gamecode")!)
        super.viewDidLoad()
        //
        iconscoreButton.setImage(UIImage(named: "iconAir"), for: .normal)
        self.view.bringSubviewToFront(iconscoreButton)
        //
        self.view.addSubview(roundLabel)
        self.view.addSubview(borderView)
        self.view.addSubview(teamNumber)
        self.view.addSubview(teamName)
        self.view.addSubview(timerLabel)
        self.view.addSubview(scoreLabel)
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.widthAnchor.constraint(equalToConstant: 211).isActive = true
        borderView.heightAnchor.constraint(equalToConstant: 306).isActive = true
        borderView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        borderView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 187).isActive = true
        teamNumber.translatesAutoresizingMaskIntoConstraints = false
        teamNumber.widthAnchor.constraint(equalToConstant: 115).isActive = true
        teamNumber.heightAnchor.constraint(equalToConstant: 38).isActive = true
        teamNumber.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        teamNumber.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 382).isActive = true
        teamName.translatesAutoresizingMaskIntoConstraints = false
        teamName.widthAnchor.constraint(equalToConstant: 174).isActive = true
        teamName.heightAnchor.constraint(equalToConstant: 38).isActive = true
        teamName.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        teamName.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 411).isActive = true
        roundLabel.translatesAutoresizingMaskIntoConstraints = false
        roundLabel.widthAnchor.constraint(equalToConstant: 149.17).isActive = true
        roundLabel.heightAnchor.constraint(equalToConstant: 61).isActive = true
        roundLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        roundLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 101).isActive = true
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.widthAnchor.constraint(equalToConstant: 179).isActive = true
        timerLabel.heightAnchor.constraint(equalToConstant: 73).isActive = true
        timerLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        timerLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 521).isActive = true
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
        scoreLabel.heightAnchor.constraint(equalToConstant: 53).isActive = true
        scoreLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        scoreLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 440).isActive = true
        runTimer()
    }
    
    private lazy var borderView: UIView = {
        var view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 211, height: 306)
        view.backgroundColor = .white
        var border = UIView()
        border.bounds = view.bounds.insetBy(dx: -5, dy: -5)
        border.center = view.center
        view.addSubview(iconscoreButton)
        view.addSubview(border)
        view.bounds = view.bounds.insetBy(dx: -5, dy: -5)
        border.layer.borderWidth = 5
        border.layer.borderColor = UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 0.5).cgColor
        return view
    }()
    
    private lazy var iconView: UIImageView = {
        var view = UIImageView()
        view.frame = CGRect(x: 0, y: 0, width: 211, height: 306)
        view.backgroundColor = .white
        var border = UIView()
        border.bounds = view.bounds.insetBy(dx: -5, dy: -5)
        border.center = view.center
        view.addSubview(border)
        view.bounds = view.bounds.insetBy(dx: -5, dy: -5)
        border.layer.borderWidth = 5
        border.layer.borderColor = UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 0.5).cgColor
        return view
    }()
    
    private lazy var teamNumber: UILabel = {
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 115, height: 38)
        view.backgroundColor = .white
        view.textColor = .black
        view.font = UIFont(name: "Dosis-SemiBold", size: 25)
        view.textAlignment = .center
        view.text = "Team " + "\(self.teamOrder[index].number)"
        return view
    }()
    
    private lazy var teamName: UILabel = {
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 174, height: 38)
        view.backgroundColor = .white
        view.textColor = .black
        view.font = UIFont(name: "Dosis-Regular", size: 25)
        view.textAlignment = .center
        view.text = teamOrder[index].name
        return view
    }()
    
    private lazy var scoreLabel: UILabel = {
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 150, height: 53)
        view.backgroundColor = .white
        view.textColor = .black
        view.font = UIFont(name: "Dosis-Bold", size: 50)
        view.textAlignment = .center
        view.text = "\(teamOrder[index].points)"
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
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(RefereePVEController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        if seconds! < 1 {
            index += 1
            teamNumber.text = "Team " + "\(self.teamOrder[index].number)"
            teamName.text = teamOrder[index].name
            roundLabel.text = "Round " + "\(index + 1)"
            scoreLabel.text = "\(teamOrder[index].points)"
            seconds = 10
        } else {
            seconds! -= 1
            timerLabel.text = timeString(time: TimeInterval(seconds!))
        }
    }
    
    func timeString(time:TimeInterval) -> String {
            let minutes = Int(time) / 60 % 60
            let seconds = Int(time) % 60
            return String(format:"%02i : %02i", minutes, seconds)
    }
    
    @IBAction func stationinfoButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "givePoints", sender: self)
        //showRefereeGameInfoPopUp()
    }
    
    @IBAction func messageButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func iconscoreButtonPressed(_ sender: Any) {
        UserData.writeTeam(team!, "points")
        performSegue(withIdentifier: "givePoints", sender: self)
    }
    
}

//MARK: - UIUpdate
extension RefereePVEController: GetStation {
    func getStation(_ station: Station) {
        self.stationName = station.name
        self.teamOrder = station.teamOrder
    }
}
//MARK: - UIUpdate
extension RefereePVEController: GetHost {
    func getHost(_ host: Host) {
        self.seconds = host.gameTime
    }
}
