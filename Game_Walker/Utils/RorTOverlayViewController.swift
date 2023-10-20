//
//  RankingOverlayViewController.swift
//  Game_Walker
//
//  Created by Noah Kim on 10/10/23.
//

import Foundation
import UIKit

class RorTOverlayViewController: UIViewController {
    
    var colorList = [UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1).cgColor, UIColor(red: 0.942, green: 0.71, blue: 0.114, alpha: 1).cgColor]
    
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.176, green: 0.176, blue: 0.208, alpha: 0.9)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupOverlayView()
    }
    
    private func setupOverlayView() {
        view.addSubview(overlayView)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        overlayView.addGestureRecognizer(tapGestureRecognizer)
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func configureGuide(_ frameList: [CGRect], _ positionList: [CGPoint], _ color: CGColor, _ textList: [String], _ tabBarTop: CGFloat, _ tabType: String, _ userType: String){
        colorList.append(color)
        let count = textList.count - 1
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
                explanationLbl.widthAnchor.constraint(equalToConstant: 90).isActive = true
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
        
        if tabType == "Ranking" {
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = textList[count]
            label.numberOfLines = 0
            label.textAlignment = .center
            label.textColor = .white
            label.font = UIFont(name: "Dosis-Bold", size: 15)
            overlayView.addSubview(label)
            
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            overlayView.addSubview(imageView)
            
            if userType == "host" {
                imageView.image = UIImage(named: "Arrow")
                
                let buttonView = UIImageView()
                buttonView.translatesAutoresizingMaskIntoConstraints = false
                overlayView.addSubview(buttonView)
                buttonView.image = UIImage(named: "switchBtn")
                
                NSLayoutConstraint.activate([
                    buttonView.widthAnchor.constraint(equalToConstant: frameList.last!.width * 1.0628279295),
                    buttonView.heightAnchor.constraint(equalToConstant: frameList.last!.height * 1.1666666667),
                    buttonView.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: positionList.last!.x),
                    buttonView.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: positionList.last!.y),
                    
                    imageView.widthAnchor.constraint(equalTo: overlayView.widthAnchor, multiplier: 0.36),
                    imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.4888888889),
                    imageView.trailingAnchor.constraint(equalTo: buttonView.leadingAnchor),
                    imageView.centerYAnchor.constraint(equalTo: buttonView.centerYAnchor),
                    
                    label.topAnchor.constraint(equalTo: imageView.bottomAnchor),
                    label.widthAnchor.constraint(equalToConstant: frameList[count].width),
                    label.heightAnchor.constraint(equalTo: label.widthAnchor, multiplier: 0.07),
                    label.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor)
                ])
            } else {
                imageView.image = UIImage(named: "blindScore")
                
                NSLayoutConstraint.activate([
                    imageView.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: frameList[count].minX),
                    imageView.centerYAnchor.constraint(equalTo: overlayView.topAnchor, constant: frameList[count].minY),
                    imageView.widthAnchor.constraint(equalToConstant: frameList[count].width),
                    imageView.heightAnchor.constraint(equalToConstant: frameList[count].height),
                    
                    label.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
                    label.bottomAnchor.constraint(equalTo: imageView.topAnchor, constant: -15),
                    label.widthAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.4)
                ])
            }
        } else {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = textList[count]
            label.numberOfLines = 0
            label.textAlignment = .center
            label.textColor = .white
            label.font = UIFont(name: "Dosis-Bold", size: 15)
            overlayView.addSubview(label)
             
            label.layer.cornerRadius = frameList[count].size.width / 2
            label.layer.borderColor = color
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
