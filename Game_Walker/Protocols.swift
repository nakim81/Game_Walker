//
//  DataUpdateListener.swift
//  Game_Walker
//
//  Created by Paul on 6/15/22.
//

import Foundation
import UIKit

protocol DataUpdateListener {
    func onDataUpdate(_ host: Host)
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
