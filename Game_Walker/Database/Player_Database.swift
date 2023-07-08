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
        
    static func addPlayer(_ gamecode: String, _ player: Player, _ uuid: String) async throws {
        let docRef = db.collection("Servers").document("Gamecode : \(gamecode)")
        do {
            let document = try await docRef.getDocument()
            if document.exists {
                try await db.collection("\(gamecode) : Players").document(uuid).setData(from: player)
                print("Player added")
            } else {
                print("Gamecode does not exist")
                //throw error
            }
        } catch {
            print("Error adding Player: \(error)")
            throw error
        }
    }
    
//    //to delete
//    static func addPlayer2(_ gamecode: String, _ player: Player, _ uuid: String){
//            let docRef = db.collection("Servers").document("Gamecode : \(gamecode)")
//            docRef.getDocument { (document, error) in
//                if let document = document, document.exists {
//                    do {
//                        try db.collection("\(gamecode) : Players").document(uuid).setData(from: player)
//                        print("Player sucessfully saved")
//                    } catch let error {
//                        print("Error writing to Firestore: \(error)")
//                    }
//                } else {
//                    print("Gamecode does not exist")
//                }
//            }
//        }
        
    static func removePlayer(_ gamecode: String, _ uuid: String){
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
            throw error
        }
    }
    
}
