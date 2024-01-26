//
//  DuplicatedOppGuideViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 10/11/23.
//

import Foundation
import UIKit
import FLAnimatedImage


class SameRoundGuideView : UIView {
    var onCloseButtonTapped: (() -> Void)?
    var onNextButtonTapped: (() -> Void)?
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

    private lazy var nextButton: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "nextbutton-guide"), for: .normal)
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
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
        label.font = getFontForLanguage(font: "GemunuLibre-Bold", size: 15)
        label.textColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.00)
        label.numberOfLines = 2

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.2

        let attributedString = NSMutableAttributedString(string: NSLocalizedString("""
        Team is playing multiple stations
        on the same round.
        """, comment: ""))
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))

        label.attributedText = attributedString
        label.textAlignment = .center

        return label
    }()
    
    
    private let gifImageView = UIImageView()
    private let flaniImageView = FLAnimatedImageView()
        
    
    //MARK: - init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBasicUI()
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        setupGif()
    }
    private func setupBasicUI() {
        // Create the title of each guide error
        // Create UIImageView
        let sharpImage = UIImageView(image: UIImage(named: "purple-sharp"))
        sharpImage.contentMode = .scaleAspectFit
        
        // Create UILabel
        let label = UILabel()
        label.text = NSLocalizedString("Duplicated Appearance", comment: "")
        label.textColor = UIColor(red: 0.84, green: 0.50, blue: 0.98, alpha: 1.00)
        label.font = getFontForLanguage(font: "GemunuLibre-Medium", size: 30)
        
        // Create Horizontal UIStackView
        let titleView = UIStackView(arrangedSubviews: [sharpImage, label])
        titleView.axis = .horizontal
        titleView.spacing = 4
        titleView.alignment = .center
        
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
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(titleView)
        containerView.addSubview(instructionLabel)
        NSLayoutConstraint.activate([
            titleView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 18),
            titleView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            titleView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.12),
            
            instructionLabel.centerXAnchor.constraint(equalTo: titleView.centerXAnchor),
            instructionLabel.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 10),
            instructionLabel.heightAnchor.constraint(equalTo: titleView.heightAnchor, multiplier: 1.12)
            ])
        
    }
    
    private func setupGif() {
        let path1 : String = Bundle.main.path(forResource: "sameround-duplicated-sample", ofType: "gif")!
        let url = URL(fileURLWithPath: path1)
        do {
            let gifData = try Data(contentsOf: url)
            let imageData1 = FLAnimatedImage(animatedGIFData: gifData)
            flaniImageView.animatedImage = imageData1
            flaniImageView.translatesAutoresizingMaskIntoConstraints = false
        } catch {
            print("Gif loading error: \(error)")
        }
        
        containerView.addSubview(nextButton)
        containerView.addSubview(previousButton)
        containerView.addSubview(flaniImageView)
        NSLayoutConstraint.activate([
            flaniImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            flaniImageView.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 40),
            flaniImageView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.5),
            flaniImageView.heightAnchor.constraint(equalTo: flaniImageView.widthAnchor, multiplier: 0.80972),
            
            previousButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            previousButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 7),
            
            nextButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            nextButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -7)
        ])
        
    }
        
    
    //MARK: - Button related functions
    @objc private func closeButtonTapped() {
        onCloseButtonTapped?()
    }
    @objc private func nextButtonTapped() {
        onNextButtonTapped?()
    }
    @objc private func previousButtonTapped() {
        onPreviousButtonTapped?()
    }
    
    //MARK: - Language
    func getFontForLanguage(font: String, size: CGFloat, ksize: CGFloat? = nil) -> UIFont {
        let finalSize = ksize ?? size
        
        if let languageCode = Locale.current.languageCode, languageCode == "ko" {
            if let customFont = UIFont(name: "koverwatch", size: finalSize) {
                return customFont
            }
        }
        
        // Fallback to default font for English or other languages
        if let defaultFont = UIFont(name: font, size: finalSize) {
            return defaultFont
        }
        
        // If both custom and default fonts are unavailable, return system font
        return UIFont.systemFont(ofSize: finalSize)
    }
    
    
}
