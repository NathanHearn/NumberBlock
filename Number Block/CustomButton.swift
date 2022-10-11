//
//  CustomButton.swift
//  Number Block
//
//  Created by Nathan on 06/03/2018.
//  Copyright © 2018 Nathan. All rights reserved.
//

import SpriteKit

//Global var that all buttons can accsess, if false, a button has been touched and all other buttons can be used untill that button has finnished is action.
var canTouchButtons: Bool = true

//An array of buttons that have been pressed, if a button completes its action it will remove its self. if other buttons are in the array it will call a function to cancel the buttons and remove them from the array.
var touchesButtons = [CustomButton]()

class CustomButton: SKShapeNode {
    
    //MARK: - Button Properties
     var action: () -> Void
    
    private var shapePath: CGPath
    private var buttonColor: UIColor
    private var shadowBack: SKShapeNode?
    private var shadowFront: SKShapeNode?
    
    var actionEnabled: Bool = true
    
    var textLabel: SKLabelNode?
    private var buttonText: String?
    
    var positionInArray: Int?
    //if the button is pressed but the action shoudnt be excuted, then when the touches end the button will skip the action then return this value to false
    var doNotCompleteAction = false
    
    //MARK: - inits
    
    init(path: CGPath, text: String?, color: UIColor, textColor: UIColor, action: @escaping () -> Void) {
        self.action = action
        self.shapePath = path
        self.buttonText = text
        self.buttonColor = color
        
        super.init()
        
        self.path = shapePath
        self.fillColor = buttonColor; self.strokeColor = buttonColor
        
        let shadowBack = SKShapeNode(path: shapePath)
        shadowBack.fillColor = buttonColor; shadowBack.strokeColor = shadowBack.fillColor
        shadowBack.position = CGPoint(x: 0, y: -4); shadowBack.zPosition = -2
        self.addChild(shadowBack)
        self.shadowBack = shadowBack
        
        let shadowFront = SKShapeNode(path: shapePath)
        shadowFront.fillColor = UIColor(red: 127/256, green: 127/256, blue: 127/256, alpha: 0.25); shadowFront.strokeColor = shadowFront.fillColor // alpha = 0.25
        shadowFront.position = CGPoint(x: 0, y: -4); shadowFront.zPosition = -1
        self.addChild(shadowFront)
        self.shadowFront = shadowFront
        
        isUserInteractionEnabled = true // let the user intract with the button
        
        if let text: String = buttonText {
            let SKTextLabel = SKLabelNode(fontNamed: "Montserrat-Bold")
            SKTextLabel.text = text
            SKTextLabel.verticalAlignmentMode = .center
            SKTextLabel.horizontalAlignmentMode = .center
            SKTextLabel.fontColor = textColor
            while SKTextLabel.frame.width > self.frame.width - 20 {
                SKTextLabel.fontSize -= CGFloat(2)
            }
            self.textLabel = SKTextLabel
            addChild(textLabel!)
        }
    }
    
    
    
    convenience init(path: CGPath, spriteNamed: String, color: UIColor, action: @escaping () -> Void) { // This is a convenience init, it allows the me to uses an alternative init when adding sprites to buttons insted of text
        self.init(path: path, text: nil, color: color, textColor: UIColor.clear, action: action)
        
        let sprite = SKSpriteNode(imageNamed: spriteNamed)
        sprite.position = CGPoint(x: 0, y: 20)
        sprite.size = CGSize(width: 65, height: 60)
        self.addChild(sprite)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func removeShadow() {
        shadowFront!.removeFromParent()
        shadowBack!.removeFromParent()
    }
    
    //MARK: - Touch Controls
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !actionEnabled {return}
        //adds itself to the array of buttons that are currently pressed.
        positionInArray = touchesButtons.count
        touchesButtons.append(self)
        let touched = SKAction.scale(to: 0.95, duration: 0.1)
        self.run(touched)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !doNotCompleteAction {
            if !actionEnabled {return}
            if !canTouchButtons {return}
            if let positon = positionInArray {
                for button in 0 ..< touchesButtons.count {
                    if button != positon {
                        touchesButtons[button].doNotCompleteAction = true
                    }
                }
                //all the buttons have been delt with and will not excute or is the relesed button
                touchesButtons = []
            }
            //stops all other buttons being touched untill action completed.
            canTouchButtons = false
            self.isUserInteractionEnabled = false
            let unTouched = SKAction.sequence([SKAction.scale(to: 1.05, duration: 0.1),
                                               SKAction.scale(to: 1, duration: 0.1)])
            self.run(unTouched, completion: completeAction)
        } else {
            doNotCompleteAction = false
            self.run(SKAction.scale(to: 1, duration: 0.1))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //print("TouchMoved")
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchesEnded(touches, with: event)
    }
    
    func completeAction() {
        //allows other buttons to be pressed now the action is commpleted.
        canTouchButtons = true
        action()
        AudioPlayer.sharedInstance.playSound(sound: .buttonClick, node: self)
        self.isUserInteractionEnabled = true
    }
    
}

class ScrollViewButton: CustomButton {
    
    override init(path: CGPath, text: String?, color: UIColor, textColor: UIColor, action: @escaping () -> Void) {
        
        super.init(path: path, text: text, color: color, textColor: textColor, action: action)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touches began is replaced be 'buttonTouched()'")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touches began is replaced be 'buttonUntouched()'")
    }
    
    func buttonTouched() {
        if !actionEnabled {return}
        positionInArray = touchesButtons.count
        touchesButtons.append(self)
        let touched = SKAction.scale(to: 0.95, duration: 0.1)
        self.run(touched)
    }
    
    func buttonUntouched() {
        if !doNotCompleteAction {
            if !actionEnabled {return}
            if !canTouchButtons {return}
            if let positon = positionInArray {
                for button in 0 ..< touchesButtons.count {
                    if button != positon {
                        touchesButtons[button].doNotCompleteAction = true
                    }
                }
                //all the buttons have been delt with and will not excute or is the relesed button
                touchesButtons = []
            }
            //stops all other buttons being touched untill action completed.
            canTouchButtons = false
            self.isUserInteractionEnabled = false
            let unTouched = SKAction.sequence([SKAction.scale(to: 1.05, duration: 0.1),
                                               SKAction.scale(to: 1, duration: 0.1)])
            self.run(unTouched, completion: completeAction)
        } else {
            doNotCompleteAction = false
            self.run(SKAction.scale(to: 1, duration: 0.1))
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class MuteButton: CustomButton {
    
    var muted: Bool
    var line = SKShapeNode(path: CGPath(rect: CGRect(x: -27, y: -1, width: 54, height: 2), transform: nil))
    
    init(path: CGPath, color: UIColor, textColor: UIColor, muted: Bool) {
        
        self.muted = muted
        
        super.init(path: path, text: "Mute", color: color, textColor: textColor, action: {})
        
        line.fillColor = textColor; line.strokeColor = textColor
        
        if muted {
            self.addChild(self.line)
        }
        
        self.action = {
            if !AudioPlayer.sharedInstance.muted {
                self.muteStatusChanged(to: true)
            } else {
                self.muteStatusChanged(to: false)
            }
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func muteStatusChanged(to: Bool) {
        if to {
            AudioPlayer.sharedInstance.muteStatusChages(to: true)
            self.addChild(self.line)
        } else {
            AudioPlayer.sharedInstance.muteStatusChages(to: false)
            self.line.removeFromParent()
        }
    }
}
