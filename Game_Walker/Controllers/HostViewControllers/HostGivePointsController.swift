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
    var currentstationName = ""
    var currentPoints = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        self.view.addSubview(containerView)
        self.view.addSubview(currentstationLabel)
        self.view.addSubview(currentpointsLabel)
        self.view.addSubview(givepointsLabel)
        self.view.addSubview(stepper)
        self.view.addSubview(confirmButton)
        self.view.bringSubviewToFront(givepointsLabel)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.widthAnchor.constraint(equalToConstant: 338).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 338).isActive = true
        containerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 220).isActive = true
        currentstationLabel.translatesAutoresizingMaskIntoConstraints = false
        currentstationLabel.widthAnchor.constraint(equalToConstant: 250).isActive = true
        currentstationLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        currentstationLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        currentstationLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 22).isActive = true
        currentpointsLabel.translatesAutoresizingMaskIntoConstraints = false
        currentpointsLabel.widthAnchor.constraint(equalToConstant: 250).isActive = true
        currentpointsLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        currentpointsLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        currentpointsLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 73).isActive = true
        givepointsLabel.translatesAutoresizingMaskIntoConstraints = false
        givepointsLabel.widthAnchor.constraint(equalToConstant: 150.85).isActive = true
        givepointsLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true
        givepointsLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        givepointsLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 118).isActive = true
        givepointsLabel.translatesAutoresizingMaskIntoConstraints = false
        givepointsLabel.widthAnchor.constraint(equalToConstant: 150.85).isActive = true
        givepointsLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true
        givepointsLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        givepointsLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 118).isActive = true
        stepper.translatesAutoresizingMaskIntoConstraints = false
        stepper.widthAnchor.constraint(equalToConstant: 265).isActive = true
        stepper.heightAnchor.constraint(equalToConstant: 134).isActive = true
        stepper.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        stepper.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 129).isActive = true
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.widthAnchor.constraint(equalToConstant: 175.8).isActive = true
        confirmButton.heightAnchor.constraint(equalToConstant: 57).isActive = true
        confirmButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        confirmButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 265).isActive = true
    }
    
    private lazy var containerView: UIView = {
        var view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 338, height: 338)
        view.layer.cornerRadius = 15
        view.backgroundColor = .white
        view.layer.backgroundColor = UIColor(red: 0.843, green: 0.502, blue: 0.976, alpha: 1).cgColor
        return view
    }()
    
    private lazy var currentstationLabel: UILabel = {
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 83.58, height: 28.76)
        view.layer.backgroundColor = UIColor(red: 0.843, green: 0.502, blue: 0.976, alpha: 1).cgColor
        view.textColor = .white
        view.font = UIFont(name: "Dosis-SemiBold", size: 20)
        view.textAlignment = .center
        view.text = "Current station: " + currentstationName
        return view
    }()
    
    private lazy var currentpointsLabel: UILabel = {
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 83.58, height: 28.76)
        view.layer.backgroundColor = UIColor(red: 0.843, green: 0.502, blue: 0.976, alpha: 1).cgColor
        view.textColor = .white
        view.font = UIFont(name: "Dosis-SemiBold", size: 20)
        view.textAlignment = .center
        view.text = "Current points: " + "\(currentPoints)"
        return view
    }()
    
    private lazy var givepointsLabel: UILabel = {
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 150.85, height: 35)
        view.layer.backgroundColor = UIColor(red: 0.843, green: 0.502, blue: 0.976, alpha: 1).cgColor
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
    
    private lazy var confirmButton: UIButton = {
        var button = UIButton(frame: CGRect(x: 0, y: 0, width: 175.8, height: 57))
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "confirm button purple 1"), for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func buttonTapped() {
        //T.givePoints(UserData.readGamecode(), , Int(stepper.value))
        //performSegue(withIdentifier: "", sender: self)
    }
}
//MARK: - UIUpdate
extension HostGivePointsController: GetTeam {
    func getTeam(_ team: Team) {
        self.currentstationName = team.currentStation
        self.currentPoints = team.points
    }
}
