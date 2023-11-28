//
//  RefereeTabBarPVEController.swift
//  Game_Walker
//
//  Created by 김현식 on 1/27/23.
//

import UIKit

class RefereeTabBarPVEController: UITabBarController, RefereeUpdateListener, HostUpdateListener, TeamUpdateListener {
    
    private var gameCode = UserData.readGamecode("gamecode") ?? ""
    
    func updateReferee(_ referee: Referee) {
        let data: [String:Referee] = ["referee":referee]
        if (!referee.assigned) {
            navigationController?.popToWaitingViewController(animated: true)
        }
        NotificationCenter.default.post(name: .refereeUpdate, object: nil, userInfo: data)
    }
    
    func updateHost(_ host: Host) {
        let data: [String:Host] = ["host":host]
        NotificationCenter.default.post(name: .hostUpdate, object: nil, userInfo: data)
        if host.gameover {
            showAwardPopUp("referee")
        }
    }
    
    func updateTeams(_ teams: [Team]) {
        let data: [String:[Team]] = ["teams":teams]
        NotificationCenter.default.post(name: .teamsUpdate, object: nil, userInfo: data)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.navigationController?.isNavigationBarHidden = true
        print("------------H.delegates------------")
        H.delegates = H.delegates.filter { $0.value != nil }
        for delegate in H.delegates {
            print(delegate)
        }
        print("------------H.delegates------------")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.navigationController?.isNavigationBarHidden = true
        H.delegates.append(WeakHostUpdateListener(value: self))
        T.delegates.append(WeakTeamUpdateListener(value: self))
        R.delegates.append(WeakRefereeUpdateListener(value: self))
        addListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        H.delegates = H.delegates.filter { $0.value != nil }
        T.delegates = T.delegates.filter { $0.value != nil }
        R.delegates = R.delegates.filter { $0.value != nil }
    }
    
    private func addListener(){
        guard let referee = UserData.readReferee("referee") else { return }
        
        H.listenHost(gameCode, onListenerUpdate: listen(_:))
        T.listenTeams(gameCode, onListenerUpdate: listen(_:))
        R.listenReferee(gameCode, referee.uuid , onListenerUpdate: listen(_:))
    }
    
    func listen(_ _ : [String : Any]){
    }
}
