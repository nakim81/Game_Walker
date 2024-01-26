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
        var count: Int
        if tabType == "Team" {
            count = textList.count
        } else {
            count = textList.count - 1
        }
        for i in 0..<count {
            let explanationLbl = UILabel()
            explanationLbl.translatesAutoresizingMaskIntoConstraints = false
            explanationLbl.text = textList[i]
            explanationLbl.numberOfLines = 0
            explanationLbl.textAlignment = .center
            explanationLbl.textColor = .white
            explanationLbl.font = getFontForLanguage(font: "Dosis-Bold", size: 15)
            overlayView.addSubview(explanationLbl)
            
            if positionList[i].y >= tabBarTop {
                if textList[i] == "Timer &\nStart/End Game" || textList[i] == "Timer & \n Station Info" {
                    explanationLbl.widthAnchor.constraint(equalToConstant: 150).isActive = true
                } else {
                    explanationLbl.widthAnchor.constraint(equalToConstant: 90).isActive = true
                }
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
        
        if tabType == "Ranking" {
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = textList[count]
            label.numberOfLines = 0
            label.textAlignment = .center
            label.textColor = .white
            label.font = getFontForLanguage(font: "Dosis-Bold", size: 15)
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
        } else if tabType == "Timer" {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = textList[count]
            label.numberOfLines = 0
            label.textAlignment = .center
            label.textColor = .white
            label.font = getFontForLanguage(font: "Dosis-Bold", size: fontSize(size: 38))
            overlayView.addSubview(label)
             
            label.layer.cornerRadius = frameList[count].size.width / 2
            label.layer.borderColor = color
            label.layer.borderWidth = 15
            
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            overlayView.addSubview(imageView)
            if let image = UIImage(named: "refresh button")?.withRenderingMode(.alwaysTemplate) {
                imageView.image = image
                imageView.tintColor = UIColor(cgColor: color)
            }
            let refreshlabel = UILabel()
            refreshlabel.translatesAutoresizingMaskIntoConstraints = false
            refreshlabel.text = NSLocalizedString("Timer may be unsynchronized.", comment: "") + "\n" + NSLocalizedString("Press to sync time with others.", comment: "")
            refreshlabel.numberOfLines = 2
            refreshlabel.textAlignment = .left
            refreshlabel.contentMode = .topLeft
            refreshlabel.textColor = .white
            refreshlabel.font = UIFont(name: "Dosis-Bold", size: 13)
            overlayView.addSubview(refreshlabel)
            
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: positionList[count].x),
                label.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: positionList[count].y),
                label.widthAnchor.constraint(equalToConstant: frameList[count].width),
                label.heightAnchor.constraint(equalToConstant: frameList[count].height),
                
                imageView.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: positionList[count+1].y),
                imageView.centerXAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: positionList[count+1].x),
                imageView.widthAnchor.constraint(equalToConstant: frameList[count+1].width),
                imageView.heightAnchor.constraint(equalToConstant: frameList[count+1].height),
                
                refreshlabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 9),
                refreshlabel.centerYAnchor.constraint(equalTo: overlayView.topAnchor, constant: frameList[count+1].midY),
                refreshlabel.widthAnchor.constraint(equalToConstant: 206),
                refreshlabel.heightAnchor.constraint(equalToConstant: 35)
                
            ])
        }
    }
}
