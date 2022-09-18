//
//  WaitingController.swift
//  Game_Walker
//
//  Created by 김현식 on 9/17/22.
//

import Foundation
import UIKit

class WaitingController:
    UIViewController {

    @IBOutlet weak var GameIconView: UIImageView!
    @IBOutlet weak var WaitingImageView: UIImageView!
    var pvp : Bool = true
    var station_name = ""
    var timer: Timer?
    var currentIndex: Int = 0
    let waitingImagesArray = ["waiting 2.png", "waiting 1.png", "waiting .1.png"]

    func startTimer() {
        if let timer = timer {
            self.timer = timer

        } else {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                self.currentIndex = self.currentIndex + 1
                self.WaitingImageView.image = UIImage(named: self.waitingImagesArray[self.currentIndex])
            }
        }
    }

    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if pvp {
            performSegue(withIdentifier: "goToPVP", sender: self)
            stopTimer()
        }
        else {
            performSegue(withIdentifier: "goToPVE", sender: self)
            stopTimer()
        }
    }
    
    
}

//MARK: - UIUpdate
extension WaitingController: GetStation {
    func getStation(_ station: Station) {
        if station_name == station.name {
            pvp = station.pvp
        }
    }
}
