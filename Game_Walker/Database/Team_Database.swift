//
//  Team_Database.swift
//  Game_Walker
//
//  Created by Paul on 7/27/22.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift
import SwiftUI

struct T {
    static let db = Firestore.firestore()
    static var delegate_teamList: TeamList?
    static var delegate_getTeam: GetTeam?
    static var delegates : [TeamUpdateListener] = []
    
    static func listenTeams(_ gamecode: String, onListenerUpdate: @escaping ([String : Any]) -> Void) {
         db.collection("\(gamecode) : Teams").addSnapshotListener { querySnapshot, error in
             guard let documents = querySnapshot?.documents else { print("Error listening Teams"); return }
             var teams: [Team] = []
             for document in documents {
                 teams.append(convertDataToTeam(document.data()))
             }
             teams.sort{$0.points > $1.points}
            for delegate in delegates {
                delegate.updateTeams(teams)
            }
        }
    }
    
    static func addTeam(_ gamecode: String, _ team: Team) async {
        let docRef = db.collection("Servers").document("Gamecode : \(gamecode)")
        do {
            let document = try await docRef.getDocument()
            if document.exists {
                updateTeam(gamecode, team)
                print("Team added")
            } else {
                print("Gamecode does not exist")
            }
        } catch {
            print("Error adding Team: \(error)")
        }
    }
    
    static func removeTeam(_ gamecode: String, _ team: Team) {
        db.collection("\(gamecode) : Teams").document(team.name).delete() { err in
            if let err = err {
                print("Error removing Team: \(err)")
            } else {
                print("Team removed")
            }
        }
    }
    
    static func joinTeam(_ gamecode: String, _ teamName: String, _ player: Player) async {
        let docRef = db.collection("\(gamecode) : Teams").document(teamName)
        do {
            let document = try await docRef.getDocument()
            if document.exists {
                guard let data = document.data() else { return }
                var team = convertDataToTeam(data)
                team.players.append(player)
                // Update team member
                updateTeam(gamecode, team)
                print("Team joined")
            } else {
                print("Team does not exist")
            }
        } catch {
            print("Error joining Team: \(error)")
        }
    }
    
    static func leaveTeam(_ gamecode: String, _ teamName: String, _ player: Player) async {
        let docRef = db.collection("\(gamecode) : Teams").document(teamName)
        do {
            let document = try await docRef.getDocument()
            if document.exists {
                guard let data = document.data() else { return }
                var team = convertDataToTeam(data)
                if let index = team.players.firstIndex(of: player) {
                    team.players.remove(at: index)
                }
                updateTeam(gamecode, team)
                print("Left Team")
            } else {
                print("Team does not exist")
            }
        } catch {
            print("Error leaving team: \(error)")
        }
    }
    
    static func givePoints(_ gamecode: String, _ teamName: String, _ points: Int) async {
        let docRef = db.collection("\(gamecode) : Teams").document(teamName)
        do {
            let document = try await docRef.getDocument()
            if document.exists {
                guard let data = document.data() else { return }
                var team = convertDataToTeam(data)
                team.points += points
                updateTeam(gamecode, team)
            } else {
                print("Team does not exist")
            }
        } catch {
            print("Error giving points to Team: \(error)")
        }
    }
    
    static func updateStationOrder(_ gamecode: String, _ team: Team, _ stationOrder: [Int]) async {
        let docRef = db.collection("\(gamecode) : Stations").document(team.name)
        do {
            try await docRef.updateData([
                "stationOrder": stationOrder
            ])
            print("Staion Order updated")
        } catch {
            print("Error updating Station Order: \(error)")
        }
    }

    static func getTeam(_ gamecode: String, _ teamName : String) {
        let docRef = db.collection("\(gamecode) : Teams").document(teamName)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                guard let data = document.data() else {return}
                let team = convertDataToTeam(data)
                delegate_getTeam?.getTeam(team)
            } else {
                print("Error getting Team")
            }
        }
    }
    
    static func getTeamList(_ gamecode: String) {
        //sort by points
        db.collection("\(gamecode) : Teams")
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting List of Team: \(err)")
                } else {
                    var teams : [Team] = []
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        let team = convertDataToTeam(data)
                        teams.append(team)
                    }
                    teams.sort{$0.points > $1.points}
                    delegate_teamList?.listOfTeams(teams)
                }
        }
    }
    
    static func updateTeam(_ gamecode: String, _ team: Team) {
        do {
            try db.collection("\(gamecode) : Teams").document("\(team.name)").setData(from: team)
            print("Team successfully saved")
        } catch {
            print("Error updating Team: \(error)")
        }
    }
    
    static func convertDataToTeam(_ data : [String : Any]) -> Team {
        do {
            //convert Dictionary data to JSON data first
            let json = try JSONSerialization.data(withJSONObject: data)
            //decode the JSON data to object
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decoded = try decoder.decode(Team.self, from: json)
            return decoded
        } catch {
            print("Converting json data to Team \(error)")
        }
        //blank team
        return Team()
     }
}

