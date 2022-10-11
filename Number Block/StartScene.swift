//
//  StartScene.swift
//  Number Block
//
//  Created by Nathan on 07/03/2018.
//  Copyright © 2018 Nathan. All rights reserved.
//

import SpriteKit

protocol StartSceneDelegate {
    //MARK:- Scene specific functions
    func updateTheme(themeNumber: Int)
    func mute()
    func goToLevelSelect()
    func getPlayerLevel() -> Int
    func nextPlayerLevel() -> (lastLevelScore: Int, nextLevelScore: Int)
    func getPlayerScore() -> Int
    func getAllThemes() -> (themes: [Theme], unlocked: [Bool])
    func unlockTheme(themeNumber: Int, showNow: Bool)
    func newThemeUnlocked(seen: Bool) -> Bool
    func reportThemePurchased(themeNumber: Int)
    func loginWithFacebook()
    func loggedInFacebook() -> Bool
    
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

class StartScene: CustomScene {
    
    //MARK:- properties
    
    var startButton: CustomButton?
    var storeButton: CustomButton?
    var themesButton: CustomButton?
    
    var livesLabel: SKLabelNode?
    var lifeSprite: SKSpriteNode!
    var gemsLabel: SKLabelNode?
    
    var newThemes: Bool?
    
    //MARK:- Delegate
    var customDelegate: StartSceneDelegate?
    
    //MARK:- Init
    
    override func didMove(to view: SKView) {
        addHUD()
        createLogo()
        addButtons()
        
        newThemes = customDelegate!.newThemeUnlocked(seen: false)
        if newThemes! {
            animateThemesButton(start: true)
        }
        
        if GameHandler.sharedInstance.firstTimeUser {
            self.createMenu(type: .info)
            if let currentMenu = self.currentMenu! as? infoMenu {
                self.createMenuScrollView(node: currentMenu.movableNode, menuType: .info, vertical: true, scrollTillEnd: true)
            }
            GameHandler.sharedInstance.firstTimeUser = false
        }
    }
    
    //MARK:- Functions
    
    //This function is overrides the parent's function to allow it to update the number of lives label.
    override func didBecomeActive() {
        if let labelForGems = gemsLabel {
            let numberOfGems = GameHandler.sharedInstance.numberOfGems
            labelForGems.text = "x\(numberOfGems)"
        }
        if let labelForLives = livesLabel {
            if customDelegate!.livesUnlimited() {
                labelForLives.text = "∞"
                labelForLives.fontSize = 45
                labelForLives.position = CGPoint(x: lifeSprite.position.x + 30, y: lifeSprite.position.y - 3)
            } else {
                let numberOfLives: Int = self.customDelegate!.getLives()
                labelForLives.text = "x\(numberOfLives)"
                labelForLives.fontSize = 36
                labelForLives.position = CGPoint(x: lifeSprite.position.x + 30, y: lifeSprite.position.y)
            }
        }
    }
    
    //This function is overrides the parent's function to allow it to use the delegate to add a scrollView for the menus.
    override func addScrollView(scollView: CustomScrollView) {
        let newScrollView = scollView
        self.scrollView = newScrollView
        customDelegate!.addScrollView(scrollView: newScrollView)
    }
    
    //Over writes the function in the parent class to also disable the buttons (for when the scrollView for menus is added).
    override func disableTouches() {
        if let startButton = self.startButton {
            startButton.actionEnabled = false
            storeButton!.actionEnabled = false
            // if the start button was added we know the store button was also added
        }
        self.isUserInteractionEnabled = false
        if let scrollView = self.scrollView {
            scrollView.disable()
        }
    }
    
    //Over writes the function in the parent class to also enable the buttons (for when the scrollView for menus is removed).
    override func enableTouches() {
        if let startButton = self.startButton {
            startButton.actionEnabled = true
            storeButton!.actionEnabled = true
            // if the start button was added we know the store button was also added
        }
        
        self.isUserInteractionEnabled = true
        if let scrollView = self.scrollView {
            scrollView.enable()
        }
    }
    
    //Create and adds all of the HUD items for the StartScene.
    func addHUD() {
        
        var extraHight: CGFloat = 0
        
        if customDelegate!.isIPhoneX() {
            extraHight = 70
        }
        
        let gemSprite = SKSpriteNode(imageNamed: "gem with detail.png")
        gemSprite.size = CGSize(width: 54, height: 45)
        gemSprite.position = CGPoint(x: -250, y: 470 + extraHight); gemSprite.zPosition = 10
        self.addChild(gemSprite)
        
        let labelForGems = SKLabelNode(fontNamed: "Montserrat-Bold")
        labelForGems.text = "x\(customDelegate!.getGems())"
        labelForGems.fontSize = 36
        labelForGems.fontColor = theme.customTextColor
        labelForGems.verticalAlignmentMode = .center; labelForGems.horizontalAlignmentMode = .left
        labelForGems.position = CGPoint(x: gemSprite.position.x + 30, y: gemSprite.position.y)
        self.addChild(labelForGems)
        
        gemsLabel = labelForGems
        
        let lifeSprite = SKSpriteNode(imageNamed: "Life with detail.png")	
        lifeSprite.size = CGSize(width: 51, height: 46)
        lifeSprite.position = CGPoint(x: -250, y: gemSprite.position.y - 50); lifeSprite.zPosition = 10
        self.addChild(lifeSprite)
        
        self.lifeSprite = lifeSprite
        
        let labelForlives = SKLabelNode(fontNamed: "Montserrat-Bold")
        let lives = customDelegate!.getLives()
        let unlimited = customDelegate!.livesUnlimited()
        if unlimited {
            labelForlives.text = "∞"
            labelForlives.fontSize = 45
            labelForlives.position = CGPoint(x: lifeSprite.position.x + 30, y: lifeSprite.position.y - 3)
        } else {
            labelForlives.text = "x\(lives)"
            labelForlives.fontSize = 36
            labelForlives.position = CGPoint(x: lifeSprite.position.x + 30, y: lifeSprite.position.y)
        }
        labelForlives.fontColor = theme.customTextColor
        labelForlives.verticalAlignmentMode = .center; labelForlives.horizontalAlignmentMode = .left
        self.addChild(labelForlives)
        
        livesLabel = labelForlives
        print("label assigned")
        
        let playerLevel = customDelegate!.getPlayerLevel()
        let levelLabel = CustomButton(path: CGPath(roundedRect: CGRect(x: -35, y: -34, width: 70, height: 68), cornerWidth: 15, cornerHeight: 15, transform: nil), text: "\(playerLevel)", color: theme.customOrangeColor, textColor: theme.customTextColor, action: {})
        levelLabel.isUserInteractionEnabled = false
        levelLabel.textLabel!.fontSize = 40
        levelLabel.position = CGPoint(x: 50, y: 465 + extraHight)
        self.addChild(levelLabel)
        
        
        let (oldLevelScore, nextLevelScore) = customDelegate!.nextPlayerLevel()
        let playerScore = customDelegate!.getPlayerScore()
        
        let scoreForLevel = CGFloat(nextLevelScore - oldLevelScore)
        let playerProgression = CGFloat(playerScore - oldLevelScore)
        
        let levelProgressBar = ProgressBar(progress: playerProgression, endValue: scoreForLevel, length: 170, height: 28, colour: theme.customGreenColor)
        levelProgressBar.position = CGPoint(x: 182, y: 465 + extraHight); levelProgressBar.zPosition = 100
        self.addChild(levelProgressBar)
    }
    
    //Create and adds the logo for the StartScene.
    func createLogo() {
        
        let yPosition = 200
        
        let blockPath = CGPath(roundedRect: CGRect(x: -34, y: -33, width: 68, height: 66), cornerWidth: 15, cornerHeight: 15, transform: nil)
        
        //let logoText = ["N","u","m","b","3","r","B","2","o","c","k"]
        let logoText = ["N","u","m","b","3","r","B","1","o","c","k"]
        var lastBlock: CustomButton?
        
        for letter in logoText {
            
            var blockColor = theme.customOrangeColor
            if letter == "3" {
                blockColor = theme.customRedColor
            } else if letter == "1" {
                blockColor = theme.customGreenColor
            }
            
            let block = CustomButton(path: blockPath, text: letter, color: blockColor!, textColor: theme.customTextColor, action:{})
            block.isUserInteractionEnabled = false
            block.textLabel!.fontSize = 40
            block.textLabel!.fontName = "Montserrat-Bold"
            if letter == "u" || letter == "m" || letter == "o" || letter == "c" {
                block.textLabel!.position = CGPoint(x: 0, y: -2)
            }
            block.zPosition = 100
            
            if let lastBlock = lastBlock {
                if letter == "B" {
                    block.position = CGPoint(x: lastBlock.position.x - (74 * 3), y: lastBlock.position.y - 76)
                } else {
                    block.position = CGPoint(x: lastBlock.position.x + 74, y: lastBlock.position.y)
                }
            } else {
                block.position = CGPoint(x: -222, y: yPosition)
            }
            self.addChild(block)
            lastBlock = block
        }
    }
    
    //Create and adds all of the buttons for the StartScene.
    func addButtons() {
        
        let yPosition = -110
        
        let largePath = CGPath(roundedRect: CGRect(x: -125, y: -38, width: 250, height: 76), cornerWidth: 15, cornerHeight: 15, transform: nil)
        let smallPath = CGPath(roundedRect: CGRect(x: -38, y: -38, width: 76, height: 76), cornerWidth: 15, cornerHeight: 15, transform: nil)
        
        let colorBlocksPath = CGPath(roundedRect: CGRect(x: -8, y: -8, width: 16, height: 16), cornerWidth: 2, cornerHeight: 2, transform: nil)
        
        //Start Button
        
        let startButton = CustomButton(path: largePath, text: "Start", color: theme.customOrangeColor, textColor: theme.customTextColor, action: {
            self.customDelegate!.goToLevelSelect()
        })
        startButton.position = CGPoint(x: 0, y: yPosition); startButton.zPosition = 100
        startButton.textLabel!.fontSize = 40
        self.addChild(startButton)
        self.startButton = startButton
        
        //Store button
        
        let storeButton = CustomButton(path: largePath, text: "Store", color: theme.customOrangeColor, textColor: theme.customTextColor, action: {
            self.createMenu(type: .shop)
            if let currentMenu = self.currentMenu! as? shop {
                self.createMenuScrollView(node: currentMenu.movableNode, menuType: .shop, vertical: false, scrollTillEnd: false)
            }
        })
        storeButton.position = CGPoint(x: 0, y: startButton.position.y - 90); storeButton.zPosition = 100
        storeButton.textLabel!.fontSize = 40
        self.addChild(storeButton)
        self.storeButton = storeButton
        
        //Mute button
        
        let muteButton = MuteButton(path: smallPath, color: theme.customOrangeColor, textColor: theme.customTextColor, muted: AudioPlayer.sharedInstance.muted)
        muteButton.position = CGPoint(x: -90, y: storeButton.position.y - 90); muteButton.zPosition = 100
        self.addChild(muteButton)
        
        //Theme button
        
        let themeButton = CustomButton(path: smallPath, text: "", color: theme.customOrangeColor, textColor: theme.customTextColor, action: {
            self.createThemesMenu()
            self.newThemes = self.customDelegate!.newThemeUnlocked(seen: true)
            self.animateThemesButton(start: false)
            if let currentMenu = self.currentMenu! as? themesMenu {
                self.createMenuScrollView(node: currentMenu.movableNode, menuType: .themesMenu, vertical: true, scrollTillEnd: false)
            }
        })
        themeButton.position = CGPoint(x: 0, y: storeButton.position.y - 90); themeButton.zPosition = 100
        self.addChild(themeButton)
        self.themesButton = themeButton
        
        let backgroundBlock = SKShapeNode(path: colorBlocksPath)
        backgroundBlock.fillColor = theme.customBackgroundColor; backgroundBlock.strokeColor = backgroundBlock.fillColor
        backgroundBlock.position = CGPoint(x: -10, y: 10)
        themeButton.addChild(backgroundBlock)
        
        let redBlock = SKShapeNode(path: colorBlocksPath)
        redBlock.fillColor = theme.customRedColor; redBlock.strokeColor = redBlock.fillColor
        redBlock.position = CGPoint(x: 10, y: 10)
        themeButton.addChild(redBlock)
        
        let greenBlock = SKShapeNode(path: colorBlocksPath)
        greenBlock.fillColor = theme.customGreenColor; greenBlock.strokeColor = greenBlock.fillColor
        greenBlock.position = CGPoint(x: -10, y: -10)
        themeButton.addChild(greenBlock)
        
        let blueBlock = SKShapeNode(path: colorBlocksPath)
        blueBlock.fillColor = theme.customBlueColor; blueBlock.strokeColor = blueBlock.fillColor
        blueBlock.position = CGPoint(x: 10, y: -10)
        themeButton.addChild(blueBlock)
        
        //Info button
        
        let infoButton = CustomButton(path: smallPath, text: "i", color: theme.customOrangeColor, textColor: theme.customTextColor, action: {
            self.createMenu(type: .info)
            if let currentMenu = self.currentMenu! as? infoMenu {
                self.createMenuScrollView(node: currentMenu.movableNode, menuType: .info, vertical: true, scrollTillEnd: true)
            }
        })
        infoButton.position = CGPoint(x: 90, y: storeButton.position.y - 90); infoButton.zPosition = 100
        infoButton.textLabel!.fontName = "Montserrat-BoldItalic"
        infoButton.textLabel!.fontSize = 40
        self.addChild(infoButton)
        
        //Facebook Button
        let loggedIn = customDelegate!.loggedInFacebook()
        if !loggedIn {
            let facebookBlue = UIColor(red: 59/255, green: 89/255, blue: 152/255, alpha: 1)
            let facebookButtonPath = CGPath(roundedRect: CGRect(x: -38, y: -36, width: 76, height: 72), cornerWidth: 15, cornerHeight: 15, transform: nil)
            let facebookButton = CustomButton(path: facebookButtonPath, text: "f", color: facebookBlue, textColor: theme.customTextColor, action: {
                self.customDelegate!.loginWithFacebook()
            })
            facebookButton.textLabel!.fontSize = 55
            facebookButton.textLabel!.position = CGPoint(x: facebookButton.textLabel!.position.x + 5, y: 0)
            facebookButton.position = CGPoint(x: 0, y: -410); themeButton.zPosition = 100
            self.addChild(facebookButton)
            
            let gemSprite = SKSpriteNode(imageNamed: "gem with detail.png")
            gemSprite.size = CGSize(width: 44, height: 35)
            gemSprite.position = CGPoint(x: facebookButton.position.x - 30, y: facebookButton.position.y - 65); gemSprite.zPosition = 10
            self.addChild(gemSprite)
            
            let gemsLabel = SKLabelNode(fontNamed: "Montserrat-Bold")
            gemsLabel.text = "x70"
            gemsLabel.fontSize = 30
            gemsLabel.fontColor = theme.customTextColor
            gemsLabel.verticalAlignmentMode = .center; gemsLabel.horizontalAlignmentMode = .left
            gemsLabel.position = CGPoint(x: gemSprite.position.x + 25, y: gemSprite.position.y)
            self.addChild(gemsLabel)
        }
    }
    
    override func menuFunctionSelectTheme() {
        if let menu = currentMenu as? themesMenu {
            self.removeScrollView()
            let newThemeNumber = menu.selectedThemeNumber!
            let themeUnlocked = menu.selectedThemeUnlocked!
            
            if themeUnlocked {
                customDelegate!.updateTheme(themeNumber: newThemeNumber)
            } else {
                let unlockLevel = menu.selectedThemeRequiredLevel!
                createGetThemeMenu(themeNumber: newThemeNumber, unlockLevel: unlockLevel)
            }
        }
    }
    
    override func menuFunctionGetTheme() {
        let gems = customDelegate!.getGems()
        if gems >= 150 {
            customDelegate!.take(consumable: .gems, number: 150)
            if let menu = currentMenu as? getThemeMenu {
                let themeNumber = menu.themeNumber
                self.customDelegate!.unlockTheme(themeNumber: themeNumber, showNow: true)
                self.customDelegate!.reportThemePurchased(themeNumber: themeNumber)
            }
        } else {
            createMenu(type: .shop)
            if let menu = currentMenu as? shop {
                createMenuScrollView(node: menu.movableNode, menuType: .shop, vertical: false, scrollTillEnd: true)
            }
        }
    }
    
    //MARK:- Animations
    
    func animateThemesButton(start: Bool) {
        
        let pulse = SKAction.sequence([SKAction.scale(to: 0.9, duration: 0.1),
                                       SKAction.scale(to: 1.1, duration: 0.1),
                                       SKAction.scale(to: 0.9, duration: 0.2),
                                       SKAction.scale(to: 1, duration: 0.1),
                                       SKAction.wait(forDuration: 0.5)])
        
        let repetingPulse = SKAction.repeatForever(pulse)
        
        if start {
            if let button = themesButton {
                button.run(repetingPulse)
            }
        } else {
            if let button = themesButton {
                button.removeAllActions()
                
                let scalseBack = SKAction.scale(to: 1, duration: 0.1)
                button.run(scalseBack)
            }
        }
    }
}

//MARK:- This is where the themesMenu and getThemesMenu is created.
extension StartScene {
    
    //This function is used to create the themesMenu insted of the parent's "createMenu" function becuase it require infomation from StartScenes Delegate.
    func createThemesMenu() {
        let (themes, unlocked) = customDelegate!.getAllThemes()
        
        let menu = themesMenu(theme: theme, themes: themes, unlocked: unlocked)
        addMenuToScene(menu: menu)
    }
    
    func createGetThemeMenu(themeNumber: Int, unlockLevel: Int) {
        let menu = getThemeMenu(theme: theme, themeNumber: themeNumber, unlockLevel: unlockLevel)
        addMenuToScene(menu: menu)
    }
}

