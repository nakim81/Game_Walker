//
//  PlayerFrame4_3.swift
//  Game_Walker
//
//  Created by Noah Kim on 6/17/22.
//

import Foundation
import UIKit

class TimerViewController: BaseViewController {
    
    @IBOutlet weak var gameInfoButton: UIButton!
    @IBOutlet weak var nextGameButton: UIButton!
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.clipsToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-Regular", size: 55)
        label.numberOfLines = 0
        label.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        label.layer.borderWidth = 4
        label.layer.cornerRadius = 130
        return label
    }()
    private var timer: Timer?
    private var seconds = 3600
    private var time = 0
    private var gameCode: String = UserData.readPlayer("player")!.gamecode
    
    override func viewDidLoad() {
        super.viewDidLoad()
        H.delegate_getHost = self
<<<<<<< HEAD
        H.getHost(gameCode)
        configureTimerLabel()
=======
//        H.getHost(RefereeData.gamecode_save)
>>>>>>> 0c2aaf30e8623abededb1bd20956616a4cf0665b
        runTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func gameInfoButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func nextGameButtonPressed(_ sender: UIButton) {
        
    }
    
    func configureTimerLabel(){
        self.view.addSubview(timerLabel)
        NSLayoutConstraint.activate([
            timerLabel.centerXAnchor.constraint(equalTo: self.view.layoutMarginsGuide.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor, constant: 200),
            timerLabel.widthAnchor.constraint(equalToConstant: 260),
            timerLabel.heightAnchor.constraint(equalToConstant: 260)
        ])
        timerLabel.text = "00 : 00"
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
