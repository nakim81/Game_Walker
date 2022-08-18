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

    static func createGame(_ gamecode: String, _ host: Host) {
        //gamecode validation through servers
        do {
            try db.collection("Servers").document("Gamecode : \(gamecode)").setData(from: host)
            print("Data sucessfully saved")
        } catch let error {
            print("Error writing to Firestore: \(error)")
        }
    }
    
    static func setTimer(_ gamecode: String, _ gameTime: Int, _ movingTime: Int, _ rounds: Int){
        let server = db.collection("Servers").document("Gamecode : \(gamecode)")
        server.updateData([
            "gameTime": gameTime,
            "movingTime": movingTime,
            "rounds": rounds
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }

}
