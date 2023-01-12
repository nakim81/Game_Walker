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
    var assigned : Bool = false
    var pvp_check : Bool = false
    var station_name = ""
    var timer: Timer?
    var currentIndex: Int = 0
    var RegisterController: RegisterController?
    let waitingImagesArray = ["waiting 2.png", "waiting 1.png", "waiting. 1.png"]

    func startTimer() {
        if let timer = timer {
            self.timer = timer

        } else {
            Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [self] timer in
                R.getReferee(UserData.readGamecode("gamecode")!, UserData.readReferee("Referee")!.name)
                //S.getStation(UserData.readReferee("Referee")!.gamecode, UserData.readReferee("Referee")!.stationName)
                if self.currentIndex == 2 {
                    self.currentIndex = 0
                }
                else {
                    self.currentIndex = self.currentIndex + 1
                }
                self.WaitingImageView.image = UIImage(named: self.waitingImagesArray[self.currentIndex])
                if self.assigned {
                    //if (UserData.readReferee("Referee")!.stationName != "") {
                        stopTimer()
                    if self.pvp_check {
                            performSegue(withIdentifier: "goToPVP", sender: self)
                        }
                        else {
                            
                            performSegue(withIdentifier: "goToPVE", sender: self)
                        }
                    //}
                }
            }
        }
    }

    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
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
        self.assigned = referee.assigned
        self.station_name = referee.stationName
    }
}

//MARK: - UIUpdate
extension WaitingController: GetStation {
    func getStation(_ station: Station) {
        self.station_name = station.name
        self.pvp_check = station.pvp
    }
}
