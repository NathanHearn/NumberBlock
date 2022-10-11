//
//  CustomProgressBar.swift
//  Number Block
//
//  Created by Nathan on 06/03/2018.
//  Copyright © 2018 Nathan. All rights reserved.
//

import SpriteKit

class ProgressBar: SKShapeNode {
    private let length: CGFloat
    private let height: CGFloat
    private let colour: UIColor
    private let endValue: CGFloat
    var currentProgress: CGFloat
    var cornerSize: CGFloat = 5
    
    init(progress: CGFloat, endValue: CGFloat, length: CGFloat, height: CGFloat, colour: UIColor) {
        self.colour = colour
        self.length = length
        self.height = height
        self.currentProgress = progress
        self.endValue = endValue
        
        super.init()
        
        let percentageProgress: CGFloat = progress/endValue
        print(percentageProgress)
        var progressLength:Int = Int(length*percentageProgress) //making it an Int is the easiest way of rounding to a whole number
        
        if progressLength < 10 {
            if progressLength < 4 {
                progressLength = 4
            }
            cornerSize = CGFloat(progressLength / 2)
        }
        
        self.path = CGPath(roundedRect: CGRect(x: -self.length / 2, y: -height / 2, width: CGFloat(progressLength), height: height) , cornerWidth: cornerSize, cornerHeight: cornerSize, transform: nil)
        self.fillColor = colour; self.strokeColor = colour
        
        let backGround = SKShapeNode(path: CGPath(roundedRect: CGRect(x: -self.length / 2, y: -height / 2, width: self.length, height: height) , cornerWidth: 5, cornerHeight: 5, transform: nil))
        backGround.fillColor = UIColor(red: 127/256, green: 127/256, blue: 127/256, alpha: 0.25); backGround.strokeColor = backGround.fillColor
        backGround.zPosition = -1
        self.addChild(backGround)
        
    }
    
    func updateProgress(progress: CGFloat) {
        print(44)
        let percentageProgress: CGFloat = progress/endValue
        var progressLength:Int = Int(length*percentageProgress)
        
        if progressLength < 10 {
            if progressLength < 4 {
                progressLength = 4
            }
            cornerSize = CGFloat(progressLength / 2)
        }
        
        let pulseIn = SKAction.sequence([SKAction.scale(to: 1.1, duration: 0.2),
                                         SKAction.scale(to: 0.6, duration: 0.1)])
        let pulseOut = SKAction.sequence([SKAction.scale(to: 1.1, duration: 0.1),
                                          SKAction.scale(to: 1, duration: 0.2)])
        
        self.run(pulseIn, completion: {
            self.path = CGPath(roundedRect: CGRect(x: -self.length / 2, y: -self.height / 2, width: CGFloat(progressLength), height: self.height) , cornerWidth: self.cornerSize, cornerHeight: self.cornerSize, transform: nil)
            self.run(pulseOut)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
