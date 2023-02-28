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
    var pvp = false
    var timer: Timer?
    var currentIndex: Int = 0
    let waitingImagesArray = ["waiting 2.png", "waiting 1.png", "waiting. 1.png"]

    func startTimer() {
        if let timer = timer {
            self.timer = timer
        } else {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] timer in
                R.getReferee(UserData.readGamecode("gamecode")!, UserData.readReferee("Referee")!.name)
                if self.currentIndex == 2 {
                    self.currentIndex = 0
                    R.assignStation(UserData.readGamecode("gamecode")!, UserData.readReferee("Referee")!, "testing")
                }
                else {
                    self.currentIndex = self.currentIndex + 1
                }
                self.WaitingImageView.image = UIImage(named: self.waitingImagesArray[self.currentIndex])
                if UserData.readReferee("Referee")!.assigned {
                    S.getStation(UserData.readGamecode("gamecode")!, UserData.readReferee("Referee")!.stationName)
                    timer.invalidate()
                    if self.pvp {
                            performSegue(withIdentifier: "goToPVP", sender: self)
                        }
                        else {
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

