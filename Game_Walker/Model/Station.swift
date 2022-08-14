//
//  Station.swift
//  Game_Walker
//
//  Created by Paul on 6/13/22.
//

import Foundation

struct Station: Codable, Equatable {
    var name: String = ""
    var pvp: Bool = true
    var points: Int = 0
    var place: String = ""
    var description: String = ""
    var teamOrder: [Team] = []

    
    enum CodingKeys: String, CodingKey {
        case name
        case pvp
        case points
        case place
        case description
        case teamOrder
    }
    
}
