//
//  RankingOverlayViewController.swift
//  Game_Walker
//
//  Created by Noah Kim on 10/10/23.
//

import Foundation
import UIKit

class RorTOverlayViewController: UIViewController {
    
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.176, green: 0.176, blue: 0.208, alpha: 0.9)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var closeBtn: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "icon _close_"), for: .normal)
        button.addTarget(self, action: #selector(dismissOverlay), for: .touchUpInside)
        return button
    }()
    
    @objc private func dismissOverlay() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupOverlayView()
    }
    
    private func setupOverlayView() {
        view.addSubview(overlayView)
        overlayView.addSubview(closeBtn)
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            closeBtn.widthAnchor.constraint(equalToConstant: 44),
            closeBtn.heightAnchor.constraint(equalToConstant: 44),
            closeBtn.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: 30),
            closeBtn.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -35)
        ])
    }
    
    func configureGuide(_ frameList: [CGRect], _ positionList: [CGPoint], _ colorList: [CGColor], _ textList: [String], _ tabBarTop: CGFloat, _ type: String){
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
        }
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = textList[count]
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont(name: "Dosis-Bold", size: 15)
        overlayView.addSubview(label)
        
        if type == "Ranking" {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.image = UIImage(named: "blindScore")
            overlayView.addSubview(imageView)
            
            NSLayoutConstraint.activate([
                imageView.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: frameList[count].minX),
                imageView.centerYAnchor.constraint(equalTo: overlayView.topAnchor, constant: frameList[count].minY),
                imageView.widthAnchor.constraint(equalToConstant: frameList[count].width),
                imageView.heightAnchor.constraint(equalToConstant: frameList[count].height),
                
                label.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
                label.bottomAnchor.constraint(equalTo: imageView.topAnchor, constant: -15),
                label.widthAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.4)
            ])
        } else {
            label.layer.cornerRadius = frameList[count].size.width / 2
            label.layer.borderColor = colorList.last
            label.layer.borderWidth = 15
            
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: positionList[count].x),
                label.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: positionList[count].y),
                label.widthAnchor.constraint(equalToConstant: frameList[count].width),
                label.heightAnchor.constraint(equalToConstant: frameList[count].height)
            ])
        }
    }
}
