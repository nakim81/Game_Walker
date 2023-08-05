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
    static var delegate_getHost: GetHost?
    static var delegates : [HostUpdateListener] = []
    
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
    
    static func createGame(_ gamecode: String, _ host: Host) {
        do {
            try db.collection("Servers").document("Gamecode : \(gamecode)").setData(from: host)
            print("Created Game")
        } catch {
            print("Error creating Game: \(error)")
        }
    }
    
    static func setSettings(_ gamecode: String, _ gameTime: Int, _ movingTime: Int, _ rounds: Int, _ teams: Int) async {
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
        }
    }
    
    static func startGame(_ gamecode: String) async {
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
        }
    }
    
    
    //if show is true, everyone can see the score; if false, only the players cannot see their team score (refs and host can)
     static func hide_show_score(_ gamecode: String, _ show: Bool) async {
        let server = db.collection("Servers").document("Gamecode : \(gamecode)")
        do {
            try await server.updateData([
                "showScoreboard": show
            ])
            print("Hid/Showed Score")
        } catch {
            print("Error hiding/showing score: \(error)")
        }
    }
    
    static func pause_resume_game(_ gamecode: String) async {
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
            }
        } catch {
            print("Error pausing/resuming Game: \(error)")
        }
    }
    
    static func updateCurrentRound(_ gamecode: String, _ currentRound: Int) async {
        let server = db.collection("Servers").document("Gamecode : \(gamecode)")
        do {
            try await server.updateData([
                "currentRound": currentRound
            ])
            print("Updated Current Round")
        } catch {
            print("Error updating Current Round: \(error)")
        }
    }
     
    static func addAnnouncement(_ gamecode: String, _ announcement: String) async {
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
            }
        } catch {
            print("Error adding Announcement: \(error)")
        }
    }
    
    static func modifyAnnouncement(_ gamecode: String, _ announcement: String, _ index: Int) async {
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
                }
            } else {
                print("Host does not exist")
            }
        } catch {
            print("Error modfiying Announcement: \(error)")
        }
    }
    
    static func removeAnnouncement(_ gamecode: String, _ index: Int) async {
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
                }
            } else {
                print("Host does not exist")
            }
        } catch {
            print("Error removing Announcement: \(error)")
        }
    }
    
    static func getHost(_ gamecode: String){
        let docRef = db.collection("Servers").document("Gamecode : \(gamecode)")
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                guard let data = document.data() else {return}
                let host = convertDataToHost(data)
                delegate_getHost?.getHost(host)
            } else {
                print("Error getting Host")
            }
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
