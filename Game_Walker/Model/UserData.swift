//
//  UserData.swift
//  Game_Walker
//
//  Created by Paul on 7/20/22.
//

import Foundation

class UserData {
    
    static func setStandardStyle(_ standardStyle: Bool) {
        UserDefaults.standard.set(standardStyle, forKey: "standardstyle")
    }
    
    static func isStandardStyle() -> Bool {
        return UserDefaults.standard.bool(forKey: "standardstyle")
    }
    
    static func confirmHost(_ confirmed: Bool) {
        UserDefaults.standard.set(confirmed, forKey: "hostconfirm")
    }
    
    static func isHostConfirmed() -> Bool? {
        return UserDefaults.standard.bool(forKey: "hostconfirm")
    }
    
    static func writeUUID(_ uuid: String){
        UserDefaults.standard.set(uuid, forKey: "uuid")
    }
    
    static func readUUID() -> String? {
        return UserDefaults.standard.string(forKey: "uuid")
    }
    
    static func writeGamecode(_ gamecode: String, _ key: String){
        UserDefaults.standard.set(gamecode, forKey: key)
    }
    
    static func readGamecode(_ key: String) -> String? {
        return UserDefaults.standard.string(forKey: key)
    }
    
    static func writeUsername(_ username: String, _ key: String){
        UserDefaults.standard.set(username, forKey: key)
    }
    
    static func readUsername(_ key: String) -> String? {
        return UserDefaults.standard.string(forKey: key)
    }
    
    static func writeMax(_ max: String, _ key: String){
        UserDefaults.standard.set(max, forKey: key)
    }
    
    static func readMax(_ key: String) -> String? {
        return UserDefaults.standard.string(forKey: key)
    }
    
    static func writePlayer(_ player: Player, _ key: String){
        do{
            let encoder = JSONEncoder()
            let data = try encoder.encode(player)
            UserDefaults.standard.set(data, forKey: key)
        }
        catch{
            print("Unable to Encode Player (\(error))")
        }
    }
    
    static func readPlayer(_ key: String) -> Player? {
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
    
    static func writeTeam(_ team: Team, _ key: String){
        do{
            let encoder = JSONEncoder()
            let data = try encoder.encode(team)
            UserDefaults.standard.set(data, forKey: key)
        }
        catch{
            print("Unable to Encode Team (\(error))")
        }
    }
    
    static func clearMyTeam(_ key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    static func readTeam(_ key: String) -> Team? {
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
    
    static func writeReferee(_ referee: Referee, _ key: String){
        do{
            let encoder = JSONEncoder()
            let data = try encoder.encode(referee)
            UserDefaults.standard.set(data, forKey: key)
        }
        catch{
            print("Unable to Encode Referee (\(error))")
        }
    }
    
    static func readReferee(_ key: String) -> Referee? {
        if let data = UserDefaults.standard.data(forKey: key) {
            do {
                let decoder = JSONDecoder()
                let referee = try decoder.decode(Referee.self, from: data)
                return referee
            } catch {
                print("Unable to Decode Referee (\(error))")
            }
        }
        return nil
    }
}
