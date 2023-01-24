//
//  UIViewController+Extensions.swift
//  Game_Walker
//
//  Created by Noah Kim on 7/11/22.
//

import UIKit


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showPopUp(_ gameName: String? = nil, _ gameLocation: String? = nil, _ gamePoitns: String? = nil, _ refereeName: String? = nil, _ gameRule: String? = nil, _ actionTitle: String = "Close", _ actionCompletion: (() -> Void)? = nil) {
        let popUpViewController = GameInfoViewController(gameName: gameName ?? "", gameLocation: gameLocation ?? "", gamePoints: gamePoitns ?? "", refereeName: refereeName ?? "", gameRule: gameRule ?? "")
        showPopUp(popUpViewController: popUpViewController, actionTitle: actionTitle, actionCompletion: actionCompletion)
    }
    
    private func showPopUp(popUpViewController: GameInfoViewController, actionTitle: String, actionCompletion: (() -> Void)?) {
        popUpViewController.addActionToButton(title: actionTitle, titleColor: .systemGray, backgroundColor: .secondarySystemBackground) {
            popUpViewController.dismiss(animated: false, completion: actionCompletion)
        }
        present(popUpViewController, animated: false, completion: nil)
    }
}
