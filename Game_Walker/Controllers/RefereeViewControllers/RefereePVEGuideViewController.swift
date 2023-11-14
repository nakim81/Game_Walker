//
//  RefereePVEGuideView.swift
//  Game_Walker
//
//  Created by 김현식 on 10/14/23.
//

import Foundation
import UIKit

class RefereePVEGuideViewController : UIViewController {
    let colorList = [UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1).cgColor, UIColor(red: 0.942, green: 0.71, blue: 0.114, alpha: 1).cgColor, UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1).cgColor]
    
    private let overlayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.176, green: 0.176, blue: 0.208, alpha: 0.9)
        return view
    }()
    
    private lazy var explanationLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Click win to give points of standard station points"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Bold", size: fontSize(size: 13))
        return label
    }()
    
    private lazy var buttonBorder: UIView = {
        var view = UIView()
        view.backgroundColor = .clear
        view.layer.borderWidth = 5.0
        view.layer.borderColor = UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 1).cgColor
        view.layer.cornerRadius = 10.0
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Click to give points of the Team"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Bold", size: fontSize(size: 13))
        view.addSubview(label)
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5).isActive = true
        return view
    }()

    private lazy var teamPointsLabel: UILabel = {
        var label = UILabel()
        label.text = "Team's total points"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Bold", size: fontSize(size: 13))
        return label
    }()
    
    private lazy var winButton: UIImageView = {
        var view = UIImageView()
        view.image = UIImage(named: "Win Blue Button")
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "WIN"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "GemunuLibre-Bold", size: fontSize(size: 13))
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
        var view = UIImageView()
        view.image = UIImage(named: "Lose Yellow Button")
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "LOSE"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "GemunuLibre-Bold", size: fontSize(size: 13))
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        view.addSubview(label)
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5).isActive = true
        return view
    }()
    
    @objc private func dismissOverlay() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupOverlayView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissOverlay))
        overlayView.addGestureRecognizer(tapGesture)
    }
    
    func setupOverlayView() {
        view.addSubview(overlayView)
        overlayView.addSubview(explanationLabel)
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            explanationLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8),
            explanationLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.025),
            explanationLabel.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor, constant: -self.view.bounds.height * 0.3),
            explanationLabel.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor)
        ])
    }
    
    
    
    func configureGuide(_ frameList: [CGRect], _ positionList: [CGPoint], _ textList: [String], _ tabBarTop: CGFloat){
        let count = frameList.count - 4
        for i in 0..<count {
            let explanationLbl = UILabel()
            explanationLbl.translatesAutoresizingMaskIntoConstraints = false
            explanationLbl.text = textList[i]
            explanationLbl.numberOfLines = 0
            explanationLbl.textAlignment = .center
            explanationLbl.textColor = .white
            explanationLbl.font = UIFont(name: "Dosis-Bold", size: 15)
            overlayView.addSubview(explanationLbl)
            
            if positionList[i].y >= tabBarTop {
                explanationLbl.widthAnchor.constraint(equalToConstant: 75).isActive = true
            } else {
                explanationLbl.widthAnchor.constraint(equalToConstant: 200).isActive = true
            }
            
            let circleView = UIView()
            circleView.translatesAutoresizingMaskIntoConstraints = false
            circleView.clipsToBounds = true
            circleView.layer.cornerRadius = frameList[i].height*1.55 / 2
            circleView.layer.borderColor = colorList[i]
            circleView.layer.borderWidth = 3
            overlayView.addSubview(circleView)
            
            NSLayoutConstraint.activate([
                explanationLbl.centerXAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: positionList[i].x),
                explanationLbl.bottomAnchor.constraint(equalTo: overlayView.topAnchor, constant: tabBarTop - 17),
                
                circleView.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: positionList[i].y*0.981),
                circleView.centerXAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: positionList[i].x),
                circleView.widthAnchor.constraint(equalToConstant: frameList[i].height * 1.6),
                circleView.heightAnchor.constraint(equalTo: circleView.widthAnchor)
            ])
        }
            
        overlayView.addSubview(buttonBorder)
        overlayView.addSubview(teamPointsLabel)
        overlayView.addSubview(winButton)
        overlayView.addSubview(loseButton)
        buttonBorder.translatesAutoresizingMaskIntoConstraints = false
        teamPointsLabel.translatesAutoresizingMaskIntoConstraints = false
        winButton.translatesAutoresizingMaskIntoConstraints = false
        loseButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            buttonBorder.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant:frameList[count].minX),
            buttonBorder.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: frameList[count].minY),
            buttonBorder.widthAnchor.constraint(equalToConstant: frameList[count].width),
            buttonBorder.heightAnchor.constraint(equalToConstant: frameList[count].height),

            teamPointsLabel.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: frameList[count + 1].minX),
            teamPointsLabel.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: frameList[count + 1].minY - frameList[count + 1].height/2),
            teamPointsLabel.widthAnchor.constraint(equalToConstant: frameList[count + 1].width),
            teamPointsLabel.heightAnchor.constraint(equalToConstant: frameList[count + 1].height),

            winButton.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: frameList[count + 2].minX),
            winButton.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: frameList[count + 2].minY),
            winButton.widthAnchor.constraint(equalToConstant: frameList[count + 2].width),
            winButton.heightAnchor.constraint(equalToConstant: frameList[count + 2].height),

            loseButton.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: frameList[count + 3].minX),
            loseButton.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: frameList[count + 3].minY),
            loseButton.widthAnchor.constraint(equalToConstant: frameList[count + 3].width),
            loseButton.heightAnchor.constraint(equalToConstant: frameList[count + 3].height),
        ])
    }
}
