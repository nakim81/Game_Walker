//
//  Host.swift
//  Game_Walker
//
//  Created by Paul on 6/13/22.
//

import Foundation

struct Host: Codable {
    var gamecode : String = ""
    var stations : [Station] = []
    var countOfPVP : Int = 0
    var teams : [Team] = []
    var players : [Player] = []
    var referees : [Referee] = []
    var gameTime : Int = 0
    var movingTime : Int = 0
    var rounds : Int = 0
    var algorithm : [[String]] = []
    var duplicated : [[Int]] = []
    var doubled : [[Int]] = []
    var blanked : [[Int]] = []
    
    enum CodingKeys: String, CodingKey {
        case gamecode
        case stations
        case countOfPVP
        case teams
        case players
        case referees
        case gameTime
        case movingTime
        case rounds
        case algorithm
        case duplicated
        case doubled
        case blanked
    }
    
  
    mutating func addPlayer(_ newPlayer : Player) {
        players.append(newPlayer)
    }
    
    mutating func removePlayer(_ oldPlayer : Player) {
        if let index = players.firstIndex(of: oldPlayer) {
                players.remove(at: index)
        }
    }
    
    mutating func addReferee(_ newReferee : Referee) {
        referees.append(newReferee)
    }
    
    mutating func removeReferee(_ oldReferee : Referee) {
        if let index = referees.firstIndex(of: oldReferee) {
                referees.remove(at: index)
        }
    }
    
    mutating func makeTeam(_ newTeam : Team) {
        teams.append(newTeam)
    }
    
    mutating func removeTeam(_ oldTeam : Team) {
        if let index = teams.firstIndex(of: oldTeam) {
                teams.remove(at: index)
        }
    }
    
    mutating func joinTeam(_ joiner : Player, _ joinee : Team) {
        if let index = teams.firstIndex(of: joinee) {
            teams[index].addPlayer(player: joiner)
        }
    }
    
    mutating func addStation(_ newStation : Station) {
        if newStation.pvp {
            self.countOfPVP += 1
        }
        stations.append(newStation)
    }
    
    mutating func removeStation(_ oldStation : Station) {
        if let index = stations.firstIndex(of: oldStation) {
                stations.remove(at: index)
        }
    }
    
    mutating func timer(_ gameTime : Int, _ movingTime : Int, _ rounds : Int) {
        self.gameTime = gameTime
        self.movingTime = movingTime
        self.rounds = rounds
    }
    
    mutating func givePoints(name : String, points : Int) {
        for i in 0...teams.count {
            if teams[i].name == name {
                teams[i].points += points
            }
        }
    }
    
//MARK: - Algorithm
    mutating func setAlgorithm(){
        sortStations()
        let columns = stations.count + countOfPVP
        algorithm = Array(repeating: Array(repeating: "-", count: columns), count: self.rounds)
        let size = teams.count
        let rows = min(self.rounds, size)
        let cols = min(columns, size)
        for r in 0...rows {
            for c in 0...cols {
                algorithm[r][c] = String((r+c+1)%size)
            }
        }
        for r in 0...rows {
            for c in 0...cols {
                hasDuplicatedStation(r, c)
                hasDoubleMatching(r, c)
            }
        }
    }
    
    //Cannot swap between rows
    mutating func swapElements(_ row : Int, _ col1 : Int , _ col2 : Int){
        let temp = algorithm[row][col1]
        algorithm[row][col1] = algorithm[row][col2]
        algorithm[row][col2] = temp
        hasDuplicatedStation(row, col1)
        hasDuplicatedStation(row, col2)
        hasDoubleMatching(row, col1)
        hasDoubleMatching(row, col2)
        hasBlank(row, col1)
        hasBlank(row, col2)
    }
    

    //checks if a team has duplicated station, if so put the element's indexes into duplicated
    mutating func hasDuplicatedStation(_ row : Int, _ col : Int) {
        let element = algorithm[row][col]
        if element  == "-" {
            return
        }
        var pvpCol = -1
        let rows = algorithm.count
 
        if col < countOfPVP * 2 {
            if col % 2 == 1{
                pvpCol = col - 1
            } else {
                pvpCol = col + 1
            }
        }
        
        for r in 0...rows {
            if r != row {
                if algorithm[r][col] == element {
                    duplicated.append([r, col])
                    duplicated.append([row, col])
                }
                if pvpCol >= 0 && algorithm[r][pvpCol] == element {
                    duplicated.append([r, pvpCol])
                    duplicated.append([row ,col])
                }
            }
        }
    }
    
    //checks if either team has double matching if so, put the element's indexes into doubled
    mutating func hasDoubleMatching(_ row : Int, _ col : Int){
        //if there is no pvp, if it is not a pvp, if its a blank do nothing
        if countOfPVP == 0 || countOfPVP*2 <= col || algorithm[row][col] == "-" {
            return
        }
        
        var pvpCol = -1
        if col % 2 == 1 {
            pvpCol = col - 1
        } else {
            pvpCol = col + 1
        }
        
        var check : [String] = [algorithm[row][col], algorithm[row][pvpCol]]
        check.sort()
        
        for r in 0...algorithm.count {
            if r != row {
                for c in 0...countOfPVP-1 {
                    var temp : [String] = []
                    let team1 = algorithm[r][c*2]
                    let team2 = algorithm[r][c*2+1]
                    if(team1 != "-" && team2 != "-"){
                        temp.append(team1)
                        temp.append(team2)
                        temp.sort()
                    }
                    if check == temp {
                        self.doubled.append([row,col])
                        self.doubled.append([row,pvpCol])
                        self.doubled.append([r,c*2])
                        self.doubled.append([r,c*2+1])
                    }
                }
            }
        }
    }
    
    //change an element value from Algorithm
    mutating func changeAlgorithm(_ row : Int, _ col : Int, value : String){
        algorithm[row][col] = value
        hasDuplicatedStation(row, col)
        hasDoubleMatching(row, col)
    }
    
    
    //need function of checking a blank opponent for pvp games
    mutating func hasBlank(_ row : Int, _ col : Int){
        if countOfPVP == 0 || countOfPVP*2 <= col {
            return
        }
        var pvpCol = -1
        if col % 2 == 1 {
            pvpCol = col - 1
        } else {
            pvpCol = col + 1
        }
        if algorithm[row][col] == "-" && algorithm[row][pvpCol] != "-" {
            self.blanked.append([row, col])
            self.blanked.append([row, pvpCol])
        }
        if algorithm[row][col] != "-" && algorithm[row][pvpCol] == "-" {
            self.blanked.append([row, col])
            self.blanked.append([row, pvpCol])
        }
    }
    
    //sorted by pvp, pve
    mutating func sortStations(){
        stations.sort { $0.pvp && !$1.pvp}
    }
    
    //need function change to blank
    //need to empty the arrays after swap process
}

