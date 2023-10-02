//
//  Announcement.swift
//  Game_Walker
//
//  Created by Paul on 10/2/23.
//

import Foundation

struct Announcement : Codable, Equatable {
    var uuid : String = ""
    var content : String = ""
    var timestamp : String = ""
    var readStatus : Bool = false
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case content
        case timestamp
        case readStatus
    }
}
