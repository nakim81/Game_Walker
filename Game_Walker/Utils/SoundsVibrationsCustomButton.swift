//
//  SoundsVibrationsCustomButton.swift
//  Game_Walker
//
//  Created by Jin Kim on 12/22/23.
//

import Foundation
import UIKit

class SoundsVibrationsCustomButton: UIButton {

    private let onLabel = UILabel()
    private let offLabel = UILabel()
    private let iconImageView = UIImageView()

    var isOn: Bool = false {
        didSet {
            updateUI()
        }
    }

    weak var delegate: CustomSwitchButtonDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        // Customize your button appearance here
        backgroundColor = .lightGray
        layer.cornerRadius = 10
        clipsToBounds = true

        // Icon Image View
        iconImageView.image = UIImage(named: "SwitchBtnImage") // Set your image for the OFF state
        iconImageView.contentMode = .center
        addSubview(iconImageView)

        // ON Label
        onLabel.text = "ON"
        onLabel.textAlignment = .center
        addSubview(onLabel)

        // OFF Label
        offLabel.text = "OFF"
        offLabel.textAlignment = .center
        addSubview(offLabel)

        // Add tap gesture
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

        // Initial UI setup
        updateUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Adjust the position and size of subviews based on the button's frame
        let iconSize = bounds.height
        iconImageView.frame = CGRect(x: 0, y: 0, width: iconSize, height: iconSize)

        let labelWidth = bounds.width - iconSize
        onLabel.frame = CGRect(x: iconSize, y: 0, width: labelWidth, height: bounds.height)
        offLabel.frame = CGRect(x: 0, y: 0, width: labelWidth, height: bounds.height)
    }

    private func updateUI() {
        // Update UI based on the isOn property
        if isOn {
            onLabel.isHidden = false
            offLabel.isHidden = true
        } else {
            onLabel.isHidden = true
            offLabel.isHidden = false
        }

        // Notify delegate about the value change
        delegate?.isOnValueChange(self, isOn: isOn)
    }

    @objc private func buttonTapped() {
        // Toggle the state when the button is tapped
        isOn.toggle()
    }
}
