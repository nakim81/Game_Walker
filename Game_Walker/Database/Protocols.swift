//
//  DataUpdateListener.swift
//  Game_Walker
//
//  Created by Paul on 6/15/22.
//

import Foundation
import UIKit

//MARK: - Protocols

protocol RefereeUpdateListener {
    func updateReferee(_ referee: Referee)
}

protocol TeamUpdateListener: AnyObject {
    func updateTeams(_ teams: [Team])
}

protocol HostUpdateListener: AnyObject {
    func updateHost(_ host: Host)
}

protocol ModalViewControllerDelegate: AnyObject {
    func modalViewControllerDidRequestPush()
}

protocol AddStationDelegate: AnyObject {
    func didUpdateStationData(completion: @escaping () -> Void)
}

//MARK: - Errors
enum GameWalkerError: Error {
    case invalidGamecode(String)
    case serverError(String)
}
// MARK: - sturct for protocols
struct WeakHostUpdateListener {
    weak var value: HostUpdateListener?
}

struct WeakTeamUpdateListener {
    weak var value: TeamUpdateListener?
}
