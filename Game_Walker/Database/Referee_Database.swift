//
//  Referee_Database.swift
//  Game_Walker
//
//  Created by Paul on 7/26/22.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift
import SwiftUI

struct R {
    static let db = Firestore.firestore()
    static var delegate_refereeList: RefereeList?
    static var delegate_getReferee: GetReferee?
    static var delegates : [RefereeUpdateListener] = []
    
    static func listenReferee(_ gamecode: String, _ uuid: String, onListenerUpdate: @escaping ([String : Any]) -> Void) {
        db.collection("\(gamecode) : Referees").document(uuid).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else { return }
            guard let data = document.data() else { return }
            let ref = convertDataToReferee(data)
            for delegate in delegates {
                delegate.updateReferee(ref)
            }
       }
    }

    static func addReferee(_ gamecode: String, _ referee: Referee, _ uuid: String){
        let docRef = db.collection("Servers").document("Gamecode : \(gamecode)")
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                do {
                    try db.collection("\(gamecode) : Referees").document(uuid).setData(from: referee)
                    print("Referee sucessfully saved")
                } catch let error {
                    print("Error writing to Firestore: \(error)")
                }
            } else {
                print("Gamecode does not exist")
            }
        }
    }
    
    static func removeReferee(_ gamecode: String, _ uuid: String){
        db.collection("\(gamecode) : Referees").document(uuid).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Referee Document successfully removed!")
            }
        }
    }
    
    static func modifyName(_ gamecode: String, _ uuid : String, _ name: String){
        let server = db.collection("\(gamecode) : Referees").document(uuid)
        server.updateData([
            "name": name
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
        
    static func assignStation(_ gamecode: String, _ uuid: String, _ stationName: String, _ assigned: Bool){
        let refDoc = db.collection("\(gamecode) : Referees").document(uuid)
        refDoc.updateData([
            "stationName": stationName,
            "assigned": assigned
        ]){ err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Referee Document successfully updated")
            }
        }
    }
    
//    static func unassignStation(_ gamecode: String, _ uuid : String){
//        let server = db.collection("\(gamecode) : Referees").document(uuid)
//        server.updateData([
//            "assigned" : false,
//            "stationName" : ""
//        ]) { err in
//            if let err = err {
//                print("Error updating document: \(err)")
//            } else {
//                print("Document successfully updated")
//            }
//        }
//    }
    
    
    static func getReferee(_ gamecode: String, _ uuid : String){
        let docRef = db.collection("\(gamecode) : Referees").document(uuid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                guard let data = document.data() else {return}
                let referee = convertDataToReferee(data)
                delegate_getReferee?.getReferee(referee)
            } else {
                print("Document does not exist")
            }
        }
    }
    
    
    //Only Unassigned Referees List
    static func getRefereeList(_ gamecode: String){
        db.collection("\(gamecode) : Referees").whereField("assigned", isEqualTo: false)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    var referees : [Referee] = []
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        let referee = convertDataToReferee(data)
                        referees.append(referee)
                    }
                    delegate_refereeList?.listOfReferees(referees)
                }
        }
    }
    
    static func convertDataToReferee(_ data : [String : Any]) -> Referee {
        do {
            //convert Dictionary data to JSON data first
            let json = try JSONSerialization.data(withJSONObject: data)
            //decode the JSON data to object
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decoded = try decoder.decode(Referee.self, from: json)
            return decoded
        } catch {
            print(error)
        }
        //blank host
        return Referee()
     }
    
    
    
    
}
