//
//  Referee_Database.swift
//  Game_Walker
//
//  Created by Paul on 7/26/22.
//

import Foundation

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift
import SwiftUI

struct R {
        static let db = Firestore.firestore()
    
        static func addReferee(_ gamecode: String, _ referee: Referee){
            let docRef = db.collection("Servers").document("Gamecode : \(gamecode)")
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    do {
                        try db.collection("\(gamecode) : Referees").document("\(referee.name)").setData(from: referee)
                        print("Referee sucessfully saved")
                    } catch let error {
                        print("Error writing to Firestore: \(error)")
                    }
                } else {
                    print("Gamecode does not exist")
                }
            }
        }
        
        static func removeReferee(_ gamecode: String, _ referee: Referee){
            db.collection("\(gamecode) : Referees").document("\(referee.name)").delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Referee Document successfully removed!")
                }
            }
        }
        
        static func assignStation(_ gamecode: String, _ referee: Referee, _ station: Station){
            let refDoc = db.collection("\(gamecode) : Referees").document("\(referee.name)")
            refDoc.updateData([
                "station": station.name
            ]){ err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Referee Document successfully updated")
                }
            }
            
        }
}
