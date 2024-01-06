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
    
    static var localMessages: [Announcement] = []
    
    private var timer = Timer()
    static var unread: Bool = false
    
    private let audioPlayerManager = AudioPlayerManager()

    var soundEnabled: Bool = true
    var vibrationEnabled: Bool = true

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
        
        Task {@MainActor in
            do {
                guard let host = try await H.getHost(gameCode) else { return }
                PlayerTabBarController.localMessages = host.announcements
            } catch GameWalkerError.serverError(let e) {
                print(e)
                serverAlert(e)
                return
            }
        }
        
        print("tabbar prints: \(H.delegates.count)")
        
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] timer in
            guard let strongSelf = self else {
                return
            }
            let unread = strongSelf.checkUnreadAnnouncements(announcements: PlayerTabBarController.localMessages)
            PlayerTabBarController.unread = unread
            if unread{
                NotificationCenter.default.post(name: .readNotification, object: nil, userInfo: ["unread":unread])
                NotificationCenter.default.post(name: .newDataNotif, object: nil)
            } else {
                NotificationCenter.default.post(name: .readNotification, object: nil, userInfo: ["unread":unread])
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        timer.invalidate()
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
        if host.gameover {
            showAwardPopUp("player")
        }
        
        let data: [String:Host] = ["host":host]
        NotificationCenter.default.post(name: .hostUpdate, object: nil, userInfo: data)
        
        if PlayerTabBarController.localMessages.count > host.announcements.count {
            removeAnnouncementsNotInHost(from: &PlayerTabBarController.localMessages, targetArray: host.announcements)
            NotificationCenter.default.post(name: .newDataNotif, object: nil, userInfo: nil)
        } else {
            // compare server announcements and local announcements
            for announcement in host.announcements {
                let ids: [String] = PlayerTabBarController.localMessages.map({ $0.uuid })
                // new announcements
                if !ids.contains(announcement.uuid) {
                    PlayerTabBarController.localMessages.append(announcement)
                    if soundEnabled {
                        self.audioPlayerManager.playAudioFile(named: "message", withExtension: "wav")
                    }
                    NotificationCenter.default.post(name: .announceNoti, object: nil, userInfo: nil)
                } else {
                    // modified announcements
                    if let localIndex = PlayerTabBarController.localMessages.firstIndex(where: {$0.uuid == announcement.uuid}) {
                        if PlayerTabBarController.localMessages[localIndex].content != announcement.content {
                            PlayerTabBarController.localMessages[localIndex].content = announcement.content
                            PlayerTabBarController.localMessages[localIndex].readStatus = false
                            if soundEnabled {
                                self.audioPlayerManager.playAudioFile(named: "message", withExtension: "wav")
                            }
                            NotificationCenter.default.post(name: .announceNoti, object: nil, userInfo: nil)
                        }
                    }
                }
                
            }
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

extension PlayerTabBarController: SettingsDelegate {
    func didChangeSettings(_ soundEnabled: Bool, _ vibrationEnabled: Bool) {
        self.soundEnabled = soundEnabled
        self.vibrationEnabled = vibrationEnabled
    }
}
