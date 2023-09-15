//
//  CellData.swift
//  Game_Walker
//
//  Created by Jin Kim on 9/7/23.
//

import UIKit

class CellData: Hashable {
//    var yellowPvpIndexSet = Set<IntPair>()
//    var bluePvpIndexSet = Set<IntPair>()
    
    var cellIndex : IntPair?
    var number : Int?

    var cellsWithSameYellowPvpWarning  = Set<CellData>()
    var cellsWithSameBluePvpWarning = Set<CellData>()
    var cellsWithSamePurpleWarning = Set<CellData>()
    var cellsWithSameYellowWarning = Set<CellData>()
    
    var isSelected : Bool = false
    
    var visible : Bool = true
    var warningColor : String?
    
    var hasPvpYellowWarning : Bool = false
    var hasYellowWarning : Bool = false
    var hasPvpBlueWarning : Bool = false
    var hasPurpleWarning: Bool = false
    var hasRedWarning: Bool = false
    
    
    
    
    init(number: Int, visible: Bool = true, index: IntPair) {
        self.number = number
        self.visible = visible
        self.cellIndex = index
    }
    
    func changeCellData(number: Int, visible: Bool) {
        self.number = number
        self.visible = visible
    }
    
    func changeCellIndex(section: Int, column: Int) {
        self.cellIndex = IntPair(first: section, second: column)
    }
    
    func changeState(to color: String) {
        switch color {
            
        case "yellowPvp":
            visible = true
            warningColor = "yellow"
            hasPvpBlueWarning = false
            hasPurpleWarning = false
            hasRedWarning = false
            hasYellowWarning = false
            hasPvpYellowWarning = true
            
        case "yellow":
            visible = true
            warningColor = "yellow"
            hasPvpBlueWarning = false
            hasPurpleWarning = false
            hasRedWarning = false
            hasYellowWarning = true
            hasPvpYellowWarning = false
            
            
        case "red":
            // Code to execute when color is "red"
            visible = true
            warningColor = "red"
//            hasPvpYellowWarning = false
//            hasPvpBlueWarning = false
//            hasPurpleWarning = false
            hasRedWarning = true
//            hasYellowWarning = false
            
        case "blue":
            visible = true
            warningColor = "purple"
            hasPvpYellowWarning = false
            hasPvpBlueWarning = true
            hasPurpleWarning = false
            hasRedWarning = false
            hasYellowWarning = false
            
        case "purple":
            visible = true
            warningColor = "purple"
            hasPvpYellowWarning = false
            hasPvpBlueWarning = false
            hasPurpleWarning = true
            hasRedWarning = false
            hasYellowWarning = false
            
        case "empty":
            visible = true
            warningColor = ""
            hasPvpYellowWarning = false
            hasPvpBlueWarning = false
            hasPurpleWarning = false
            hasRedWarning = false
            hasYellowWarning = false
            number = 0
            
        case "invisible":
            visible = false
            warningColor = ""
            hasYellowWarning = false
            hasPvpYellowWarning = false
            hasPvpBlueWarning = false
            hasPurpleWarning = false
            hasRedWarning = false
            hasYellowWarning = false
            number = -1
            
        case "selected":
            isSelected = true
            
        case "deselected":
            isSelected = false
            
        default:
            print("No State Change Has Been Made")
        }
    }
    
    func addYellowPvpIndexToCellData(_ indexSet: Set<CellData>) {
        hasPvpYellowWarning = true
//        hasPvpBlueWarning = false
//        hasPurpleWarning = false
//        hasYellowWarning = false
        
        if !cellsWithSameYellowPvpWarning.isEmpty {
            cellsWithSameYellowPvpWarning.formUnion(indexSet)
        } else {
            cellsWithSameYellowPvpWarning = indexSet
        }
    }
    
    func addBluePvpIndexToCellData(_ indexSet: Set<CellData>) {
        hasPvpBlueWarning = true
//        hasPvpYellowWarning = false
//        hasPurpleWarning = false
//        hasYellowWarning = false
        
        if !cellsWithSameBluePvpWarning.isEmpty {
            cellsWithSameBluePvpWarning.formUnion(indexSet)
        } else {
            cellsWithSameBluePvpWarning = indexSet
        }
    }
    func addPurpleIndexToCellData(_ indexSet: Set<CellData>) {
        hasPurpleWarning = true
//        hasPvpYellowWarning = false
//        hasPvpBlueWarning = false
//        hasYellowWarning = false

        
        if !cellsWithSamePurpleWarning.isEmpty {
            cellsWithSamePurpleWarning.formUnion(indexSet)
        } else {
            cellsWithSamePurpleWarning = indexSet
        }
    }
    func addYellowIndexToCellData(_ indexSet: Set<CellData>) {
        hasYellowWarning = true
//        hasPvpYellowWarning = false
//        hasPvpBlueWarning = false
//        hasPurpleWarning = false

        
        if !cellsWithSameYellowWarning.isEmpty {
            cellsWithSameYellowWarning.formUnion(indexSet)
        } else {
            cellsWithSameYellowWarning = indexSet
        }
    }
    
    func emptyIndexData() {
        cellsWithSameYellowPvpWarning.removeAll()
        cellsWithSameBluePvpWarning.removeAll()
        cellsWithSamePurpleWarning.removeAll()
        cellsWithSameYellowWarning.removeAll()
    }
    
    func resetCellToDefault() {
        cellsWithSameYellowPvpWarning.removeAll()
        cellsWithSameBluePvpWarning.removeAll()
        cellsWithSamePurpleWarning.removeAll()
        cellsWithSameYellowWarning.removeAll()
        visible = true
        warningColor = ""
        hasPvpYellowWarning = false
        hasPvpBlueWarning = false
        hasPurpleWarning = false
        hasYellowWarning = false
        hasRedWarning = false
        isSelected = false
    }
    

    
    //Hashable Methods Implementation
    func hash(into hasher: inout Hasher) {
        hasher.combine(cellIndex)
        hasher.combine(number)
    }

    static func == (lhs: CellData, rhs: CellData) -> Bool {
        return lhs.cellIndex == rhs.cellIndex && lhs.number == rhs.number
    }
    
}
