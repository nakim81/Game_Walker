//
//  WaitingController.swift
//  Game_Walker
//
//  Created by 김현식 on 9/17/22.
//

import Foundation
import UIKit

class WaitingController: BaseViewController {
    
    private var gameCode = UserData.readGamecode("gamecode")!
    private var referee = UserData.readReferee("referee")!
    private var timer: Timer?
    
    private var stations : [Station]?
    private var teamCreated = false
    private var isSeguePerformed = false
    private var currentIndex: Int = 0
    private var index : Int = 0
    let waitingImagesArray = ["waiting 1.png", "waiting 2.png", "waiting 3.png"]
    private var waitingImageViewWidthConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        configureNavItem()
        callProtocols()
        addSubviews()
        makeConstraints()
        animateWaitingScreen()
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        R.delegates = R.delegates.filter { $0.value != nil }
    }
    
    private func configureNavItem() {
        self.navigationItem.hidesBackButton = true
        let backButtonImage = UIImage(named: "BackIcon")?.withRenderingMode(.alwaysTemplate)
        let newBackButton = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(RegisterController.onBackPressed))
        newBackButton.tintColor = UIColor(red: 0.18, green: 0.18, blue: 0.21, alpha: 1)
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    @objc override func onBackPressed() {
        R.removeReferee(gameCode, referee.uuid)
        UserDefaults.standard.removeObject(forKey: "gamecode")
        UserDefaults.standard.removeObject(forKey: "username")
        performSegue(withIdentifier: "toRegister", sender: self)
    }
    
    //MARK: - Animating Screen
    func animateWaitingScreen() {
        if timer != nil {
            return
        }
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if self.currentIndex == 2 {
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
            if self.referee.assigned {
                self.timer?.invalidate()
                findStation()
            }
            self.view.layoutIfNeeded()
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
    
    func makeConstraints() {
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
    }
    
    func addSubviews() {
        self.view.addSubview(gameIconView)
        self.view.addSubview(waitingImageView)
    }
    
    //MARK: - Find Station Assgined to Referee
    func findStation() {
        Task { @MainActor in
            stations = try await S.getStationList(gameCode)
            for station in stations! {
                if referee.name == station.referee!.name && !isSeguePerformed {
                    performSegue(withIdentifier: "goToPVE", sender: self)
                    isSeguePerformed = true
                }
            }
        }
    }
}
// MARK: - Protocols
extension WaitingController: RefereeUpdateListener {
    func updateReferee(_ referee: Referee) {
        UserData.writeReferee(referee, "referee")
        self.referee = UserData.readReferee("referee")!
    }
    
    func listen(_ _ : [String : Any]){
    }
    
    func callProtocols() {
        R.delegates.append(WeakRefereeUpdateListener(value: self))
        R.listenReferee(self.gameCode, UserData.readUUID()!, onListenerUpdate: listen(_:))
    }
}


