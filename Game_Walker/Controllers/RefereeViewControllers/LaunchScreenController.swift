//
//  LaunchScreenController.swift
//  Game_Walker
//
//  Created by 김현식 on 2/13/23.
//

import Foundation
import UIKit

class LaunchScreenViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let rectangle = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        rectangle.backgroundColor = .blue
        rectangle.center = view.center
        view.addSubview(rectangle)
        UIView.animate(withDuration: 2.0, delay: 0, options: [.autoreverse, .repeat], animations: {
                    rectangle.backgroundColor = .red
                    rectangle.center.y -= 50
        }, completion: nil)
    }
}


