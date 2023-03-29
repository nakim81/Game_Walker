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
    var gameCode = UserData.readGamecode("gamecode")!
    var referee = UserData.readReferee("Referee")!
    var timer: Timer?
    var pvp: Bool = false
    var isGetStationCalled = false
    var isAssignStationCalled = false
    var currentIndex: Int = 0
    let waitingImagesArray = ["waiting 1.png", "waiting 2.png", "waiting 3.png"]

    override func viewDidLoad() {
        super.viewDidLoad()
        R.delegates.append(self)
        S.delegate_getStation = self
        R.listenReferee(self.gameCode, self.referee, onListenerUpdate: listen(_:))
        startTimer()
        nextScreen()
    }
    
    func listen(_ _ : [String : Any]){
    }
    
    func startTimer() {
        if timer != nil {
            return
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            if self.currentIndex == 2 {
                self.currentIndex = 0
                // This command only exists for testing.
                if !self.isAssignStationCalled {
                    self.isAssignStationCalled = true
                    print("A")
                    print(self.isAssignStationCalled)
                    //R.assignStation(self.gameCode, self.referee, "testingPVE")
                }
                //
            }
            else {
                self.currentIndex = self.currentIndex + 1
            }
            
            self.WaitingImageView.image = UIImage(named: self.waitingImagesArray[self.currentIndex])
            
            if self.referee.assigned && !self.isGetStationCalled {
                S.getStation(self.gameCode, self.referee.stationName)
                print(1)
                print(self.pvp)
            }
            
            if self.referee.assigned && self.isGetStationCalled {
                timer.invalidate()
                print("Is timer invalidated? \(timer.isValid)")
            }
        }
    }
    func nextScreen() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            print(2)
            print(self.pvp)
            if self.pvp {
                self.performSegue(withIdentifier: "goToPVP", sender: self)
            }
            else {
                self.performSegue(withIdentifier: "goToPVE", sender: self)
            }
        }
    }
}
// MARK: - listener
extension WaitingController: RefereeUpdateListener {
    func updateReferee(_ referee: Referee) {
        UserData.writeReferee(referee, "Referee")
        self.referee = UserData.readReferee("Referee")!
    }
}

//MARK: - GetStation
extension WaitingController: GetStation {
    func getStation(_ station: Station) {
        self.pvp = station.pvp
        isGetStationCalled = true
    }
}

