//
//  GameScene.swift
//  Number Block
//
//  Created by Nathan on 06/03/2018.
//  Copyright © 2018 Nathan. All rights reserved.
//

import SpriteKit
import GameplayKit

protocol GameSceneDelegate {
    //MARK:- Scene specific functions
    func endGame(score: Int, goldenBlocks: Int)
    func nextLifeIn() -> CGFloat
    func getPlayerLevel() -> Int
    func nextPlayerLevel() -> (lastLevelScore: Int, nextLevelScore: Int)
    func getPlayerScore() -> Int
    func levelStatsImproved(goldenBlocks: Int) -> Bool
    func goToLevelSelect()
    func restart()
    func addLife()
    func reportLevelFail()
    func reportadWatchedForLife()
    func reportMovesPurchased()
    func presentInterstitial()
    func presentRewardedAd()
    
    //MARK:- Default scene functions
    func getLives() -> Int
    func livesUnlimited() -> Bool
    func getGems() -> Int
    func buy(get: buyConsumables)
    func take(consumable: consumables, number: Int)
    func addScrollView(scrollView: CustomScrollView)
    func goHome()
    func reportLifePurchased(amount: Int)
    func isIPhoneX() -> Bool
}

enum gameModes: Int {
    case target = 0, targetWithBlocks, targetWithScore
}

class GameScene: CustomScene {
    
    //MARK:- Properties
    
    //MARK:- Delegate
    var customDelegate: GameSceneDelegate?
    
    //MARK:- Block sizes
    
    var tileSize = CGSize(width: 84, height: 87)
    
    var blockSize: CGSize {
        let dimension = tileSize.width - 7
        let size = CGSize(width: dimension, height: dimension)
        return size
    }
    
    //MARK:- Layers
    
    var gameLayer: SKNode?
    var tileLayer: SKNode?
    var gameIntraction: Bool = true
    
    //MARK:- Level data
    
    var level: Level?
    
    //MARK:- Blocks
    
    var blocks = Array2D<Block>(columns: numColumns, rows: numRows) // This array keeps track of the blocks in the gameScene
    
    //MARK:- HUD
    
    var gameHUD: HUD?
    
    //MARK:- Buttons
    
    var undoButton: CustomButton?
    var pauseButton: CustomButton?
    var helpButton: CustomButton?
    
    //MARK:- swipe properties
    
    private var swipeFromColumn: Int?
    private var swipeFromRow: Int?
    private var blockSwipedFrom: CGPoint?
    
    //MARK:- Undo properties
    
    var moveNumber: Int = -1 // move number starts of at -1 becuase as soon as the level loads its coppied and the move number is increased to 0, the first move.
    var previousBlocks = [Set<BlockStruct>]()
    var previousScores = [Int]()
    var previousTargetBlocks = [[blockType]]()
    
    //MARK:- Init

    init(size: CGSize, theme: Theme, level: String) {
        self.level = Level(filename: level)
        
        super.init(size: size, theme: theme)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        if let level = level {
            let blocks = level.createInitalBlocks()
            configureLayers()
            addBlocks(for: blocks)
            addTiles(for: blocks)
            addHUD()
            addButtons()
            copyLevel()
            
            createGameMenu(menu: .helpMenu)
        } else {
            print("Error: Level not loaded!")
        }
    }
    
    //MARK:- Functions
    
    //Over writes the function in the parent class to get the time to the next life through the delegate.
    override func timeToNextLife() -> CGFloat {
        let timeLeft = customDelegate!.nextLifeIn()
        return timeLeft
    }
    
    //Over writes the parent's function to allow it to use the delegate to add a scrollView for the menus.
    override func addScrollView(scollView: CustomScrollView) {
        let newScrollView = scollView
        self.scrollView = newScrollView
        customDelegate!.addScrollView(scrollView: newScrollView)
    }
    
    //This function creates the tile and game (Block) layers and positions them accordind to the number or columns and rows.
    func configureLayers() {
        var position: CGPoint {
            let x = -tileSize.width*CGFloat(numColumns)/2
            let y = -tileSize.height*CGFloat(numRows)/2
            let point = CGPoint(x: x, y: y)
            return point
        }
        
        tileLayer = SKNode()
        tileLayer!.position = position
        tileLayer!.zPosition = 50
        self.addChild(tileLayer!)
        
        gameLayer = SKNode()
        gameLayer!.position = position
        gameLayer!.zPosition = 100
        self.addChild(gameLayer!)
    }
    
    //This function creates and adds the blocks for the level from a set of block structs
    func addBlocks(for blocks: Set<BlockStruct>) {
        if let layer = gameLayer {
            for block in blocks {
                let position = pointFor(column: block.column, row: block.row)
                let newBlock = Block(block: block, size: blockSize)
                newBlock.updateColours(theme: theme)
                newBlock.position = position
                layer.addChild(newBlock)
                self.blocks[newBlock.column, newBlock.row] = newBlock
            }
        }
    }
    
    //This function creates and adds the tiles for the level from the same set of block structs as addblocks
    func addTiles(for blocks: Set<BlockStruct>) {
        let tileSize = CGSize(width: blockSize.width - 4, height: blockSize.height + 2)
        
        for block in blocks {
            let position = pointFor(column: block.column, row: block.row)
            let newTile = TileBlock(size: tileSize, backgroundColour: theme.customBackgroundColor)
            newTile.position = position
            tileLayer!.addChild(newTile)
        }
    }
    
    //This function create and adds the HUD to the gamescene
    func addHUD() {
        let isIphoneX: Bool = self.customDelegate!.isIPhoneX()
        gameHUD = HUD(theme: theme, target: level!.target!, moves: level!.moves!, score: 0, isIphoneX: isIphoneX)
        
        let height = CGFloat(self.size.height / 2)
        gameHUD!.position = CGPoint(x: 0, y: height)
        
        self.addChild(gameHUD!)
    }
    
    override func disableTouches() {
        self.isUserInteractionEnabled = false
        gameIntraction = false
        
        undoButton!.isUserInteractionEnabled = false
        pauseButton!.isUserInteractionEnabled = false
        helpButton!.isUserInteractionEnabled = false
    }
    
    override func enableTouches() {
        self.isUserInteractionEnabled = true
        gameIntraction = true
        
        undoButton!.isUserInteractionEnabled = true
        pauseButton!.isUserInteractionEnabled = true
        helpButton!.isUserInteractionEnabled = true
    }
    
    func addButtons() {
        
        var extraHight: CGFloat = 0
        
        if customDelegate!.isIPhoneX() {
            extraHight = 75
        }
        
        let largeButton = CGPath(roundedRect: CGRect(x: -65, y: -40, width: 130, height: 80), cornerWidth: 15, cornerHeight: 15, transform: nil)
        let smallButton = CGPath(roundedRect: CGRect(x: -40, y: -40, width: 80, height: 80), cornerWidth: 15, cornerHeight: 15, transform: nil)
        
        undoButton = CustomButton(path: largeButton, text: "Undo", color: theme.customOrangeColor, textColor: theme.customTextColor, action: {
            self.undoLevel()
        })
        undoButton!.textLabel!.fontSize = 32
        undoButton!.position = CGPoint(x: -120, y: -425 - extraHight)
        undoButton!.zPosition = 50
        self.addChild(undoButton!)
        
        pauseButton = CustomButton(path: smallButton,  text: "ll", color: theme.customOrangeColor, textColor: theme.customTextColor, action: {
            self.createMenu(type: .pauseMenu)
        })
        pauseButton!.textLabel!.fontSize = 42
        pauseButton!.position = CGPoint(x: 0, y: -425 - extraHight)
        pauseButton!.zPosition = 50
        self.addChild(pauseButton!)
        
        helpButton = CustomButton(path: largeButton,  text: "Help", color: theme.customOrangeColor, textColor: theme.customTextColor, action: {
            self.createGameMenu(menu: .helpMenu)
        })
        helpButton!.textLabel!.fontSize = 32
        helpButton!.textLabel!.position = CGPoint(x: 0, y: -2)
        helpButton!.position = CGPoint(x: 120, y: -425 - extraHight)
        helpButton!.zPosition = 50
        self.addChild(helpButton!)

    }
    
    //MARK: - Point Converters
    
    //Converts points (row & column) from the array2d for blocks to a point on the game scene
    func pointFor(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column)*tileSize.width + tileSize.width/2,
            y: CGFloat(row)*tileSize.height + tileSize.height/2)
    }
    
    //This method converts a touch location to the relitive column and row of the levels array2D (the oposite of the pointFor method above)
    func convertPoint(point: CGPoint) -> (success: Bool, column: Int, row: Int) {
        if point.x >= 0 && point.x < CGFloat(numColumns)*tileSize.width && point.y >= 0 && point.y < CGFloat(numRows)*tileSize.height {
            return (true, Int(point.x / tileSize.width), Int(point.y / tileSize.height))
        } else {
            return (false, 0, 0)
        }
    }
    
    //MARK: - Touch Controls
    
    //Once a touch has started, this function gets the location and assigns blockSwipedFrom with the appropriate block
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameIntraction {
            guard let touch = touches.first else {return}
            let location = touch.location(in: gameLayer!)
            let (success, column, row) = convertPoint(point: location)
            if success {
                if level!.blockAt(column: column, row: row) != nil {
                    swipeFromColumn = column
                    swipeFromRow = row
                    blockSwipedFrom = pointFor(column: swipeFromColumn!, row: swipeFromRow!)
                }
            }
        }
    }
    
    //when the user moves their finger across the screen, this function checks the location agianst the conditions to see if the swipe if valid yet, if so it creates a struct and proceds
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard swipeFromColumn != nil else {return}
        guard let touch = touches.first else {return}
        let location = touch.location(in: gameLayer!)
        let swipeMargin = (tileSize.width / 4) //players swipe is allowed to move +- swipeMargin in axis perpendicular to their swipe before its considerd a diagonal swipe
        var subtract: Bool = false
        
        //Could do with a bit of simplifying
        var horzDelta = 0, vertDelta = 0
        if blockSwipedFrom!.x + (tileSize.width / 2) < location.x && blockSwipedFrom!.y + swipeMargin > location.y && blockSwipedFrom!.y - swipeMargin < location.y { // Swiped Right
            horzDelta = 1
        } else if blockSwipedFrom!.x - (tileSize.width / 2) > location.x && blockSwipedFrom!.y + swipeMargin > location.y && blockSwipedFrom!.y - swipeMargin < location.y { // Swiped Left
            horzDelta = -1
        } else if blockSwipedFrom!.y + (tileSize.height / 2) < location.y && blockSwipedFrom!.x + swipeMargin > location.x && blockSwipedFrom!.x - swipeMargin < location.x { // Swiped Up
            vertDelta = 1
        } else if blockSwipedFrom!.y - (tileSize.height / 2) > location.y && blockSwipedFrom!.x + swipeMargin > location.x && blockSwipedFrom!.x - swipeMargin < location.x { // Swiped Down
            vertDelta = -1
        } else if blockSwipedFrom!.x + (tileSize.height / 2) < location.x && blockSwipedFrom!.y + (tileSize.width / 2) < location.y { // Swiped Right and Up
            horzDelta = 1; vertDelta = 1; subtract = true
        } else if blockSwipedFrom!.x - (tileSize.width / 2) > location.x && blockSwipedFrom!.y + (tileSize.width / 2) < location.y { // Swiped Left and Up
            horzDelta = -1; vertDelta = 1; subtract = true
        } else if blockSwipedFrom!.x + (tileSize.width / 2) < location.x && blockSwipedFrom!.y - (tileSize.width / 2) > location.y { // Swiped Right and Down
            horzDelta = 1; vertDelta = -1; subtract = true
        } else if blockSwipedFrom!.x - (tileSize.width / 2) > location.x && blockSwipedFrom!.y - (tileSize.width / 2) > location.y { // Swiped Ledt and Down
            horzDelta = -1; vertDelta = -1; subtract = true
        }
        
        if horzDelta != 0 || vertDelta != 0 {
            let (success, _, _) = convertPoint(point: location) //checks location is a tile on the grid
            if success {
                let toColumn = swipeFromColumn! + horzDelta
                let toRow = swipeFromRow! + vertDelta
                let posibleBlock = level?.posibleMove(toColumn: toColumn, toRow: toRow)
                
                if posibleBlock == true {
                    var blockA: Block?
                    var blockB: Block?
                    
                    blockA = self.blocks[swipeFromColumn!, swipeFromRow!]
                    blockB = self.blocks[toColumn, toRow]
                    
                    let move = Move(subtract: subtract, blockA: blockA!, blockB: blockB!)
                    moveToBlock(move: move)
                } else if posibleBlock == false {
                    if vertDelta == 0 { // player sould only be able to move to tile that is to the left or right of the block
                        var blockA: Block?
                        
                        blockA = self.blocks[swipeFromColumn!, swipeFromRow!]
                        let move = MoveToEmptyTile(blockA: blockA!, toColumn: toColumn, toRow: toRow)
                        moveToTile(move: move)
                    }
                }
                
                swipeFromColumn = nil
                blockSwipedFrom = nil
            }
        }
    }
    
    //MARK:- Logic
    
    //This method checks to see if a move (not move to tile) is valid with block types and subtraction rules
    func isMoveValid(move: Move) -> Bool {
        var moveValid: Bool = true
        
        //Checking move is valid if it uses a blue block
        if move.blockA.blockType == .blueBlock || move.blockB.blockType == .blueBlock {
            if move.blockA.blockValue != move.blockB.blockValue {
                moveValid = false
            }
            
            //Checking move is valid if its a subtraction
        } else if move.subtract {
            if move.blockA.blockType == .redBlock || move.blockB.blockType == .redBlock {
                moveValid = false
            } else if move.blockA.blockValue < move.blockB.blockValue {
                moveValid = false
            }
            
            //Checking move is valid if its addition
        } else {
            if move.blockA.blockType == .greenBlock || move.blockB.blockType == .greenBlock {
                moveValid = false
            }
        }
        return moveValid
    }
    
    //This function carries out a move to a block
    func moveToBlock(move: Move) {
        disableTouches()
        var newValue: Int!
        let moveValid = isMoveValid(move: move)
        
        if !moveValid {
            AudioPlayer.sharedInstance.playSound(sound: .invalidMove, node: self)
            animateInvalidMove(block: move.blockA)
            return
        }
        
        calculateScore(move: move) // score is calculated here before any of the blocks a changed
        
        //finds new value
        if move.subtract {
            newValue = move.blockA.blockValue - move.blockB.blockValue
        } else {
            newValue = move.blockA.blockValue + move.blockB.blockValue
        }
        
        //moves blocks
        if newValue != 0 {
            //Remove blockA
            level!.updateBlockValue(newValue: newValue, column: move.blockB.column, row: move.blockB.row)
            level!.updateBlockType(newType: .orangeBlock, column: move.blockB.column, row: move.blockB.row)
            level!.removeBlock(column: move.blockA.column, row: move.blockA.row)
            
            blocks[move.blockA.column, move.blockA.row] = nil
            
            if level!.gameMode == .targetWithBlocks {
                gamemode1ExtraSteps(move: move)
            }
            
            if move.blockA.blockType != .orangeBlock || move.blockB.blockType != .orangeBlock {
                AudioPlayer.sharedInstance.playSound(sound: .specialMove, node: self)
            } else {
                AudioPlayer.sharedInstance.playSound(sound: .validMoved, node: self)
            }
            
            move.blockB.updateValue(newValue: newValue)
            move.blockB.blockType = .orangeBlock
            move.blockB.updateColours(theme: theme)
            
            animateMoveToBlock(move: move, removeBoth: false)
            
        } else {
            //Remove both blocks
            //data model
            level!.removeBlock(column: move.blockA.column, row: move.blockA.row)
            level!.removeBlock(column: move.blockB.column, row: move.blockB.row)
            
            blocks[move.blockA.column, move.blockA.row] = nil
            blocks[move.blockB.column, move.blockB.row] = nil
            
            if level!.gameMode == .targetWithBlocks {
                gamemode1ExtraSteps(move: move)
            }
            
            if move.blockA.blockType != .orangeBlock || move.blockB.blockType != .orangeBlock {
                AudioPlayer.sharedInstance.playSound(sound: .specialMove, node: self)
            } else {
                AudioPlayer.sharedInstance.playSound(sound: .validMoved, node: self)
            }
            
            animateMoveToBlock(move: move, removeBoth: true)
            
        }
        
        takeMove()
        
        gameHUD!.updateHud(moves: level!.moves!, score: level!.score)
        finishMove(move: move)
        fillHoles()
        copyLevel()
    }
    
    //This function carries out a move to a tile
    func moveToTile(move: MoveToEmptyTile) {
        disableTouches()
        level!.moveBlock(fromColumn: move.blockA.column, fromRow: move.blockA.row, toColumn: move.toColumn, toRow: move.toRow)
        
        blocks[move.blockA.column, move.blockA.row] = nil
        blocks[move.toColumn, move.toRow] = move.blockA
        move.blockA.column = move.toColumn
        move.blockA.row = move.toRow
        
        AudioPlayer.sharedInstance.playSound(sound: .moveToSpace, node: self)
        animateMoveToTile(move: move, completion: {
            self.fillHoles()
            self.copyLevel()
        })
        
        takeMove()
        
        if level!.moves! == 0 {
            self.createMenu(type: .getMovesMenu)
        }
        gameHUD!.updateHud(moves: level!.moves!, score: level!.score)
    }
    
    func finishMove(move: Move) { // This function is called at the end of moveToBlock
        let gamemode = level!.gameMode!
        
        if gamemode == .target {
            
            if move.blockB.blockValue == level!.target! {
                //In any case, this is a win
                
                levelComplete()
            } else if level!.moves == 0 {
                //user can by more lives
                createMenu(type: .getMovesMenu)
            }
            
        } else if gamemode == .targetWithBlocks {
            
            if move.blockB.blockValue == level!.target! && level!.targetBlocks.isEmpty {
                //In any case, this is a win
                levelComplete()
            } else if move.blockB.blockValue == level!.target! && level!.targetBlocks.isEmpty == false {
                //In any case, this is fail
                createMenu(type: .failMenu)
                customDelegate!.reportLevelFail()
                AudioPlayer.sharedInstance.playSound(sound: .fail, node: self)
            } else if level!.moves == 0 {
                //user can by more lives
                createMenu(type: .getMovesMenu)
            }
            
        } else if gamemode == .targetWithScore {
            
            if move.blockB.blockValue == level!.target! && level!.score >= level!.targetScore! {
                //In any case, this is a win
                levelComplete()
            } else if move.blockB.blockValue == level!.target! && level!.score < level!.targetScore! {
                //In any case, this is fail
                createMenu(type: .failMenu)
                AudioPlayer.sharedInstance.playSound(sound: .fail, node: self)
                customDelegate!.reportLevelFail()
            } else if level!.moves == 0 {
                //user can by more lives
                createMenu(type: .getMovesMenu)
            }
        }
    }
    
    func levelComplete() {
        
        //Gets all of the users stats BEFORE calling "endGame" to update them.
        let playerLevel = customDelegate!.getPlayerLevel()
        let (oldLevelScore, nextLevelScore) = customDelegate!.nextPlayerLevel()
        let playerScore = customDelegate!.getPlayerScore()
        
        let scoreForLevel = CGFloat(nextLevelScore - oldLevelScore)
        let playerProgression = CGFloat(playerScore - oldLevelScore)
        let levelImpoved: Bool = customDelegate!.levelStatsImproved(goldenBlocks: getGoldenBlocks())
        
        customDelegate!.endGame(score: level!.score, goldenBlocks: getGoldenBlocks())
        createGameMenu(menu: .successMenu)
        
        let newPlayerLevel = customDelegate!.getPlayerLevel()
        
        AudioPlayer.sharedInstance.playSound(sound: .success, node: self)
        if newPlayerLevel > playerLevel {
            //The user has leveled up.
            if let successMenu = self.currentMenu as? successMenu {
                successMenu.userLeveledUp(oldLevel: playerLevel, newLevel: newPlayerLevel)
            }
        } else {
            //The user has not level up, so now we need to check if the player has improved their score for the level.
            print(levelImpoved)
            //This is returning false when its the first time they have played the level or just improved the socre.
            if levelImpoved {
                //The user has improved their score for the level.
                let newPlayerScore = customDelegate!.getPlayerScore()
                let newPlayerProgression = CGFloat(newPlayerScore - oldLevelScore)
                if let successMenu = self.currentMenu as? successMenu {
                    successMenu.updateUserProgression(playerLevel: playerLevel, playerProgression: playerProgression, newPlayerProgression: newPlayerProgression, scoreForLevel: scoreForLevel)
                }
            } else {
                //The user hasn't improved their score for the level.
                if let successMenu = self.currentMenu as? successMenu {
                    successMenu.userProgression(playerLevel: playerLevel, playerProgression: playerProgression, scoreForLevel: scoreForLevel)
                }
            }
        }
    }
    
    //Well... It takes a move.
    func takeMove() {
        level!.moves! -= 1
    }
    
    //This function is called after a level is complete and works out the number of golden blocks from the ideal score, and the returns it.
    func getGoldenBlocks() -> Int {
        //This function works out the number of golden blocks
        
        let perfectScore = level!.idealScore!
        let playersScore = level!.score
        
        if playersScore >= (perfectScore / 3) * 2 {
            return 3
        } else if playersScore >= (perfectScore / 3) {
            return 2
        } else {
            return 1
        }
    }
    
    //This function is called after every successful move and copys all relevent infomation for the player to undo to.
    func copyLevel() {
        moveNumber += 1
        
        let currentBlocks = level!.copyCurrentBlocks()
        previousBlocks.append(currentBlocks)
        
        let currentScore = level!.score
        previousScores.append(currentScore)
        
        if level!.gameMode == .targetWithBlocks {
            let currentTargetBlocks = level!.copyCurrentTargetBlocks()
            previousTargetBlocks.append(currentTargetBlocks)
        }
    }
    
    //This function undoes the level to the last time copyLevel was called.
    func undoLevel() {
        disableTouches()
        
        if moveNumber != 0 {
            takeMove()
            
            previousBlocks.remove(at: moveNumber)
            previousScores.remove(at: moveNumber)
            
            if level!.gameMode == .targetWithBlocks {
                previousTargetBlocks.remove(at: moveNumber)
            }
            moveNumber -= 1
            
            //Reset the gamescene blocks & array2d
            for row in 0 ..< numRows {
                for column in 0 ..< numColumns {
                    if let block = blocks[column, row] {
                        block.removeFromParent()
                        blocks[column, row] = nil
                    }
                }
            }
            
            //add the previous blocks to game scene
            self.addBlocks(for: previousBlocks[moveNumber])
            
            var targetBlocks: [blockType]?
            
            if level!.gameMode == .targetWithBlocks {
                targetBlocks = previousTargetBlocks[moveNumber]
            }
            
            level!.undoMove(previousBlocks: previousBlocks[moveNumber], score: previousScores[moveNumber], targetBlocks: targetBlocks)
        }
        
        gameHUD?.updateHud(moves: level!.moves!, score: level!.score)
        
        if level!.moves! == 0 {
            self.createMenu(type: .getMovesMenu)
        }
        
        enableTouches()
    }
    
    //This function is called after every successful move to a block and calculates the score for that move, and adds it to the current score.
    func calculateScore(move: Move) { // calculates core when player moves to block
        
        var score: Int = 0
        let blocksInMove = [move.blockA, move.blockB]
        
        for block in blocksInMove {
            switch block.blockType {
            case .unknown:
                score += 0
            case .orangeBlock:
                score += 16
            case .redBlock:
                score += 52
            case .greenBlock:
                score += 52
            case .blueBlock:
                score += 85
            }
        }
        level!.score += score
    }
    
    //This function is called after every successful move and updates the level (data moddle), the scenes array2D of blocks and then calls the animations
    func fillHoles() {
        
        //Updates level data model
        let blocks = level!.fillHoles()
        
        //Updates blocks in blocksArray2d
        var blocksToMove = [[Block]]()
        for columns in blocks {
            
            var column = [Block]()
            for blockStruct in columns {
                
                for row in blockStruct.row ..< numRows {
                    if let block = self.blocks[blockStruct.column, row] {
                        self.blocks[block.column, block.row] = nil
                        block.row = blockStruct.row
                        self.blocks[block.column, block.row] = block
                        column.append(block)
                        break
                    }
                }
                
            }
            if !column.isEmpty {
                blocksToMove.append(column)
            }
        }
        animateFillBlocks(blocks: blocksToMove)
    }
    
    //This function is called when in gamemode 1 (target blocks) after a successful move.
    func gamemode1ExtraSteps(move: Move) {
        for block in 0 ..< level!.targetBlocks.count {
            if move.blockA.blockType == level!.targetBlocks[block] {
                level!.targetBlocks.remove(at: block)
                print("A")
                break
            }
        }
        for block in 0 ..< level!.targetBlocks.count {
            if move.blockB.blockType == level!.targetBlocks[block] {
                level!.targetBlocks.remove(at: block)
                print("B")
                break
            }
        }
        print(level!.targetBlocks)
    }
    
    //MARK:- Animations
    
    //This functiom is called after a successful move to a block and animates it.
    func animateMoveToBlock(move: Move, removeBoth: Bool) {
        if !removeBoth {
            let pulse = SKAction.sequence([SKAction.scale(by: 10/9, duration: 0.1),
                                           SKAction.scale(by: 9/10, duration: 0.1),
                                           SKAction.scale(by: 10/9, duration: 0.1),
                                           SKAction.scale(by: 9/10, duration: 0.1)])
            
            move.blockB.run(pulse)
            move.blockA.removeFromParent()
        } else {
            move.blockA.removeFromParent()
            move.blockB.removeFromParent()
        }
    }
    
    //This function is called if the user attempts an invaled move and shakes a block.
    func animateInvalidMove(block: Block) {
        let shake = SKAction.sequence([SKAction.move(by: CGVector(dx: 5, dy: 0), duration: 0.05),
                                       SKAction.move(by: CGVector(dx: -10, dy: 0), duration: 0.1),
                                       SKAction.move(by: CGVector(dx: 5, dy: 0), duration: 0.05)])
        
        block.run(shake, completion: {
            self.enableTouches()
        })
    }
    
    //This functiom is called after a successful move to a tile and animates it.
    func animateMoveToTile(move: MoveToEmptyTile, completion: @escaping () -> Void) {
        let moveAction = SKAction.move(to: pointFor(column: move.toColumn, row: move.toRow), duration: 0.2)
        moveAction.timingMode = .easeOut
        
        move.blockA.run(moveAction, completion: completion)
    }
    
    //This function is animates a given array of blocks falling.
    func animateFillBlocks(blocks: [[Block]]) {
        print(blocks)
        var longestDuration: TimeInterval = 0
        for array in blocks {
            for (n, block) in array.enumerated() { // enumerated returns a pair (n,x) where n is the position in the array and x is the element
                let newPosition = pointFor(column: block.column, row: block.row)
                let delay = 0.1 + 0.1*TimeInterval(n)
                
                let duration = TimeInterval(((block.position.y - newPosition.y) / tileSize.height) * 0.1)
                
                longestDuration = max(longestDuration, duration + delay)
                
                let moveAction = SKAction.move(to: newPosition, duration: duration)
                moveAction.timingMode = .easeOut
                block.run(SKAction.sequence([
                    SKAction.wait(forDuration: delay),
                    SKAction.group([moveAction])]))
            }
        }
        run(SKAction.wait(forDuration: longestDuration), completion: {
            self.enableTouches()
        })
    }
    
    //This function is called by the GVC if the user has watched a rewarded video.
    func rewardUserWithMove() {
        customDelegate!.reportadWatchedForLife()
        level!.moves! += 1
        dismissMenu(all: true)
        self.gameHUD!.updateHud(moves: level!.moves!, score: level!.score)
    }
    
    //MARK:- Menu Function
    
    //Over writen these functions to allow menus to use GameScene functions and delegate.
    override func menuFunctionRestart() {
        let lives = customDelegate!.getLives()
        let unlimited = customDelegate!.livesUnlimited()
        if lives > 0 || unlimited {
            customDelegate!.restart()
        } else {
            createMenu(type: .getLifeMenu)
        }
    }
    
    override func menuFunctionHome() {
        customDelegate!.goHome()
        customDelegate!.presentInterstitial()
    }
    
    override func menuFunctionInfoMenu() {
        createMenu(type: .info)
        if let currentMenu = self.currentMenu! as? infoMenu {
            createMenuScrollView(node: currentMenu.movableNode, menuType: .info, vertical: true, scrollTillEnd: true)
        }
    }
    
    override func menuFunctionGetLife() {
        let gems = customDelegate!.getGems()
        if gems >= 40 {
            customDelegate!.take(consumable: .gems, number: 40)
            customDelegate!.addLife()
            customDelegate!.reportLifePurchased(amount: 1)
            self.dismissMenu(all: false)
        } else {
            createMenu(type: .shop)
            if let menu = currentMenu as? shop {
                createMenuScrollView(node: menu.movableNode, menuType: .shop, vertical: false, scrollTillEnd: true)
            }
        }
    }
    
    override func menuFunctionGetMoves() {
        let gems = customDelegate!.getGems()
        if gems >= 30 {
            customDelegate!.take(consumable: .gems, number: 30)
            customDelegate!.reportMovesPurchased()
            level!.moves! += 5
            self.gameHUD!.updateHud(moves: level!.moves!, score: level!.score)
            dismissMenu(all: true)
        } else {
            createMenu(type: .shop)
            if let menu = currentMenu as? shop {
                createMenuScrollView(node: menu.movableNode, menuType: .shop, vertical: false, scrollTillEnd: true)
            }
        }
    }
    
    override func menuFunctionWatchAdForMove() {
        customDelegate!.presentRewardedAd()
    }
    
    override func menuFunctionShopMenu() {
        createMenu(type: .shop)
        if let currentMenu = self.currentMenu! as? shop {
            createMenuScrollView(node: currentMenu.movableNode, menuType: .shop, vertical: false, scrollTillEnd: false)
        }
    }
    
    override func menuFunctionLevelSelect() {
        customDelegate!.presentInterstitial()
        customDelegate!.goToLevelSelect()
    }
    
    override func menuFunctionFailMenu() {
        createMenu(type: .failMenu)
        customDelegate!.reportLevelFail()
        AudioPlayer.sharedInstance.playSound(sound: .fail, node: self)
    }
}

//MARK:- This is where the succsess menu and help menu are created
extension GameScene {
    
    //This function is used to create the helpMenu and successMenu insted of the parent's "createMenu" function becuase they require infomation from GameScene.
    func createGameMenu(menu: menus) {
        if menu == .helpMenu {
            let newMenu = helpMenu(theme: self.theme, gameMode: level!.gameMode!, target: level!.target!, moves: level!.moves!, targetScore: level!.targetScore, targetBlocks: level!.targetBlocks)
            addMenuToScene(menu: newMenu)
        } else if menu == .successMenu {
            let newMenu = successMenu(theme: self.theme, goldenBlocks: getGoldenBlocks())
            addMenuToScene(menu: newMenu)
        } else {
            print("Canot add type \(menu)")
        }
    }
}
