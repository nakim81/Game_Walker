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
    var timer: Timer?
    var pvp: Bool = false
    var currentIndex: Int = 0
    let waitingImagesArray = ["waiting 2.png", "waiting 1.png", "waiting 3.png"]

    override func viewDidLoad() {
        super.viewDidLoad()
        R.delegates.append(self)
        S.delegate_getStation = self
        R.listenReferee(UserData.readGamecode("gamecode")!, UserData.readReferee("Referee")!, onListenerUpdate: listen(_:))
        startTimer()
    }
    
    func listen(_ _ : [String : Any]){
    }
    
    func startTimer() {
        if let timer = timer {
                    self.timer = timer
                } else {
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] timer in
                        if self.currentIndex == 2 {
                            self.currentIndex = 0
                            // This command only exists for testing.
                            R.assignStation(UserData.readGamecode("gamecode")!, UserData.readReferee("Referee")!, "testingPVE")
                            //
                        }
                        else {
                            self.currentIndex = self.currentIndex + 1
                        }
                        self.WaitingImageView.image = UIImage(named: self.waitingImagesArray[self.currentIndex])
                        if UserData.readReferee("Referee")!.assigned {
                            S.getStation(UserData.readGamecode("gamecode")!, UserData.readReferee("Referee")!.stationName)
                            print("1")
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
    
}
// MARK: - listener
extension WaitingController: RefereeUpdateListener {
    func updateReferee(_ referee: Referee) {
        UserData.writeReferee(referee, "Referee")
    }
}

//MARK: - UIUpdate
extension WaitingController: GetStation {
    func getStation(_ station: Station) {
        self.pvp = station.pvp
    }
}

