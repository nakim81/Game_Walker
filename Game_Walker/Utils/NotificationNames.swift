//
//  NotificationNames.swift
//  Game_Walker
//
//  Created by Noah Kim on 10/31/23.
//

import Foundation

extension Notification.Name {
    static let readNotification = Notification.Name("readNotification")
    static let announceNoti = Notification.Name("announceNoti")
    static let newDataNotif = Notification.Name("newDataNotif")
    static let hostUpdate = Notification.Name("hostUpdate")
    static let standardOnly = Notification.Name("standardOnly")
    static let pointsOnly = Notification.Name("pointsOnly")
    static let stationUpdate = Notification.Name("stationUpdate")
    static let roundUpdate = Notification.Name("roundUpdate")
    static let teamsUpdate = Notification.Name("teamsUpdate")
    static let refereeUpdate = Notification.Name("refereeUpdate")
//    static let stationDataUpdated = Notification.Name("stationDataUpdated")
}
