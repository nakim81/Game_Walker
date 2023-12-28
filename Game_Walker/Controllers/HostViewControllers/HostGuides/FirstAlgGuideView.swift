//
//  FirstAlgGuideViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 10/11/23.
//

import Foundation
import UIKit

class FirstAlgGuideView : UIView {
    
    var onCloseButtonTapped: (() -> Void)?
    var onNextButtonTapped: (() -> Void)?
    
    //MARK: - UI Elements
    let containerView = UIView()
    let textBorderView = UIView()
    var instructionLabel = UILabel()
    
    private lazy var closeButton: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "CloseIconModalSmall"), for: .normal)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var nextButton: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "nextbutton-guide"), for: .normal)
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBasicUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        
        textBorderView.translatesAutoresizingMaskIntoConstraints = false
        textBorderView.layer.cornerRadius = 20.0
        textBorderView.layer.borderWidth = 3
        textBorderView.layer.borderColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.00).cgColor
        containerView.addSubview(textBorderView)
        NSLayoutConstraint.activate([
            textBorderView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.94),
            textBorderView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.7),
            textBorderView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            textBorderView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        containerView.addSubview(nextButton)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nextButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -7),
            nextButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        
    }
    private func setupGuideText() {
        
        let instructionText = """
        \u{2022} Tap "Stations" to see the 
        new order of Stations.
        \u{2022} Swap teams by click.
        \u{2022} Manually change team 
        by long-click.
        \u{2022} Beware, mixing teams 
        can cause errors.
        """
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6

        let attributedString = NSAttributedString(string: instructionText, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])

        instructionLabel.attributedText = attributedString
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.textAlignment = .left
        instructionLabel.font = UIFont(name: "Dosis-Regular", size: 20)
        instructionLabel.textColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.00)
        instructionLabel.numberOfLines = 7
        instructionLabel.adjustsFontForContentSizeCategory = true
        
        textBorderView.addSubview(instructionLabel)
        
        NSLayoutConstraint.activate([
            instructionLabel.centerXAnchor.constraint(equalTo: textBorderView.centerXAnchor),
            instructionLabel.centerYAnchor.constraint(equalTo: textBorderView.centerYAnchor)
        ])
        
    }
    
    override func layoutSubviews() {
        setupGuideText()
    }
    //MARK: - Button related functions
    @objc private func closeButtonTapped() {
        onCloseButtonTapped?()
    }
    @objc private func nextButtonTapped() {
        onNextButtonTapped?()
    }
}
