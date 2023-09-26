//
//  IntPair.swift
//  Game_Walker
//
//  Created by Jin Kim on 9/7/23.
//

import Foundation

struct IntPair: Hashable {
    //when used as indexing cells, first is section and second is column.
    
    let first: Int
    let second: Int
    
    func switchPair(_ intPair: IntPair) -> IntPair {
        return IntPair(first: intPair.second, second: intPair.first)
    }
    
    func cleanOrderPair(_ intPair: IntPair) -> IntPair {
        if intPair.first > intPair.second {
            return IntPair(first: intPair.second, second: intPair.first)
        }
        return intPair
    }
}

