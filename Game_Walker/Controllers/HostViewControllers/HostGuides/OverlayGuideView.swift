//
//  AddStationGuideViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 10/11/23.
//

import Foundation
import UIKit

class OverlayGuideView: UIView {
    
    var onCloseButtonTapped: (() -> Void)?
    let overlay = UIView()
    
    private lazy var closeButton: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "icon _close_"), for: .normal)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        let tappedAroundGesture = UITapGestureRecognizer(target: self, action: #selector(closeButtonTapped))
        overlay.addGestureRecognizer(tappedAroundGesture)
        return button
    }()
    
    @objc private func closeButtonTapped() {
        onCloseButtonTapped?()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupOverlay()
        setupCloseButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupOverlay() {
        overlay.translatesAutoresizingMaskIntoConstraints = false
        addSubview(overlay)
        
        NSLayoutConstraint.activate([
            overlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: trailingAnchor),
            overlay.topAnchor.constraint(equalTo: topAnchor),
            overlay.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        overlay.backgroundColor = UIColor(red: 0.18, green: 0.18, blue: 0.21, alpha: 0.9)

    }
    
    private func setupCloseButton() {
        overlay.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: overlay.topAnchor, constant: 18),
            closeButton.trailingAnchor.constraint(equalTo: overlay.trailingAnchor, constant: -18)
        ])
    }
    
    func giveCornerRadius(of cornerradius : CGFloat) {
        overlay.layer.cornerRadius = cornerradius
    }
}

//MARK: - for overlay component
class OverlayComponentView:UIView {
    
    let explainLabel = UILabel()
    let component = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        
        component.translatesAutoresizingMaskIntoConstraints = false
        addSubview(component)
        
        NSLayoutConstraint.activate([
            component.leadingAnchor.constraint(equalTo: leadingAnchor),
            component.trailingAnchor.constraint(equalTo: trailingAnchor),
            component.topAnchor.constraint(equalTo: topAnchor),
            component.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        component.layer.cornerRadius = 10
        component.layer.borderWidth = 3
        component.layer.borderColor = UIColor.white.cgColor

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addLabel(with text: String, width: CGFloat) {
        explainLabel.translatesAutoresizingMaskIntoConstraints = false
        explainLabel.text = text
        var fontsize = CGFloat(13)
        
        component.addSubview(explainLabel)
        NSLayoutConstraint.activate([
            explainLabel.centerXAnchor.constraint(equalTo: component.centerXAnchor),
            explainLabel.centerYAnchor.constraint(equalTo: component.centerYAnchor)
        ])
        var labelWidth = text.size(withAttributes: [.font: getFontForLanguage(font: "GemunuLibre-Medium", size: fontsize) ?? UIFont.systemFont(ofSize: fontsize)]).width

        if labelWidth > width{
            while labelWidth > component.frame.width {
                fontsize -= 2
                labelWidth = text.size(withAttributes: [.font: getFontForLanguage(font: "GemunuLibre-Medium", size: fontsize) ?? UIFont.systemFont(ofSize: fontsize)]).width
            }
        }
        explainLabel.font = getFontForLanguage(font: "GemunuLibre-Medium", size: fontsize)
        explainLabel.textColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.00)
    }
    
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
