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
    
    func showGameInfoPopUp(gameName: String? = nil, gameLocation: String? = nil, gamePoitns: String? = nil, refereeName: String? = nil, gameRule: String? = nil, _ actionTitle: String = "Close", _ actionCompletion: (() -> Void)? = nil) {
        let popUpViewController = GameInfoViewController(gameName: gameName ?? "", gameLocation: gameLocation ?? "", gamePoints: gamePoitns ?? "", refereeName: refereeName ?? "", gameRule: gameRule ?? "")
        showGameInfoPopUp(popUpViewController: popUpViewController, actionTitle: actionTitle, actionCompletion: actionCompletion)
    }
    
    private func showGameInfoPopUp(popUpViewController: GameInfoViewController, actionTitle: String, actionCompletion: (() -> Void)?) {
        popUpViewController.addActionToButton(title: actionTitle, titleColor: .systemGray, backgroundColor: .secondarySystemBackground) {
            popUpViewController.dismiss(animated: false, completion: actionCompletion)
        }
        present(popUpViewController, animated: false, completion: nil)
    }
    
    func showRefereeGameInfoPopUp(gameName: String? = nil, gameLocation: String? = nil, gamePoitns: String? = nil, gameRule: String? = nil, _ actionTitle: String = "Close", _ actionCompletion: (() -> Void)? = nil) {
        let popUpViewController = RefereeGameInfoViewcontroller(gameName: gameName ?? "", gameLocation: gameLocation ?? "", gamePoints: gamePoitns ?? "", gameRule: gameRule ?? "")
        showRefereeGameInfoPopUp(popUpViewController: popUpViewController, actionTitle: actionTitle, actionCompletion: actionCompletion)
    }
    
    private func showRefereeGameInfoPopUp(popUpViewController: RefereeGameInfoViewcontroller, actionTitle: String, actionCompletion: (() -> Void)?) {
        popUpViewController.addActionToButton(title: actionTitle, titleColor: .systemGray, backgroundColor: .secondarySystemBackground) {
            popUpViewController.dismiss(animated: false, completion: actionCompletion)
        }
        present(popUpViewController, animated: false, completion: nil)
    }
    
    func showMessagePopUp(messages: [String]? = nil, _ actionTitle: String = "Close", _ actionCompletion: (() -> Void)? = nil) {
        let popUpViewController = MessageViewController()
        showMessagePopUp(popUpViewcontroller: popUpViewController, actionTitle: actionTitle, actionCompletion: actionCompletion)
        
    }
    
    private func showMessagePopUp(popUpViewcontroller: MessageViewController, actionTitle: String, actionCompletion: (() -> Void)?) {
        popUpViewcontroller.addActionToButton(title: actionTitle, titleColor: .systemGray, backgroundColor: .secondarySystemBackground) {
            popUpViewcontroller.dismiss(animated: false, completion: actionCompletion)
        }
        present(popUpViewcontroller, animated: false, completion: nil)
    }
}
