//
//  HostRankingGuideViewController.swift
//  Game_Walker
//
//  Created by 김현식 on 10/14/23.
//

import Foundation
import UIKit

class HostRankingGuideViewController: UIViewController {
    let colorList = [UIColor(red: 0.942, green: 0.71, blue: 0.114, alpha: 1).cgColor, UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1).cgColor]
    
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var closeBtn: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "icon _close_"), for: .normal)
        button.addTarget(self, action: #selector(dismissOverlay), for: .touchUpInside)
        return button
    }()
    
    private lazy var arrowView: UIImageView = {
        var view = UIImageView()
        view.image = UIImage(named: "Arrow")
        return view
    }()
    
    private lazy var explanationLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Click to hide points from others"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Bold", size: 13)
        return label
    }()
    
    private lazy var switchBtn: UIImageView = {
        var view = UIImageView()
        view.image = UIImage(named: "stateShow")
        return view
    }()
    
    @objc private func dismissOverlay() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupOverlayView()
    }
    
    func setupOverlayView() {
        view.addSubview(overlayView)
        overlayView.addSubview(closeBtn)
        overlayView.addSubview(switchBtn)
        overlayView.addSubview(arrowView)
        overlayView.addSubview(explanationLabel)
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        switchBtn.translatesAutoresizingMaskIntoConstraints = false
        explanationLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            closeBtn.widthAnchor.constraint(equalToConstant: 44),
            closeBtn.heightAnchor.constraint(equalToConstant: 44),
            closeBtn.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 25),
            closeBtn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -25),
        ])
    }

    func configureGuide(_ frameList: [CGRect], _ positionList: [CGPoint], _ color: CGColor, _ textList: [String], _ tabBarTop: CGFloat){
        let count = frameList.count - 1
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
            circleView.layer.cornerRadius = frameList[i].height*1.2 / 2
            circleView.layer.borderColor = colorList[i]
            circleView.layer.borderWidth = 3
            overlayView.addSubview(circleView)
            
            NSLayoutConstraint.activate([
                explanationLbl.centerXAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: positionList[i].x),
                explanationLbl.bottomAnchor.constraint(equalTo: overlayView.topAnchor, constant: tabBarTop - 10),
                
                circleView.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: positionList[i].y*0.992),
                circleView.centerXAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: positionList[i].x),
                circleView.widthAnchor.constraint(equalToConstant: frameList[i].height * 1.25),
                circleView.heightAnchor.constraint(equalTo: circleView.widthAnchor)
            ])
            
            NSLayoutConstraint.activate([
                switchBtn.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: frameList[count].minX),
                switchBtn.centerYAnchor.constraint(equalTo: overlayView.topAnchor, constant: frameList[count].minY),
                switchBtn.widthAnchor.constraint(equalToConstant: frameList[count].width),
                switchBtn.heightAnchor.constraint(equalToConstant: frameList[count].height),
                
                explanationLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.80),
                explanationLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.0604),
                explanationLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                explanationLabel.topAnchor.constraint(equalTo: switchBtn.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.03),
                
                arrowView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.35),
                arrowView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.12),
                arrowView.bottomAnchor.constraint(equalTo: explanationLabel.topAnchor, constant: UIScreen.main.bounds.size.height * 0.005),
                arrowView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
            ])
        }
    }
}
