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
                 guard let document = documentSnapshot else { return }
                 guard let data = document.data() else { return }
                 var host = convertDataToHost(data)
                 for delegate in delegates {
                     delegate.updateHost(host)
                 }
            }
    }
    

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
    
    static func pause_resume_Game(_ gamecode: String){
        let docRef = db.collection("Servers").document("Gamecode : \(gamecode)")
        docRef.getDocument {(document, error) in
            if let document = document, document.exists {
                guard let data = document.data() else {return}
                var host = convertDataToHost(data)
                host.paused = !host.paused
                updateHost(gamecode, host)
            } else {
                print("Host does not exist")
            }
        }
    }
    
    static func addAnnouncement(_ gamecode: String, _ announcement: String){
        let docRef = db.collection("Servers").document("Gamecode : \(gamecode)")
        docRef.getDocument {(document, error) in
            if let document = document, document.exists {
                guard let data = document.data() else {return}
                var host = convertDataToHost(data)
                host.announcements.append(announcement)
                updateHost(gamecode, host)
            } else {
                print("Host does not exist")
            }
        }
    }
    
    static func modifyAnnouncement(_ gamecode: String, _ announcement: String, _ index : Int){
        let docRef = db.collection("Servers").document("Gamecode : \(gamecode)")
        docRef.getDocument {(document, error) in
            if let document = document, document.exists {
                guard let data = document.data() else {return}
                var host = convertDataToHost(data)
                host.announcements[index] = announcement
                updateHost(gamecode, host)
            } else {
                print("Host does not exist")
            }
        }
    }
    
    static func removeAnnouncement(_ gamecode: String, _ index : Int){
        let docRef = db.collection("Servers").document("Gamecode : \(gamecode)")
        docRef.getDocument {(document, error) in
            if let document = document, document.exists {
                guard let data = document.data() else {return}
                var host = convertDataToHost(data)
                host.announcements.remove(at: index)
                updateHost(gamecode, host)
            } else {
                print("Host does not exist")
            }
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
                print("Host does not exist")
            }
        }
    }
    
    static func updateHost(_ gamecode: String, _ host: Host){
        do {
            try db.collection("Servers").document("Gamecode : \(gamecode)").setData(from: host)
            print("Data sucessfully saved")
        } catch let error {
            print("Error writing to Firestore: \(error)")
        }
    }
    
    static func convertDataToHost(_ data : [String : Any]) -> Host {
        do {
            //convert Dictionary data to JSON data first
            let json = try JSONSerialization.data(withJSONObject: data)
            //decode the JSON data to object
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decoded = try decoder.decode(Host.self, from: json)
            return decoded
        } catch {
            print(error)
        }
        //blank team
        return Host()
     }

}
