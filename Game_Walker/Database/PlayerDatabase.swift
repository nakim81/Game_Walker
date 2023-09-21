//
//  Constants_New.swift
//  Game_Walker
//
//  Created by Paul on 7/25/22.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift
import SwiftUI


struct P {
    
    static let db = Firestore.firestore()
    
    //MARK: - Player Control Functions
    
    static func addPlayer(_ gamecode: String, _ player: Player, _ uuid: String) async throws {
        let docRef = db.collection("Servers").document("Gamecode : \(gamecode)")
        do {
            let document = try await docRef.getDocument()
            if document.exists {
                try db.collection("\(gamecode) : Players").document(uuid).setData(from: player)
                print("Player added")
            } else {
                print("Gamecode does not exist")
                throw GameWalkerError.invalidGamecode("\(gamecode) is not an existing gamecode.\nPlease check again!")
            }
        } catch GameWalkerError.invalidGamecode(let message) {
            throw GameWalkerError.invalidGamecode(message)
        } catch {
            print("Error adding Player: \(error)")
            throw GameWalkerError.serverError("Something went wrong while adding Player")
        }
    }
    
    static func removePlayer(_ gamecode: String, _ uuid: String) {
        db.collection("\(gamecode) : Players").document(uuid).delete() { err in
            if let err = err {
                print("Error removing player: \(err)")
            } else {
                print("Player removed")
            }
        }
    }
    
    static func modifyName(_ gamecode: String, _ uuid: String, _ name: String) async throws {
        do {
            let server = db.collection("\(gamecode) : Players").document(uuid)
            try await server.updateData([
                "name": name
            ])
            print("Player name modified")
        } catch {
            print("Error modifying Player name: \(error)")
            throw GameWalkerError.serverError("Something went wrong while modifying Player Name")
        }
    }
    
}
