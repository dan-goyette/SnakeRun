//
//  GameScene.swift
//  SnakeRun
//
//  Created by Dan Goyette on 1/3/16.
//  Copyright (c) 2016 Dan Goyette. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var leftTurnButton: SKShapeNode!
    var rightTurnButton: SKShapeNode!
    var snakeHead: SKSpriteNode!
    var radialVelocity: Double!
    
    var debugLabel: SKLabelNode!
    var currentTurnButton = TurnDirection.None
    
    var maxTurnMagnitude: Double! = 2.0;
    var turnIncremement: Double! = 0.01
    
    
    override func didMoveToView(view: SKView) {
         
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        /* Setup your scene here */
        self.leftTurnButton = SKShapeNode(circleOfRadius: 30)
        self.leftTurnButton.fillColor = UIColor.redColor()
        self.leftTurnButton.position = CGPointMake(-1 * screenSize.width/2 + 50, -1 * screenSize.height/2 + 100)
        self.leftTurnButton.zPosition = 2
        self.addChild(self.leftTurnButton)
       
        self.rightTurnButton = SKShapeNode(circleOfRadius: 30)
        self.rightTurnButton.fillColor = UIColor.redColor()
        self.rightTurnButton.position = CGPointMake( screenSize.width/2 - 50, -1 * screenSize.height/2 + 100)
        self.rightTurnButton.zPosition = 2
        self.addChild(self.rightTurnButton)
    
        
        self.snakeHead = SKSpriteNode(color: UIColor.blackColor(), size: CGSizeMake(15,15))
        self.snakeHead.position = CGPointMake(0,0)
        self.addChild(snakeHead)
        
        let snakeNose = SKSpriteNode(color: UIColor.blackColor(), size: CGSizeMake(2,5))
        snakeNose.position = CGPointMake(-1,6)
        snakeNose.anchorPoint = CGPointMake(0,0)
        self.snakeHead.addChild(snakeNose)
        
        
        self.debugLabel = SKLabelNode()
        self.debugLabel.horizontalAlignmentMode = .Left
        self.debugLabel.position = CGPointMake(-1 * screenSize.width/2, screenSize.height/2 - 25)
        self.debugLabel.fontSize = 12
        self.debugLabel.fontColor = UIColor.blackColor()
        self.addChild(self.debugLabel)
        
        self.radialVelocity = 0
    }
    
    func setDebugMessage(message: String) {
        self.debugLabel.text = message

    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            if (self.currentTurnButton == TurnDirection.None) {
                if (self.leftTurnButton.containsPoint(location)) {
                    self.currentTurnButton = TurnDirection.Left
                } else if (self.rightTurnButton.containsPoint(location)) {
                    self.currentTurnButton = TurnDirection.Right
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        
        if (self.currentTurnButton == TurnDirection.Left) {
            if (abs( self.radialVelocity) < maxTurnMagnitude) {
                self.radialVelocity = self.radialVelocity - self.turnIncremement
            }
        } else if (self.currentTurnButton == TurnDirection.Right) {
            if (abs( self.radialVelocity) < maxTurnMagnitude) {
                self.radialVelocity = self.radialVelocity + self.turnIncremement
            }
        } else {
            if (self.radialVelocity < 0) {
                self.radialVelocity = self.radialVelocity + self.turnIncremement
            } else if (self.radialVelocity > 0) {
                self.radialVelocity = self.radialVelocity - self.turnIncremement
            }
        }
    }
    
    
    enum TurnDirection {
        case None
        case Left
        case Right
    }
}
