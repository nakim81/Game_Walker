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
        addSubViews()
        addConstraints()
        super.viewDidLoad()
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.backgroundColor = .white
        view.layer.backgroundColor = UIColor(red: 0.843, green: 0.502, blue: 0.976, alpha: 1).cgColor
        return view
    }()
    
    private lazy var givePointsLabel: UILabel = {
        var view = UILabel()
        view.text = "Give Points"
        view.textColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        view.font = UIFont(name: "GemunuLibre-SemiBold", size: 45)
        view.textAlignment = .center
        return view
    }()
    
    private lazy var stepper: GMStepper = {
        var view = GMStepper()
        view.buttonsBackgroundColor = UIColor(red: 0.843, green: 0.502, blue: 0.976, alpha: 1)
        view.buttonsFont = UIFont(name: "Dosis-Regular", size: fontSize(size: 80)) ?? UIFont(name: "AvenirNext-Bold", size: 20.0)!
        view.labelBackgroundColor = UIColor(red: 0.843, green: 0.502, blue: 0.976, alpha: 1)
        view.labelFont = UIFont(name: "Dosis-Bold", size: fontSize(size: 80)) ?? UIFont(name: "AvenirNext-Bold", size: 25.0)!
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        var button = UIButton()
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "icon _close_"), for: .normal)
        button.addTarget(self, action: #selector(popupClosed), for: .touchUpInside)
        return button
    }()
    
    private lazy var editButton: UIButton = {
        var button = UIButton()
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "edit"), for: .normal)
        button.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var confirmButton: UIButton = {
        var button = UIButton()
        button.setTitle("CONFIRM", for: .normal)
        button.titleLabel?.font = UIFont(name: "GemunuLibre-Bold", size: 20)
        button.setTitleColor(UIColor(red: 0.843, green: 0.502, blue: 0.976, alpha: 1), for: .normal)
        button.layer.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1).cgColor
        button.layer.cornerRadius = 10.0
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func buttonTapped() {
        Task { @MainActor in
            do{
                try await T.givePoints(gameCode, team.name, Int(stepper.value))
            }
            catch GameWalkerError.serverError(let text){
                print(text)
                serverAlert(text)
                return
            }
        }
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @objc func popupClosed() {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @objc func editButtonTapped(_ sender: UITapGestureRecognizer) {
        showNumberInputPopup()
    }

    func showNumberInputPopup() {
        let alertController = UIAlertController(title: NSLocalizedString("Enter a number", comment: ""), message: nil, preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = NSLocalizedString("Type the number", comment: "")
            textField.keyboardType = .numberPad
        }

        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { [weak self, weak alertController] _ in
                guard let textField = alertController?.textFields?.first, let enteredNumber = textField.text else { return }
            self?.stepper.minimumValue = -999
            self?.stepper.label.text = enteredNumber
            if Double(enteredNumber)! > 999 {
                self?.stepper.value = 999
            }
            else if Double(enteredNumber)! < -999 {
                self?.stepper.value = -999
            }
            else {
                self?.stepper.value = Double(enteredNumber)!
            }
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)

        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func addConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        givePointsLabel.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        stepper.translatesAutoresizingMaskIntoConstraints = false
        editButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.4),
            containerView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.473),
            containerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            
            givePointsLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.620),
            givePointsLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.13),
            givePointsLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            givePointsLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 25/812 * UIScreen.main.bounds.size.height),
            
            closeButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.125),
            closeButton.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.125),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),

            stepper.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30),
            stepper.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30),
            stepper.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.35),
            stepper.topAnchor.constraint(equalTo: givePointsLabel.bottomAnchor, constant: 20/812 * UIScreen.main.bounds.size.height),
            
            editButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.0861),
            editButton.heightAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.0861),
            editButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            editButton.topAnchor.constraint(equalTo: stepper.bottomAnchor, constant: 15/812 * UIScreen.main.bounds.size.height),
            
            confirmButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.38),
            confirmButton.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.11),
            confirmButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            confirmButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -UIScreen.main.bounds.size.height * 20/812)
        ])
    }
    
    func addSubViews() {
        self.view.addSubview(containerView)
        containerView.addSubview(givePointsLabel)
        containerView.addSubview(editButton)
        containerView.addSubview(closeButton)
        containerView.addSubview(stepper)
        containerView.addSubview(confirmButton)
    }
}
