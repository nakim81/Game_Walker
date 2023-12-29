//
//  SoundsVibrationsCustomButton.swift
//  Game_Walker
//
//  Created by Jin Kim on 12/22/23.
//

import Foundation
import UIKit

class SoundsVibrationsCustomButton: UIButton {
    typealias SwitchImage = (bar: UIImage, circle: UIImage)

    private var barView: UIImageView!
    private var circleView: UIImageView!

    var isOn: Bool = true {
        didSet {
            self.changeState()
        }
    }

    // button image when the button is on
    var onImage: SwitchImage = (UIImage(named: "onstate-switch")!, UIImage(named: "SwitchBtnImage")!) {
        didSet {
            if isOn {
                self.barView.image = self.onImage.bar
                self.circleView.image = self.onImage.circle
            }
        }
    }

    // button image when the button is off
    var offImage: SwitchImage = (UIImage(named: "offstate-switch")!, UIImage(named: "SwitchBtnImage")!) {
        didSet {
               if isOn == false {
                self.barView.image = self.offImage.bar
                self.circleView.image = self.offImage.circle
            }
        }
    }

    // switch animation duration
    var animationDuration: TimeInterval = 0.25

    // set animation when isOn value changes
    private var isAnimated: Bool = false

    // circleView's top and bottom margin
    var circleViewTopBottomMargin: CGFloat = 2

    weak var delegate: CustomSwitchButtonDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.buttonInit(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.buttonInit(frame: frame)
        print(frame)
    }
    
    private func buttonInit(frame: CGRect) {
        let circleViewHeight = frame.height - (circleViewTopBottomMargin * 2)

        barView = UIImageView()
        barView.translatesAutoresizingMaskIntoConstraints = false
        barView.image = self.onImage.bar
        barView.contentMode = .scaleToFill
        self.addSubview(barView)

        circleView = UIImageView()
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.image = self.onImage.circle
        circleView.contentMode = .scaleAspectFit
        self.addSubview(circleView)

        NSLayoutConstraint.activate([
            barView.topAnchor.constraint(equalTo: self.topAnchor),
            barView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            barView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            barView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            circleView.widthAnchor.constraint(equalTo: circleView.heightAnchor),
            circleView.heightAnchor.constraint(equalToConstant: circleViewHeight),
            circleView.centerYAnchor.constraint(equalTo: self.centerYAnchor),

            circleView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: circleViewTopBottomMargin)
        ])

        layoutIfNeeded()

        let circleCenter: CGFloat = isOn ?
            circleView.frame.width / 2 + circleViewTopBottomMargin :
            frame.width - (circleView.frame.width / 2) - circleViewTopBottomMargin

        circleView.center.x = circleCenter

        print("circleView frame in buttonInit: \(circleView.frame)")
    }



        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.setOn(on: !self.isOn, animated: true)
        }

        func setOn(on: Bool, animated: Bool) {
            self.isAnimated = animated
            self.isOn = on
        }
    
    private func changeState() {
        var circleCenter: CGFloat = 0
        var barViewColor: UIImage
        var circleViewColor: UIImage

        if self.isOn {
            circleCenter = self.circleView.frame.width / 2 + circleViewTopBottomMargin
            barViewColor = self.onImage.bar
            circleViewColor = self.onImage.circle
        } else {
            circleCenter = self.frame.width - (self.circleView.frame.width / 2) - circleViewTopBottomMargin
            barViewColor = self.offImage.bar
            circleViewColor = self.offImage.circle
        }

        let duration = self.isAnimated ? self.animationDuration : 0

        UIView.animate(withDuration: duration, animations: { [weak self] in
            guard let self = self else { return }

            self.circleView.center.x = circleCenter
            self.barView.image = barViewColor
            self.circleView.image = circleViewColor

        }) { [weak self] _ in
            guard let self = self else { return }

            self.delegate?.isOnValueChange(self, isOn: self.isOn)
            self.isAnimated = false
        }
    }

}
