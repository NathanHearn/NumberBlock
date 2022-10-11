//
//  CustomGameScene.swift
//  Number Block
//
//  Created by Nathan on 06/03/2018.
//  Copyright © 2018 Nathan. All rights reserved.
//

import SpriteKit

class CustomScene: SKScene {
    //The CustomGameScene is just a subclass of SKScene with the added functions required to show PopUpMenus
    
    //MARK:- Properties
    
    //MARK:- PopUpMenu Properties
    enum menus {
        case pauseMenu, restartMenu, homeMenu, getMovesMenu, getLifeMenu, helpMenu, failMenu, successMenu, shop, info, themesMenu, levelSelectMenu
    }
    
    var scrollView: CustomScrollView?
    
    var currentMenu: PopUpMenu?
    var previousMenus = [PopUpMenu]()
    
    lazy var menuBackground: SKShapeNode = {
        let size = CGSize(width: self.size.width + 50, height: self.size.height + 50)
        let background = SKShapeNode(path: CGPath(rect: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height), transform: nil))
        background.fillColor = UIColor(red: 127/255, green: 127/255, blue: 127/255, alpha: 0.25)
        background.position = CGPoint(x: 0, y: 0)
        background.zPosition = 100
        
        return background
    }()
    
    //MARK:- Theme Properties
    
    var theme: Theme
    
    //MARK:- Initialiser
    
    init(size: CGSize, theme: Theme) {
        self.theme = theme
        
        super.init(size: size)
        
        self.backgroundColor = theme.customBackgroundColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Functions
    
    //This function will be over writen be scenes (StartScene) that need to update elements when the game becomes active agian.
    func didBecomeActive() {
        
    }
    
    //When in GameScene or SelectScene override the function "timeToNextLife" below to get the real time till the next life with a function in their delegate.
    func timeToNextLife() -> CGFloat {
        return 15
    }
    
    //When in GameScene or SelectScene override the function "addScrollView" below to use their delegates to allow the view controler to ADD the scroll view.
    func addScrollView(scollView: CustomScrollView) {
        
    }
    
    //Disables the touches in the scene
    func disableTouches() {
        self.isUserInteractionEnabled = false
        if let scrollView = self.scrollView {
            scrollView.disable()
        }
    }
    
    //Enables the touches in the scene
    func enableTouches() {
        self.isUserInteractionEnabled = true
        if let scrollView = self.scrollView {
            scrollView.enable()
        }
    }
    
    //MARK:- Pop-up Menu methods
    
    //MARK:- Menu Functions
    
    //In all scenes overide the function "menuFunctions" below to allow the menus in each scene to user their delegates.
    func menuFunctions(function: menuFunction) {
        switch function {
        case .restart:
            menuFunctionRestart()
        case .restartMenu:
            menuFunctionRestartMenu()
        case .home:
            menuFunctionHome()
        case .homeMenu:
            menuFunctionHomeMenu()
        case .infoMenu:
            menuFunctionInfoMenu()
        case .getlife:
            menuFunctionGetLife()
        case .getMovesMenu:
            menuFunctionGetMovesMenu()
        case .getMoves:
            menuFunctionGetMoves()
        case .watchAdForMove:
            menuFunctionWatchAdForMove()
        case .shopMenu:
            menuFunctionShopMenu()
        case .selectTheme:
            menuFunctionSelectTheme()
        case .levelSelect:
            menuFunctionLevelSelect()
        case .getTheme:
            menuFunctionGetTheme()
        case .dismissMenu:
            menuFunctionDismissMenu()
        case .failMenu:
            menuFunctionFailMenu()
        }
    }
    
    func menuFunctionRestart() {
        print("Restart")
    }
    
    func menuFunctionRestartMenu() {
        createMenu(type: .restartMenu)
    }
    
    func menuFunctionHome() {
        print("Home")
    }
    
    func menuFunctionHomeMenu() {
        createMenu(type: .homeMenu)
    }
    
    func menuFunctionInfoMenu() {
        createMenu(type: .info)
    }
    
    func menuFunctionGetLife() {
        print("GetLives")
    }
    
    func menuFunctionGetMovesMenu() {
        createMenu(type: .getMovesMenu)
    }
    
    func menuFunctionGetMoves() {
        print("GetMoves")
    }
    
    func menuFunctionWatchAdForMove() {
        print("watchAdForMove")
    }
    
    func menuFunctionShopMenu() {
        createMenu(type: .shop)
    }
    
    func menuFunctionSelectTheme() {
        print("SelectTheme")
    }
    
    func menuFunctionLevelSelect() {
        print("LevelSelect")
    }
    
    func menuFunctionGetTheme() {
        print("Getting Theme")
    }
    
    func menuFunctionDismissMenu() {
        dismissMenu(all: false)
    }
    
    func menuFunctionFailMenu() {
         createMenu(type: .failMenu)
    }
    
    
    
    //MARK:-
    
    //This function adds all menus to the scene, apart from menus that requirer infomation from their current scene or the GameHandler throught the sences delgate.
    func createMenu(type: menus) {
        var menu: PopUpMenu?
        switch type {
        case .pauseMenu:
            menu = pauseMenu(theme: theme, isMuted: false)
        case .restartMenu:
            menu = restartMenu(theme: theme)
        case .homeMenu:
            menu = homeMenu(theme: theme)
        case .getMovesMenu:
            menu = outOfMovesMenu(theme: theme)
        case .getLifeMenu:
            let nextLifeIn: CGFloat = timeToNextLife()
            menu = outOfLivesMenu(theme: theme, nextLifeIn: nextLifeIn)
        case .helpMenu:
            menu = PopUpMenu(theme: theme, title: "Error")
            //gamescene has custom function in which this menu is created
        case .failMenu:
            menu = failMenu(theme: theme)
        case .successMenu:
            menu = PopUpMenu(theme: theme, title: "Error")
            //gamescene has custom function in which this menu is created
        case .shop:
            menu = shop(theme: theme)
        case .info:
            menu = infoMenu(theme: theme)
        case .themesMenu:
            menu = PopUpMenu(theme: theme, title: "Error")
            //selectscene has custom function in which this menu is created
        case .levelSelectMenu:
            menu = PopUpMenu(theme: theme, title: "Error")
            //selectscene has custom function in which this menu is created
        }
        addMenuToScene(menu: menu!)
    }
    
    //This function adds the given menu to the scene.
    func addMenuToScene(menu: PopUpMenu) {
        if let currentView = view {
            currentView.isUserInteractionEnabled = false
        }
        disableTouches()
        let menuScale: CGFloat = 1.3
        menu.xScale = menuScale; menu.yScale = menuScale
        menu.zPosition = 200
        menu.menuHandler = menuFunctions
        if currentMenu == nil {
            
            let pulse = SKAction.sequence([SKAction.scale(to: menuScale + 0.05, duration: 0.1),
                                           SKAction.scale(to: menuScale - 0.05, duration: 0.1),
                                           SKAction.scale(to: menuScale, duration: 0.1)])
            
            menuBackground.zPosition = 150
            self.addChild(menuBackground)
            
            menu.position = CGPoint(x: 0, y: 0)
            menu.run(pulse, completion: {self.view!.isUserInteractionEnabled = true})
            self.addChild(menu)
            
            currentMenu = menu
        } else {
            
            let moveIn = SKAction.move(to: CGPoint(x: 0, y: 0), duration: 0.3)
            let moveOut = SKAction.move(by: CGVector(dx: -self.size.width, dy: 0), duration: 0.3)
            
            menu.position = CGPoint(x: self.size.width, y: 0)
            self.addChild(menu)
            menu.run(moveIn)
            currentMenu?.run(moveOut, completion: {self.view!.isUserInteractionEnabled = true})
            
            previousMenus.append(currentMenu!)
            currentMenu = menu
        }
        currentMenu = menu
    }
    
    //This function either dismisses the current menu or all of the menus
    func dismissMenu(all: Bool) {
        view!.isUserInteractionEnabled = false
        removeScrollView()
        print(1)
        if all {
            print(2)
            let menuScale: CGFloat = 1.3
            let pulse = SKAction.sequence([SKAction.scale(to: menuScale + 0.05, duration: 0.1),
                                           SKAction.scale(to: menuScale - 0.05, duration: 0.1),
                                           SKAction.scale(to: menuScale, duration: 0.1)])
            
            currentMenu!.run(pulse, completion: {
                self.currentMenu!.removeFromParent()
                self.menuBackground.removeFromParent()
                self.currentMenu = nil
                self.previousMenus = []
                self.view!.isUserInteractionEnabled = true
                self.enableTouches()
            })
            
        } else {
            print(3)
            if previousMenus.isEmpty {
                self.enableOtherObjects()
                let menuScale: CGFloat = 1.3
                let pulse = SKAction.sequence([SKAction.scale(to: menuScale + 0.05, duration: 0.1),
                                               SKAction.scale(to: menuScale - 0.05, duration: 0.1),
                                               SKAction.scale(to: menuScale, duration: 0.1)])
                
                currentMenu!.run(pulse, completion: {
                    self.currentMenu!.removeFromParent()
                    self.menuBackground.removeFromParent()
                    self.currentMenu = nil
                    self.view!.isUserInteractionEnabled = true
                    self.enableTouches()
                })
            } else {
                let moveIn = SKAction.move(to: CGPoint(x: 0, y: 0), duration: 0.3)
                let moveOut = SKAction.move(by: CGVector(dx: self.size.width, dy: 0), duration: 0.3)
                
                let oldMenu = currentMenu!
                currentMenu = previousMenus.last
                previousMenus.removeLast()
                
                oldMenu.run(moveOut, completion: {oldMenu.removeFromParent()})
                currentMenu!.run(moveIn, completion: {
                    self.view!.isUserInteractionEnabled = true
                })
                
                addBackScrollView(menu: currentMenu!)
            }
        }
    }
    
    //This function removes the scrollViews for the menus
    func removeScrollView() {
        if let scrollView = self.scrollView {
            scrollView.removeFromSuperview()
        }
    }
    
    func enableOtherObjects() {
        print("No unique objects to enable in current scene.")
    }
    
    //This function CREATES a scrollView for menus (The selectScene has its own function for creating a scrollView for the level select buttons).
    func createMenuScrollView(node: SKNode, menuType: menus, vertical: Bool, scrollTillEnd: Bool) {
        
        let verticalRatio = self.view!.frame.height / self.frame.height
        let horizontalRatio = self.view!.frame.width / self.frame.width
        var contentSize: CGFloat!
        
        switch menuType {
        case .info:
            //contentSize = 1200 - (430  * (1 - ratio))
            contentSize = 1350 - (430  * (1 - verticalRatio))
        case .themesMenu:
            contentSize = 700 - (400  * (1 - verticalRatio))
        case .shop:
            contentSize = 900 - (380  * (1 - horizontalRatio))
        default:
            return
        }
        
        let scrollView: CustomScrollView!
        
        var bounds = CGRect(x: (view!.frame.width / 2) - ((350 * horizontalRatio) / 2), y: ((view!.frame.height / 2) - ((360 * verticalRatio) / 2)) - 20, width: 350 * horizontalRatio, height: 360 * verticalRatio)
        
        if scrollTillEnd && vertical {
            bounds = CGRect(x: (view!.frame.width / 2) - ((350 * horizontalRatio) / 2), y: ((view!.frame.height / 2) - ((430 * verticalRatio) / 2)) - 20, width: 350 * horizontalRatio, height: 430 * verticalRatio)
        }
        
        if vertical {
            scrollView = CustomScrollView(frame: bounds, scene: self, moveableNode: node, scrollDirecton: .vertical)
            scrollView.contentSize = CGSize(width: 270 * verticalRatio, height: contentSize
            )
        } else {
            scrollView = CustomScrollView(frame: bounds, scene: self, moveableNode: node, scrollDirecton: .horizontal)
            scrollView.contentSize = CGSize(width: contentSize, height: 360 * horizontalRatio)
        }
        
        if menuType == .shop {
            scrollView.contentOffset = CGPoint(x: 510, y: 0)
        }
        
        self.scrollView = scrollView
        scrollView.enable()
        
        addScrollView(scollView: scrollView)
    }
    
    //This function is called by "dismissMenu" when moving back to a previous menu. It checks if the previous menu is meant to have a scrollview, and adds it if it should.
    func addBackScrollView(menu: PopUpMenu) {
        
        if let previousMenu = menu as? shop {
            let moveableNode = previousMenu.movableNode
            createMenuScrollView(node: moveableNode, menuType: .shop, vertical: false, scrollTillEnd: false)
        } else if let previousMenu = menu as? themesMenu {
            let moveableNode = previousMenu.movableNode
            createMenuScrollView(node: moveableNode, menuType: .themesMenu, vertical: true, scrollTillEnd: false)
        } else if let previousMenu = menu as? infoMenu {
            let moveableNode = previousMenu.movableNode
            createMenuScrollView(node: moveableNode, menuType: .info, vertical: true, scrollTillEnd: false)
        }
        
    }

}
