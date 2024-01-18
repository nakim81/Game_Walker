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
    static var delegates : [WeakTeamUpdateListener] = []
    
    //MARK: - Team Control Functions
    
    static func addTeam(_ gamecode: String, _ team: Team) async throws {
        let docRef = db.collection("Servers").document("Gamecode : \(gamecode)")
        do {
            let document = try await docRef.getDocument()
            if document.exists {
                // Check if the team number already exists
                var existingTeams = try await getTeamList(gamecode)
                if existingTeams.contains(where: { $0.number == team.number }) {
                    throw GameWalkerError.teamNumberAlreadyExists(NSLocalizedString("Team number \(team.number) already exists.", comment: ""))
                }
                updateTeam(gamecode, team)
                print("Team added.")
            } else {
                print("Gamecode does not exist.")
                let errorMessage = NSLocalizedString("%@ is not an existing gamecode.\nPlease check again!", comment: "")
                let formattedErrorMessage = String.localizedStringWithFormat(errorMessage, gamecode)
                throw GameWalkerError.invalidGamecode(formattedErrorMessage)
            }
        } catch {
            if case GameWalkerError.teamNumberAlreadyExists = error {
                throw error
            }
            print("Error adding Team: \(error).")
            throw GameWalkerError.serverError(NSLocalizedString("Something went wrong while adding Team.", comment: ""))
        }
    }
    
    static func removeTeam(_ gamecode: String, _ team: Team) {
        db.collection("\(gamecode) : Teams").document(team.name).delete() { err in
            if let err = err {
                print("Error removing Team: \(err).")
            } else {
                print("Team removed.")
            }
        }
    }
    
    static func joinTeam(_ gamecode: String, _ teamName: String, _ player: Player) async throws {
        let docRef = db.collection("\(gamecode) : Teams").document(teamName)
        do {
            let document = try await docRef.getDocument()
            if document.exists {
                guard let data = document.data() else { return }
                var team = convertDataToTeam(data)
                team.players.append(player)
                // Update team member
                updateTeam(gamecode, team)
                print("Team joined.")
            } else {
                print("Team does not exist.")
                throw GameWalkerError.serverError(NSLocalizedString("Something went wrong while joining Team.", comment: ""))
            }
        } catch {
            print("Error joining Team: \(error).")
            throw GameWalkerError.serverError(NSLocalizedString("Something went wrong while joining Team.", comment: ""))
        }
    }
    
    static func leaveTeam(_ gamecode: String, _ teamName: String, _ player: Player) async throws {
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
                print("Left Team.")
            } else {
                print("Team does not exist.")
                throw GameWalkerError.serverError(NSLocalizedString("Something went wrong while leaving Team.", comment: ""))
            }
        } catch {
            print("Error leaving team: \(error).")
            throw GameWalkerError.serverError(NSLocalizedString("Something went wrong while leaving Team.", comment: ""))
        }
    }
    
    static func givePoints(_ gamecode: String, _ teamName: String, _ points: Int) async throws {
        let docRef = db.collection("\(gamecode) : Teams").document(teamName)
        do {
            let document = try await docRef.getDocument()
            if document.exists {
                guard let data = document.data() else { return }
                var team = convertDataToTeam(data)
                team.points += points
                updateTeam(gamecode, team)
            } else {
                print("Team does not exist.")
                throw GameWalkerError.serverError(NSLocalizedString("Something went wrong while giving points to a Team.", comment: ""))
            }
        } catch {
            print("Error giving points to Team: \(error).")
            throw GameWalkerError.serverError(NSLocalizedString("Something went wrong while giving points to a Team.", comment: ""))
        }
    }
    
    static func updateStationOrder(_ gamecode: String, _ team: Team, _ stationOrder: [Int]) async throws{
        let docRef = db.collection("\(gamecode) : Teams").document(team.name)
        do {
            try await docRef.updateData([
                "stationOrder": stationOrder
            ])
            print("Updated Station Order.")
        } catch {
            print("Error updating Station Order: \(error).")
            throw GameWalkerError.serverError(NSLocalizedString("Something went wrong while updating Station order.", comment: ""))
        }
    }
    
    //MARK: - Database Functions
    
    static func listenTeams(_ gamecode: String, onListenerUpdate: @escaping ([String : Any]) -> Void) {
        db.collection("\(gamecode) : Teams").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else { print("Error listening Teams"); return }
            var teams: [Team] = []
            for document in documents {
                teams.append(convertDataToTeam(document.data()))
            }
            teams.sort{$0.points > $1.points}
            for delegate in delegates {
                delegate.value?.updateTeams(teams)
            }
        }
    }
    
    static func getTeam(_ gamecode: String, _ teamName: String) async throws -> Team? {
        let docRef = db.collection("\(gamecode) : Teams").document(teamName)
        let document = try await docRef.getDocument()
        if document.exists {
            guard let data = document.data() else { return nil }
            let team = convertDataToTeam(data)
            return team
        } else {
            print("Error getting Team.")
            throw GameWalkerError.serverError(NSLocalizedString("Something went wrong while getting Team.", comment: ""))
        }
    }
    
    static func getTeamList(_ gamecode: String) async throws -> [Team] {
        do{
            let querySnapshot = try await db.collection("\(gamecode) : Teams").getDocuments()
            var teams: [Team] = []
            
            for document in querySnapshot.documents {
                let data = document.data()
                let team = convertDataToTeam(data)
                teams.append(team)
            }
            teams.sort { (team1, team2) in
                if team1.points != team2.points {
                    return team1.points > team2.points
                } else {
                    return team1.number < team2.number
                }
            }
            return teams
        }
        catch {
            print("Error getting TeamList.")
            throw GameWalkerError.serverError(NSLocalizedString("Something went wrong while getting TeamList.", comment: ""))
        }
    }
    
    static func updateTeam(_ gamecode: String, _ team: Team) {
        do {
            try db.collection("\(gamecode) : Teams").document("\(team.name)").setData(from: team)
            print("Team successfully saved.")
        } catch {
            print("Error updating Team: \(error).")
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
            print("Converting json data to Team \(error).")
        }
        //blank team
        return Team()
    }
}
