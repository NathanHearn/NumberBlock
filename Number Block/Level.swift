//
//  Level.swift
//  Number Block
//
//  Created by Nathan on 06/03/2018.
//  Copyright © 2018 Nathan. All rights reserved.
//

import SpriteKit

let numRows = 8
let numColumns = 6

class Level {
    
    //MARK: - Level Properties
    
    var target: Int?
    var moves: Int?
    var score: Int = 0
    var idealScore: Int!
    
    var theme: Theme?
    
    var gameMode: gameModes?
    var targetBlocks = [blockType?]() // This is an array of block types that will be used in gamemode 1
    var targetScore: Int? // This is an Int that is the extra score the user must get in gamemode 2
    
    fileprivate var blocks = Array2D<BlockStruct>(columns: numColumns, rows: numRows)
    //This array keeps track of the block objects in the level via block structs
    private var tiles = Array2D<Tile>(columns: numColumns, rows: numRows)
    //This array simply describes what part of the grid can contain a block
    
    private var blockValues = Array2D<Int>(columns: numColumns, rows: numRows) // Array2D for blockValues
    private var blockTypes = Array2D<Int>(columns: numColumns, rows: numRows) // Array2D for blockTypes
    
    //MARK: - init
    
    init(filename: String) {
        //All data from the json file is read and prosesed here.
        guard let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename: filename) else {return}
        guard let tilesArray = dictionary["tiles"] as? [[Int]] else {return}
        guard let blockValuesArray = dictionary["values"] as? [[Int]] else {return}
        guard let blockTypesArray = dictionary["types"] as? [[Int]] else {return}
        
        guard let target = dictionary["target"] as? Int else {return}
        self.target = target
        guard let moves = dictionary["moves"] as? Int else {return}
        self.moves = moves
        guard let gameMode = dictionary["gameMode"] as? Int else {return}
        self.gameMode = gameModes(rawValue: gameMode)
        guard let idealScore = dictionary["idealScore"] as? Int else {return}
        self.idealScore = idealScore
        
        if gameMode == 1 { //if its gamemode one, it gets the extra blocks and adds them to an array
            guard let extraBlocks = dictionary["extraBlocks"] as? [Int] else {return}
            for block in extraBlocks {
                let type = blockType(rawValue: block)
                targetBlocks.append(type)
            }
        } else if gameMode == 2 { //if its gamemode two, it get the score and assigns it to the targetscore var
            guard let targetScore = dictionary["targetScore"] as? Int else {return}
            self.targetScore = targetScore
        }
        
        for (row, rowArray) in tilesArray.enumerated() {
            
            let tileRow = numRows - row - 1
            //The tiles array is read from the top on the json file, so we want to 'flip' this
            
            for (column, value) in rowArray.enumerated() {
                if value == 1 {
                    tiles[column, tileRow] = Tile()
                    blockValues[column, tileRow] = blockValuesArray[row][column]
                    blockTypes[column, tileRow] = blockTypesArray[row][column]
                }
            }
        }
    }
    
    //MARK: - Level Array2D Helper Methods
    
    func blockAt(column: Int, row: Int) -> BlockStruct? {
        assert(column >= 0 && column < numColumns)
        assert(row >= 0 && row < numRows)
        // assert is used to check a condition, if the condition fails then the app will crash and make it easier to find the unexpected condition
        return blocks[column, row]
    }
    
    func tileAt(column: Int, row: Int) -> Tile? {
        assert(column >= 0 && column < numColumns)
        assert(row >= 0 && row < numRows)
        return tiles[column, row]
    }
    
    //MARK: - Level Elements
    
    func createInitalBlocks() -> Set<BlockStruct> {
        var set = Set<BlockStruct>()
        
        for row in 0 ..< numRows {
            for column in 0 ..< numColumns {
                
                if tiles[column, row] != nil {
                    let newBlockType = blockType(rawValue: blockTypes[column, row]!)
                    
                    let newBlock = BlockStruct(column: column, row: row, blockType: newBlockType!, blockValue: blockValues[column, row]!)
                    blocks[column, row] = newBlock
                    
                    set.insert(newBlock)
                }
            }
        }
        return set
    }
    
    //MARK:- Functions
    
    func posibleMove(toColumn: Int, toRow: Int) -> Bool? {
        let tile = tileAt(column: toColumn, row: toRow)
        let block = blockAt(column: toColumn, row: toRow)
        
        if tile == nil {
            return nil
        } else if block == nil {
            return false
        } else {
            return true
        }
    }
    
    func updateBlockValue(newValue: Int, column: Int, row: Int) {
        var block = blocks[column, row]
        block!.blockValue = newValue
        blocks[column, row] = block!
    }
    
    func updateBlockType(newType: blockType, column: Int, row: Int) {
        var block = blocks[column, row]
        block!.blockType = newType
        blocks[column, row] = block!
    }
    
    func removeBlock(column: Int, row: Int) {
        blocks[column, row] = nil
    }
    
    func moveBlock(fromColumn: Int, fromRow: Int, toColumn: Int, toRow: Int) {
        var block = blockAt(column: fromColumn, row: fromRow)
        block!.column = toColumn
        block!.row = toRow
        
        blocks[fromColumn, fromRow] = nil
        blocks[toColumn, toRow] = block!
    }
    
    func copyCurrentBlocks() -> Set<BlockStruct> { // makes a copy of the blocks currently in the level for the gamescene to save, done to seprate instences
        var set = Set<BlockStruct>()
        for column in 0 ..< numColumns {
            for row in 0 ..< numRows {
                let tempBlock = blockAt(column: column, row: row)
                if tempBlock != nil {
                    let block = BlockStruct(column: tempBlock!.column, row: tempBlock!.row, blockType: tempBlock!.blockType, blockValue: tempBlock!.blockValue)
                    set.insert(block)
                }
            }
        }
        return set
    }
    
    func copyCurrentTargetBlocks() -> [blockType] { // makes a copy of the targrt blocks currently in the level for the gamescene to save, done to make non optional values
        var array = [blockType]()
        for type in targetBlocks {
            if type != nil {
                array.append(type!)
            }
        }
        return array
    }
    
    func undoMove(previousBlocks: Set<BlockStruct>, score: Int, targetBlocks: [blockType]?) {
        
        //resets the blocks array2d
        for row in 0 ..< numRows {
            for column in 0 ..< numColumns {
                blocks[column, row] = nil
            }
        }
        
        //repopulates blocks with previous block structs
        for block in previousBlocks {
            blocks[block.column, block.row] = block
        }
        
        //sets score and targetblocks if needed
        self.score = score
        
        if self.gameMode == . targetWithBlocks {
            self.targetBlocks = targetBlocks!
        }
    }
    
    func fillHoles() -> [[BlockStruct]] { // This updates the data model and returns a set of blockStructs to be moved
        var columns = [[BlockStruct]]()
        
        for column in 0 ..< numColumns {
            var array = [BlockStruct]()
            
            for row in 0 ..< numRows {
                if tiles[column, row] != nil && blocks[column, row] == nil {
                    
                    for lookUp in (row + 1) ..< numRows {
                        
                        if tiles[column, lookUp] != nil {
                            if var block = blocks[column, lookUp] {
                                blocks[column, lookUp] = nil
                                block.row = row
                                blocks[column, block.row] = block
                                array.append(block)
                                break
                            }
                        } else {
                            break
                        }
                    }
                }
            }
            if !array.isEmpty {
                columns.append(array)
            }
        }
        return columns
    }
}
