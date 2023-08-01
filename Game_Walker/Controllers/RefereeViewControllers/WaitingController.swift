//
//  WaitingController.swift
//  Game_Walker
//
//  Created by 김현식 on 9/17/22.
//

import Foundation
import UIKit
import PromiseKit

class WaitingController: BaseViewController {
    
    private var gameCode = UserData.readGamecode("refereeGamecode")!
    private var referee = UserData.readReferee("Referee")!
    private var timer: Timer?
    private var pvp: Bool = false
    private var isGetStationCalled = false
    private var isAssignStationCalled = false
    private var currentIndex: Int = 0
    private var index : Int = 0
    let waitingImagesArray = ["waiting 1.png", "waiting 2.png", "waiting 3.png"]
    private var waitingImageViewWidthConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        R.delegates.append(self)
        S.delegate_getStation = self
        R.listenReferee(self.gameCode, UserData.readUUID()!, onListenerUpdate: listen(_:))
        self.view.addSubview(gameIconView)
        self.view.addSubview(waitingImageView)
        gameIconView.translatesAutoresizingMaskIntoConstraints = false
        gameIconView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        gameIconView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.36).isActive = true
        gameIconView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.18).isActive = true
        gameIconView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.83).isActive = true
        waitingImageView.translatesAutoresizingMaskIntoConstraints = false
        waitingImageView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.07).isActive = true
        waitingImageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.567).isActive = true
        waitingImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: self.view.bounds.width * 0.24).isActive = true
        waitingImageViewWidthConstraint = waitingImageView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.47)
        waitingImageViewWidthConstraint?.isActive = true
        animateWaitingScreen()
    }
    
    func listen(_ _ : [String : Any]){
    }
    
    func animateWaitingScreen() {
        if timer != nil {
            return
        }
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            if self.currentIndex == 2 {
                Task {@ MainActor in
                    await R.assignStation(self.referee.gamecode, self.referee.uuid, "testing", true)
                }
                self.waitingImageViewWidthConstraint?.isActive = false
                self.waitingImageViewWidthConstraint = self.waitingImageView.widthAnchor.constraint(equalTo: self.view.widthAnchor,multiplier: 0.47)
                self.waitingImageViewWidthConstraint?.isActive = true
                self.currentIndex = 0
            }
            else {
                self.currentIndex += 1
                if self.currentIndex == 1 {
                    self.waitingImageViewWidthConstraint?.isActive = false
                    self.waitingImageViewWidthConstraint = self.waitingImageView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.50)
                    self.waitingImageViewWidthConstraint?.isActive = true
                }
                else {
                    self.waitingImageViewWidthConstraint?.isActive = false
                    self.waitingImageViewWidthConstraint = self.waitingImageView.widthAnchor.constraint(equalTo: self.view.widthAnchor,multiplier: 0.53)
                    self.waitingImageViewWidthConstraint?.isActive = true
                }
            }
            self.waitingImageView.image = UIImage(named: self.waitingImagesArray[self.currentIndex])
            if self.referee.assigned && !self.isGetStationCalled {
                self.performSegue(withIdentifier: "goToPVE", sender: self)
                //print("assigned")
                //S.getStation(self.gameCode, self.referee.stationName)
            }
            if self.referee.assigned && self.isGetStationCalled {
                self.timer?.invalidate()
            }
            self.view.layoutIfNeeded() // Update the layout immediately
        }
    }
    
    func checkStatus() {
        if self.pvp {
            print("A")
            timer?.invalidate()
            self.performSegue(withIdentifier: "goToPVP", sender: self)
        }
        else {
            print("A")
            timer?.invalidate()
            self.performSegue(withIdentifier: "goToPVE", sender: self)
        }
    }
//MARK: - UI elements
    private lazy var gameIconView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 311, height: 146.46))
        imageView.image = UIImage(named: "game 1")
        return imageView
    }()
    
    private lazy var waitingImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 174.4, height: 57))
        imageView.image = UIImage(named: "waiting 1")
        return imageView
    }()
}
// MARK: - RefereeUpdateListener
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
        print("C")
        Task { @MainActor in
            checkStatus()
        }
    }
}

