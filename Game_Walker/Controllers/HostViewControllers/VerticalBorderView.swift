//
//  VerticalBorderView.swift
//  Game_Walker
//
//  Created by Jin Kim on 6/21/23.
//

import UIKit

class VerticalBorderView: UIView {

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        let lineWidth: CGFloat = 1.0
        let lineX = bounds.width - lineWidth
        path.move(to: CGPoint(x: lineX, y: 0))
        path.addLine(to: CGPoint(x: lineX, y: bounds.height))
        UIColor.black.setStroke()
        path.lineWidth = lineWidth
        path.stroke()
    }

}
