//
//  CellData.swift
//  Game_Walker
//
//  Created by Jin Kim on 9/7/23.
//

import UIKit

class CellData {
    var yellowPvpIndexSet = Set<IntPair>()
    var bluePvpIndexSet = Set<IntPair>()
    
    var cellIndex : IntPair?
    
    var visible : Bool = true
    var warningColor : String?
    
    var hasWarning : Bool = false
    var hasPvpYellowWarning : Bool = false
    var hasYellowWarning : Bool = false
    var hasPvpBlueWarning : Bool = false
    var hasPurpleWarning: Bool = false
    var hasRedWarning: Bool = false
    
    
    var number : Int?

    init(number: Int, visible: Bool = true, index: IntPair) {
        self.number = number
        self.visible = visible
        self.cellIndex = index
    }
    
    func changeCellData(number: Int, visible: Bool) {
        self.number = number
        self.visible = visible
    }
    
    func changeState(to color: String) {
        switch color {
        case "yellow":
            hasWarning = true
            visible = true
            warningColor = "yellow"
            hasPvpBlueWarning = false
            hasPurpleWarning = false
            hasRedWarning = false
            hasYellowWarning = true
            
            
        case "red":
            // Code to execute when color is "red"
            hasWarning = true
            visible = true
            warningColor = "red"
            hasPvpYellowWarning = false
            hasPvpBlueWarning = false
            hasPurpleWarning = false
            hasRedWarning = true
            hasYellowWarning = false
            
        case "blue":
            hasWarning = true
            visible = true
            warningColor = "purple"
            hasPvpYellowWarning = false
            hasPvpBlueWarning = true
            hasPurpleWarning = false
            hasRedWarning = false
            hasYellowWarning = false
            
        case "purple":
            hasWarning = true
            visible = true
            warningColor = "purple"
            hasPvpYellowWarning = false
            hasPvpBlueWarning = false
            hasPurpleWarning = true
            hasRedWarning = false
            hasYellowWarning = false
            
        case "none":
            hasWarning = false
            visible = true
            warningColor = ""
            hasPvpYellowWarning = false
            hasPvpBlueWarning = false
            hasPurpleWarning = false
            hasRedWarning = false
            hasYellowWarning = false
            
        case "invisible":
            hasWarning = false
            visible = false
            warningColor = ""
            hasPvpYellowWarning = false
            hasPvpBlueWarning = false
            hasPurpleWarning = false
            hasRedWarning = false
            hasYellowWarning = false
            
        default:
            print("No State Change Has Been Made")
        }
    }
    
    func addYellowIndexToCellData(_ indexSet: Set<IntPair>) {
        hasPvpYellowWarning = true
        if !yellowPvpIndexSet.isEmpty {
            yellowPvpIndexSet.formUnion(indexSet)
        } else {
            yellowPvpIndexSet = indexSet
        }
    }
    
    func addBlueIndexToCellData(_ indexSet: Set<IntPair>) {
        hasPvpBlueWarning = true
        if !bluePvpIndexSet.isEmpty {
            bluePvpIndexSet.formUnion(indexSet)
        } else {
            bluePvpIndexSet = indexSet
        }
    }
    
    func emptyIndexData() {
        bluePvpIndexSet.removeAll()
        yellowPvpIndexSet.removeAll()
    }
    
}
