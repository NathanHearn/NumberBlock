//
//  GameHandler.swift
//  Number Block
//
//  Created by Nathan on 12/02/2018.
//  Copyright © 2018 Nathan. All rights reserved.
//

import Foundation
import SpriteKit
import Firebase

//The GameHandler is a singleton object responsable for reading and writing data, it used User Defults to achieve data persistents. It can ONLY communicate with the GameViewControler.
//It is also responsible for some logic, mainly working out wheter or not to store data and the logic for regenarating lives.
class GameHandler {
    
    //MARK: - Properties
    
    var userLevel: Int
    var userScore: Int
    var nextUserLevel: Int
    var lastUserLevel: Int
    
    var numberOfLives: Int
    var unlimitedLives: Bool
    var unlimitedLivesTime: Date?
    var numberOfGems: Int
    
    var timesForLives = [Date]()
    
    var currentLevel: Int?
    var levelProgression: [Int] = [Int]()
    
    var currentTheme: Int
    var unlockedThemes = [Bool]()
    
    var newThemes: Bool
    
    var muted: Bool
    var loggedInFacebook: Bool
    
    var adsOn: Bool
    
    //Used to tell the start scene to show the info menu on the first "login"
    var firstTimeUser: Bool = false
    
    class var sharedInstance: GameHandler {
        struct Singleton {
            static let instance = GameHandler()
        }
        return Singleton.instance
    }
    
    //MARK: - Init
    
    init() {
        
        //Sets all to the values of a new save
        userLevel = 0
        userScore = 0
        numberOfLives = 5
        unlimitedLives = false
        unlimitedLivesTime = nil
        numberOfGems = 120
        levelProgression = []
        timesForLives = []
        nextUserLevel = 130
        lastUserLevel = 1
        currentTheme = 0
        unlockedThemes = [true, false, false, false, false, false, false, false, false, false]
        
        newThemes = false
        
        muted = false
        loggedInFacebook = false
        
        adsOn = true
        
        let userDefaults = UserDefaults.standard
        
        //If returning user has been set, then the user with have their own save data.
        if userDefaults.bool(forKey: "returningUser") == true {
            userScore = userDefaults.integer(forKey: "userScore")
            userLevel = userDefaults.integer(forKey: "userLevel")
            nextUserLevel = userDefaults.integer(forKey: "nextUserLevel")
            lastUserLevel = userDefaults.integer(forKey: "lastUserLevel")
            numberOfLives = userDefaults.integer(forKey: "lives")
            numberOfGems = userDefaults.integer(forKey: "gems")
            unlimitedLivesTime = userDefaults.object(forKey: "unlimitedLivesTime") as? Date
            unlimitedLives = userDefaults.bool(forKey: "unlimitedLives")
            currentTheme = userDefaults.integer(forKey: "currentTheme")
            newThemes = userDefaults.bool(forKey: "newThemes")
            muted = userDefaults.bool(forKey: "muted")
            loggedInFacebook = userDefaults.bool(forKey: "loggedInFacebook")
            adsOn = userDefaults.bool(forKey: "adsOn")
            if let savedUnlockedThemes = userDefaults.array(forKey: "unlockedThemes") {
                unlockedThemes = savedUnlockedThemes as! [Bool]
            }
            if let savedLifeTimes = userDefaults.array(forKey: "timesForLives") {
                timesForLives = savedLifeTimes as! [Date]
            }
            if let savedProgression = userDefaults.array(forKey: "userProgression") {
                levelProgression = savedProgression as! [Int]
            }
        //If returning user has not been set, then the starting values will be saved.
        } else {
            userDefaults.set(true, forKey: "returningUser")
            userDefaults.set(userScore, forKey: "userScore")
            userDefaults.set(userLevel, forKey: "userLevel")
            userDefaults.set(numberOfLives, forKey: "lives")
            userDefaults.set(numberOfGems, forKey: "gems")
            userDefaults.set(timesForLives, forKey: "timesForLives")
            userDefaults.set(timesForLives, forKey: "timesForLives")
            userDefaults.set(unlimitedLivesTime, forKey: "unlimitedLivesTime")
            userDefaults.set(levelProgression, forKey: "currentLevel")
            userDefaults.set(nextUserLevel, forKey: "nextUserLevel")
            userDefaults.set(lastUserLevel, forKey: "lastUserLevel")
            userDefaults.set(unlockedThemes, forKey: "unlockedThemes")
            userDefaults.set(currentTheme, forKey: "currentTheme")
            userDefaults.set(newThemes, forKey: "newThemes")
            userDefaults.set(muted, forKey: "muted")
            userDefaults.set(loggedInFacebook, forKey: "loggedInFacebook")
            userDefaults.set(adsOn, forKey: "adsOn")
            firstTimeUser = true
        }
    }
    
    //MARK: - Functions
    
    //MARK:- Saving
    
    //Called after completing a level, saves the stats for the current level. Also handles adding to the user level if they leveld up and calls the "leveledUp" function.
    func saveLevelStats(goldenBlocks: Int, score: Int, levelledUp: Bool) {
        let userDefaults = UserDefaults.standard
        if currentLevel == levelProgression.count + 1 {
            // This is the first time the user has completed the level
            levelProgression.append(goldenBlocks)
            Analytics.logEvent("new_level_completed", parameters: ["level": currentLevel!])
        } else {
            //the user has already completed the level and has just re-completed it
            levelProgression[currentLevel! - 1] = goldenBlocks
        }
        userDefaults.set(levelProgression, forKey: "userProgression")
        
        userScore += score; print("Score Saved")
        userDefaults.set(userScore, forKey: "userScore")
        
        //adds life if leveld up
        if levelledUp {
            while userScore >= nextUserLevel {
                addLife()
                userLevel += 1
                leveledUp()
            }
            userDefaults.set(userLevel, forKey: "userLevel")
            Analytics.logEvent("level_up", parameters: ["level": userLevel])
        }
    }
    
    func adsOf() {
        self.adsOn = false
        UserDefaults.standard.set(adsOn, forKey: "adsOn")
    }
    
    //Saves all player related stats.
    func savePlayerStats() {
        let userDefaults = UserDefaults.standard
        
        userDefaults.set(userLevel, forKey: "userLevel")
        userDefaults.set(userScore, forKey: "userScore")
        userDefaults.set(numberOfLives, forKey: "lives")
        userDefaults.set(numberOfGems, forKey: "gems")
        userDefaults.set(unlockedThemes, forKey: "unlockedThemes")
        userDefaults.set(currentTheme, forKey: "currentTheme")
        userDefaults.set(newThemes, forKey: "newThemes")
        userDefaults.set(loggedInFacebook, forKey: "loggedInFacebook")
    }
    
    func muteStatusChages(to: Bool) {
        self.muted = to
        UserDefaults.standard.set(muted, forKey: "muted")
    }
    
    //Checks previous lives and adds life.
    func addLife() {
        if !timesForLives.isEmpty {
            timesForLives.removeLast()
            UserDefaults.standard.set(timesForLives, forKey: "timesForLives")
        }
        numberOfLives += 1
        savePlayerStats()
    }
    
    //Ads gems
    func addGems(amount: Int) {
        numberOfGems += amount
        savePlayerStats()
    }
    
    func unlimitedLivesOn(time: Date) {
        print("fail two")
        unlimitedLives = true
        unlimitedLivesTime = time
        UserDefaults.standard.set(unlimitedLives, forKey: "unlimitedLives")
        UserDefaults.standard.set(unlimitedLivesTime, forKey: "unlimitedLivesTime")
        print(unlimitedLives)
        
    }
    
    //MARK:- Calculations (Logic)
    
    //When a level is completed this is to be called to see if the level stats should be stored
    func levelStatsImproved(goldenBlocks: Int) -> Bool {
        if currentLevel! == levelProgression.count + 1 {
            //This is the first time the player has compleated the level
            return true
        } else {
            //The level has been replayed
            let oldScore = levelProgression[currentLevel! - 1]
            if goldenBlocks > oldScore {
                return true
            }
        }
        return false
    }
    
    //Gets the score needed to get to the next new level
    func leveledUp() {
        let oldNextLevel = self.nextUserLevel
        let nextUserLevel = getNextLevel()
        self.nextUserLevel = nextUserLevel
        UserDefaults.standard.set(nextUserLevel, forKey: "nextUserLevel")
        self.lastUserLevel = oldNextLevel
        UserDefaults.standard.set(oldNextLevel, forKey: "lastUserLevel")
    }
    
    //returns the score required to get to the next level
    func getNextLevel() -> Int {
        let nextLevel: Int = (userLevel + 1)
        switch nextLevel {
        case 1:
            return 130
        case 2:
            return 1298
        case 3:
            return 3239
        case 4:
            return 5096
        case 5:
            return 7808
        case 6:
            return 10355
        case 7:
            return 12638
        case 8:
            return 15353
        case 9:
            return 19015
        case 10:
            return 22628
        case 11:
            return 25871
        case 12:
            return 30137
        case 13:
            return 32788
        case 14:
            return 35296
        case 15:
            return 38172
        case 16:
            return 40767
        case 17:
            return 44062
        case 18:
            return 46950
        case 19:
            return 49445
        case 20:
            return 52639
        default:
            return (userLevel * 2500)
        }
    }
    
    //Called to cheack if a life sould be regenarated
    func regenerateLives() {
        if !timesForLives.isEmpty {
            let currentDate = Date()
            var livesToAdd = 0
            for date in 0 ..< timesForLives.count { // Finds lives that need to be regenarated
                if timesForLives[date] < currentDate {
                    livesToAdd += 1
                }
            }
            for _ in 0 ..< livesToAdd {
                timesForLives.removeFirst()
            }
            UserDefaults.standard.set(timesForLives, forKey: "timesForLives")
            numberOfLives += livesToAdd
            self.savePlayerStats()
        }
    }
    
    //Sees if the user has unlimited lives
    func updateUnlimitedLives() {
        if let time = self.unlimitedLivesTime {
            let currentDate = Date()
            if time < currentDate {
                print("fail three")
                self.unlimitedLivesTime = nil
                UserDefaults.standard.set(unlimitedLivesTime, forKey: "unlimitedLivesTime")
                self.unlimitedLives = false
                UserDefaults.standard.set(unlimitedLives, forKey: "unlimitedLives")
                
            }
        }
    }
    
    //Finds the time till the next life is regenrated
    func timeToLife() -> CGFloat {
        if let nextLife = timesForLives.first {
            let currentDate = Date()
            let calender = Calendar.current
            let diff = calender.dateComponents([.hour, .minute, .second], from: currentDate, to: nextLife)
            let minutesIn = CGFloat(diff.minute!)
            let minutesLeft = 30 - minutesIn
            return minutesLeft
        } else {
            return 30
        }
    }
    
    //Called to add a life to regenarate if lives <= 5
    func lifeToRegenerate() {
        if numberOfLives < 5 {
            let currentdate = Date()
            let calender = Calendar.current
            var date: Date!
            if timesForLives.isEmpty {
                date = calender.date(byAdding: .minute, value: 30, to: currentdate)
            } else {
                date = calender.date(byAdding: .minute, value: 30, to: timesForLives.last!)
            }
            timesForLives.append(date)
            UserDefaults.standard.set(timesForLives, forKey: "timesForLives")
            
            print(timesForLives)
        }
    }
    
    func getGoldenBlocksFor(level: Int) -> Int {
        if levelProgression.count == level - 1 {
            //This is the latest level and will not have been completed yet.
            return 0
        } else {
            //This is not the latest level and will be within range of levelProgresion.
            let goldenBlocks = levelProgression[level - 1]
            return goldenBlocks
        }
    }
}
