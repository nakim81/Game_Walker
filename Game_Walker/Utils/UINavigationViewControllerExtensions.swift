//
//  UINavigationViewControllerExtensions.swift
//  Game_Walker
//
//  Created by Noah Kim on 11/28/23.
//

import Foundation
import UIKit

extension UINavigationController {
    
    func popToMainViewController(_ from: String, animated: Bool) {
        if from == "host" {
            if let destinationViewController = navigationController?.viewControllers.filter({$0 is MainViewController}).first {
                navigationController?.popToViewController(destinationViewController, animated: true)
            }
        } else {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootController = windowScene.windows.first?.rootViewController as? UINavigationController,
               let mainViewController = rootController.viewControllers.first(where: { $0 is MainViewController }) {
                print(mainViewController)
                popToViewController(mainViewController, animated: animated)
            }
        }
    }
    
    func popToWaitingViewController(animated: Bool) {
        if let destinationViewController = navigationController?.viewControllers.filter({$0 is WaitingController
        }).first {
            navigationController?.popToViewController(destinationViewController, animated: true)
        }
    }
    
    func popToRegisterViewController(animated: Bool) {
        if let destinationViewController = navigationController?.viewControllers.filter({$0 is RegisterController
        }).first {
            navigationController?.popToViewController(destinationViewController, animated: true)
        }
    }
}
