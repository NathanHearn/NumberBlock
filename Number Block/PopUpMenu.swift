//
//  PopUpMenu.swift
//  Number Block
//
//  Created by Nathan on 06/03/2018.
//  Copyright © 2018 Nathan. All rights reserved.
//

import SpriteKit

enum menuFunction {
    case restart, restartMenu, home, homeMenu, infoMenu, getlife, getMovesMenu, getMoves, watchAdForMove, shopMenu, selectTheme, getTheme, levelSelect, dismissMenu, failMenu
}

//MARK: - PopUpMenus

class PopUpMenu: SKShapeNode {
    
    var menuHandler: ((menuFunction) -> Void)?
    
    let headerTitle: String?
    let theme: Theme!
    var headerLabel = SKLabelNode(fontNamed: "Montserrat-Bold")
    var shapePath = CGPath(roundedRect: CGRect(x: -150, y: -110 ,width: 300, height: 220) , cornerWidth: 30, cornerHeight: 30, transform: nil)
    let header = SKShapeNode(path: CGPath(roundedRect: CGRect(x: -50, y: -30 ,width: 100, height: 60) , cornerWidth: 10, cornerHeight: 10, transform: nil))
    
    init(theme: Theme, title: String) {
        self.theme = theme
        self.headerTitle = title
        
        super.init()
        
        self.path = shapePath
        self.fillColor = theme.customBackgroundColor
        self.strokeColor = theme.customBackgroundColor
        
        header.fillColor = theme.customOrangeColor; header.strokeColor = theme.customBackgroundColor
        header.lineWidth = 3
        header.position = CGPoint(x: 0, y: (self.frame.height / 2) + 8)
        addChild(header)
        
        headerLabel.text = headerTitle!
        headerLabel.fontSize = 28
        headerLabel.verticalAlignmentMode = .center; headerLabel.horizontalAlignmentMode = .center
        headerLabel.position = CGPoint(x: 0, y: 0)
        headerLabel.fontColor = theme.customTextColor
        header.addChild(headerLabel)
        
        while header.frame.width < (headerLabel.frame.width + 16) {
            var newWidth = header.frame.width
            header.path = CGPath(roundedRect: CGRect(x: -(newWidth / 2), y: -30 ,width: newWidth, height: 60) , cornerWidth: 10, cornerHeight: 10, transform: nil)
            newWidth += 1
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class failMenu: PopUpMenu {
    
    let buttonPath = CGPath(roundedRect: CGRect(x: -75, y: -25, width: 150, height: 50), cornerWidth: 10, cornerHeight: 10, transform: nil)
    
    init(theme: Theme) {
        
        super.init(theme: theme, title: "Level Failed")
        
        let restartButton = CustomButton(path: buttonPath, text: "Restart", color: theme.customOrangeColor, textColor: theme.customTextColor, action: {
            if let handler = self.menuHandler {
                handler(.restart)
            }
        })
        restartButton.position = CGPoint(x: 0, y: 30); restartButton.zPosition = 10
        restartButton.textLabel?.fontSize = 28
        self.addChild(restartButton)
        
        let homeButton = CustomButton(path: buttonPath, text: "Home", color: theme.customOrangeColor, textColor: theme.customTextColor, action: {
            if let handler = self.menuHandler {
                handler(.home)
            }
        })
        homeButton.position = CGPoint(x: 0, y: -45); homeButton.zPosition = 10
        homeButton.textLabel?.fontSize = 28
        self.addChild(homeButton)
        
        let life = SKSpriteNode(imageNamed: "Life.png")
        life.size = CGSize(width: 44, height: 38)
        life.position = CGPoint(x: 73, y: 23)
        restartButton.addChild(life)
        
        let lifeLabel = SKLabelNode(fontNamed: "Montserrat-Bold")
        lifeLabel.text = "-1"
        lifeLabel.fontSize = 18
        lifeLabel.verticalAlignmentMode = .center; lifeLabel.horizontalAlignmentMode = .center
        lifeLabel.position = CGPoint(x: 0, y: 1 )
        lifeLabel.zPosition = 10
        life.addChild(lifeLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK:- DismissableMenus

class dismissibleMenu: PopUpMenu {
    
    var dismissAction: menuFunction = .dismissMenu
    var dismissButton: CustomButton?
    
    init(theme: Theme, title: String, largeSize: Bool) {
        
        super.init(theme: theme, title: title)
        
        if largeSize {
            super.path = CGPath(roundedRect: CGRect(x: -145, y: -190 ,width: 290, height: 380) , cornerWidth: 30, cornerHeight: 30, transform: nil)
            super.header.position = CGPoint(x: 0, y: (self.frame.height / 2) + 8)
        }
        
        let buttonPath = CGPath(roundedRect: CGRect(x: -45, y: -25, width: 90, height: 50), cornerWidth: 10, cornerHeight: 10, transform: nil)
        let dismissButton = CustomButton(path: buttonPath, text: "Okay!", color: theme.customOrangeColor, textColor: theme.customTextColor, action: {
            if let handler = self.menuHandler {
                handler(self.dismissAction)
            }
        })
        dismissButton.position = CGPoint(x: 0, y: -(self.frame.height / 2) + 45); dismissButton.zPosition = 10
        dismissButton.zPosition = 100
        addChild(dismissButton)
        
        self.dismissButton = dismissButton
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class shop: dismissibleMenu {
    
    var movableNode = SKNode()
    
    init(theme: Theme) {
        
        super.init(theme: theme, title: "Shop", largeSize: true)
        
        let node = SKShapeNode(path: CGPath(rect: CGRect(x: -250, y: -400, width: 500, height: 500), transform: nil))
        node.strokeColor = .clear
        
        //add shop contents
        let buttonPath = CGPath(roundedRect: CGRect(x: -57, y: -55, width: 114, height: 110), cornerWidth: 20, cornerHeight: 20, transform: nil)
        
        let gems200 = ScrollViewButton(path: buttonPath, spriteNamed: "glowinggem.png", color: theme.customOrangeColor, action: {
            IAPService.sharedInstance.purchase(product: .gems200)
        })
        gems200.position = CGPoint(x: -590, y: 90)
        node.addChild(gems200)
        let gems200Text = SKLabelNode(fontNamed: "Montserrat-Bold")
        gems200Text.fontSize = 18
        gems200Text.text = "200 Gems"
        gems200Text.position = CGPoint(x: 0, y: -28)
        gems200.addChild(gems200Text)
        let gems200Price = SKLabelNode(fontNamed: "Montserrat-Bold")
        gems200Price.fontSize = 20
        gems200Price.text = "\(IAPService.sharedInstance.productPrices["gems200"]!)"
        gems200Price.position = CGPoint(x: 0, y: -48)
        gems200.addChild(gems200Price)
        
        let gems600 = ScrollViewButton(path: buttonPath, spriteNamed: "glowinggem.png", color: theme.customOrangeColor, action: {
            IAPService.sharedInstance.purchase(product: .gems600)
        })
        gems600.position = CGPoint(x: -460, y: 90)
        let gems600Text = SKLabelNode(fontNamed: "Montserrat-Bold")
        node.addChild(gems600)
        gems600Text.fontSize = 18
        gems600Text.text = "600 Gems"
        gems600Text.position = CGPoint(x: 0, y: -28)
        gems600.addChild(gems600Text)
        let gems600Price = SKLabelNode(fontNamed: "Montserrat-Bold")
        gems600Price.fontSize = 20
        gems600Price.text = "\(IAPService.sharedInstance.productPrices["gems600"]!)"
        gems600Price.position = CGPoint(x: 0, y: -48)
        gems600.addChild(gems600Price)
        
        let gems1500 = ScrollViewButton(path: buttonPath, spriteNamed: "glowinggem.png", color: theme.customOrangeColor, action: {
            IAPService.sharedInstance.purchase(product: .gems1500)
        })
        gems1500.position = CGPoint(x: -330, y: 90)
        node.addChild(gems1500)
        let gems1500Text = SKLabelNode(fontNamed: "Montserrat-Bold")
        gems1500Text.fontSize = 18
        gems1500Text.text = "1500 Gems"
        gems1500Text.position = CGPoint(x: 0, y: -28)
        gems1500.addChild(gems1500Text)
        let gems1500Price = SKLabelNode(fontNamed: "Montserrat-Bold")
        gems1500Price.fontSize = 20
        gems1500Price.text = "\(IAPService.sharedInstance.productPrices["gems1500"]!)"
        gems1500Price.position = CGPoint(x: 0, y: -48)
        gems1500.addChild(gems1500Price)
        
        let gems3000 = ScrollViewButton(path: buttonPath, spriteNamed: "glowinggem.png", color: theme.customOrangeColor, action: {
            IAPService.sharedInstance.purchase(product: .gems3000)
        })
        gems3000.position = CGPoint(x: -200, y: 90)
        node.addChild(gems3000)
        let gems3000Text = SKLabelNode(fontNamed: "Montserrat-Bold")
        gems3000Text.fontSize = 17
        gems3000Text.text = "3000 Gems"
        gems3000Text.position = CGPoint(x: 0, y: -28)
        gems3000.addChild(gems3000Text)
        let gems3000Price = SKLabelNode(fontNamed: "Montserrat-Bold")
        gems3000Price.fontSize = 20
        gems3000Price.text = "\(IAPService.sharedInstance.productPrices["gems3000"]!)"
        gems3000Price.position = CGPoint(x: 0, y: -48)
        gems3000.addChild(gems3000Price)
        
        let gems10000 = ScrollViewButton(path: buttonPath, spriteNamed: "glowinggem.png", color: theme.customOrangeColor, action: {
            IAPService.sharedInstance.purchase(product: .gems10000)
        })
        gems10000.position = CGPoint(x: -70, y: 90)
        node.addChild(gems10000)
        let gems10000Text = SKLabelNode(fontNamed: "Montserrat-Bold")
        gems10000Text.fontSize = 16
        gems10000Text.text = "10000 Gems"
        gems10000Text.position = CGPoint(x: 0, y: -28)
        gems10000.addChild(gems10000Text)
        let gems10000Price = SKLabelNode(fontNamed: "Montserrat-Bold")
        gems10000Price.fontSize = 20
        gems10000Price.text = "\(IAPService.sharedInstance.productPrices["gems10000"]!)"
        gems10000Price.position = CGPoint(x: 0, y: -48)
        gems10000.addChild(gems10000Price)
        
        let adsRemove = ScrollViewButton(path: buttonPath, text: "", color: theme.customOrangeColor, textColor: theme.customTextColor, action: {
            IAPService.sharedInstance.purchase(product: .adsRemove)
        })
        adsRemove.position = CGPoint(x: 60, y: 90)
        node.addChild(adsRemove)
        let line1 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line1.fontSize = 20
        line1.text = "Remove"
        line1.position = CGPoint(x: 0, y: 10)
        adsRemove.addChild(line1)
        let line2 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line2.fontSize = 20
        line2.text = "Ads"
        line2.position = CGPoint(x: 0, y: -15)
        adsRemove.addChild(line2)
        let adsRemovePrice = SKLabelNode(fontNamed: "Montserrat-Bold")
        adsRemovePrice.fontSize = 20
        adsRemovePrice.text = "\(IAPService.sharedInstance.productPrices["adsRemove"]!)"
        adsRemovePrice.position = CGPoint(x: 0, y: -48)
        adsRemove.addChild(adsRemovePrice)
        
        if GameHandler.sharedInstance.adsOn == false {
            let maskPath = CGPath(roundedRect: CGRect(x: -57, y: -59, width: 114, height: 114), cornerWidth: 20, cornerHeight: 20, transform: nil)
            let mask = SKShapeNode(path: maskPath)
            mask.fillColor = UIColor(red: 127/255, green: 127/255, blue: 127/255, alpha: 0.5)
            mask.strokeColor = mask.fillColor
            mask.zPosition = 50
            adsRemove.addChild(mask)
            adsRemove.actionEnabled = false
            
        }
        
        let lives1 = ScrollViewButton(path: buttonPath, spriteNamed: "glowinglive.png", color: theme.customOrangeColor, action: {
            if GameHandler.sharedInstance.numberOfGems >= 40 {
                IAPService.sharedInstance.GVC!.buy(get: .lives1)
            } else {
                AudioPlayer.sharedInstance.playSound(sound: .fail, node: self)
            }
        })
        lives1.position = CGPoint(x: -590, y: -40)
        node.addChild(lives1)
        let lives1Text = SKLabelNode(fontNamed: "Montserrat-Bold")
        lives1Text.fontSize = 16
        lives1Text.text = "1 life"
        lives1Text.position = CGPoint(x: 0, y: -28)
        lives1.addChild(lives1Text)
        let lives1Price = SKLabelNode(fontNamed: "Montserrat-Bold")
        lives1Price.fontSize = 18
        lives1Price.text = "40 Gems"
        lives1Price.position = CGPoint(x: 0, y: -48)
        lives1.addChild(lives1Price)
        
        let lives5 = ScrollViewButton(path: buttonPath, spriteNamed: "glowinglive.png", color: theme.customOrangeColor, action: {
            if GameHandler.sharedInstance.numberOfGems >= 200 {
                IAPService.sharedInstance.GVC!.buy(get: .lives5)
            } else {
                AudioPlayer.sharedInstance.playSound(sound: .fail, node: self)
            }
        })
        lives5.position = CGPoint(x: -460, y: -40)
        node.addChild(lives5)
        let lives5Text = SKLabelNode(fontNamed: "Montserrat-Bold")
        lives5Text.fontSize = 16
        lives5Text.text = "5 lives"
        lives5Text.position = CGPoint(x: 0, y: -28)
        lives5.addChild(lives5Text)
        let lives5Price = SKLabelNode(fontNamed: "Montserrat-Bold")
        lives5Price.fontSize = 18
        lives5Price.text = "200 Gems"
        lives5Price.position = CGPoint(x: 0, y: -48)
        lives5.addChild(lives5Price)
        
        let livesUnlimited3 = ScrollViewButton(path: buttonPath, spriteNamed: "glowinglive.png", color: theme.customOrangeColor, action: {
            if GameHandler.sharedInstance.numberOfGems >= 500 {
                IAPService.sharedInstance.GVC!.buy(get: .livesUnlimited3)
            } else {
                AudioPlayer.sharedInstance.playSound(sound: .fail, node: self)
            }
        })
        livesUnlimited3.position = CGPoint(x: -330, y: -40)
        node.addChild(livesUnlimited3)
        let u3Line1 = SKLabelNode(fontNamed: "Montserrat-Bold")
        u3Line1.fontSize = 16
        u3Line1.text = "∞"
        u3Line1.position = CGPoint(x: 0, y: -20)
        livesUnlimited3.addChild(u3Line1)
        let u3Line2 = SKLabelNode(fontNamed: "Montserrat-Bold")
        u3Line2.fontSize = 16
        u3Line2.text = "3 hours"
        u3Line2.position = CGPoint(x: 0, y: -32)
        livesUnlimited3.addChild(u3Line2)
        let u3Line3 = SKLabelNode(fontNamed: "Montserrat-Bold")
        u3Line3.fontSize = 18
        u3Line3.text = "500 Gems"
        u3Line3.position = CGPoint(x: 0, y: -50)
        livesUnlimited3.addChild(u3Line3)
        
        
        if GameHandler.sharedInstance.unlimitedLives {
            let maskPath = CGPath(roundedRect: CGRect(x: -57, y: -59, width: 114, height: 114), cornerWidth: 20, cornerHeight: 20, transform: nil)
            let mask = SKShapeNode(path: maskPath)
            mask.fillColor = UIColor(red: 127/255, green: 127/255, blue: 127/255, alpha: 0.5)
            mask.strokeColor = mask.fillColor
            mask.zPosition = 50
            livesUnlimited3.addChild(mask)
            livesUnlimited3.actionEnabled = false
        }
        
        let livesUnlimited6 = ScrollViewButton(path: buttonPath, spriteNamed: "glowinglive.png", color: theme.customOrangeColor, action: {
            if GameHandler.sharedInstance.numberOfGems >= 800 {
                IAPService.sharedInstance.GVC!.buy(get: .livesUnlimited6)
            } else {
                AudioPlayer.sharedInstance.playSound(sound: .fail, node: self)
        }
        })
        livesUnlimited6.position = CGPoint(x: -200, y: -40)
        node.addChild(livesUnlimited6)
        let u6Line1 = SKLabelNode(fontNamed: "Montserrat-Bold")
        u6Line1.fontSize = 16
        u6Line1.text = "∞"
        u6Line1.position = CGPoint(x: 0, y: -20)
        livesUnlimited6.addChild(u6Line1)
        let u6Line2 = SKLabelNode(fontNamed: "Montserrat-Bold")
        u6Line2.fontSize = 16
        u6Line2.text = "6 hours"
        u6Line2.position = CGPoint(x: 0, y: -32)
        livesUnlimited6.addChild(u6Line2)
        let u6Line3 = SKLabelNode(fontNamed: "Montserrat-Bold")
        u6Line3.fontSize = 18
        u6Line3.text = "800 Gems"
        u6Line3.position = CGPoint(x: 0, y: -50)
        livesUnlimited6.addChild(u6Line3)
        
        if GameHandler.sharedInstance.unlimitedLives {
            let maskPath = CGPath(roundedRect: CGRect(x: -57, y: -59, width: 114, height: 114), cornerWidth: 20, cornerHeight: 20, transform: nil)
            let mask = SKShapeNode(path: maskPath)
            mask.fillColor = UIColor(red: 127/255, green: 127/255, blue: 127/255, alpha: 0.5)
            mask.strokeColor = mask.fillColor
            mask.zPosition = 50
            livesUnlimited6.addChild(mask)
            livesUnlimited6.actionEnabled = false
            
        }
        
        let livesUnlimited12 = ScrollViewButton(path: buttonPath, spriteNamed: "glowinglive.png", color: theme.customOrangeColor, action: {
            if GameHandler.sharedInstance.numberOfGems >= 1000 {
                IAPService.sharedInstance.GVC!.buy(get: .livesUnlimited12)
            } else {
                AudioPlayer.sharedInstance.playSound(sound: .fail, node: self)
            }
        })
        livesUnlimited12.position = CGPoint(x: -70, y: -40)
        node.addChild(livesUnlimited12)
        let u12Line1 = SKLabelNode(fontNamed: "Montserrat-Bold")
        u12Line1.fontSize = 16
        u12Line1.text = "∞"
        u12Line1.position = CGPoint(x: 0, y: -20)
        livesUnlimited12.addChild(u12Line1)
        let u12Line2 = SKLabelNode(fontNamed: "Montserrat-Bold")
        u12Line2.fontSize = 16
        u12Line2.text = "12 hours"
        u12Line2.position = CGPoint(x: 0, y: -32)
        livesUnlimited12.addChild(u12Line2)
        let u12Line3 = SKLabelNode(fontNamed: "Montserrat-Bold")
        u12Line3.fontSize = 17
        u12Line3.text = "1000 Gems"
        u12Line3.position = CGPoint(x: 0, y: -50)
        livesUnlimited12.addChild(u12Line3)
        
        if GameHandler.sharedInstance.unlimitedLives {
            let maskPath = CGPath(roundedRect: CGRect(x: -57, y: -59, width: 114, height: 114), cornerWidth: 20, cornerHeight: 20, transform: nil)
            let mask = SKShapeNode(path: maskPath)
            mask.fillColor = UIColor(red: 127/255, green: 127/255, blue: 127/255, alpha: 0.5)
            mask.strokeColor = mask.fillColor
            mask.zPosition = 50
            livesUnlimited12.addChild(mask)
            livesUnlimited12.actionEnabled = false
            
        }
        
        print("Unliilive************************", GameHandler.sharedInstance.unlimitedLives)
        
        let restorePurchases = ScrollViewButton(path: buttonPath, text: "", color: theme.customOrangeColor, textColor: theme.customTextColor, action: {
            IAPService.sharedInstance.restorePurchases()
        })
        restorePurchases.position = CGPoint(x: 60, y: -40)
        node.addChild(restorePurchases)
        let line3 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line3.fontSize = 20
        line3.text = "Restore"
        line3.position = CGPoint(x: 0, y: 10)
        restorePurchases.addChild(line3)
        let line4 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line4.fontSize = 19
        line4.text = "Purchases"
        line4.position = CGPoint(x: 0, y: -15)
        restorePurchases.addChild(line4)
        
        let cropNode = SKCropNode()
        cropNode.position = CGPoint(x: 0, y: 0)
        cropNode.zPosition = 10
        
        let maskNode = SKShapeNode(path: CGPath(rect: CGRect(x: -130, y: -140 + 25 ,width: 260, height: 280), transform: nil))
        maskNode.fillColor = .purple //must have a colour becuase the mask shows its nodes in its coloured bits and not in its uncoloured bits
        cropNode.maskNode = maskNode
        
        self.addChild(cropNode)
        
        cropNode.addChild(node)
        movableNode = node
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class themesMenu: dismissibleMenu {
    
    var movableNode = SKNode()
    
    var selectedThemeNumber: Int?
    var selectedThemeUnlocked: Bool?
    var selectedThemeRequiredLevel: Int?
    
    init(theme: Theme, themes: [Theme], unlocked: [Bool]) {
        
        super.init(theme: theme, title: "Themes", largeSize: true)
        
        headerLabel.fontSize = 26
        
        let node = SKNode()
        
        let colorBlocksPath = CGPath(roundedRect: CGRect(x: -18, y: -16, width: 36, height: 34), cornerWidth: 10, cornerHeight: 10, transform: nil)
        
        var counter: Int = 0
        var previousPosition = CGPoint(x: -60, y: 100)
        
        for (themeNumber, theme) in themes.enumerated() {
            let buttonPath = CGPath(roundedRect: CGRect(x: -50, y: -50, width: 100, height: 100), cornerWidth: 15, cornerHeight: 15, transform: nil)
            let themeButton = ScrollViewButton(path: buttonPath, text: "", color: theme.customBackgroundColor , textColor: theme.customTextColor, action: {
                if let handler = self.menuHandler {
                    self.selectedThemeNumber = themeNumber
                    self.selectedThemeUnlocked = unlocked[themeNumber]
                    self.selectedThemeRequiredLevel = theme.requiredLevel
                    handler(menuFunction.selectTheme)
                }
            })
            
            let orangeBlock = ScrollViewButton(path: colorBlocksPath, text: "", color: theme.customOrangeColor, textColor: .clear, action: {})
            orangeBlock.isUserInteractionEnabled = false
            orangeBlock.actionEnabled = false
            orangeBlock.position = CGPoint(x: -23, y: 23)
            orangeBlock.zPosition = 10
            themeButton.addChild(orangeBlock)
            
            let redBlock = ScrollViewButton(path: colorBlocksPath, text: "", color: theme.customRedColor, textColor: .clear, action: {})
            redBlock.isUserInteractionEnabled = false
            redBlock.actionEnabled = false
            redBlock.position = CGPoint(x: 23, y: 23)
            redBlock.zPosition = 10
            themeButton.addChild(redBlock)
            
            let greenBlock = ScrollViewButton(path: colorBlocksPath, text: "", color: theme.customGreenColor, textColor: .clear, action: {})
            greenBlock.isUserInteractionEnabled = false
            greenBlock.actionEnabled = false
            greenBlock.position = CGPoint(x: -23, y: -23)
            greenBlock.zPosition = 10
            themeButton.addChild(greenBlock)
            
            let blueBlock = ScrollViewButton(path: colorBlocksPath, text: "", color: theme.customBlueColor, textColor: .clear, action: {})
            blueBlock.isUserInteractionEnabled = false
            blueBlock.actionEnabled = false
            blueBlock.position = CGPoint(x: 23, y: -23)
            blueBlock.zPosition = 10
            themeButton.addChild(blueBlock)
            
            if !unlocked[themeNumber] {
                
                let maskPath = CGPath(roundedRect: CGRect(x: -50, y: -54, width: 100, height: 104), cornerWidth: 15, cornerHeight: 15, transform: nil)
                let mask = SKShapeNode(path: maskPath)
                mask.fillColor = UIColor(red: 127/255, green: 127/255, blue: 127/255, alpha: 0.5)
                mask.strokeColor = mask.fillColor
                mask.zPosition = 50
                themeButton.addChild(mask)
            }
            
            //This is how we tell if the theme is the currentTheme. We can do this becuase more then one theme will never unlock after a level up.
            if theme.requiredLevel == self.theme.requiredLevel {
                let selectedShapePath = CGPath(roundedRect: CGRect(x: -52, y: -52, width: 104, height: 104), cornerWidth: 15, cornerHeight: 15, transform: nil)
                let selectedShape = SKShapeNode(path: selectedShapePath)
                selectedShape.strokeColor = theme.customOrangeColor
                selectedShape.lineWidth = 4
                selectedShape.zPosition = 5
                themeButton.addChild(selectedShape)
            }
            
            
            if counter == 0 {
                //This is the first themeButton and needs it position to be set manually
                themeButton.position = previousPosition
                counter = 1
            } else if counter == 1 {
                themeButton.position = CGPoint(x: previousPosition.x + 120, y: previousPosition.y)
                previousPosition = themeButton.position
                counter = 2
            } else {
                themeButton.position = CGPoint(x: previousPosition.x - 120, y: previousPosition.y - 120)
                previousPosition = themeButton.position
                counter = 1
            }
            node.addChild(themeButton)
        }
        
        let cropNode = SKCropNode()
        cropNode.position = CGPoint(x: 0, y: 0)
        cropNode.zPosition = 10
        
        let maskNode = SKShapeNode(path: CGPath(rect: CGRect(x: -130, y: -140 + 25 ,width: 260, height: 280), transform: nil))
        maskNode.fillColor = .purple //must have a colour becuase the mask shows its nodes in its coloured bits and not in its uncoloured bits
        cropNode.maskNode = maskNode
        
        self.addChild(cropNode)
        
        cropNode.addChild(node)
        movableNode = node
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class infoMenu: dismissibleMenu {
    
    weak var scrollView: CustomScrollView!
    
    var movableNode = SKNode()
    
    init(theme: Theme) {
        
        super.init(theme: theme, title: "Info", largeSize: true)
        
        //Recreates dismiss button as scrollviewbutton
        self.dismissButton!.removeFromParent()
        let buttonPath = CGPath(roundedRect: CGRect(x: -45, y: -25, width: 90, height: 50), cornerWidth: 10, cornerHeight: 10, transform: nil)
        let dismissButton = ScrollViewButton(path: buttonPath, text: "Okay!", color: theme.customOrangeColor, textColor: theme.customTextColor, action: {
            if let handler = self.menuHandler {
                handler(self.dismissAction)
            }
        })
        dismissButton.zPosition = 20
        
        self.dismissButton = dismissButton
        
        let blockPath = CGPath(roundedRect: CGRect(x: -25, y: -23, width: 50, height: 46), cornerWidth: 12, cornerHeight: 12, transform: nil)
        
        let node = SKNode()
        
        let line1 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line1.fontColor = theme.customTextColor
        line1.fontSize = 26
        line1.text = "Addition:"
        line1.position = CGPoint(x: -120, y: 130)
        line1.horizontalAlignmentMode = .left
        node.addChild(line1)
        
        let line2 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line2.fontColor = theme.customTextColor
        line2.fontSize = 22
        line2.text = "Swipe up, down,"
        line2.position = CGPoint(x: -120, y: 95)
        line2.horizontalAlignmentMode = .left
        node.addChild(line2)
        
        let line3 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line3.fontColor = theme.customTextColor
        line3.fontSize = 22
        line3.text = "left & right to add."
        line3.position = CGPoint(x: -120, y: 65)
        line3.horizontalAlignmentMode = .left
        node.addChild(line3)
        
        let addBlock = CustomButton(path: blockPath, text: "42", color: theme.customRedColor, textColor: theme.customTextColor, action: {})
        addBlock.isUserInteractionEnabled = false
        addBlock.position = CGPoint (x: 0, y: -40)
        addBlock.zPosition = 10
        node.addChild(addBlock)
        
        let upBlock = CustomButton(path: blockPath, text: "48", color: theme.customOrangeColor, textColor: theme.customTextColor, action: {})
        upBlock.isUserInteractionEnabled = false
        upBlock.position = CGPoint (x: upBlock.position.x, y: addBlock.position.y + 55)
        upBlock.zPosition = 10
        node.addChild(upBlock)
        
        let downBlock = CustomButton(path: blockPath, text: "35", color: theme.customOrangeColor, textColor: theme.customTextColor, action: {})
        downBlock.isUserInteractionEnabled = false
        downBlock.position = CGPoint (x: upBlock.position.x, y: addBlock.position.y - 55)
        downBlock.zPosition = 10
        node.addChild(downBlock)
        
        let leftBlock = CustomButton(path: blockPath, text: "60", color: theme.customOrangeColor, textColor: theme.customTextColor, action: {})
        leftBlock.isUserInteractionEnabled = false
        leftBlock.position = CGPoint (x: upBlock.position.x - 55, y: addBlock.position.y)
        leftBlock.zPosition = 10
        node.addChild(leftBlock)
        
        let rightBlock = CustomButton(path: blockPath, text: "43", color: theme.customOrangeColor, textColor: theme.customTextColor, action: {})
        rightBlock.isUserInteractionEnabled = false
        rightBlock.position = CGPoint (x: upBlock.position.x + 55, y: addBlock.position.y)
        rightBlock.zPosition = 10
        node.addChild(rightBlock)
        
        let line4 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line4.fontColor = theme.customTextColor
        line4.fontSize = 26
        line4.text = "Subtraction:"
        line4.position = CGPoint(x: -120, y: -160)
        line4.horizontalAlignmentMode = .left
        node.addChild(line4)
        
        let line5 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line5.fontColor = theme.customTextColor
        line5.fontSize = 22
        line5.text = "Swipe diagonally"
        line5.position = CGPoint(x: -120, y: -195)
        line5.horizontalAlignmentMode = .left
        node.addChild(line5)
        
        let line6 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line6.fontColor = theme.customTextColor
        line6.fontSize = 22
        line6.text = "TO the block you"
        line6.position = CGPoint(x: -120, y: -225)
        line6.horizontalAlignmentMode = .left
        node.addChild(line6)

        let line7 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line7.fontColor = theme.customTextColor
        line7.fontSize = 22
        line7.text = "want to subtract"
        line7.position = CGPoint(x: -120, y: -255)
        line7.horizontalAlignmentMode = .left
        node.addChild(line7)
        
        let subtractBlock = CustomButton(path: blockPath, text: "42", color: theme.customGreenColor, textColor: theme.customTextColor, action: {})
        subtractBlock.isUserInteractionEnabled = false
        subtractBlock.position = CGPoint (x: 0, y: -350)
        subtractBlock.zPosition = 10
        node.addChild(subtractBlock)
        
        let upLeftBlock = CustomButton(path: blockPath, text: "32", color: theme.customOrangeColor, textColor: theme.customTextColor, action: {})
        upLeftBlock.isUserInteractionEnabled = false
        upLeftBlock.position = CGPoint (x: subtractBlock.position.x - 50, y: subtractBlock.position.y + 50)
        upLeftBlock.zPosition = 10
        node.addChild(upLeftBlock)
        
        let upRightBlock = CustomButton(path: blockPath, text: "35", color: theme.customOrangeColor, textColor: theme.customTextColor, action: {})
        upRightBlock.isUserInteractionEnabled = false
        upRightBlock.position = CGPoint (x: subtractBlock.position.x + 50, y: subtractBlock.position.y + 50)
        upRightBlock.zPosition = 10
        node.addChild(upRightBlock)
        
        let downLeftBlock = CustomButton(path: blockPath, text: "25", color: theme.customOrangeColor, textColor: theme.customTextColor, action: {})
        downLeftBlock.isUserInteractionEnabled = false
        downLeftBlock.position = CGPoint (x: subtractBlock.position.x - 50, y: subtractBlock.position.y - 50)
        downLeftBlock.zPosition = 10
        node.addChild(downLeftBlock)
        
        let downRightBlock = CustomButton(path: blockPath, text: "22", color: theme.customOrangeColor, textColor: theme.customTextColor, action: {})
        downRightBlock.isUserInteractionEnabled = false
        downRightBlock.position = CGPoint (x: subtractBlock.position.x + 50, y: subtractBlock.position.y - 50)
        downRightBlock.zPosition = 10
        node.addChild(downRightBlock)
        
        let redBlock = CustomButton(path: blockPath, text: "42", color: theme.customRedColor, textColor: theme.customTextColor, action: {})
        redBlock.isUserInteractionEnabled = false
        redBlock.position = CGPoint (x: -95, y: -480)
        redBlock.zPosition = 10
        node.addChild(redBlock)
        
        let line8 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line8.fontColor = theme.customTextColor
        line8.fontSize = 20
        line8.text = "- can only be used"
        line8.position = CGPoint(x: -60, y: -480)
        line8.horizontalAlignmentMode = .left
        node.addChild(line8)
        
        let line9 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line9.fontColor = theme.customTextColor
        line9.fontSize = 20
        line9.text = "in addition"
        line9.position = CGPoint(x: -60, y: -500)
        line9.horizontalAlignmentMode = .left
        node.addChild(line9)
        
        let greenBlock = CustomButton(path: blockPath, text: "42", color: theme.customGreenColor, textColor: theme.customTextColor, action: {})
        greenBlock.isUserInteractionEnabled = false
        greenBlock.position = CGPoint (x: -95, y: -550)
        greenBlock.zPosition = 10
        node.addChild(greenBlock)
        
        let line10 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line10.fontColor = theme.customTextColor
        line10.fontSize = 20
        line10.text = "- can only be used"
        line10.position = CGPoint(x: -60, y: -550)
        line10.horizontalAlignmentMode = .left
        node.addChild(line10)
        
        let line11 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line11.fontColor = theme.customTextColor
        line11.fontSize = 20
        line11.text = "in subtraction"
        line11.position = CGPoint(x: -60, y: -570)
        line11.horizontalAlignmentMode = .left
        node.addChild(line11)
        
        let blueBlock = CustomButton(path: blockPath, text: "42", color: theme.customBlueColor, textColor: theme.customTextColor, action: {})
        blueBlock.isUserInteractionEnabled = false
        blueBlock.position = CGPoint (x: -95, y: -620)
        blueBlock.zPosition = 10
        node.addChild(blueBlock)
        
        let line12 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line12.fontColor = theme.customTextColor
        line12.fontSize = 20
        line12.text = "- can only interact"
        line12.position = CGPoint(x: -60, y: -620)
        line12.horizontalAlignmentMode = .left
        node.addChild(line12)
        
        let line13 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line13.fontColor = theme.customTextColor
        line13.fontSize = 20
        line13.text = "with equal blocks"
        line13.position = CGPoint(x: -60, y: -640)
        line13.horizontalAlignmentMode = .left
        node.addChild(line13)
        
        let line14 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line14.fontColor = theme.customTextColor
        line14.fontSize = 20
        line14.text = "You're score increases"
        line14.position = CGPoint(x: -128, y: -690)
        line14.horizontalAlignmentMode = .left
        node.addChild(line14)
        
        let line15 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line15.fontColor = theme.customTextColor
        line15.fontSize = 20
        line15.text = "with each successful"
        line15.position = CGPoint(x: -128, y: -715)
        line15.horizontalAlignmentMode = .left
        node.addChild(line15)
        
        let line16 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line16.fontColor = theme.customTextColor
        line16.fontSize = 20
        line16.text = "move, use special blocks"
        line16.position = CGPoint(x: -128, y: -740)
        line16.horizontalAlignmentMode = .left
        node.addChild(line16)
        
        let line17 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line17.fontColor = theme.customTextColor
        line17.fontSize = 20
        line17.text = "for extra points!"
        line17.position = CGPoint(x: -128, y: -765)
        line17.horizontalAlignmentMode = .left
        node.addChild(line17)
        
        let line18 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line18.fontColor = theme.customTextColor
        line18.fontSize = 26
        line18.text = "Tip:"
        line18.position = CGPoint(x: -128, y: -810)
        line18.horizontalAlignmentMode = .left
        node.addChild(line18)
        
        let moveBlock = CustomButton(path: blockPath, text: "42", color: theme.customOrangeColor, textColor: theme.customTextColor, action: {})
        moveBlock.isUserInteractionEnabled = false
        moveBlock.position = CGPoint (x: 0, y: -850)
        moveBlock.zPosition = 10
        node.addChild(moveBlock)
        
        let moveLeftBlock = TileBlock(size: CGSize(width: 50, height: 52) , backgroundColour: theme.customBackgroundColor)
        moveLeftBlock.isUserInteractionEnabled = false
        moveLeftBlock.position = CGPoint (x: moveBlock.position.x - 55, y: moveBlock.position.y)
        moveLeftBlock.zPosition = 10
        node.addChild(moveLeftBlock)
        
        let moveRightBlock = TileBlock(size: CGSize(width: 50, height: 52) , backgroundColour: theme.customBackgroundColor)
        moveRightBlock.isUserInteractionEnabled = false
        moveRightBlock.position = CGPoint (x: moveBlock.position.x + 55, y: moveBlock.position.y)
        moveRightBlock.zPosition = 10
        node.addChild(moveRightBlock)
        
        let line19 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line19.fontColor = theme.customTextColor
        line19.fontSize = 20
        line19.text = "You can also move"
        line19.position = CGPoint(x: -128, y: -910)
        line19.horizontalAlignmentMode = .left
        node.addChild(line19)
        
        let line20 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line20.fontColor = theme.customTextColor
        line20.fontSize = 20
        line20.text = "blocks left or right into"
        line20.position = CGPoint(x: -128, y: -935)
        line20.horizontalAlignmentMode = .left
        node.addChild(line20)
        
        let line21 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line21.fontColor = theme.customTextColor
        line21.fontSize = 20
        line21.text = "empty spaces."
        line21.position = CGPoint(x: -128, y: -960)
        line21.horizontalAlignmentMode = .left
        node.addChild(line21)
        
        self.dismissButton!.position = CGPoint(x: 0, y: -1000)
        node.addChild(self.dismissButton!)
        
        let line30 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line30.fontColor = theme.customTextColor
        line30.fontSize = 18
        line30.text = "For more infomation visit:"
        line30.position = CGPoint(x: -120, y: -1060)
        line30.horizontalAlignmentMode = .left
        node.addChild(line30)
        
        let line31 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line31.fontColor = theme.customTextColor
        line31.fontSize = 16
        line31.text = "www.bullhogintractive.com"
        line31.position = CGPoint(x: -120, y: -1080)
        line31.horizontalAlignmentMode = .left
        node.addChild(line31)
        
        let cropNode = SKCropNode()
        cropNode.position = CGPoint(x: 0, y: 0)
        cropNode.zPosition = 10
        
        let maskNode = SKShapeNode(path: CGPath(rect: CGRect(x: -130, y: -165 ,width: 260, height: 330), transform: nil))
        maskNode.fillColor = .purple //must have a colour becuase the mask shows its nodes in its coloured bits and not in its uncoloured bits
        cropNode.maskNode = maskNode
        
        self.addChild(cropNode)
        
        cropNode.addChild(node)
        movableNode = node
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class pauseMenu: dismissibleMenu {
    
    private let largePath = CGPath(roundedRect: CGRect(x: -85, y: -27, width: 170, height: 54), cornerWidth: 10, cornerHeight: 10, transform: nil)
    private let smallPath = CGPath(roundedRect: CGRect(x: -30, y: -28, width: 60, height: 56), cornerWidth: 10, cornerHeight: 10, transform: nil)
    
    //These to propertes are decleared here because they can change within an instance of this menu
    private var muteButton: CustomButton?
    var isMuted: Bool
    
    init(theme: Theme, isMuted: Bool) {
        
        self.isMuted = isMuted
        
        super.init(theme: theme, title: "Pause", largeSize: true)
        
        let restartButton = CustomButton(path: largePath, text: "Restart", color: theme.customOrangeColor, textColor: theme.customTextColor, action: {
            if let handler = self.menuHandler {
                handler(.restartMenu)
            }
        })
        restartButton.position = CGPoint(x: 0, y: 114); restartButton.zPosition = 10
        restartButton.textLabel?.fontSize = 28
        self.addChild(restartButton)
        
        let homeButton = CustomButton(path: largePath, text: "Home", color: theme.customOrangeColor, textColor: theme.customTextColor, action: {
            if let handler = self.menuHandler {
                handler(.homeMenu)
            }
        })
        homeButton.position = CGPoint(x: 0, y: 28); homeButton.zPosition = 10
        homeButton.textLabel?.fontSize = 28
        self.addChild(homeButton)
        
        let muteButton = MuteButton(path: smallPath, color: theme.customOrangeColor, textColor: theme.customTextColor, muted: AudioPlayer.sharedInstance.muted)
        muteButton.position = CGPoint(x: -50, y: -60); muteButton.zPosition = 10
        muteButton.textLabel?.fontSize = 18
        self.addChild(muteButton)
        self.muteButton = muteButton
        
        let infoButton = CustomButton(path: smallPath, text: "i", color: theme.customOrangeColor, textColor: theme.customTextColor, action: {
            if let handler = self.menuHandler {
                handler(.infoMenu)
            }
        })
        infoButton.position = CGPoint(x: 50, y: -60); infoButton.zPosition = 10
        infoButton.textLabel!.fontName = "Montserrat-BoldItalic"
        self.addChild(infoButton)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class successMenu: dismissibleMenu {
    
    let blockPath = CGPath(roundedRect: CGRect(x: -30, y: -28, width: 60, height: 56) , cornerWidth: 15, cornerHeight: 15, transform: nil)
    
    init(theme: Theme, goldenBlocks: Int) {
        
        super.init(theme: theme, title: "Success!", largeSize: true)
        
        self.dismissAction = .levelSelect
        
        let blockXPositions = [-75, 0, 75]
        let goldColour = UIColor(red: 0.950, green: 0.761, blue: 0.196, alpha: 1)
        let backgroundColour = UIColor(red: 0.498, green: 0.498, blue: 0.498, alpha: 0.25)
        
        
        var blocks = [CustomButton]()
        
        for block in 0 ..< 3 {
            
            if block < goldenBlocks {
                let goldenBlock = CustomButton(path: blockPath, text: "\(block + 1)", color: goldColour, textColor: theme.customTextColor, action: {})
                goldenBlock.position = CGPoint(x: blockXPositions[block], y: 100)
                goldenBlock.zPosition = 150
                blocks.append(goldenBlock)
                self.addChild(goldenBlock)
            } else {
                let backgroundBlock = SKShapeNode(path: blockPath)
                backgroundBlock.fillColor = backgroundColour
                backgroundBlock.strokeColor = backgroundColour
                backgroundBlock.position = CGPoint(x: blockXPositions[block], y: 100)
                backgroundBlock.zPosition = 150
                self.addChild(backgroundBlock)
            }
        }
        
        animateBlocks(blocks: blocks)
        
    }
    
    func userLeveledUp(oldLevel: Int, newLevel: Int) {
        let levelUpLabel = SKLabelNode(fontNamed: "Montserrat-Bold")
        levelUpLabel.text = "Level Up!"
        levelUpLabel.fontColor = theme.customTextColor
        levelUpLabel.verticalAlignmentMode = .center; levelUpLabel.horizontalAlignmentMode = .center
        levelUpLabel.fontSize = 30
        levelUpLabel.position = CGPoint(x: 0, y: 30)
        
        let newLevelBlock = CustomButton(path: blockPath, text: "\(oldLevel)", color: theme.customOrangeColor, textColor: theme.customTextColor, action: {})
        newLevelBlock.position = CGPoint(x: 0, y: -25)
        newLevelBlock.zPosition = 150
        self.addChild(newLevelBlock)
        
        run(SKAction.wait(forDuration: 0.8), completion: {
            AudioPlayer.sharedInstance.playSound(sound: .levelUp, node: self)
            self.animatePulse(object: levelUpLabel)
            self.animatePulse(object: newLevelBlock)
            newLevelBlock.textLabel!.text = "\(newLevel)"
            self.addChild(levelUpLabel)
        })
        
        let lifeSprite = SKSpriteNode(imageNamed: "Life.png")
        lifeSprite.size = CGSize(width: 43, height: 37)
        lifeSprite.position = CGPoint(x: -20, y: -90)
        lifeSprite.zPosition = 150
        
        let plusLabel = SKLabelNode(fontNamed: "Montserrat-Bold")
        plusLabel.text = "x2"
        plusLabel.fontColor = theme.customTextColor
        plusLabel.verticalAlignmentMode = .center; plusLabel.horizontalAlignmentMode = .center
        plusLabel.fontSize = 30
        plusLabel.position = CGPoint(x: 24, y: -90)
        
        run(SKAction.wait(forDuration: 1.5), completion: {
            self.animatePulse(object: lifeSprite)
            self.animatePulse(object: plusLabel)
            self.addChild(lifeSprite)
            self.addChild(plusLabel)
        })
    }
    
    func updateUserProgression(playerLevel: Int, playerProgression: CGFloat, newPlayerProgression: CGFloat, scoreForLevel: CGFloat) {
        print(41)
        let levelBlockPath = CGPath(roundedRect: CGRect(x: -25, y: -23, width: 50, height: 46) , cornerWidth: 13, cornerHeight: 13, transform: nil)
        let currentLevelBlock = CustomButton(path: levelBlockPath, text: "\(playerLevel)", color: theme.customOrangeColor, textColor: theme.customTextColor, action: {})
        currentLevelBlock.position = CGPoint(x: -100, y: 0)
        currentLevelBlock.zPosition = 150
        self.addChild(currentLevelBlock)
        
        let nextLevelBlock = CustomButton(path: levelBlockPath, text: "\(playerLevel + 1)", color: theme.customOrangeColor, textColor: theme.customTextColor, action: {})
        nextLevelBlock.position = CGPoint(x: 100, y: 0)
        nextLevelBlock.zPosition = 150
        self.addChild(nextLevelBlock)
        
        let progressBar = ProgressBar(progress: playerProgression, endValue: scoreForLevel, length: 110, height: 20, colour: theme.customGreenColor)
        progressBar.zPosition = 150
        self.addChild(progressBar)
        
        print(42)
        run(SKAction.wait(forDuration: 0.8), completion: {
            print(43)
            progressBar.updateProgress(progress: newPlayerProgression)
        })
        
        extraRewards()
    }
    
    func userProgression(playerLevel: Int, playerProgression: CGFloat, scoreForLevel: CGFloat) {
        let levelBlockPath = CGPath(roundedRect: CGRect(x: -25, y: -23, width: 50, height: 46) , cornerWidth: 13, cornerHeight: 13, transform: nil)
        let currentLevelBlock = CustomButton(path: levelBlockPath, text: "\(playerLevel)", color: theme.customOrangeColor, textColor: theme.customTextColor, action: {})
        currentLevelBlock.position = CGPoint(x: -100, y: 0)
        currentLevelBlock.zPosition = 150
        self.addChild(currentLevelBlock)
        
        let nextLevelBlock = CustomButton(path: levelBlockPath, text: "\(playerLevel + 1)", color: theme.customOrangeColor, textColor: theme.customTextColor, action: {})
        nextLevelBlock.position = CGPoint(x: 100, y: 0)
        nextLevelBlock.zPosition = 150
        self.addChild(nextLevelBlock)
        
        let progressBar = ProgressBar(progress: playerProgression, endValue: scoreForLevel, length: 110, height: 20, colour: theme.customGreenColor)
        progressBar.zPosition = 150
        self.addChild(progressBar)
        
        extraRewards()
    }
    
    func extraRewards() {
        
        let extraLabel = SKLabelNode(fontNamed: "Montserrat-Bold")
        extraLabel.text = "extra:"
        extraLabel.fontColor = theme.customTextColor
        extraLabel.verticalAlignmentMode = .center; extraLabel.horizontalAlignmentMode = .center
        extraLabel.fontSize = 25
        extraLabel.position = CGPoint(x: 0, y: -45)
        self.addChild(extraLabel)
        
        let lifeSprite = SKSpriteNode(imageNamed: "Life.png")
        lifeSprite.size = CGSize(width: 43, height: 37)
        lifeSprite.position = CGPoint(x: 20, y: -90)
        lifeSprite.zPosition = 150
        
        let plusLabel = SKLabelNode(fontNamed: "Montserrat-Bold")
        plusLabel.text = "+"
        plusLabel.fontColor = theme.customTextColor
        plusLabel.verticalAlignmentMode = .center; plusLabel.horizontalAlignmentMode = .center
        plusLabel.fontSize = 40
        plusLabel.position = CGPoint(x: -20, y: -90)
        
        run(SKAction.wait(forDuration: 1.5), completion: {
            self.animatePulse(object: lifeSprite)
            self.animatePulse(object: plusLabel)
            self.addChild(lifeSprite)
            self.addChild(plusLabel)
        })
    }

    
    func animateBlocks(blocks: [CustomButton]) {
        var counterForSounds: Int = 0
        for (n, block) in blocks.enumerated() {
            
            let delay = TimeInterval(n)*0.35
            counterForSounds = n
            
            let pulse = SKAction.sequence([SKAction.scale(by: 1.2, duration: 0.1),
                                            SKAction.scale(by: 0.8, duration: 0.1),
                                            SKAction.scale(by: 1.1, duration: 0.1),
                                            SKAction.scale(by: 1, duration: 0.1)])
            
            block.run(SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.group([pulse])]))
        }
        AudioPlayer.sharedInstance.soundsForGoldenBlocks(numberOfBlocks: counterForSounds, node: self)
    }
    
    func animatePulse(object: SKNode) {
        let pulse = SKAction.sequence([SKAction.scale(by: 1.2, duration: 0.1),
                                       SKAction.scale(by: 0.8, duration: 0.1),
                                       SKAction.scale(by: 1.1, duration: 0.1),
                                       SKAction.scale(by: 1, duration: 0.1)])
        
        object.run(pulse)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class helpMenu: dismissibleMenu {
    
    init(theme: Theme, gameMode: gameModes, target: Int, moves: Int, targetScore: Int?, targetBlocks: [blockType?]) {
        
        var largeSize: Bool
        
        if gameMode == gameModes.targetWithBlocks && targetBlocks.isEmpty == false {
            largeSize = true
        } else if gameMode == gameModes.targetWithScore {
            largeSize = true
        } else {
            largeSize = false
        }
        
        super.init(theme: theme, title: "Help", largeSize: largeSize)
        
        let line1 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line1.text = "Get a block to"
        line1.fontSize = 26
        line1.verticalAlignmentMode = .center; line1.horizontalAlignmentMode = .center
        line1.position = CGPoint(x: 0, y: 60)
        line1.fontColor = theme.customTextColor
        self.addChild(line1)
        let line2 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line2.text = "the target \(target)"
        line2.fontSize = 26
        line2.verticalAlignmentMode = .center; line1.horizontalAlignmentMode = .center
        line2.position = CGPoint(x: 0, y: 25)
        line2.fontColor = theme.customTextColor
        self.addChild(line2)
        let line3 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line3.text = "within \(moves) moves."
        line3.fontSize = 26
        line3.verticalAlignmentMode = .center; line1.horizontalAlignmentMode = .center
        line3.position = CGPoint(x: 0, y: -10)
        line3.fontColor = theme.customTextColor
        self.addChild(line3)
        
        if GameHandler.sharedInstance.currentLevel! == 1 || GameHandler.sharedInstance.currentLevel! == 2 {
            line3.text = "within 1 move."
        }
        
        //These lines are only added if gameMode is not 0
        let line4 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line4.text = "Before"
        line4.fontSize = 28
        line4.verticalAlignmentMode = .center; line1.horizontalAlignmentMode = .center
        line4.position = CGPoint(x: 0, y: 25)
        line4.fontColor = theme.customTextColor
        let line5 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line5.fontSize = 26
        line5.verticalAlignmentMode = .center; line1.horizontalAlignmentMode = .center
        line5.position = CGPoint(x: 0, y: 140)
        line5.fontColor = theme.customTextColor
        
        if gameMode == gameModes.targetWithBlocks && targetBlocks.isEmpty == false {
            line1.text = "Getting a block to"
            line1.position = CGPoint(x: 0, y: -20)
            line2.position = CGPoint(x: 0, y: -50)
            line3.position = CGPoint(x: 0, y: -80)
            self.addChild(line4)
            line5.text = "Remove:"
            self.addChild(line5)
            
            var blocksToDraw: Int = 0
            var (red, green, blue) = blocksForMenu(blocks: targetBlocks as! [blockType])
            
            if red != 0 {
                blocksToDraw += 1
            }
            if green != 0 {
                blocksToDraw += 1
            }
            if blue != 0 {
                blocksToDraw += 1
            }
            
            for i in 0 ..< blocksToDraw {
                var block = SKShapeNode()
                if red != 0 {
                    let number = red
                    block = drawBlock(color: theme.customRedColor, number: number)
                    red -= number
                } else if green != 0 {
                    let number = green
                    block = drawBlock(color: theme.customGreenColor, number: number)
                    green -= number
                } else if blue != 0 {
                    let number = blue
                    block = drawBlock(color: theme.customBlueColor, number: number)
                    blue -= number
                }
                
                if blocksToDraw == 1 {
                    block.position = CGPoint(x: 0, y: 82)
                } else if blocksToDraw == 2 {
                    if i == 0 {
                        block.position = CGPoint(x: -40, y: 82)
                    } else {
                        block.position = CGPoint(x: 40, y: 82)
                    }
                } else if blocksToDraw == 3 {
                    if i == 0 {
                        block.position = CGPoint(x: -65, y: 82)
                    } else if i == 2 {
                        block.position = CGPoint(x: 0, y: 82)
                    } else {
                        block.position = CGPoint(x: 65, y: 82)
                    }
                }
                block.zPosition = 100
                self.addChild(block)
            }
            
        } else if gameMode == gameModes.targetWithScore {
            line1.text = "Getting a block to"
            line1.position = CGPoint(x: 0, y: -20)
            line2.position = CGPoint(x: 0, y: -50)
            line3.position = CGPoint(x: 0, y: -80)
            self.addChild(line4)
            line5.text = "Score at least:"
            self.addChild(line5)
            
            let line6 = SKLabelNode(fontNamed: "Montserrat-Bold")
            line6.text = "\(targetScore!)"
            line6.fontColor = theme.customTextColor
            line6.fontSize = 46
            line6.verticalAlignmentMode = .center; line1.horizontalAlignmentMode = .center
            line6.position = CGPoint(x: 0, y: 82)
            self.addChild(line6)
        }
    }
    
    func blocksForMenu(blocks: [blockType]) -> (red: Int, green: Int, blue: Int) {
        
        var redBlocks = 0
        var greenBlocks = 0
        var blueBlocks = 0
        
        for block in 0 ..< blocks.count {
            let block = blocks[block]
            
            if block == blockType.redBlock {
                redBlocks += 1
            } else if block == blockType.greenBlock {
                greenBlocks += 1
            } else if block == blockType.blueBlock {
                blueBlocks += 1
            }
        }
        return(red: redBlocks, green: greenBlocks, blue: blueBlocks)
    }
    
    func drawBlock(color: UIColor, number: Int) -> SKShapeNode {
        let origin: CGFloat = -50 / 2 // width of block / 2 (minus because 0,0 is top right in shape nodes (1,1 is at the bottom left))
        let shapeNode = SKShapeNode(path: CGPath(roundedRect: CGRect(x: origin, y: origin ,width: 50, height: 50) , cornerWidth: 10, cornerHeight: 10, transform: nil))
        let label = SKLabelNode(text: "x\(number)")
        
        shapeNode.fillColor = color
        shapeNode.strokeColor = shapeNode.fillColor
        
        //label created
        label.fontName = "Montserrat-Bold"
        label.fontSize = 24
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.fontColor = theme.customTextColor
        shapeNode.addChild(label)
        
        //Creates the shadow and 3d effect
        let shadowBack = SKShapeNode(path: shapeNode.path!)
        shadowBack.fillColor = shapeNode.fillColor; shadowBack.strokeColor = shapeNode.strokeColor
        shadowBack.position = CGPoint(x: 0, y: -3); shadowBack.zPosition = -2
        shapeNode.addChild(shadowBack)
        
        let shadowFront = SKShapeNode(path: shapeNode.path!) // shapenode that creates texture for spritenode
        shadowFront.fillColor = UIColor(red: 127/256, green: 127/256, blue: 127/256, alpha: 0.25); shadowFront.strokeColor = shadowFront.fillColor //alpha set to 0.25
        shadowFront.position = CGPoint(x: 0, y: -3); shadowFront.zPosition = -1
        shapeNode.addChild(shadowFront)
        
        return shapeNode
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK:- YesNoMenus

class yesNoMenu: PopUpMenu {
    
    var yesButton: CustomButton?
    var noButton: CustomButton?
    
    override init(theme: Theme, title: String) {
        
        super.init(theme: theme, title: title)
        
        let buttonPath = CGPath(roundedRect: CGRect(x: -45, y: -25, width: 90, height: 50), cornerWidth: 10, cornerHeight: 10, transform: nil)
        
        self.yesButton = CustomButton(path: buttonPath, text: "Yes!", color: theme.customOrangeColor, textColor: theme.customTextColor, action: {
            print("yes")
        })
        yesButton!.position = CGPoint(x: -55, y: -60); yesButton!.zPosition = 10
        yesButton!.textLabel?.fontSize = 28
        self.addChild(yesButton!)
        
        self.noButton = CustomButton(path: buttonPath, text: "No!", color: theme.customOrangeColor, textColor: theme.customTextColor) {
            print("No")
        }
        noButton!.position = CGPoint(x: 55, y: -60); noButton!.zPosition = 10
        noButton!.textLabel?.fontSize = 28
        self.addChild(noButton!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class levelSelectMenu: yesNoMenu {
    
    let blockPath = CGPath(roundedRect: CGRect(x: -28, y: -26, width: 56, height: 52) , cornerWidth: 13, cornerHeight: 13, transform: nil)
    
    init(theme: Theme, level: Int, goldenBlocks: Int, dismissAction: @escaping () -> Void) {
        
        super.init(theme: theme, title: "level \(level)")
        
        self.yesButton!.action = dismissAction
        self.yesButton!.textLabel!.text = "Start!"
        self.yesButton!.textLabel!.fontSize = 26
        
        self.noButton!.textLabel!.fontSize = 26
        self.noButton!.action = {
            if let handler = self.menuHandler {
                handler(.dismissMenu)
            }
        }
        
        let blockXPositions = [-70, 0, 70]
        let goldColour = UIColor(red: 0.950, green: 0.761, blue: 0.196, alpha: 1)
        let backgroundColour = UIColor(red: 0.498, green: 0.498, blue: 0.498, alpha: 0.25)
        
        
        var blocks = [CustomButton]()
        
        for block in 0 ..< 3 {
            
            if block < goldenBlocks {
                let goldenBlock = CustomButton(path: blockPath, text: "\(block + 1)", color: goldColour, textColor: theme.customTextColor, action: {})
                goldenBlock.position = CGPoint(x: blockXPositions[block], y: 30)
                goldenBlock.zPosition = 150
                blocks.append(goldenBlock)
                self.addChild(goldenBlock)
            } else {
                let backgroundBlock = SKShapeNode(path: blockPath)
                backgroundBlock.fillColor = backgroundColour
                backgroundBlock.strokeColor = backgroundColour
                backgroundBlock.position = CGPoint(x: blockXPositions[block], y: 30)
                backgroundBlock.zPosition = 150
                self.addChild(backgroundBlock)
            }
        }
        
        animateBlocks(blocks: blocks)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animateBlocks(blocks: [CustomButton]) {
        for (n, block) in blocks.enumerated() {
            
            let delay = TimeInterval(n)*0.35
            
            let pulse = SKAction.sequence([SKAction.scale(by: 1.2, duration: 0.1),
                                           SKAction.scale(by: 0.8, duration: 0.1),
                                           SKAction.scale(by: 1.1, duration: 0.1),
                                           SKAction.scale(by: 1, duration: 0.1)])
            
            block.run(SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.group([pulse])]))
        }
    }
}

class getThemeMenu: yesNoMenu {
    
    var themeNumber: Int
    
    init(theme: Theme, themeNumber: Int, unlockLevel: Int) {
        
        self.themeNumber = themeNumber
        
        super.init(theme: theme, title: "Get Theme?")
        
        headerLabel.fontSize = 26
        
        self.yesButton!.action = {
            if let handler = self.menuHandler {
                handler(.getTheme)
            }
        }
        self.noButton!.action = {
            if let handler = self.menuHandler {
                handler(.dismissMenu)
            }
        }
        
        let line1 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line1.text = "Unlocks at level:"
        line1.fontSize = 22
        line1.position = CGPoint(x: 0, y: 63)
        line1.fontColor = theme.customTextColor
        
        let levelPath = CGPath(roundedRect: CGRect(x: -24, y: -22, width: 48, height: 44), cornerWidth: 13, cornerHeight: 13, transform: nil)
        let level = CustomButton(path: levelPath, text: "\(unlockLevel)", color: theme.customOrangeColor, textColor: theme.customTextColor, action: {})
        level.position = CGPoint(x: 0, y: 32)
        level.zPosition = 10
        self.addChild(level)
        
        let line3 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line3.text = "Get it now?"
        line3.fontSize = 24
        line3.position = CGPoint(x: 0, y: -20)
        line3.fontColor = theme.customTextColor

        
        self.addChild(line1)
        self.addChild(line3)
        
        let gem = SKSpriteNode(imageNamed: "gem.png")
        gem.size = CGSize(width: 50, height: 40)
        gem.position = CGPoint(x: 43, y: 23)
        self.yesButton!.addChild(gem)
        
        let gemLabel = SKLabelNode(fontNamed: "Montserrat-Bold")
        gemLabel.text = "-150"
        gemLabel.fontSize = 16
        gemLabel.verticalAlignmentMode = .center; gemLabel.horizontalAlignmentMode = .center
        gemLabel.position = CGPoint(x: 0, y: 2)
        gemLabel.zPosition = 10
        gemLabel.fontColor = theme.customTextColor
        gem.addChild(gemLabel)
        
        yesButton!.position = CGPoint(x: -55, y: -70)
        noButton!.position = CGPoint(x: 55, y: -70)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class outOfMovesMenu: yesNoMenu {
    
    let buttonPath = CGPath(roundedRect: CGRect(x: -75, y: -20, width: 150, height: 40), cornerWidth: 10, cornerHeight: 10, transform: nil)
    
    init(theme: Theme) {
        
        super.init(theme: theme, title: "Out Of Moves!")
        
        self.path = CGPath(roundedRect: CGRect(x: -150, y: -110 ,width: 300, height: 235) , cornerWidth: 30, cornerHeight: 30, transform: nil)
        self.header.position = CGPoint(x: 0, y: (self.frame.height / 2) + 8)
        
        self.headerLabel.fontSize = 26
        
        self.yesButton!.position = CGPoint(x: -55, y: 17)
        self.noButton!.position = CGPoint(x: 55, y: 17)
        
        self.yesButton!.action = {
            if let handler = self.menuHandler {
                handler(.getMoves)
            }
        }
        self.noButton!.action = {
            if let handler = self.menuHandler {
                handler(.failMenu)
            }
        }
        
        let line1 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line1.text = "Get 5 extra moves?"
        line1.fontSize = 26
        line1.verticalAlignmentMode = .center; line1.horizontalAlignmentMode = .center
        line1.position = CGPoint(x: 0, y: 75)
        line1.fontColor = theme.customTextColor
        self.addChild(line1)
        
        let gem = SKSpriteNode(imageNamed: "gem.png")
        gem.size = CGSize(width: 46, height: 38)
        gem.position = CGPoint(x: 43, y: 23)
        self.yesButton!.addChild(gem)
        
        let gemLabel = SKLabelNode(fontNamed: "Montserrat-Bold")
        gemLabel.text = "-30"
        gemLabel.fontSize = 16
        gemLabel.verticalAlignmentMode = .center; gemLabel.horizontalAlignmentMode = .center
        gemLabel.position = CGPoint(x: 0, y: 2)
        gemLabel.zPosition = 10
        gemLabel.fontColor = theme.customTextColor
        gem.addChild(gemLabel)
        
        let watchAdButton = CustomButton(path: buttonPath, text: "Watch Ad", color: theme.customOrangeColor, textColor: theme.customTextColor, action: {
            if let handler = self.menuHandler {
                handler(.watchAdForMove)
            }
        })
        watchAdButton.position = CGPoint(x: 0, y: -45); watchAdButton.zPosition = 10
        watchAdButton.textLabel!.fontSize = 22
        self.addChild(watchAdButton)
        
        let line2 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line2.text = "+1 move"
        line2.fontSize = 20
        line2.verticalAlignmentMode = .center; line1.horizontalAlignmentMode = .center
        line2.position = CGPoint(x: 0, y: -85); line2.zPosition = 10
        line2.fontColor = theme.customTextColor
        self.addChild(line2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class outOfLivesMenu: yesNoMenu {
    
    init(theme: Theme, nextLifeIn: CGFloat) {
        
        super.init(theme: theme, title: "Out Of Lives!")
        
        self.headerLabel.fontSize = 26
        
        self.yesButton!.action = {
            if let handler = self.menuHandler {
                handler(.getlife)
            }
        }
        self.noButton!.action = {
            if let handler = self.menuHandler {
                handler(.dismissMenu)
            }
        }
        
        let line1 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line1.text = "Buy 1 Life?"
        line1.fontSize = 28
        line1.position = CGPoint(x: 0, y: 50)
        line1.fontColor = theme.customTextColor
        let line2 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line2.text = "Next life:"
        line2.fontSize = 20
        line2.position = CGPoint(x: 0, y: 23)
        line2.fontColor = theme.customTextColor
        
        self.addChild(line1)
        self.addChild(line2)
        
        let nextLife = ProgressBar(progress: nextLifeIn, endValue: 30, length: 200, height: 20, colour: theme.customGreenColor)
        nextLife.position = CGPoint(x: 0, y: 3); nextLife.zPosition = 100
        self.addChild(nextLife)
        
        let life = SKSpriteNode(imageNamed: "Life.png")
        life.size = CGSize(width: 34, height: 31)
        life.position = CGPoint(x: 100, y: 10)
        nextLife.addChild(life)
        
        let gem = SKSpriteNode(imageNamed: "gem.png")
        gem.size = CGSize(width: 46, height: 38)
        gem.position = CGPoint(x: 43, y: 22)
        self.yesButton!.addChild(gem)
        
        let gemLabel = SKLabelNode(fontNamed: "Montserrat-Bold")
        gemLabel.text = "-40"
        gemLabel.fontSize = 16
        gemLabel.verticalAlignmentMode = .center; gemLabel.horizontalAlignmentMode = .center
        gemLabel.position = CGPoint(x: 0, y: 2)
        gemLabel.zPosition = 10
        gemLabel.fontColor = theme.customTextColor
        gem.addChild(gemLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class homeMenu: yesNoMenu {
    
    init(theme: Theme) {
        
        super.init(theme: theme, title: "Home?")
        
        self.yesButton!.action = {
            if let handler = self.menuHandler {
                handler(.home)
            }
        }
        self.noButton!.action = {
            if let handler = self.menuHandler {
                handler(.dismissMenu)
            }
        }
        
        let line1 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line1.text = "Your progress for"
        line1.fontSize = 26
        line1.position = CGPoint(x: 0, y: 35)
        line1.fontColor = theme.customTextColor
        let line2 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line2.text = "this level will be lost!"
        line2.fontSize = 26
        line2.position = CGPoint(x: 0, y: 5)
        line2.fontColor = theme.customTextColor
        
        self.addChild(line1)
        self.addChild(line2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class restartMenu: yesNoMenu {
    
    init(theme: Theme) {
        
        super.init(theme: theme, title: "Restart?")
        
        self.yesButton!.action = {
            if let handler = self.menuHandler {
                handler(.restart)
            }
        }
        self.noButton!.action = {
            if let handler = self.menuHandler {
                handler(.dismissMenu)
            }
        }
        
        let line1 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line1.text = "Your progress for"
        line1.fontSize = 26
        line1.position = CGPoint(x: 0, y: 35)
        line1.fontColor = theme.customTextColor
        let line2 = SKLabelNode(fontNamed: "Montserrat-Bold")
        line2.text = "this level will be lost!"
        line2.fontSize = 26
        line2.position = CGPoint(x: 0, y: 5)
        line2.fontColor = theme.customTextColor
        
        self.addChild(line1)
        self.addChild(line2)
        
        let life = SKSpriteNode(imageNamed: "Life.png")
        life.size = CGSize(width: 44, height: 38)
        life.position = CGPoint(x: 42, y: 22)
        yesButton!.addChild(life)
        
        let lifeLabel = SKLabelNode(fontNamed: "Montserrat-Bold")
        lifeLabel.text = "-1"
        lifeLabel.fontSize = 18
        lifeLabel.verticalAlignmentMode = .center; lifeLabel.horizontalAlignmentMode = .center
        lifeLabel.position = CGPoint(x: 0, y: 1 )
        lifeLabel.zPosition = 10
        lifeLabel.fontColor = theme.customTextColor
        life.addChild(lifeLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
