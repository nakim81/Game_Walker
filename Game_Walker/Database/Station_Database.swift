//
//  Station_Database.swift
//  Game_Walker
//
//  Created by Paul on 7/27/22.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift
import SwiftUI

struct S {
    static let db = Firestore.firestore()
    static var delegate_stationList: StationList?
    static var delegate_getStation: GetStation?

    static func addStation(_ gamecode: String, _ station: Station) async throws {
        let docRef = db.collection("Servers").document("Gamecode : \(gamecode)")
        do {
            let document = try await docRef.getDocument()
            if document.exists {
                try await db.collection("\(gamecode) : Stations").document("\(station.name)").setData(from: station)
                print("Station added")
            } else {
                print("Gamecode does not exist")
            }
        } catch {
            print("Error adding Station: \(error)")
            throw error
        }
    }
    
    static func removeStation(_ gamecode: String, _ station: Station){
        db.collection("\(gamecode) : Stations").document(station.name).delete() { err in
            if let err = err {
                print("Error removing Station: \(err)")
            } else {
                print("Station removed")
            }
        }
    }
    
    static func assignReferee(_ gamecode: String, _ station: Station, _ referee: Referee) async throws {
        let docRef = db.collection("\(gamecode) : Stations").document(station.name)
        do {
            try await docRef.updateData([
                "referee": referee
            ])
            print("Station assigned Referee")
        } catch {
            print("Error assigning Station a Referee: \(error)")
            throw error
        }
    }

    static func getStation(_ gamecode: String, _ stationName : String){
        let docRef = db.collection("\(gamecode) : Stations").document(stationName)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                guard let data = document.data() else {return}
                let station = convertDataToStation(data)
                delegate_getStation?.getStation(station)
            } else {
                print("Error getting Station")
            }
        }
    }
    
    static func getStationList(_ gamecode: String){
        //Sorted by pvp, pve
        db.collection("\(gamecode) : Stations")
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting List of Station: \(err)")
                } else {
                    var stations : [Station] = []
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        let station = convertDataToStation(data)
                        stations.append(station)
                    }
                    stations.sort {$0.pvp && !$1.pvp}
                    delegate_stationList?.listOfStations(stations)
                }
        }
    }
    
    static func convertDataToStation(_ data : [String : Any]) -> Station {
        do {
            //convert Dictionary data to JSON data first
            let json = try JSONSerialization.data(withJSONObject: data)
            //decode the JSON data to object
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decoded = try decoder.decode(Station.self, from: json)
            return decoded
        } catch {
            print("Converting json data to Station \(error)")
        }
        //blank station
        return Station()
     }
}
