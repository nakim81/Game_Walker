//
//  RefereePVEGuideView.swift
//  Game_Walker
//
//  Created by 김현식 on 10/14/23.
//

import Foundation
import UIKit

class RefereePVEGuideViewController : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupOverlayView()
        showOverlay()
    }
    
    private lazy var shadeView: UIView = {
        var view = UIView(frame: view.bounds)
        view.backgroundColor = UIColor(red: 0.176, green: 0.176, blue: 0.208, alpha: 0.9)
        return view
    }()
    
    private lazy var closeBtn: UIImageView = {
        var view = UIImageView()
        view.image = UIImage(named: "icon _close_")
        view.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissOverlay))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    private lazy var buttonBorder: UIView = {
        var view = UIView()
        view.backgroundColor = .clear
        view.layer.borderWidth = 5.0
        view.layer.borderColor = UIColor(red: 40.0 / 255.0, green: 209.0 / 255.0, blue: 113.0 / 255.0, alpha: 1.0).cgColor
        view.layer.cornerRadius = 5.0
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Click to give points of the Team"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Bold", size: 13)
        view.addSubview(label)
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5).isActive = true
        return view
    }()
    
    private lazy var teamPointsLabel: UIView = {
        var view = UIView()
        view.backgroundColor = .clear
        view.layer.borderWidth = 5.0
        view.layer.borderColor = UIColor(red: 40.0 / 255.0, green: 209.0 / 255.0, blue: 113.0 / 255.0, alpha: 1.0).cgColor
        view.layer.cornerRadius = 5.0
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Team's total points"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Bold", size: 13)
        view.addSubview(label)
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5).isActive = true
        return view
    }()
    
    private lazy var explanationLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Click win to give points of standard station points"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Bold", size: 13)
        return label
    }()
    
    private lazy var winButton: UIImageView = {
        var view = UIImageView(frame: CGRect(x: 0, y: 0, width: 57, height: 13))
        view.image = UIImage(named: "Win Blue Button")
        var label = UILabel(frame: CGRect(x: 0, y: 0, width: 57, height: 13))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "WIN"
        label.textColor = .white
        label.font = UIFont(name: "GemunuLibre-Bold", size: 13) ?? UIFont(name: "Dosis-Bold", size: 13)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        view.addSubview(label)
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5).isActive = true
        return view
    }()
    
    private lazy var loseButton: UIImageView = {
        var view = UIImageView(frame: CGRect(x: 0, y: 0, width: 57, height: 13))
        view.image = UIImage(named: "Lose Yellow Button")
        var label = UILabel(frame: CGRect(x: 0, y: 0, width: 57, height: 13))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "LOSE"
        label.textColor = .white
        label.font = UIFont(name: "GemunuLibre-Bold", size: 13) ?? UIFont(name: "Dosis-Bold", size: 13)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        view.addSubview(label)
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5).isActive = true
        return view
    }()
    
    private func setupOverlayView() {
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        buttonBorder.translatesAutoresizingMaskIntoConstraints = false
        teamPointsLabel.translatesAutoresizingMaskIntoConstraints = false
        explanationLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeBtn.widthAnchor.constraint(equalToConstant: 44),
            closeBtn.heightAnchor.constraint(equalToConstant: 44),
            closeBtn.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 25),
            closeBtn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -25),
            
//            buttonBorder.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
//            buttonBorder.topAnchor.constraint(equalTo: teamNumLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.03),
//            buttonBorder.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.467),
//            buttonBorder.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.467),
//            
//            teamPointsLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.370),
//            teamPointsLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.0604),
//            teamPointsLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
//            teamPointsLabel.topAnchor.constraint(equalTo: teamNameLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.05),
//            
//            explanationLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.80),
//            explanationLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.0604),
//            explanationLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
//            explanationLabel.topAnchor.constraint(equalTo: winButton.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.01),
            
//            winButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.176),
//            winButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.032),
//            winButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: UIScreen.main.bounds.size.width * 0.315),
//            winButton.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 5),
//            
//            loseButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.176),
//            loseButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.032),
//            loseButton.leadingAnchor.constraint(equalTo: winButton.trailingAnchor, constant: 5),
//            loseButton.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 5)
        ])
    }
    
    @objc func dismissOverlay() {
        dismiss(animated: true, completion: nil)
    }
    
    var circularBorders: [UIView] = []
    var explanationLbls: [UILabel] = []
    
    private func showOverlay() {
        var index : Int = 0
        var tabBarTop: CGFloat = 0
        var componentPositions: [CGPoint] = []
        let explanationTexts = ["Remote your Station", "Ranking Status", "Timer & Station Info"]
        let colors = [UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1).cgColor, UIColor(red: 0.942, green: 0.71, blue: 0.114, alpha: 1).cgColor, UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1).cgColor]
        if let tabBarController = self.tabBarController {
            for viewController in tabBarController.viewControllers ?? [] {
                if let tabItem = viewController.tabBarItem {
                    if let tabItemView = tabItem.value(forKey: "view") as? UIView {
                        // Adding Circle Borders on Tab Bar Frame
                        let tabItemFrame = tabItemView.frame
                        let tabBarFrame = tabBarController.tabBar.frame
                        let centerXPosition = tabItemFrame.midX
                        let centerYPosition = tabBarFrame.midY
                        let circularBorder = UIView()
                        circularBorder.frame = CGRect(x: centerXPosition / 2, y: centerYPosition / 2, width: tabItemFrame.width * 0.45, height: tabItemFrame.width * 0.45)
                        circularBorder.layer.cornerRadius = tabItemFrame.width * 0.45 / 2
                        circularBorder.layer.borderWidth = 4.0
                        circularBorder.layer.borderColor = colors[index]
                        circularBorder.translatesAutoresizingMaskIntoConstraints = false
                        self.view.addSubview(circularBorder)
                        circularBorders.append(circularBorder)
                        // Adding Texts on Tab Bar Frame
                        let topAnchorPosition = tabItemFrame.minY + tabBarFrame.origin.y
                        if (tabBarTop == 0) {
                            tabBarTop = topAnchorPosition
                        }
                        componentPositions.append(CGPoint(x: centerXPosition, y: topAnchorPosition))
                        NSLayoutConstraint.activate([
                            circularBorder.centerXAnchor.constraint(equalTo: tabItemView.centerXAnchor),
                            circularBorder.centerYAnchor.constraint(equalTo: tabItemView.centerYAnchor),
                            circularBorder.widthAnchor.constraint(equalTo: tabItemView.widthAnchor, multiplier: 0.45),
                            circularBorder.heightAnchor.constraint(equalTo: tabItemView.widthAnchor, multiplier: 0.45)
                        ])
                        
                        let explanationLbl = UILabel()
                        explanationLbl.translatesAutoresizingMaskIntoConstraints = false
                        explanationLbl.text = explanationTexts[index]
                        explanationLbl.numberOfLines = 0
                        explanationLbl.textAlignment = .center
                        explanationLbl.textColor = .white
                        explanationLbl.font = UIFont(name: "Dosis-Bold", size: 15)
                        self.view.addSubview(explanationLbl)
                        explanationLbls.append(explanationLbl)
                        var maxWidth: CGFloat = 0
                        if (componentPositions[index].y >= tabBarTop) {
                            maxWidth = 75
                        } else {
                            maxWidth = 200
                        }
                        explanationLbl.widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth).isActive = true
                        NSLayoutConstraint.activate([
                            explanationLbl.centerXAnchor.constraint(equalTo: self.view.leadingAnchor, constant: componentPositions[index].x),
                            explanationLbl.bottomAnchor.constraint(equalTo: self.view.topAnchor, constant: componentPositions[index].y - 15)
                        ])
                        index += 1
                    }
                }
            }
        }
    }
}
