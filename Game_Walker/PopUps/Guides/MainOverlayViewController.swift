//
//  MainOverlayViewController.swift
//  Game_Walker
//
//  Created by Noah Kim on 10/9/23.
//

import Foundation
import UIKit

class MainOverlayViewController: UIViewController {
    
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
    
    func configureGuide(_ frameList: [CGRect], _ layerList:[CALayer], _ textList: [String]){
        let count = frameList.count - 1
        for i in 0..<count {
            let explanationLbl = UILabel()
            explanationLbl.translatesAutoresizingMaskIntoConstraints = false
            explanationLbl.text = textList[i]
            explanationLbl.numberOfLines = 0
            explanationLbl.textAlignment = .center
            explanationLbl.textColor = .white
            explanationLbl.font = UIFont(name: "Dosis-Bold", size: 15)
            explanationLbl.layer.cornerRadius = layerList[i].cornerRadius
            explanationLbl.layer.borderWidth = layerList[i].borderWidth
            explanationLbl.layer.borderColor = layerList[i].borderColor
            overlayView.addSubview(explanationLbl)
            
            NSLayoutConstraint.activate([
                explanationLbl.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
                explanationLbl.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: frameList[i].minY),
                explanationLbl.widthAnchor.constraint(equalToConstant: frameList[i].width),
                explanationLbl.heightAnchor.constraint(equalToConstant: frameList[i].height)
            ])
        }
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "GameWalkerLogo")
        overlayView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: frameList[count].minY),
            imageView.widthAnchor.constraint(equalToConstant: frameList[count].width),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.4712230216)
        ])
    }
}
