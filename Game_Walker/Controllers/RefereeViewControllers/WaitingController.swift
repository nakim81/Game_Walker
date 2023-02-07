//
//  WaitingController.swift
//  Game_Walker
//
//  Created by 김현식 on 9/17/22.
//

import Foundation
import UIKit

class WaitingController: BaseViewController {

    @IBOutlet weak var GameIconView: UIImageView!
    @IBOutlet weak var WaitingImageView: UIImageView!
    var pvp : Bool = true
    var timer: Timer?
    var currentIndex: Int = 0
    let waitingImagesArray = ["waiting 2.png", "waiting 1.png", "waiting. 1.png"]

    func startTimer() {
        if let timer = timer {
            self.timer = timer
        } else {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [self] timer in
                R.getReferee(UserData.readGamecode("gamecode")!, UserData.readReferee("Referee")!.name)
                if self.currentIndex == 2 {
                    self.currentIndex = 0
                    R.assignStation(UserData.readGamecode("gamecode")!, UserData.readReferee("Referee")!, "testing")
                    S.getStation(UserData.readReferee("Referee")!.gamecode, "testing")
                }
                else {
                    self.currentIndex = self.currentIndex + 1
                }
                self.WaitingImageView.image = UIImage(named: self.waitingImagesArray[self.currentIndex])
                R.getReferee(UserData.readGamecode("gamecode")!, UserData.readReferee("Referee")!.name)
                if UserData.readReferee("Referee")!.assigned {
                    timer.invalidate()
                    if self.pvp {
                            performSegue(withIdentifier: "goToPVP", sender: self)
                        }
                        else {
                            //Example//
                            var team1 = Team(gamecode: UserData.readReferee("Referee")!.gamecode, name: "Air", number: 1, players: [], points: 10, currentStation: "testing", nextStation: "", iconName: "iconAir")
                            var team2 = Team(gamecode: UserData.readReferee("Referee")!.gamecode, name: "Bear", number: 2, players: [], points: 20, currentStation: "testing", nextStation: "", iconName: "iconBear")
                            var team3 = Team(gamecode: UserData.readReferee("Referee")!.gamecode, name: "Air", number: 3, players: [], points: 30, currentStation: "testing", nextStation: "", iconName: "iconBlue")
                            var team4 = Team(gamecode: UserData.readReferee("Referee")!.gamecode, name: "Air", number: 4, players: [], points: 40, currentStation: "testing", nextStation: "", iconName: "iconBoy")
                            var newStation1 = Station(name: "testing", pvp: false, points: 10, place: "", description: "", teamOrder: [team1, team2, team3, team4])
                            S.addStation(UserData.readReferee("Referee")!.gamecode, newStation1)
                            //
                            performSegue(withIdentifier: "goToPVE", sender: self)
                        }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        R.delegate_getReferee = self
        S.delegate_getStation = self
        startTimer()
    }
}
//MARK: - UIUpdate
extension WaitingController: GetReferee {
    func getReferee(_ referee: Referee) {
        let newReferee = Referee(gamecode: UserData.readReferee("Referee")!.gamecode, name: UserData.readReferee("Referee")!.name, stationName: referee.stationName, assigned: referee.assigned)
        UserData.writeReferee(newReferee, "Referee")
    }
}
//MARK: - UIUpdate
extension WaitingController: GetStation {
    func getStation(_ station: Station) {
        self.pvp = station.pvp
    }
}

