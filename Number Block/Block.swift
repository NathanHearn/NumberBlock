//
//  Block.swift
//  Number Block
//
//  Created by Nathan on 06/03/2018.
//  Copyright © 2018 Nathan. All rights reserved.
//

import SpriteKit

enum blockType: Int {
    case unknown = 0, orangeBlock, redBlock, greenBlock, blueBlock // unknown exsists so that 0 can be used to repersent no block in the json file
}

class Block: SKShapeNode {
    
    //MARK:- Properties
    
    override var description: String {
        return "type: \(blockType) value: \(blockValue) square:(\(column),\(row))"
    }
    
    var column: Int
    var row: Int
    var blockType: blockType
    var blockValue: Int
    var shapeShadowColor: SKShapeNode?
    var numberLabel: SKLabelNode?
    
    //MARK:- init
    
    init(block: BlockStruct, size: CGSize) {
        self.column = block.column
        self.row = block.row
        self.blockType = block.blockType
        self.blockValue = block.blockValue
        
        super.init()
        
        let origin: CGFloat = -(size.width) / 2 // width of block / 2 (minus because 0,0 is top right in shape nodes (1,1 is at the bottom left))
        self.path = CGPath(roundedRect: CGRect(x: origin, y: origin ,width: size.width, height: size.height) , cornerWidth: 15, cornerHeight: 15, transform: nil)
        let numberLabel = SKLabelNode(text: String(blockValue))
        
        //numberlabel created
        numberLabel.fontName = "Montserrat-Bold"
        numberLabel.verticalAlignmentMode = .center
        numberLabel.horizontalAlignmentMode = .center
        self.addChild(numberLabel)
        self.numberLabel = numberLabel
        
        //Creates the shadow and 3d effect
        let shadowBack = SKShapeNode(path: self.path!)
        shadowBack.position = CGPoint(x: 0, y: -4); shadowBack.zPosition = -2
        self.addChild(shadowBack)
        self.shapeShadowColor = shadowBack // only the back is stored as it is the colour of the shadow and may need to change!
        
        let shadowFront = SKShapeNode(path: self.path!) // shapenode that creates texture for spritenode
        shadowFront.fillColor = UIColor(red: 127/256, green: 127/256, blue: 127/256, alpha: 0.25); shadowFront.strokeColor = shadowFront.fillColor //alpha set to 0.25
        shadowFront.position = CGPoint(x: 0, y: -4); shadowFront.zPosition = -1
        self.addChild(shadowFront)
        
        resiseFont()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Methods
    
    func updateColours(theme: Theme) {
        
        switch blockType {
        case .orangeBlock:
            self.fillColor = theme.customOrangeColor
        case .redBlock:
            self.fillColor = theme.customRedColor
        case .greenBlock:
            self.fillColor = theme.customGreenColor
        case .blueBlock:
            self.fillColor = theme.customBlueColor
        case .unknown:
            return
        }
        self.strokeColor = self.fillColor
        
        numberLabel!.fontColor = theme.customTextColor
        
        shapeShadowColor!.fillColor = self.fillColor
        shapeShadowColor!.strokeColor = self.strokeColor
        
        
    }
    
    func resiseFont() {
        numberLabel!.fontSize = 42 // sets font size to ideal font size
        
        while (numberLabel!.frame.width + 6) >= self.frame.width {
            // if the label is to big, it will decrease the size by 0.5 until it fits with the desired margin (4 either side of the block)
            numberLabel!.fontSize -= 0.5
        }
    }
    
    func updateValue(newValue: Int) {
        blockValue = newValue
        numberLabel!.text = "\(newValue)"
        resiseFont()
    }
}

struct BlockStruct: CustomStringConvertible, Hashable { // a Block Structs only purpose is to store a discription of a block
    
    var hashValue: Int {
        return row*15 + column
        // Its position in the 2d grid is good enough to identify each block, so we use it to genarate a hash value
    }
    
    var column: Int
    var row: Int
    var blockType: blockType
    var blockValue: Int
    
    var description: String {
        return "type: \(blockType) value: \(blockValue) square:(\(column),\(row))"
    }
    
    static func ==(lhs: BlockStruct, rhs: BlockStruct) -> Bool {
        return lhs.column == rhs.column && lhs.row == rhs.row
    }
}

class Tile {
    
}

class TileBlock: SKShapeNode {
    
    let size: CGSize
    
    init(size: CGSize, backgroundColour: UIColor) {
        self.size = size
        
        super.init()
        
        self.path = CGPath(roundedRect: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height) , cornerWidth: 15, cornerHeight: 15, transform: nil)
        self.fillColor = UIColor(red: 127/255, green: 127/255, blue: 127/255, alpha: 0.25)
        self.strokeColor = backgroundColour
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
