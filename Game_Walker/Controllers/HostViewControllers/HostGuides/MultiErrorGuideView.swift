//
//  MultiErrorGuideViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 10/11/23.
//

import Foundation
import UIKit
import FLAnimatedImage


class MultiErrorGuideView : UIView {
    var onCloseButtonTapped: (() -> Void)?
    var onPreviousButtonTapped: (() -> Void)?
    
    //MARK: - UI Elements
    let containerView = UIView()
    
    private lazy var closeButton: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "CloseIconModalSmall"), for: .normal)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var previousButton: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "previousbutton-guide"), for: .normal)
        button.addTarget(self, action: #selector(previousButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var instructionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        label.font = UIFont(name: "Dosis-Regular", size: 15)
        label.textColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.00)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.text = """
        There are multiple errors shown 
        previously at the same time.
        """
        return label
    }()
    
    private let titleImage = UIImageView(image: UIImage(named: "multi-error-title"))
    
    private let gifImageView = UIImageView()
    private let flaniImageView = FLAnimatedImageView()
        
    
    //MARK: - init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBasicUI()
        print("flaniImageView.frame.size : ", flaniImageView.frame.size)
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        setupGif()
    }
    private func setupBasicUI() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = 20.0
        containerView.backgroundColor = UIColor(red: 0.18, green: 0.18, blue: 0.21, alpha: 0.98)
        addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        containerView.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 13),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -13)
        ])
        
        titleImage.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(titleImage)
        containerView.addSubview(instructionLabel)
        NSLayoutConstraint.activate([
            titleImage.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 18),
            titleImage.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            instructionLabel.centerXAnchor.constraint(equalTo: titleImage.centerXAnchor),
            instructionLabel.topAnchor.constraint(equalTo: titleImage.bottomAnchor, constant: 10)
            ])
        
    }
    
    private func setupGif() {
        let path1 : String = Bundle.main.path(forResource: "multi-error-sample", ofType: "gif")!
        let url = URL(fileURLWithPath: path1)
        do {
            let gifData = try Data(contentsOf: url)
            let imageData1 = FLAnimatedImage(animatedGIFData: gifData)
            flaniImageView.animatedImage = imageData1
            flaniImageView.translatesAutoresizingMaskIntoConstraints = false
        } catch {
            print("Gif loading error: \(error)")
        }
        
        containerView.addSubview(previousButton)
        containerView.addSubview(flaniImageView)
        NSLayoutConstraint.activate([
            flaniImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            flaniImageView.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 50),
            flaniImageView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.5),
            flaniImageView.heightAnchor.constraint(equalTo: flaniImageView.widthAnchor, multiplier: 0.80972),
            
            previousButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            previousButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 7)
        ])
        
    }
        
    
    //MARK: - Button related functions
    @objc private func closeButtonTapped() {
        onCloseButtonTapped?()
    }

    @objc private func previousButtonTapped() {
        onPreviousButtonTapped?()
    }
    
    
}
