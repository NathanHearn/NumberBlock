//
//  MoveBlock.swift
//  Number Block
//
//  Created by Nathan on 11/03/2018.
//  Copyright © 2018 Nathan. All rights reserved.
//

struct Move: CustomStringConvertible {
    let blockA: Block
    let blockB: Block
    let subtract: Bool
    
    init(subtract: Bool, blockA: Block, blockB: Block) {
        self.subtract = subtract
        self.blockA = blockA
        self.blockB = blockB
    }
    
    var description: String {
        if subtract {
            return "subtracting \(blockA) from \(blockB)"
        } else {
            return "adding \(blockA) to \(blockB)"
        }
    }
}

struct MoveToEmptyTile: CustomStringConvertible {
    let blockA: Block
    let toColumn: Int
    let toRow: Int
    
    init(blockA: Block, toColumn: Int, toRow: Int) {
        self.blockA = blockA
        self.toColumn = toColumn
        self.toRow = toRow
    }
    
    var description: String {
        return "Moving \(blockA) to column \(toColumn), row \(toRow)"
    }
}
