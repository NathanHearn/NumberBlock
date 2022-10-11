//
//  AudioPlayer.swift
//  Number Block
//
//  Created by Nathan on 03/04/2018.
//  Copyright © 2018 Nathan. All rights reserved.
//

import SpriteKit

enum sounds {
    case buttonClick, validMoved, specialMove, moveToSpace, invalidMove, goldenBlock, success, fail, levelUp
}

class AudioPlayer {
    
    var muted: Bool = false
    
    let buttonClick = SKAction.playSoundFileNamed("glitch-click.wav", waitForCompletion: false)
    let validMoved = SKAction.sequence([SKAction.playSoundFileNamed("whoosh.wav", waitForCompletion: false),
                                        SKAction.wait(forDuration: 0.05),
                                        SKAction.playSoundFileNamed("Click2.wav", waitForCompletion: false)])
    let specialMove = SKAction.playSoundFileNamed("itemize.wav", waitForCompletion: false)
    let moveToSpace = SKAction.playSoundFileNamed("whoosh.wav", waitForCompletion: false)
    let invalidMove = SKAction.playSoundFileNamed("cancel-miss-chime.wav", waitForCompletion: false)
    let goldenBlock = SKAction.playSoundFileNamed("level-up-02.wav", waitForCompletion: false)
    let success = SKAction.playSoundFileNamed("320655-rhodesmas-level-up-01", waitForCompletion: false)
    let failure = SKAction.playSoundFileNamed("failure.wav", waitForCompletion: false)
    let levelUp = SKAction.playSoundFileNamed("rpg-sfx-1-item-jingle", waitForCompletion: false)
    
    class var sharedInstance: AudioPlayer {
        struct Singleton {
            static let instance = AudioPlayer()
        }
        return Singleton.instance
    }
    
    func playSound(sound: sounds, node: SKNode) {
        if !muted {
            switch sound {
            case .buttonClick:
                print(1)
                node.run(buttonClick)
            case .validMoved:
                node.run(validMoved)
            case .specialMove:
                node.run(specialMove)
            case .moveToSpace:
                node.run(moveToSpace)
            case .invalidMove:
                node.run(invalidMove)
            case .goldenBlock:
                node.run(goldenBlock)
            case .success:
                node.run(success)
            case .fail:
                node.run(failure)
            case .levelUp:
                node.run(levelUp)
            }
        }
    }
    
    func muteStatusChages(to: Bool) {
        self.muted = to
        GameHandler.sharedInstance.muteStatusChages(to: to)
    }
    
    func soundsForGoldenBlocks(numberOfBlocks: Int, node: SKNode) {
        if !muted {
            if numberOfBlocks == 1 {
                let sounds = SKAction.sequence([SKAction.wait(forDuration: 0.35),
                                            goldenBlock])
            
                node.run(sounds)
            } else if numberOfBlocks == 2 {
                let sounds = SKAction.sequence([SKAction.wait(forDuration: 0.35),
                                                goldenBlock,
                                                SKAction.wait(forDuration: 0.35),
                                                goldenBlock])
                node.run(sounds)
            } else {
                let sounds = SKAction.sequence([SKAction.wait(forDuration: 0.35),
                                                goldenBlock,
                                                SKAction.wait(forDuration: 0.35),
                                                goldenBlock,
                                                SKAction.wait(forDuration: 0.35),
                                                goldenBlock])
                node.run(sounds)
            }
        }
    }
}
