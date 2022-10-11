//
//  GameViewController.swift
//  Number Block
//
//  Created by Nathan on 06/03/2018.
//  Copyright © 2018 Nathan. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import Firebase
import FacebookCore
import FacebookLogin

enum consumables {
    case gems, lives
}

enum buyConsumables {
    case adsremove, gems200, gems600, gems1500, gems3000, gems10000, lives1, lives5, livesUnlimited3, livesUnlimited6, livesUnlimited12
}

class GameViewController: UIViewController, GameSceneDelegate, SelectSceneDelegate, StartSceneDelegate, GADInterstitialDelegate, GADRewardBasedVideoAdDelegate {
    
    var interstitialAd: GADInterstitial?
    //GADRewardBasedVideoAd is a singleton
    var rewardedAd: GADRewardBasedVideoAd!
    
    
    var  sceneSize: CGSize {
        
        if isIPhoneX() {
            return CGSize(width: 768, height: 1250)
        } else {
            return CGSize(width: 768, height: 1024)
        }
    }
    
    var currentTheme: Theme?
    
    var currentScene: CustomScene?
    
    //MARK:- Initialisation

    override func viewDidLoad() {
        
        IAPService.sharedInstance.GVC = self
        IAPService.sharedInstance.getProducts()
        
        interstitialAd = createAndLoadInterstitial()
        
        rewardedAd = createRewardedAd()
        loadRewardedAd()
        
        addDidBecomeActiveObserver()
        
        currentTheme = getTheme(themeNumber: GameHandler.sharedInstance.currentTheme)
        
        AudioPlayer.sharedInstance.muted = GameHandler.sharedInstance.muted
        print(GameHandler.sharedInstance.muted)
        
        //This stops the  thread just before super.viewDidLoad to let the launch screen show for atleast 2 seconds
        //Done after loading all ads ect to let them load.
        Thread.sleep(forTimeInterval: 2)
        
        super.viewDidLoad()
        
        loadMenuScene(mainMenu: true)
    }
    
    
    
    //MARK:- Scene Initialisation
    
    //Loads either start scene or select scene.
    func loadMenuScene(mainMenu: Bool) {
        if let view = self.view as! SKView? {
            
            if mainMenu {
                let scene = StartScene(size: sceneSize, theme: currentTheme!)
                scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                scene.customDelegate = self
                // Present the scene
                view.presentScene(scene)
                self.currentScene = scene
            } else {
                let scene = SelectScene(size: sceneSize, theme: currentTheme!)
                scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                scene.customDelegate = self
                // Present the scene
                view.presentScene(scene)
                self.currentScene = scene
            }
        }
    }
    
    //Loads the game with a selected level.
    func loadGameScene(level: String) {
        showInterstitial()
        if let view = self.view as! SKView? {
            // Load the game scene
            let scene = GameScene(size: sceneSize, theme: currentTheme!, level: level)
            scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            scene.customDelegate = self
            // Present the scene
            view.presentScene(scene)
            
            self.currentScene = scene
        }
    }
    
    //This function adds the observer for the "applicationDidBecomeActive" notification in the AppDelegate.
    func addDidBecomeActiveObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive(_:)),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
    }
    
    //This function is called be when the game becomes active and calls functions in the scenes so they can update appropriately.
    @objc func applicationDidBecomeActive(_ notification: NSNotification) {
        if let scene = currentScene {
            scene.didBecomeActive()
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK:- Functions
    
    //This function uses the theme number to select a theme name from the themes array and creates a theme struct from the relevent json file.
    func getTheme(themeNumber: Int) -> Theme? {
        let themes = ["Default", "Night", "Green", "ColourFull", "test1", "test2", "test3", "test4", "test5", "test6"]
        
        //Loads the colours for the current theme from the json file
        var newTheme = Theme()
        guard let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename: themes[themeNumber]) else {return nil}
        if let backgroundcolour = dictionary["backgroundColour"] as? [CGFloat] {
            let colour = UIColor(red: backgroundcolour[0], green: backgroundcolour[1], blue: backgroundcolour[2], alpha: backgroundcolour[3])
            newTheme.customBackgroundColor = colour
        }
        if let backgroundcolour = dictionary["textColour"] as? [CGFloat] {
            let colour = UIColor(red: backgroundcolour[0], green: backgroundcolour[1], blue: backgroundcolour[2], alpha: backgroundcolour[3])
            newTheme.customTextColor = colour
        }
        if let backgroundcolour = dictionary["orangeColour"] as? [CGFloat] {
            let colour = UIColor(red: backgroundcolour[0], green: backgroundcolour[1], blue: backgroundcolour[2], alpha: backgroundcolour[3])
            newTheme.customOrangeColor = colour
        }
        if let backgroundcolour = dictionary["redColour"] as? [CGFloat] {
            let colour = UIColor(red: backgroundcolour[0], green: backgroundcolour[1], blue: backgroundcolour[2], alpha: backgroundcolour[3])
            newTheme.customRedColor = colour
        }
        if let backgroundcolour = dictionary["greenColour"] as? [CGFloat] {
            let colour = UIColor(red: backgroundcolour[0], green: backgroundcolour[1], blue: backgroundcolour[2], alpha: backgroundcolour[3])
            newTheme.customGreenColor = colour
        }
        if let backgroundcolour = dictionary["blueColour"] as? [CGFloat] {
            let colour = UIColor(red: backgroundcolour[0], green: backgroundcolour[1], blue: backgroundcolour[2], alpha: backgroundcolour[3])
            newTheme.customBlueColor = colour
        }
        
        if let requiredLevel = dictionary["requiredLevel"] as? Int {
            newTheme.requiredLevel = requiredLevel
        }
        return newTheme
    }
    
    //This function is called when the player finishes a level, it unlocks any new levels.
    func getNewThemes() {
        let (allThemes, unlockStatus) = getAllThemes()
        
        for (themeNumber, theme) in allThemes.enumerated() {
            if theme.requiredLevel <= GameHandler.sharedInstance.userLevel && !unlockStatus[themeNumber] {
                self.unlockTheme(themeNumber: themeNumber, showNow: false)
                GameHandler.sharedInstance.newThemes = true
                GameHandler.sharedInstance.savePlayerStats()
                
            }
        }
    }
    
}

extension GameViewController {
    
    //MARK:- Custom delegate metods
    
    //This function is called be they gamescene through its delegate when a level is successfully completed.
    func endGame(score: Int, goldenBlocks: Int) {
        
        if GameHandler.sharedInstance.levelStatsImproved(goldenBlocks: goldenBlocks) {
            let (oldScoreTo, scoreToNext) = self.nextPlayerLevel()
            let currentScore = self.getPlayerScore()
            
            //Works out if the player has leveled up
            var levelUp: Bool {
                if (currentScore + score) >= scoreToNext {
                    return true
                } else {
                    return false
                }
            }
            //If the user has leveled up, they will be given the extra life by the GameHandler. This is incase the user levels up multiple levels.
            GameHandler.sharedInstance.saveLevelStats(goldenBlocks: goldenBlocks, score: score, levelledUp: levelUp)
            getNewThemes()
        }
        //extra life if leveld up added in game handler
        //if unlimited lives is on then we dont want to give back a life we didnt take, can give them extra life for leveling up in gamescene though
        if !GameHandler.sharedInstance.unlimitedLives {
            GameHandler.sharedInstance.addLife()
        }
        GameHandler.sharedInstance.savePlayerStats()
    }
    
    //This function is called be they gamescene through its delegate when the user wants to restart the level.
    func restart() {
        startGame(level: GameHandler.sharedInstance.currentLevel!)
    }
    
    func reportLevelFail() {
        if let level = GameHandler.sharedInstance.currentLevel {
            Analytics.logEvent("level_failed", parameters: ["level": level])
        }
    }
    
    //This function is used by the get life menu in the select scene becuase the start game function requires a life. ((gamescene restart doesnt)?? I Think it does, should look into it.)
    func  addLife() {
        GameHandler.sharedInstance.addLife()
    }
    
    func reportThemePurchased(themeNumber: Int) {
        Analytics.logEvent("theme_purchased", parameters: ["theme_number": themeNumber])
    }
    
    func reportadWatchedForLife() {
        Analytics.logEvent("ad_for_life", parameters: nil)
    }

    
    //This function is called by the selectscene and starts a given level, this is where the life is taken.
    func startGame(level: Int) {
        let unlimited = self.livesUnlimited()
        
        if !unlimited {
            take(consumable: .lives, number: 1)
        }
        GameHandler.sharedInstance.currentLevel = level
        loadGameScene(level: "Level_\(level)")
    }
    
    //This function gets the next level for the selectScreen.
    func getNextLevel() -> Int {
        let nextLevel = GameHandler.sharedInstance.levelProgression.count + 1
        return nextLevel
    }
    
    //This function is called by the startscene through its delegate and restarts the scene with the new theme.
    func updateTheme(themeNumber: Int) {
        if let newTheme = getTheme(themeNumber: themeNumber) {
            currentTheme = newTheme
            GameHandler.sharedInstance.currentTheme = themeNumber
            GameHandler.sharedInstance.savePlayerStats()
            self.loadMenuScene(mainMenu: true)
        }
        
    }
    
    //Function is not used
    //Well.. It mutes the game (is toggled).
    func mute() {
        print(1)
    }
    
    //Called by both the startscene and the gamescene to load the selectscene.
    func goToLevelSelect() {
        loadMenuScene(mainMenu: false)
    }
    
    //Called by both the startscene and the gamescene to get the players level.
    func getPlayerLevel() -> Int {
        let playerLevel = GameHandler.sharedInstance.userLevel
        return playerLevel
    }
    
    //Called by both the startscene and the gamescene to get the players next level.
    func nextPlayerLevel() -> (lastLevelScore: Int, nextLevelScore: Int) {
        let lastLevel = GameHandler.sharedInstance.lastUserLevel
        let nextLevel = GameHandler.sharedInstance.nextUserLevel
        return(lastLevel, nextLevel)
    }
    
    //Called by both the startscene and the gamescene to get the players current score.
    func getPlayerScore() -> Int {
        let playerScore = GameHandler.sharedInstance.userScore
        return playerScore
    }
    
    //Called by the selectscene and the gamescene to get the time till the next life is regenrated.
    func nextLifeIn() -> CGFloat {
        let timeToLife = GameHandler.sharedInstance.timeToLife()
        return timeToLife
    }
    
    //Called by the gamescene, it returns the bool returned by the gamehandler. Needed as only the GVC intracts with the GameHandler
    func levelStatsImproved(goldenBlocks: Int) -> Bool {
        let levelImproved: Bool = GameHandler.sharedInstance.levelStatsImproved(goldenBlocks: goldenBlocks)
        return levelImproved
    }
    
    //Called by the startscenes delegate, it gets all of the themes and their unlocked status for the themes menu.
    func getAllThemes() -> (themes: [Theme], unlocked: [Bool]) {
        var themes = [Theme]()
        let unlocked = GameHandler.sharedInstance.unlockedThemes
        
        for themeNumber in 0 ..< unlocked.count {
            let theme = self.getTheme(themeNumber: themeNumber)
            themes.append(theme!)
        }
        return(themes, unlocked)
    }
    
    //Called by the startscenes deelgate, it unlocks the theme in the gamehandler, and then restats the startscene with the new theme.
    func unlockTheme(themeNumber: Int, showNow: Bool) {
        GameHandler.sharedInstance.unlockedThemes[themeNumber] = true
        if showNow {
            updateTheme(themeNumber: themeNumber)
        }
    }
    
    //This function is called through the select scene delegate and gets the number of golden block the player got for a given level
    func getGoldenBlocksFor(level: Int) -> Int {
        let goldenBlocks = GameHandler.sharedInstance.getGoldenBlocksFor(level: level)
        return goldenBlocks
    }
    
    //This function is used by the start scene delegate to 1: see if there is a new theme unlocked and unseen by the player, and 2: to notify the GameHandler once the player has seen the new theme.
    func newThemeUnlocked(seen: Bool) -> Bool {
        if !seen {
            let newThemes = GameHandler.sharedInstance.newThemes
            return newThemes
        } else {
            GameHandler.sharedInstance.newThemes = false
            GameHandler.sharedInstance.savePlayerStats()
            return false
        }
    }
    
    //Used by the gamescene delegate to call the GVC's show interstitial ad.
    func presentInterstitial() {
        self.showInterstitial()
    }
    
    //Used by the gamescene delegate to call the GVC's show rewareded ad.
    func presentRewardedAd() {
        self.showRewardedAd()
    }
    
    func loggedInFacebook() -> Bool {
        return GameHandler.sharedInstance.loggedInFacebook
    }
    
    //MARK:- Default delegate methods
    
    //Called by the all, it returns the number of lives the player has returned by the gamehandler. Needed as only the GVC intracts with the GameHandler
    func getLives() -> Int {
        GameHandler.sharedInstance.regenerateLives()
        let numberOfLives = GameHandler.sharedInstance.numberOfLives
        return numberOfLives
    }
    
    func livesUnlimited() -> Bool {
        GameHandler.sharedInstance.updateUnlimitedLives()
        let unlimited = GameHandler.sharedInstance.unlimitedLives
        return unlimited
    }
    
    //Called by the all, it returns the number of gems the player has returned by the gamehandler. Needed as only the GVC intracts with the GameHandler
    func getGems() -> Int {
        let numberOfGems = GameHandler.sharedInstance.numberOfGems
        return numberOfGems
    }
    
    //Called through the shop. This function buys the consumables avalible in the shop.
    func buy(get: buyConsumables) {
        switch get {
        case .adsremove:
            GameHandler.sharedInstance.adsOf()
        case .gems200:
            GameHandler.sharedInstance.addGems(amount: 200)
        case .gems600:
            GameHandler.sharedInstance.addGems(amount: 600)
        case . gems1500:
            GameHandler.sharedInstance.addGems(amount: 1500)
        case .gems3000:
            GameHandler.sharedInstance.addGems(amount: 3000)
        case .gems10000:
            GameHandler.sharedInstance.addGems(amount: 10000)
        case .lives1:
            //Double checks to make sure button hasnt been spamed
            if GameHandler.sharedInstance.numberOfGems >= 40 {
                GameHandler.sharedInstance.numberOfGems -= 40
                GameHandler.sharedInstance.savePlayerStats()
                GameHandler.sharedInstance.addLife()
            }
        case .lives5:
            //Double checks to make sure button hasnt been spamed
            if GameHandler.sharedInstance.numberOfGems >= 200 {
                GameHandler.sharedInstance.numberOfGems -= 200
                GameHandler.sharedInstance.savePlayerStats()
                for _ in 0 ..< 5 {
                    GameHandler.sharedInstance.addLife()
                }
            }
        case .livesUnlimited3:
            if GameHandler.sharedInstance.numberOfGems >= 500 {
                GameHandler.sharedInstance.numberOfGems -= 500
                let currentdate = Date()
                let calender = Calendar.current
                let date = calender.date(byAdding: .hour, value: 3, to: currentdate)
                print("Fail one")
                GameHandler.sharedInstance.unlimitedLivesOn(time: date!)
                //saves gems after opration complete
                GameHandler.sharedInstance.savePlayerStats()
            }
        case .livesUnlimited6:
            if GameHandler.sharedInstance.numberOfGems >= 800 {
                GameHandler.sharedInstance.numberOfGems -= 800
                let currentdate = Date()
                let calender = Calendar.current
                let date = calender.date(byAdding: .hour, value: 6, to: currentdate)
                GameHandler.sharedInstance.unlimitedLivesOn(time: date!)
                GameHandler.sharedInstance.unlimitedLivesOn(time: date!)
                //saves gems after opration complete
            }
        case .livesUnlimited12:
            if GameHandler.sharedInstance.numberOfGems >= 1000 {
                GameHandler.sharedInstance.numberOfGems -= 1000
                let currentdate = Date()
                let calender = Calendar.current
                let date = calender.date(byAdding: .hour, value: 12, to: currentdate)
                GameHandler.sharedInstance.unlimitedLivesOn(time: date!)
                GameHandler.sharedInstance.unlimitedLivesOn(time: date!)
                //saves gems after opration complete
            }
        }
        //updates the current scene.
        if let scene = self.currentScene {
            scene.didBecomeActive()
            scene.dismissMenu(all: false)
        }
    }
    
    func reportLifePurchased(amount: Int) {
        Analytics.logEvent("life_purchased", parameters: ["amount": amount])
    }
    
    func reportMovesPurchased() {
        Analytics.logEvent("moves_purchased", parameters: nil)
    }
    
    //Takes the given numbero of the given consumable. This is how all lives and gems are spent.
    func take(consumable: consumables, number: Int) {
        switch consumable {
        case .gems:
            let numberOfGems = getGems()
            if numberOfGems >= number {
                GameHandler.sharedInstance.numberOfGems -= number
                GameHandler.sharedInstance.savePlayerStats()
            }
        case .lives:
            if number == 1 {
                let numberOfLives: Int = getLives()
                if numberOfLives >= number {
                    GameHandler.sharedInstance.numberOfLives -= number
                    GameHandler.sharedInstance.savePlayerStats()
                    GameHandler.sharedInstance.lifeToRegenerate()
                }
            } else {
                print("Can not take more then 1 life at a time")
            }
        }
    }
    
    //Adds the ScrollView of the popupmenus (Is not used to add a scrollview for the level select buttons).
    func addScrollView(scrollView: CustomScrollView) {
        view!.addSubview(scrollView)
    }
    
    
    //This function returns the game to the startscene.
    func goHome() {
        GameHandler.sharedInstance.currentLevel = nil
        self.loadMenuScene(mainMenu: true)
    }
    
    func isIPhoneX() -> Bool {
        if UIScreen.main.nativeBounds.height == 2436 && UIDevice().userInterfaceIdiom == .phone{
            return true
        } else {
            return false
        }
    }
    
    //MARK:- AdMob
    
    //This function creates and loads an interstitial.
    func createAndLoadInterstitial () -> GADInterstitial {
        let request = GADRequest()
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-4772999923585944/4863984804")
        interstitial.delegate = self
        interstitial.load(request)
        return interstitial
    }
    
    //This function shows an interstitial, then reloads the next one.
    func showInterstitial() {
        if GameHandler.sharedInstance.adsOn {
            if let level = GameHandler.sharedInstance.currentLevel {
                if level > 3 {
                    let showAd = arc4random_uniform(2)
                    if showAd == 0 {
                        if let ad = interstitialAd {
                            if ad.isReady {
                                ad.present(fromRootViewController: self)
                                interstitialAd = createAndLoadInterstitial()
                            } else {
                                print("ad not ready")
                            }
                        }
                    }
                } else {
                    print("Will not show ads before level 3")
                }
            }
        } else {
            print("ads disabled")
        }
    }
    
    //This function creates a rewarded ad (refrences the singleton object).
    func createRewardedAd() -> GADRewardBasedVideoAd {
        let ad = GADRewardBasedVideoAd.sharedInstance()
        ad.delegate = self
        return ad
    }
    
    //This function loads a rewarded ad.
    func loadRewardedAd() {
        let request = GADRequest()
        rewardedAd.load(request, withAdUnitID: "ca-app-pub-4772999923585944/1866410083")
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didFailToLoadWithError error: Error) {
        print(error)
    }
    
    //This function shows a rewarded ad.
    func showRewardedAd() {
        if rewardedAd.isReady {
            rewardedAd.present(fromRootViewController: self)
            //Loads next ad in did close.
        }
    }
    
    func rewardBasedVideoAdDidOpen(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Did open")
    }
    
    func rewardBasedVideoAdDidStartPlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Did start")
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        self.loadRewardedAd()
    }
    
    //This function rewards the user after watching a rewarded ad.
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd, didRewardUserWith reward: GADAdReward) {
        if let gameScene = currentScene as? GameScene {
            gameScene.rewardUserWithMove()
        }
    }
}

extension GameViewController {
    
    func loginWithFacebook() {
        let loginManager = LoginManager()
        
        loginManager.logIn(readPermissions: [.publicProfile], viewController: self) { (result) in
            
            switch result {
            case.failed(let error):
                print(error.localizedDescription)
            case.cancelled:
                print("cancelled")
            case.success(let grantedPermissions, _, token: let userInfo):
                print(userInfo.userId!)
                print(grantedPermissions)
                GameHandler.sharedInstance.numberOfGems += 70
                GameHandler.sharedInstance.loggedInFacebook = true
                GameHandler.sharedInstance.savePlayerStats()
                self.loadMenuScene(mainMenu: true)
            }
            
        }
        
    }
}
