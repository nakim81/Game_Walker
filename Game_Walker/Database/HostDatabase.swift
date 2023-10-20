//
//  Constants.swift
//  Game_Walker
//
//  Created by Paul on 6/15/22.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift
import SwiftUI

struct H {
    
    static let db = Firestore.firestore()
    static var delegates : [HostUpdateListener] = []
    
    //MARK: - Game Control Functions
    
    static func createGame(_ gamecode: String, _ host: Host) throws {
        do {
            try db.collection("Servers").document("Gamecode : \(gamecode)").setData(from: host)
            print("Created Game")
        } catch {
            print("Error creating Game: \(error)")
            throw GameWalkerError.serverError("Something went wrong while creating Host")
        }
    }
    
    static func completeStations(_ gamecode: String, _ finished: Bool) async throws {
        let server = db.collection("Servers").document("Gamecode : \(gamecode)")
        do {
            try await server.updateData([
                "confirmStations": finished
            ])
            print("Stations complete!")
        } catch {
            print("Error completing stations: \(error)")
            throw GameWalkerError.serverError("Something went wrong while completing Stations")
        }
    }
    
    static func setSettings(_ gamecode: String, _ gameTime: Int, _ movingTime: Int, _ rounds: Int, _ teams: Int) async throws {
        let server = db.collection("Servers").document("Gamecode : \(gamecode)")
        do {
            try await server.updateData([
                "gameTime": gameTime,
                "movingTime": movingTime,
                "rounds": rounds,
                "teams": teams
            ])
            print("Host setted Settings")
        } catch {
            print("Error setting settings Host: \(error)")
            throw GameWalkerError.serverError("Something went wrong while setting Settings")
        }
    }
    
    static func setAlgorithm(_ gamecode: String, _ algorithm: [Int]) async throws {
        let docRef = db.collection("Servers").document("Gamecode : \(gamecode)")
        do {
            let document = try await docRef.getDocument()
            if document.exists {
                guard let data = document.data() else { return }
                var host = convertDataToHost(data)
                host.algorithm = algorithm
                updateHost(gamecode, host)
                print("Setted Algorithm")
            } else {
                print("Host does not exist")
                throw GameWalkerError.serverError("Something went wrong while setting Algorithm")
            }
        } catch {
            print("Error setting Algorithm Host: \(error)")
            throw GameWalkerError.serverError("Something went wrong while setting Algorithm")
        }
    }
    
    static func startGame(_ gamecode: String) async throws {
        let server = db.collection("Servers").document("Gamecode : \(gamecode)")
        do {
            try await server.updateData([
                "startTimestamp": Int(Date().timeIntervalSince1970),
                "paused": false,
                "gameStart": true
            ])
            print("Started Game")
        } catch {
            print("Error starting Game: \(error)")
            throw GameWalkerError.serverError("Something went wrong while starting Game")
        }
    }
    
    static func pause_resume_game(_ gamecode: String) async throws {
        let docRef = db.collection("Servers").document("Gamecode : \(gamecode)")
        do {
            let document = try await docRef.getDocument()
            if document.exists {
                guard let data = document.data() else { return }
                var host = convertDataToHost(data)
                // When resuming
                if host.paused {
                    let currentTime = Int(Date().timeIntervalSince1970)
                    host.pausedTime += (currentTime - host.pauseTimestamp)
                }
                // When pausing
                else {
                    host.pauseTimestamp = Int(Date().timeIntervalSince1970)
                }
                host.paused = !host.paused
                updateHost(gamecode, host)
                print("Paused/Resumed Game")
            } else {
                print("Host does not exist")
                throw GameWalkerError.serverError("Something went wrong while pauseing/resuming Game")
            }
        } catch {
            print("Error pausing/resuming Game: \(error)")
            throw GameWalkerError.serverError("Something went wrong while pauseing/resuming Game")
        }
    }
    
    static func endGame(_ gamecode: String) async throws {
        let server = db.collection("Servers").document("Gamecode : \(gamecode)")
        do {
            try await server.updateData([
                "gameover": true
            ])
            print("End Game")
        } catch {
            print("Error ending Game: \(error)")
            throw GameWalkerError.serverError("Something went wrong while ending Host")
        }
    }
    
    static func updateCurrentRound(_ gamecode: String, _ currentRound: Int) async throws {
        let server = db.collection("Servers").document("Gamecode : \(gamecode)")
        do {
            try await server.updateData([
                "currentRound": currentRound
            ])
            print("Updated Current Round")
        } catch {
            print("Error updating Current Round: \(error)")
            throw GameWalkerError.serverError("Something went wrong while updating Current Round")
        }
    }
    
    // Needed for Resetting Time Case
    static func updatePausedTime(_ gamecode: String, _ pausedTime: Int) async throws {
        let server = db.collection("Servers").document("Gamecode : \(gamecode)")
        do {
            try await server.updateData([
                "pausedTime": pausedTime
            ])
            print("Updated Paused Time")
        } catch {
            print("Error updating Paused Time: \(error)")
            throw GameWalkerError.serverError("Something went wrong while updating Paused Time")
        }
    }
    
    //if show is true, everyone can see the score; if false, only the players cannot see their team score (refs and host can)
    static func hide_show_score(_ gamecode: String, _ show: Bool) async throws {
        let server = db.collection("Servers").document("Gamecode : \(gamecode)")
        do {
            try await server.updateData([
                "showScoreboard": show
            ])
            print("Hid/Showed Score")
        } catch {
            print("Error hiding/showing score: \(error)")
            throw GameWalkerError.serverError("Something went wrong while hiding/showing Score")
        }
    }
    
    //MARK: - Announcment Functions
    
    static func addAnnouncement(_ gamecode: String, _ announcement: Announcement) async throws {
        let docRef = db.collection("Servers").document("Gamecode : \(gamecode)")
        do {
            let document = try await docRef.getDocument()
            if document.exists {
                guard let data = document.data() else { return }
                var host = convertDataToHost(data)
                host.announcements.append(announcement)
                updateHost(gamecode, host)
                print("Added Announcement")
            } else {
                print("Host does not exist")
                throw GameWalkerError.serverError("Something went wrong while adding Announcement")
            }
        } catch {
            print("Error adding Announcement: \(error)")
            throw GameWalkerError.serverError("Something went wrong while adding Announcement")
        }
    }
    
    static func modifyAnnouncement(_ gamecode: String, _ announcement: Announcement, _ index: Int) async throws {
        let docRef = db.collection("Servers").document("Gamecode : \(gamecode)")
        do {
            let document = try await docRef.getDocument()
            if document.exists {
                guard let data = document.data() else { return }
                var host = convertDataToHost(data)
                if index >= 0 && index < host.announcements.count {
                    host.announcements[index] = announcement
                    updateHost(gamecode, host)
                    print("Modified Announcement")
                } else {
                    print("Invalid index of announcement")
                    throw GameWalkerError.serverError("Wrong index while modifying Announcement")
                }
            } else {
                print("Host does not exist")
                throw GameWalkerError.serverError("Something went wrong while modifying Announcement")
            }
        } catch {
            print("Error modfiying Announcement: \(error)")
            throw GameWalkerError.serverError("Something went wrong while modifying Announcement")
        }
    }
    
    static func removeAnnouncement(_ gamecode: String, _ index: Int) async throws {
        let docRef = db.collection("Servers").document("Gamecode : \(gamecode)")
        do {
            let document = try await docRef.getDocument()
            if document.exists {
                guard let data = document.data() else { return }
                var host = convertDataToHost(data)
                if index >= 0 && index < host.announcements.count {
                    host.announcements.remove(at: index)
                    updateHost(gamecode, host)
                    print("Removed Announcement")
                } else {
                    print("Invalid announcement index")
                    throw GameWalkerError.serverError("Wrong index while removing Announcement")
                }
            } else {
                print("Host does not exist")
                throw GameWalkerError.serverError("Something went wrong while removing Announcement")
            }
        } catch {
            print("Error removing Announcement: \(error)")
            throw GameWalkerError.serverError("Something went wrong while removing Announcement")
        }
    }
    
    //MARK: - Database Functions
    
    static func listenHost(_ gamecode: String, onListenerUpdate: @escaping ([String : Any]) -> Void) {
        db.collection("Servers").document("Gamecode : \(gamecode)").addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else { print("Error listening Host"); return }
            guard let data = document.data() else { print("Error listening Host"); return }
            let host = convertDataToHost(data)
            for delegate in delegates {
                delegate.updateHost(host)
            }
        }
    }
    
    static func getHost(_ gamecode: String) async throws -> Host? {
        let docRef = db.collection("Servers").document("Gamecode : \(gamecode)")
        do {
            let document = try await docRef.getDocument()
            if document.exists {
                guard let data = document.data() else { return nil }
                let host = convertDataToHost(data)
                return host
            } else {
                print("Error getting Host by Gamecode")
                throw GameWalkerError.invalidGamecode("\(gamecode) is not an existing gamecode. \n Please check again!")
            }
        } catch {
            print("Error getting Host")
            throw GameWalkerError.serverError("Something went wrong while getting Host")
        }
    }


    static func updateHost(_ gamecode: String, _ host: Host) {
        do {
            try db.collection("Servers").document("Gamecode : \(gamecode)").setData(from: host)
        } catch {
            print("Error updating Host: \(error)")
        }
    }
    
    static func convertDataToHost(_ data : [String : Any]) -> Host {
        do {
            //convert Dictionary data to JSON data first
            let json = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            //decode the JSON data to object
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let host = try decoder.decode(Host.self, from: json)
            return host
        } catch {
            print("Converting json data to Host \(error)")
        }
        //blank team
        return Host()
    }
}
