//
//  SelectScene.swift
//  Number Block
//
//  Created by Nathan on 07/03/2018.
//  Copyright © 2018 Nathan. All rights reserved.
//

import SpriteKit

protocol SelectSceneDelegate {
    //MARK:- Scene specific functions
    func startGame(level: Int)
    func getNextLevel() -> Int
    func nextLifeIn() -> CGFloat
    func getGoldenBlocksFor(level: Int) -> Int
    func addLife()
    
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

class SelectScene: CustomScene {
    
    //MARK:- properties
    
    var firstButtonY: CGFloat?
    var backButton: CustomButton!
    var nextLevelAt: CGFloat?
    
    //This stores the refrence for the scrollView for the level start buttons
    var levelScrollView: CustomScrollView?
    
    //MARK:- Delegate
    var customDelegate: SelectSceneDelegate?
    
    //MARK:- Init
    
    override func didMove(to view: SKView) {
        //A node is returned has the level select buttons and is the moveable node for the levelScrollView
        let node = addLevels()
        addBackButton()
        
        //The levelScrollView is created and given the node made above.
        addScrollView(node: node)
        levelScrollView!.enable()
        
        if let nextLevelPoint = nextLevelAt {
            scrollToPoint(point: nextLevelPoint)
        }
    }
    
    //MARK:- Functions
    
    //Over writes the function in the parent class to get the time to the next life through the delegate.
    override func timeToNextLife() -> CGFloat {
        let timeLeft = customDelegate!.nextLifeIn()
        print(timeLeft)
        return timeLeft
    }
    
    //Over writes the parent's function to allow it to use the delegate to add a scrollView for the menus (Shop)
    override func addScrollView(scollView: CustomScrollView) {
        let newScrollView = scollView
        self.scrollView = newScrollView
        customDelegate!.addScrollView(scrollView: newScrollView)
    }
        
    //function over written to enable levelscrollview if last menu dismissed.
    override func enableOtherObjects() {
        levelScrollView!.enable()
    }
    
    //This function CREATES and ADDs the scrollView for the level select buttons (This is not the over written function used to add scrollViews for menus as this scene still needs that for menus).
    func addScrollView(node: SKNode) {
        
        let ratio = view!.frame.height / self.frame.height
        
        var bounds = CGRect(x: 0, y: 0, width: self.size.width * ratio, height: self.size.height * ratio)
        //var bounds = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        if let frame = view {
            //If the scene is being presented by a view (It always should be!), it resizes the scrollview frame
            bounds = frame.bounds
        }
        
        let scrollView = CustomScrollView(frame: bounds, scene: self, moveableNode: node, scrollDirecton: .vertical)
        //Content size is set to firstButtonY + 600, which is the corret size for the ipad 9.7 (defult size for scene)
        //1000 * the ratio is then taken from that number to make it fit on all screen sizes. IDK why 1000 works or why taking the ratio from 1 works, but it does.
        scrollView.contentSize = CGSize(width: 0, height: -firstButtonY! + (600 - (1000 * (1 - ratio))))
        scrollView.setContentOffset(CGPoint(x: 0, y: -firstButtonY! - 430), animated: false)
        
        self.levelScrollView = scrollView
        customDelegate!.addScrollView(scrollView: scrollView)
        self.addChild(node)
    }
    
    func scrollToPoint(point: CGFloat) {
        if let scrollView = levelScrollView {
            scrollView.setContentOffset(CGPoint(x: 0,y: -point), animated: true)
        }
    }
    
    //This function creates a node with the buttons to select each button.
    func addLevels() -> SKNode {
        let node = SKNode() // This is the node that gets added to the scrollview
        
        let buttonPath = CGPath(roundedRect: CGRect(x: -39, y: -37, width: 76, height: 72), cornerWidth: 15, cornerHeight: 15, transform: nil)
        
        let firstButton = CustomButton(path: buttonPath, text: "\(1)", color: theme.customOrangeColor, textColor: theme.customTextColor, action: {
            self.createLevelSelectMenu(level: 1)
        })
        firstButton.textLabel!.fontSize = 38
        //firstButton.position = CGPoint(x: -90, y: -13000)
        firstButton.position = CGPoint(x: -90, y: -4000)
        node.addChild(firstButton)
        
        firstButtonY = firstButton.position.y
        
        var counter = 0
        var direction = "right"
        var previousXDirection = "right"
        var lastPosition = firstButton.position
        let nextLevel = customDelegate!.getNextLevel()
        
        for level in 2 ... 100 {
            
            //This part works out if it shold place the next button up left or right
            if counter == 2 {
                if direction == "right" || direction == "left" {
                    previousXDirection = direction
                    direction = "up" // if its just moved left or right 2 then it must go up
                } else if previousXDirection == "right" {
                    direction = "left"
                } else {
                    direction = "right"
                }
                counter = 1
            } else {
                counter += 1
            }
            
            let nextButton = CustomButton(path: buttonPath, text: "\(level)", color: theme.customOrangeColor, textColor: theme.customTextColor, action: {
                self.createLevelSelectMenu(level: level)
            })
            
            if level < 200 {
                nextButton.textLabel!.fontSize = 38
            } else {
                nextButton.textLabel!.fontSize = 36
            }
            
            if nextLevel < level {
                nextButton.actionEnabled = false
                let mask = SKShapeNode(path: CGPath(roundedRect: CGRect(x: -39, y: -37, width: 76, height: 72), cornerWidth: 15, cornerHeight: 15, transform: nil))
                mask.fillColor = UIColor(red: 127/255, green: 127/255, blue: 127/255, alpha: 0.25)
                mask.strokeColor = mask.fillColor
                mask.zPosition = 90
                nextButton.addChild(mask)
            } else if nextLevel == level && nextLevel > 12 && nextLevel < 91 {
                nextLevelAt = lastPosition.y
            } else if nextLevel == level && nextLevel > 91 {
                nextLevelAt = 10
            }
            
            if direction == "right" {
                nextButton.position = CGPoint(x: lastPosition.x + 90, y: lastPosition.y)
                lastPosition = nextButton.position
            } else if direction == "left" {
                nextButton.position = CGPoint(x: lastPosition.x - 90, y: lastPosition.y)
                lastPosition = nextButton.position
            } else { //must be "up"
                nextButton.position = CGPoint(x: lastPosition.x, y: lastPosition.y + 90)
                lastPosition = nextButton.position
            }
            node.addChild(nextButton)
        }
        return node
    }
    
    func addBackButton() {
        
        var extraHight: CGFloat = 0
        
        if customDelegate!.isIPhoneX() {
            extraHight = 60
        }
        
        let buttonPath = CGPath(roundedRect: CGRect(x: -40, y: -25, width: 80, height: 50), cornerWidth: 13, cornerHeight: 13, transform: nil)
        let button = CustomButton(path: buttonPath, text: "Back", color: theme.customOrangeColor, textColor: theme.customTextColor, action: {
            self.customDelegate!.goHome()
            self.levelScrollView!.removeFromSuperview()
        })
        button.position = CGPoint(x: -230, y: 475 + extraHight)
        self.addChild(button)
        self.backButton = button
    }
    
    //This function tells the delegate to start a level and removes the levelScrollView
    func startGame(level: Int) {
        let numberOfLives = customDelegate!.getLives()
        let unlimited = customDelegate!.livesUnlimited()
        
        if numberOfLives > 0 || unlimited {
            customDelegate!.startGame(level: level)
            levelScrollView!.removeFromSuperview()
        } else {
            self.createMenu(type: .getLifeMenu)
        }
    }
    
    //MARK:- Menu Functions
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
}

//MARK:- This is where the levelSelectMenu is created.
extension SelectScene {
    
    //This function is used to create the levelSelectMenu insted of the parent's "createMenu" function becuase it require infomation from SelectScenes Delegate.
    func createLevelSelectMenu(level: Int) {
        let numberOfGoldenBlocks = customDelegate!.getGoldenBlocksFor(level: level)
        
        self.levelScrollView!.disable()
        self.disableTouches()
        
        let menu = levelSelectMenu(theme: theme, level: level, goldenBlocks: numberOfGoldenBlocks, dismissAction: {
            self.startGame(level: level)
        })
        
        addMenuToScene(menu: menu)
    }
}
