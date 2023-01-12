//
//  PlayerFrame4_3.swift
//  Game_Walker
//
//  Created by Noah Kim on 6/17/22.
//

import Foundation
import UIKit

class TimerViewController: BaseViewController {
    
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.clipsToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-Regular", size: 20)
        label.numberOfLines = 0
        return label
    }()
    var timer: Timer?
    var seconds = 3600
    var time = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        H.delegate_getHost = self
        //H.getHost(RefereeData.gamecode_save)
        runTimer()
    }
    
    func configureTimerLabel(){
        self.view.addSubview(timerLabel)
        NSLayoutConstraint.activate([
            timerLabel.centerXAnchor.constraint(equalTo: self.view.layoutMarginsGuide.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor, constant: 160),
            timerLabel.widthAnchor.constraint(equalToConstant: 260),
            timerLabel.heightAnchor.constraint(equalToConstant: 260)
        ])
        timerLabel.text = ""
    }
    
    func runTimer() {
           timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(TimerViewController.updateTimer)), userInfo: nil, repeats: true)
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
           let seconds = Int(time) % 60
           return String(format:"%02i : %02i", minutes, seconds)
   }
    
}
//MARK: - UIUpdate
extension TimerViewController: GetHost {
    func getHost(_ host: Host) {
        print(host.gameTime)
        self.seconds = host.gameTime
    }
}
