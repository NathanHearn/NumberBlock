//
//  CustomScrollView.swift
//  Number Block
//
//  Created by Nathan on 06/03/2018.
//  Copyright © 2018 Nathan. All rights reserved.
//

import SpriteKit

//Scroll direction

enum scrollDirection {
    case vertical, horizontal
}

class CustomScrollView: UIScrollView {
    
    //MARK:- Static properties
    
    //Touches allowed
    static var disableTouches = false
    
    //Scroll view
    private static var scrollView: UIScrollView!
    
    //MARK: - Properties
    
    //Current scene
    private let currentScene: SKScene
    
    //Moveable node
    let moveableNode: SKNode
    
    //Scroll direction
    private let scrollDirection: scrollDirection
    
    //Touched nodes
    private var nodesTouched = [AnyObject]()
    
    //MARK:- Init
    init(frame: CGRect, scene: SKScene, moveableNode: SKNode, scrollDirecton: scrollDirection) {
        self.currentScene = scene
        self.moveableNode = moveableNode
        self.scrollDirection = scrollDirecton
        super.init(frame: frame)
        
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        
        CustomScrollView.scrollView = self
        self.frame = frame
        delegate = self
        indicatorStyle = .default
        isScrollEnabled = true
        isUserInteractionEnabled = true
        
        if scrollDirection == .horizontal {
            let flip = CGAffineTransform(scaleX: -1, y: -1)
            transform = flip
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK: - Touches
extension CustomScrollView {
    
    //Began
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("************************************Touches Began*******************************************")
        for touch in touches {
            let location = touch.location(in: currentScene)
            
            guard !CustomScrollView.disableTouches else {return}
            
            //Call touches began in current sceme
            currentScene.touchesBegan(touches, with: event)
            print("************************************done step 2************************************")
            
            //Call touches began in all touched nodes in the current scene
            nodesTouched = currentScene.nodes(at: location)
            for node in nodesTouched {
                if let button = node as? ScrollViewButton {
                    button.buttonTouched()
                } else {
                    node.touchesBegan(touches, with: event)
                }
            }
        }
    }
    
    //Moved
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: currentScene)
            
            guard !CustomScrollView.disableTouches else {return}
            
            //Call touches moved in current scene
            currentScene.touchesMoved(touches, with: event)
            
            //Call touches moved in all touched nodes in the current scene
            nodesTouched = currentScene.nodes(at: location)
            for node in nodesTouched {
                node.touchesMoved(touches, with: event)
            }
        }
    }
    
    //Ended
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let location = touch.location(in: currentScene)
            
            guard !CustomScrollView.disableTouches else {return}
            
            //Call touches ended in current scene
            currentScene.touchesEnded(touches, with: event)
            
            //Call touches ended in all touched nodes in the current scene
            nodesTouched = currentScene.nodes(at: location)
            for node in nodesTouched {
                if let button = node as? ScrollViewButton {
                    button.buttonUntouched()
                } else {
                    node.touchesEnded(touches, with: event)
                }
            }
        }
    }
    
    //Canceled
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: currentScene)
            
            guard !CustomScrollView.disableTouches else {return}
            
            //Call touches canclled in all touched nodes in the current scene
            nodesTouched = currentScene.nodes(at: location)
            for node in nodesTouched {
                node.touchesCancelled(touches, with: event)
            }
        }
    }
}

//MARK: - Touch Controls
extension CustomScrollView {
    
    //Disable
    func disable() {
        CustomScrollView.scrollView?.isUserInteractionEnabled = false
        CustomScrollView.disableTouches = true
    }
    
    //Enable
    func enable() {
        CustomScrollView.scrollView?.isUserInteractionEnabled = true
        CustomScrollView.disableTouches = false
    }
    
    func disableTouch() {
        CustomScrollView.disableTouches = true
    }
}

//MARK:- Delegates
extension CustomScrollView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollDirection == .horizontal {
            moveableNode.position.x = scrollView.contentOffset.x
        } else {
            moveableNode.position.y = scrollView.contentOffset.y
        }
    }
}

