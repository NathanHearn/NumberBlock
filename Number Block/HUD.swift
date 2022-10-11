//
//  HUD.swift
//  Number Block
//
//  Created by Nathan on 13/03/2018.
//  Copyright © 2018 Nathan. All rights reserved.
//

import SpriteKit

class HUD: SKShapeNode {
    
    var size = CGSize(width: 574, height: 90)
    let headerSize = CGSize(width: 140, height: 80)
    
    var theme: Theme
    var score: Int
    var moves: Int
    
    var scoreInfo: SKLabelNode?
    var movesInfo: SKLabelNode?
    
    init(theme: Theme, target: Int, moves: Int, score: Int, isIphoneX: Bool) {
        
        self.theme = theme
        self.score = score
        self.moves = moves
        
        super.init()
        
        var addWidth: CGFloat = 0
        
        if isIphoneX {
            self.size = CGSize(width: 574, height: 130)
            addWidth = 45
        }
        
        let origin = CGPoint(x: -size.width / 2, y: -size.height + 15) // The corner width is 15, this y origin makes it easy to position the HUD at the top
        
        self.path = CGPath(roundedRect: CGRect(x: origin.x, y: origin.y ,width: size.width, height: size.height) , cornerWidth: 20, cornerHeight: 20, transform: nil)
        self.fillColor = theme.customOrangeColor; self.strokeColor = theme.customOrangeColor
        
        //Creates the shadow and 3d effect for HUD
        let shadowBack = SKShapeNode(path: self.path!)
        shadowBack.position = CGPoint(x: 0, y: -4); shadowBack.zPosition = -2
        shadowBack.fillColor = theme.customOrangeColor; shadowBack.strokeColor = theme.customOrangeColor
        self.addChild(shadowBack)
        
        let shadowFront = SKShapeNode(path: self.path!)
        shadowFront.fillColor = UIColor(red: 127/256, green: 127/256, blue: 127/256, alpha: 0.25); shadowFront.strokeColor = shadowFront.fillColor
        shadowFront.position = CGPoint(x: 0, y: -4); shadowFront.zPosition = -1
        self.addChild(shadowFront)
        
        let header = SKShapeNode(path: CGPath(roundedRect: CGRect(x: -headerSize.width / 2, y: -headerSize.height / 2 ,width: headerSize.width, height: headerSize.height) , cornerWidth: 15, cornerHeight: 15, transform: nil))
        header.position = CGPoint(x: 0, y: -self.size.height + 20); header.zPosition = 3
        header.fillColor = theme.customOrangeColor; header.strokeColor = theme.customOrangeColor
        self.addChild(header)
        
        let headerShadowBack = SKShapeNode(path: header.path!)
        headerShadowBack.position = CGPoint(x: 0, y: -4); headerShadowBack.zPosition = -2
        headerShadowBack.fillColor = theme.customOrangeColor; headerShadowBack.strokeColor = theme.customOrangeColor
        header.addChild(headerShadowBack)
        
        let headerShadowFront = SKShapeNode(path: header.path!)
        headerShadowFront.fillColor = UIColor(red: 127/256, green: 127/256, blue: 127/256, alpha: 0.25); headerShadowFront.strokeColor = headerShadowFront.fillColor
        headerShadowFront.position = CGPoint(x: 0, y: -4); headerShadowFront.zPosition = -1
        header.addChild(headerShadowFront)
        
        let targetLabel = SKLabelNode(fontNamed: "Montserrat-Bold")
        targetLabel.text = "Target:"
        targetLabel.fontSize = 28
        targetLabel.fontColor = theme.customTextColor
        targetLabel.position = CGPoint(x: 0, y: 28)
        header.addChild(targetLabel)
        
        let movesLabel = SKLabelNode(fontNamed: "Montserrat-Bold")
        movesLabel.text = "Moves:"
        movesLabel.fontSize = 22
        movesLabel.fontColor = theme.customTextColor
        movesLabel.position = CGPoint(x: ((-self.size.width - 70) / 4) - addWidth, y: 40)
        header.addChild(movesLabel)
        
        let scoreLabel = SKLabelNode(fontNamed: "Montserrat-Bold")
        scoreLabel.text = "Score:"
        scoreLabel.fontSize = 22
        scoreLabel.fontColor = theme.customTextColor
        scoreLabel.position = CGPoint(x: ((self.size.width + 70) / 4) + addWidth, y: 40)
        header.addChild(scoreLabel)
        
        let targeInfo = SKLabelNode(fontNamed: "Montserrat-Bold")
        targeInfo.text = "\(target)"
        targeInfo.fontSize = 44
        targeInfo.fontColor = theme.customTextColor
        targeInfo.position = CGPoint(x: 0, y: -25)
        header.addChild(targeInfo)
        
        movesInfo = SKLabelNode(fontNamed: "Montserrat-Bold")
        movesInfo!.text = "\(moves)"
        movesInfo!.fontSize = 36
        movesInfo!.fontColor = theme.customTextColor
        movesInfo!.position = CGPoint(x: ((-self.size.width - 70) / 4) - addWidth, y: 5)
        header.addChild(movesInfo!)
        
        scoreInfo = SKLabelNode(fontNamed: "Montserrat-Bold")
        scoreInfo!.text = "\(0)"
        scoreInfo!.fontSize = 36
        scoreInfo!.fontColor = theme.customTextColor
        scoreInfo!.position = CGPoint(x: ((self.size.width + 70) / 4) + addWidth, y: 5)
        header.addChild(scoreInfo!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateHud(moves: Int, score: Int) {
        animateUpdate(label: movesInfo!,completion: {})
        movesInfo!.text = "\(moves)"
        self.moves = moves
        
        if self.score < score { //Not an undo move
            
            let startPosition = CGPoint(x: 0, y: -60)
            let scoreToAdd = score - self.score
            
            let tempScoreLabel = SKLabelNode(fontNamed: "Montserrat-Bold")
            tempScoreLabel.fontColor = theme.customTextColor
            tempScoreLabel.fontSize = 36
            tempScoreLabel.text = "+\(scoreToAdd)"
            tempScoreLabel.position = startPosition
            tempScoreLabel.zPosition = 50
            scoreInfo!.addChild(tempScoreLabel)
            
            animateUpdate(label: tempScoreLabel, completion: {
                let moveAction = SKAction.move(to: CGPoint(x: 0, y: 0), duration: 0.2)
                tempScoreLabel.run(moveAction, completion: {
                    tempScoreLabel.removeFromParent()
                    self.animateUpdate(label: self.scoreInfo!,completion: {})
                    self.scoreInfo!.text = "\(score)"
                })
            })
        } else if self.score != score { //An undo move, not a move to tile
            animateUpdate(label: self.scoreInfo!,completion: {})
            self.scoreInfo!.text = "\(score)"
        }
        self.score = score
    }
    
    func animateUpdate(label: SKLabelNode, completion: @escaping () -> Void) {
        let pulse = SKAction.sequence([SKAction.scale(by: 10/9, duration: 0.1),
                                       SKAction.scale(by: 9/10, duration: 0.2)])
        
        label.run(pulse, completion: completion)
    }
}
