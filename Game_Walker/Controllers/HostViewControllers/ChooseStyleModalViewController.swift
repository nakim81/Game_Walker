//
//  ChooseStyleModalViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 10/19/23.
//

import Foundation
import UIKit

class ChooseStyleModalViewController: BaseViewController {
    @IBOutlet weak var modalContainerView: UIView!
    
    //CreateStandardGameSegue
    //CreatePointsOnlySegue
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var pointsOnlyView: UIView!
    @IBOutlet weak var standardModeView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        T.delegates.append(WeakTeamUpdateListener(value: self))
        let standardModeTapGesture = UITapGestureRecognizer(target: self, action: #selector(standardModeViewTapped))
        standardModeView.addGestureRecognizer(standardModeTapGesture)

        let pointsOnlyTapGesture = UITapGestureRecognizer(target: self, action: #selector(pointsOnlyViewTapped))
        pointsOnlyView.addGestureRecognizer(pointsOnlyTapGesture)
        
        let tappedAroundGesture = UITapGestureRecognizer(target: self, action: #selector(closeButtonTapped))
        view.addGestureRecognizer(tappedAroundGesture)
    }
    
    override func viewDidLayoutSubviews() {
        setupUIElements()
    }
    
    func listen(_ _ : [String : Any]){
    }
    
    private func setupUIElements() {
        standardModeView.isUserInteractionEnabled = true
        pointsOnlyView.isUserInteractionEnabled = true
        closeButton.layer.cornerRadius = 10.0
        modalContainerView.layer.cornerRadius = 10.0
        pointsOnlyView.layer.cornerRadius = 10.0
        standardModeView.layer.cornerRadius = 10.0
    }
    

    @IBAction func closeButtonTapped(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }

    @objc func standardModeViewTapped() {
        let gc = String(Int.random(in: 100000 ... 999999))
        var host = Host(gamecode: gc)
        host.standardStyle = true
        Task { @MainActor in
            do {
            try await H.createGame(gc, host)
            } catch (let e) {
                print("error : ", e)
            }
        }
        UserData.writeGamecode(gc, "gamecode")
        UserData.setStandardStyle(true)
        print("created game. mode is: ", host.standardStyle)
        T.listenTeams(gc, onListenerUpdate: listen(_:))
        
        dismiss(animated: true) { [weak self] in
            NotificationCenter.default.post(name: Notification.Name("StandardMode"), object: nil)
        }
        NotificationCenter.default.removeObserver(self, name: Notification.Name("StandardMode"), object: nil)
    }

    @objc func pointsOnlyViewTapped() {
        let gc = String(Int.random(in: 100000 ... 999999))
        var host = Host(gamecode: gc)
        host.standardStyle = false
        Task { @MainActor in
            do {
            try await H.createGame(gc, host)
            } catch (let e) {
                print("error : ", e)
            }
        }
        UserData.writeGamecode(gc, "gamecode")
        UserData.setStandardStyle(false)
        print("created game. mode is: ", host.standardStyle)
        T.listenTeams(gc, onListenerUpdate: listen(_:))
     
        dismiss(animated: true) { [weak self] in
            print("Dismissed view controller")
            NotificationCenter.default.post(name: Notification.Name("PointsOnly"), object: nil)
        }
        NotificationCenter.default.removeObserver(self, name: Notification.Name("PointsOnly"), object: nil)
    }
}

extension ChooseStyleModalViewController: TeamUpdateListener {
    func updateTeams(_ teams: [Team]) {
        
    }
}
