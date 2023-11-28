//
//  PlayerTabViewController.swift
//  Game_Walker
//
//  Created by Noah Kim on 7/18/22.
//

import UIKit

class PlayerTabBarController: UITabBarController, HostUpdateListener, TeamUpdateListener {
    
    var standardStyle: Bool = true // Default value is true
    let gameCode = UserData.readGamecode("gamecode") ?? ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        H.delegates.append(WeakHostUpdateListener(value: self))
        T.delegates.append(WeakTeamUpdateListener(value: self))
        addHostListener()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        customizeTimerTabBarItem()
        print("tabbar prints: \(H.delegates.count)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        H.delegates = H.delegates.filter { $0.value != nil }
        T.delegates = T.delegates.filter { $0.value != nil}
        removeListeners()
    }
    
    private func removeListeners() {
        H.detatchHost()
    }
    
    
    private func customizeTimerTabBarItem() {
        if let viewControllers = viewControllers, viewControllers.count > 2 {
            let timerViewController = viewControllers[2] // Assuming Timer is the third tab
            
            if !standardStyle {
                // Customize the tabBarItem when standardStyle is false
//                timerViewController.tabBarItem.image = UIImage(named: "TimerButton")
                timerViewController.tabBarItem.isEnabled = false
            } else {
                // Reset the tabBarItem to its original image and title when standardStyle is true
                timerViewController.tabBarItem.image = UIImage(named: "TimerButton1")
            }
        }
    }
    
    private func addHostListener(){
        H.listenHost(gameCode, onListenerUpdate: listen(_:))
        T.listenTeams(gameCode, onListenerUpdate: listen(_:))
    }
    
    func updateHost(_ host: Host) {
        let data: [String:Host] = ["host":host]
        NotificationCenter.default.post(name: .hostUpdate, object: nil, userInfo: data)
        if host.gameover {
            showAwardPopUp("player")
        }
    }
    
    func updateTeams(_ teams: [Team]) {
        let data: [String:[Team]] = ["teams":teams]
        NotificationCenter.default.post(name: .teamsUpdate, object: nil, userInfo: data)
    }
    
    func listen(_ _ : [String : Any]){
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
