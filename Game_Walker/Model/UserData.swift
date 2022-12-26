//
//  UserData.swift
//  Game_Walker
//
//  Created by Noah Kim on 7/20/22.
//

import Foundation

class UserData {
    static func writeUserData(_ player: Player, _ key: String){
        do{
            let encoder = JSONEncoder()
            let data = try encoder.encode(player)
            UserDefaults.standard.set(data, forKey: key)
        }
        catch{
            print("Unable to Encode Player (\(error))")
        }
    }
    
    static func readUserData(_ key: String) -> Player? {
        if let data = UserDefaults.standard.data(forKey: key) {
            do {
                let decoder = JSONDecoder()
                let player = try decoder.decode(Player.self, from: data)
                return player
            } catch {
                print("Unable to Decode Player (\(error))")
            }
        }
        return nil
    }
    
    static func writeUserData(_ team: Team, _ key: String){
        do{
            let encoder = JSONEncoder()
            let data = try encoder.encode(team)
            UserDefaults.standard.set(data, forKey: key)
        }
        catch{
            print("Unable to Encode Team (\(error))")
        }
    }
    
    static func readUserData(_ key: String) -> Team? {
        if let data = UserDefaults.standard.data(forKey: key) {
            do {
                let decoder = JSONDecoder()
                let team = try decoder.decode(Team.self, from: data)
                return team
            } catch {
                print("Unable to Decode Team (\(error))")
            }
        }
        return nil
    }
}
