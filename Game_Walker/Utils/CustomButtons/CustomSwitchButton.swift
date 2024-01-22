//
//  CustomSwitchButton.swift
//  Game_Walker
//
//  Created by Noah Kim on 3/18/23.
//

import Foundation
import UIKit

protocol CustomSwitchButtonDelegate: AnyObject {
    func isOnValueChange(_ sender: UIButton, isOn: Bool)}

class CustomSwitchButton: UIButton {
    typealias SwitchImage = (bar: UIImage, circle: UIImage)

        private var barView: UIImageView!
        private var circleView: UIImageView!

        var isOn: Bool = true {
            didSet {
                self.changeState()
            }
        }

        // button image when the button is on
        var onImage: SwitchImage = (UIImage(named: "StateShow")!, UIImage(named: "SwitchBtnImage")!) {
            didSet {
                if isOn {
                    self.barView.image = self.onImage.bar
                    self.circleView.image = self.onImage.circle
                }
            }
        }

        // button image when the button is off
        var offImage: SwitchImage = (UIImage(named: "StateHid")!, UIImage(named: "SwitchBtnImage")!) {
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
            _ = frame.width * 0.9438202247
            _ = frame.height
        }

        private func buttonInit(frame: CGRect) {

            let circleViewHeight = frame.height - (circleViewTopBottomMargin * 2)

            barView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
            barView.image = self.onImage.bar
            barView.contentMode = .scaleToFill

            self.addSubview(barView)

            circleView = UIImageView(frame: CGRect(x: 0, y: circleViewTopBottomMargin, width: circleViewHeight, height: circleViewHeight))
            circleView.center.x = self.circleView.frame.width / 2
            circleView.image = self.onImage.circle
            circleView.contentMode = .scaleAspectFit

            self.addSubview(circleView)
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
                circleCenter = self.circleView.frame.width / 1.7
                barViewColor = self.onImage.bar
                circleViewColor = self.onImage.circle
            } else {
                circleCenter = self.frame.width - self.circleView.frame.width / 2.2
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
