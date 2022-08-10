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

struct K {
    
    static var gamecode : String = ""

    enum setupRequestType {
        case addPlayer, removePlayer, addReferee, removeReferee, addTeam, removeTeam, joinTeam, addStation, removeStation, timer
    }
    
    enum processRequestType {
        case givePoints
    }
    
    struct Database {
        static let db = Firestore.firestore()
        static var delegates : [DataUpdateListener] = []
        static var listener : ListenerRegistration?
        
        static func readHost(gamecode: String, onListenerUpdate: @escaping ([String : Any]) -> Void) {
            listener = db.collection("Server").document("Game : \(gamecode)").addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else { return }
                guard let data = document.data() else { return }
                let host = convertDataToHost(data)
                for delegate in delegates {
                    delegate.onDataUpdate(host)
                }
            }
        }
        

        static func getHost(gamecode: String) {
            let docRef = db.collection("Server").document("Game : \(gamecode)")
            docRef.getDocument(as: Host.self) { result in
                switch result {
                case .success(let host):
                    for delegate in delegates {
                        delegate.onDataUpdate(host)
                    }
                case .failure(let error):
                    print("Error decoding host: \(error)")
                }
            }
        }
        
        static func setupRequest(gamecode: String, player: Player? = nil, referee: Referee? = nil, team: Team? = nil, station: Station? = nil, gameTime: Int? = nil, movingTime: Int? = nil, rounds : Int? = nil, request: setupRequestType) {
            let docRef = db.collection("Server").document("Game : \(gamecode)")
            var nextHost: Host?
            docRef.getDocument(as: Host.self) { result in
                switch result {
                case .success(let host):
                    nextHost = host
                    guard var nextHost = nextHost else {
                        return
                    }
                    switch request {
                    case .addPlayer :
                        nextHost.addPlayer(player!)
                    case .removePlayer :
                        nextHost.removePlayer(player!)
                    case .addReferee:
                        nextHost.addReferee(referee!)
                    case .removeReferee:
                        nextHost.removeReferee(referee!)
                    case .addTeam:
                        nextHost.makeTeam(team!)
                    case .removeTeam:
                        nextHost.removeTeam(team!)
                    case .joinTeam:
                        nextHost.joinTeam(player!, team!)
                    case .addStation:
                        nextHost.addStation(station!)
                    case .removeStation:
                        nextHost.removeStation(station!)
                    case .timer:
                        nextHost.timer(gameTime!, movingTime!, rounds!)
                    }
                    print(nextHost)
                    K.Database.updateHost(nextHost)
                    
                case .failure(let error):
                    print("Error decoding host: \(error)")
                }
            }
        }
        
        
        
        
        static func processUpdateRequest(gamecode: String, teamname: String, points: Int, requestType: processRequestType) {
            let docRef = db.collection("Server").document("Game : \(gamecode)")
            var nextHost: Host?
            docRef.getDocument(as: Host.self) { result in
                switch result {
                case .success(let host):
                    nextHost = host
                case .failure(let error):
                    print("Error decoding host: \(error)")
                }
            }
            guard let nextHost = nextHost else {
                return
            }
            

        }
            
       static func convertDataToHost(_ data : [String : Any]) -> Host {
           do {
               //convert Dictionary data to JSON data first
               let json = try JSONSerialization.data(withJSONObject: data)
               //decode the JSON data to Host object
               let decoder = JSONDecoder()
               decoder.keyDecodingStrategy = .convertFromSnakeCase
               let decoded = try decoder.decode(Host.self, from: json)
               return decoded
           } catch {
               print(error)
           }
           //blank host
           return Host()
        }
        
        static func updateHost(_ host : Host) {
            do {
                try db.collection("Server").document("Game : \(host.gamecode)").setData(from: host)
                print("Data sucessfully saved")
            } catch let error {
                print("Error writing to Firestore: \(error)")
            }
        }
        
        static func createGame(_ gamecode: String, _ host: Host2) {
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
}
