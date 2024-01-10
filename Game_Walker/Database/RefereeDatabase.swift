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
    static var delegates : [WeakRefereeUpdateListener] = []
    
    //MARK: - Referee Control Functions
    
    static func addReferee(_ gamecode: String, _ referee: Referee, _ uuid: String) async throws {
        let docRef = db.collection("Servers").document("Gamecode : \(gamecode)")
        do {
            let document = try await docRef.getDocument()
            if document.exists {
                try db.collection("\(gamecode) : Referees").document(uuid).setData(from: referee)
                print("Referee added")
            } else {
                print("Gamecode does not exist")
                let errorMessage = NSLocalizedString("%@ is not an existing gamecode.\nPlease check again!", comment: "")
                let formattedErrorMessage = String.localizedStringWithFormat(errorMessage, gamecode)
                throw GameWalkerError.invalidGamecode(formattedErrorMessage)
            }
        } catch GameWalkerError.invalidGamecode(let message) {
            throw GameWalkerError.invalidGamecode(message)
        } catch {
            print("Error adding Referee: \(error)")
            throw GameWalkerError.serverError(NSLocalizedString("Something went wrong while adding Referee", comment: ""))
        }
    }
    
    static func removeReferee(_ gamecode: String, _ uuid: String) {
        db.collection("\(gamecode) : Referees").document(uuid).delete() { err in
            if let err = err {
                print("Error removing Referee: \(err)")
            } else {
                print("Referee removed")
            }
        }
    }
    
    static func modifyName(_ gamecode: String, _ uuid: String, _ name: String) async throws {
        let server = db.collection("\(gamecode) : Referees").document(uuid)
        do {
            try await server.updateData([
                "name": name
            ])
            print("Referee name modified")
        } catch {
            print("Gamecode does not exist")
            throw GameWalkerError.serverError(NSLocalizedString("Something went wrong while modifying Referee", comment: ""))
        }
    }
    
    
    static func assignStation(_ gamecode: String, _ uuid: String, _ stationName: String, _ assigned: Bool) async throws {
        let refDoc = db.collection("\(gamecode) : Referees").document(uuid)
        do {
            try await refDoc.updateData([
                "stationName": stationName,
                "assigned": assigned
            ])
            print("Referee assigned station")
        } catch {
            print("Error assigning Referee a station: \(error)")
            throw GameWalkerError.serverError(NSLocalizedString("Something went wrong while assigning Referee", comment: ""))
        }
    }
    
    //MARK: - Database Functions
    
    static func listenReferee(_ gamecode: String, _ uuid: String, onListenerUpdate: @escaping ([String : Any]) -> Void) {
        db.collection("\(gamecode) : Referees").document(uuid).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else { return }
            guard let data = document.data() else { return }
            let ref = convertDataToReferee(data)
            for delegate in delegates {
                delegate.value?.updateReferee(ref)
            }
        }
    }
    
    static func getReferee(_ gamecode: String, _ uuid: String) async throws -> Referee? {
        let docRef = db.collection("\(gamecode) : Referees").document(uuid)
        let document = try await docRef.getDocument()
        if document.exists {
            guard let data = document.data() else { return nil }
            let referee = convertDataToReferee(data)
            return referee
        } else {
            print("Error in getting Referee")
            throw GameWalkerError.serverError(NSLocalizedString("Something went wrong while getting Referee", comment: ""))
        }
    }
    
    static func getRefereeList(_ gamecode: String) async throws -> [Referee] {
        do{
            let querySnapshot = try await db.collection("\(gamecode) : Referees").getDocuments()
            var referees: [Referee] = []
            for document in querySnapshot.documents {
                let data = document.data()
                let referee = convertDataToReferee(data)
                referees.append(referee)
            }
            referees.sort { $0.name < $1.name }
            return referees
        }
        catch{
            print("Error in getting RefereeList")
            throw GameWalkerError.serverError(NSLocalizedString("Something went wrong while getting RefereeList", comment: ""))
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
            print("Converting json data to Referee \(error)")
        }
        //blank host
        return Referee()
    }
    
}
