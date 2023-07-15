//
//  Station.swift
//  Game_Walker
//
//  Created by Paul on 6/13/22.
//

import Foundation

struct Station: Codable, Equatable {
    var name: String = ""
    var number: Int = 0
    var pvp: Bool = true
    var points: Int = 0
    var place: String = ""
    var referee: Referee? = nil
    var description: String = ""
    var teamOrder: [Team] = []
    
    enum CodingKeys: String, CodingKey {
        case name
        case number
        case pvp
        case points
        case place
        case referee
        case description
        case teamOrder
    }
    
}
