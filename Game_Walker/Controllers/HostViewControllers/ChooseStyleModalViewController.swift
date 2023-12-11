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
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var pointsOnlyView: UIView!
    @IBOutlet weak var standardModeView: UIView!
    
    weak var delegate: ChooseStyleModalDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            try H.createGame(gc, host)
            } catch (let e) {
                print("error : ", e)
            }
        }
        UserData.writeGamecode(gc, "gamecode")
        UserData.setStandardStyle(true)
        print("created game. mode is: ", host.standardStyle)
        
        delegate?.didSelectStandardMode()
        dismiss(animated: true, completion: nil)
    }

    @objc func pointsOnlyViewTapped() {
        let gc = String(Int.random(in: 100000 ... 999999))
        var host = Host(gamecode: gc)
        host.standardStyle = false
        Task { @MainActor in
            do {
            try H.createGame(gc, host)
            } catch (let e) {
                print("error : ", e)
            }
        }
        UserData.writeGamecode(gc, "gamecode")
        UserData.setStandardStyle(false)
        print("created game. mode is: ", host.standardStyle)
     
        delegate?.didSelectPointsOnlyMode()
        dismiss(animated: true, completion: nil)
    }
}

