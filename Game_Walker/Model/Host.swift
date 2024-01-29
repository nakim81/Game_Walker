//
//  Host.swift
//  Game_Walker
//
//  Created by Paul on 6/13/22.
//

import Foundation

struct Host: Codable {
    //MARK: - Game Info
    var gamecode: String = ""
    var standardStyle: Bool = true
    var confirmStations: Bool = false
    var confirmCreated: Bool = false
    var gameTime: Int = 0
    var movingTime: Int = 0
    var rounds: Int = 0
    var teams: Int = 0
    var currentRound: Int = 1
    //algorithm
    var algorithm: [Int] = []
    
    //MARK: - Game Control
    var showScoreboard: Bool = true
    var gameStart: Bool = false
    var gameover: Bool = false
    //pause
    var paused: Bool = true
    var startTimestamp: Int = Int(Date().timeIntervalSince1970)
    var pauseTimestamp: Int = Int(Date().timeIntervalSince1970)
    var pausedTime: Int = 0
    //announcements
    var announcements: [Announcement] = []
    //awards
    var firstReveal: Bool = false
    var secondReveal: Bool = false
    var thirdReveal: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case gamecode
        case standardStyle
        case confirmStations
        case confirmCreated
        case gameTime
        case movingTime
        case rounds
        case currentRound
        case teams
        case algorithm
        case showScoreboard
        case gameStart
        case gameover
        case paused
        case startTimestamp
        case pauseTimestamp
        case pausedTime
        case announcements
        case firstReveal
        case secondReveal
        case thirdReveal
    }
}

