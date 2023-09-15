//
//  HostGivePointsController.swift
//  Game_Walker
//
//  Created by 김현식 on 2/6/23.
//

import Foundation
import UIKit
import GMStepper

class HostGivePointsController : UIViewController {
    
    var currentPoints: Int
    let gameCode: String
    let team: Team
    
    init(team: Team, gameCode: String) {
        self.team = team
        self.currentPoints = team.points
        self.gameCode = gameCode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        addConstraints()
        addSubViews()
        super.viewDidLoad()
    }
    
    private lazy var containerView: UIView = {
        var view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 338, height: 338)
        view.layer.cornerRadius = 15
        view.backgroundColor = .white
        view.layer.backgroundColor = UIColor(red: 0.843, green: 0.502, blue: 0.976, alpha: 1).cgColor
        return view
    }()
    
    private lazy var givePointsLabel: UILabel = {
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 267.74, height: 61)
        let image0 = UIImage(named: "white!give points 1.png")?.cgImage
        let layer0 = CALayer()
        layer0.contents = image0
        layer0.bounds = view.bounds
        layer0.position = view.center
        view.layer.addSublayer(layer0)
        return view
    }()
    
    private lazy var stepper: GMStepper = {
        var view = GMStepper()
        view.frame = CGRect(x: 0, y: 0, width: 265, height: 134)
        view.buttonsBackgroundColor = UIColor(red: 0.843, green: 0.502, blue: 0.976, alpha: 1)
        view.buttonsFont = UIFont(name: "Dosis-Regular", size: 100) ?? UIFont(name: "AvenirNext-Bold", size: 20.0)!
        view.labelBackgroundColor = UIColor(red: 0.843, green: 0.502, blue: 0.976, alpha: 1)
        view.labelFont = UIFont(name: "Dosis-Bold", size: 100) ?? UIFont(name: "AvenirNext-Bold", size: 25.0)!
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        var button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "icon _close_"), for: .normal)
        button.addTarget(self, action: #selector(popupClosed), for: .touchUpInside)
        return button
    }()
    
    private lazy var confirmButton: UIButton = {
        var button = UIButton(frame: CGRect(x: 0, y: 0, width: 175.8, height: 57))
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "confirm button purple 1"), for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func buttonTapped() {
        Task { @MainActor in
            do{
                try await T.givePoints(gameCode, team.name, Int(stepper.value))
            }
            catch ServerError.serverError(let text){
                print(text)
                //serverAlert(text)
                return
            }
        }
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @objc func popupClosed() {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    func addConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.widthAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.416).isActive = true
        containerView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.416).isActive = true
        containerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        givePointsLabel.translatesAutoresizingMaskIntoConstraints = false
        givePointsLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.714).isActive = true
        givePointsLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.15).isActive = true
        givePointsLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: containerView.bounds.width * 0.1).isActive = true
        givePointsLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: containerView.bounds.height * 0.12).isActive = true
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.125).isActive = true
        closeButton.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.125).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: containerView.bounds.width * 0.85).isActive = true
        closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: containerView.bounds.height * 0.0110).isActive = true
        stepper.translatesAutoresizingMaskIntoConstraints = false
        stepper.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.8).isActive = true
        stepper.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.35).isActive = true
        stepper.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        stepper.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.469).isActive = true
        confirmButton.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.4).isActive = true
        confirmButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        confirmButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: containerView.bounds.height * 0.6).isActive = true
    }
    
    func addSubViews() {
        self.view.addSubview(containerView)
        containerView.addSubview(givePointsLabel)
        containerView.addSubview(closeButton)
        containerView.addSubview(stepper)
        containerView.addSubview(confirmButton)
    }
}
