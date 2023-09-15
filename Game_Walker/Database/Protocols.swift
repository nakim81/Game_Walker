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

protocol GetReferee {
    func getReferee(_ referee: Referee)
}

protocol RefereeList {
    func listOfReferees(_ referees: [Referee])
}

protocol GetStation {
    func getStation(_ station: Station)
}

protocol StationList {
    func listOfStations(_ stations: [Station])
}

protocol TeamUpdateListener {
    func updateTeams(_ teams: [Team])
}

protocol GetTeam {
    func getTeam(_ team: Team)
}

protocol TeamList {
    func listOfTeams(_ teams: [Team])
}

protocol HostUpdateListener {
    func updateHost(_ host: Host)
}

protocol GetHost {
    func getHost(_ host: Host)
}

protocol ModalViewControllerDelegate: AnyObject {
    func modalViewControllerDidRequestPush()
}

protocol AddStationDelegate: AnyObject {
    func didUpdateStationData()
}

//MARK: - Errors

enum GamecodeError: Error {
    case invalidGamecode(String)
}

enum ServerError: Error {
    case serverError(String)
}
