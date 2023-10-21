//
//  PlayerTabViewController.swift
//  Game_Walker
//
//  Created by Noah Kim on 7/18/22.
//

import UIKit

class PlayerTabBarController: UITabBarController {
    
    var standardStyle: Bool = true // Default value is true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.delegate = self
        customizeTimerTabBarItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func customizeTimerTabBarItem() {
        if let viewControllers = viewControllers, viewControllers.count > 2 {
            let timerViewController = viewControllers[2] // Assuming Timer is the third tab
            
            if !standardStyle {
                // Customize the tabBarItem when standardStyle is false
                timerViewController.tabBarItem.image = UIImage(named: "TimerButton")
            } else {
                // Reset the tabBarItem to its original image and title when standardStyle is true
                timerViewController.tabBarItem.image = UIImage(named: "TimerButton1")
            }
        }
    }
}
// MARK: - standardStyle?
extension PlayerTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let index = tabBarController.viewControllers?.firstIndex(of: viewController) {
            if index == 2 {
                // If "standardStyle" is false, prevent the tab switch
                if !standardStyle {
                    return false
                }
            }
        }

        return true
    }
}
