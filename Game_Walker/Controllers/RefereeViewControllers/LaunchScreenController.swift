//
//  LaunchScreenController.swift
//  Game_Walker
//
//  Created by 김현식 on 2/13/23.
//

import Foundation
import UIKit

class LaunchScreenViewController: UIViewController {
    @IBOutlet weak var iconView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let blackView = UIView(frame: self.view.bounds)
            blackView.backgroundColor = .black
            self.view.addSubview(blackView)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                blackView.removeFromSuperview()
                self.addRectangles()
        }
    }
    func addRectangles() {
        let screenSize = UIScreen.main.bounds.size
        let rectangleWidth = screenSize.width
        let rectangleHeight = screenSize.height/4
        let rectangleViews = [
            UIView(frame: CGRect(x: 0, y: 0, width: rectangleWidth, height: rectangleHeight)),
            UIView(frame: CGRect(x: 0, y: rectangleHeight, width: rectangleWidth, height: rectangleHeight)),
            UIView(frame: CGRect(x: 0, y: rectangleHeight*2, width: rectangleWidth, height: rectangleHeight)),
            UIView(frame: CGRect(x: 0, y: rectangleHeight*3, width: rectangleWidth, height: rectangleHeight))
        ]
        let colors = [
            UIColor(red: 0.98, green: 0.204, blue: 0, alpha: 1),
            UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1),
            UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 1),
            UIColor(red: 0.843, green: 0.502, blue: 0.976, alpha: 1)
        ]
        let words = ["LET", "THERE", "BE", "LIGHT"]
        for (index, color) in colors.enumerated() {
            let rectangleView = rectangleViews[index]
            rectangleView.backgroundColor = color
            let label = UILabel(frame: rectangleView.bounds)
            label.text = words[index]
            label.textAlignment = .center
            label.font = UIFont.boldSystemFont(ofSize: 50)
            label.textColor = .white
            rectangleView.addSubview(label)
            self.view.addSubview(rectangleView)
            UIView.animate(withDuration: 3.0, animations: {
                   rectangleView.alpha = 1.0
               }, completion: { _ in
                   UIView.animate(withDuration: 3.0, animations: {
                       rectangleView.alpha = 0.0
                   }, completion: { _ in
                       rectangleView.removeFromSuperview()
                   })
               })
        }
    }
}
