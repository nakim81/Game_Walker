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
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootController = windowScene.windows.first?.rootViewController as? UINavigationController,
           let mainViewController = rootController.viewControllers.first(where: { $0 is MainViewController }) {
            rootController.setViewControllers([mainViewController], animated: animated)
        }
    }
    
    func popToWaitingViewController(animated: Bool) {
        print("going back to waiting")
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootController = windowScene.windows.first?.rootViewController as? UINavigationController,
           let waitingController = rootController.viewControllers.first(where: { $0 is WaitingViewController }) {
            print(waitingController)
            popToViewController(waitingController, animated: animated)
        }
    }
    
    func popToRegisterViewController(animated: Bool) {
        if let destinationViewController = navigationController?.viewControllers.filter({$0 is RegisterViewController
        }).last {
            navigationController?.popToViewController(destinationViewController, animated: true)
        }
    }
}
