//
//  Player.swift
//  Game_Walker
//
//  Created by Paul on 6/13/22.
//

import Foundation

struct Player : Codable, Equatable {
    var gamecode : String = ""
    var name : String = ""
    
    enum CodingKeys: String, CodingKey {
        case gamecode
        case name
    }
    
    mutating func createTeam() {
        
    }
        

    mutating func createPlayer(playerName : String, gamecode: String) {
        //Set player's name
        name = playerName
        self.gamecode = gamecode
    }
}
