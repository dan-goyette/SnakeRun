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
    
    var addSnakePartButton: SKShapeNode!
    
    var snakeHead: SKSpriteNode!
    
    
    var gameWorld: SKSpriteNode!
    var rotationWrapper: SKSpriteNode!
    var debris1: SKSpriteNode!
    var debris2: SKSpriteNode!
    
    var debrisSprites = [SKSpriteNode]()
    
    var snakeBodyPartSprites = [SKSpriteNode]()
    var snakeBodyPartHistories = [[SnakePartHistory]]()
    
    
    var radialVelocity: Double!
    var directionInRadians: Double!
    
    var debugLabel: SKLabelNode!
    var currentTurnButton = TurnDirection.None
    
    var maxTurnMagnitude: Double! = 2.0;
    var turnIncremement: Double! = 0.1
    var unturnIncremement: Double! = 0.2
    
    var historyEntryQueueSize = 6
    
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
        
        
        self.addSnakePartButton = SKShapeNode(circleOfRadius: 30)
        self.addSnakePartButton.fillColor = UIColor.purpleColor()
        self.addSnakePartButton.position = CGPointMake(-1 * screenSize.width/2 + 50, -1 * screenSize.height/2 + 350)
        self.addSnakePartButton.zPosition = 2
        self.addChild(self.addSnakePartButton)
        
        
        
        self.rotationWrapper = SKSpriteNode()
        self.rotationWrapper.position = CGPointMake(0, -1 * screenSize.height/4)
        self.addChild(rotationWrapper)
        
        self.gameWorld = SKSpriteNode()
        self.gameWorld.position = CGPointMake(0, 0)
        self.rotationWrapper.addChild(gameWorld)
        
        
        
        self.snakeHead = SKSpriteNode(color: UIColor.blackColor(), size: CGSizeMake(15,15))
        self.snakeHead.position = CGPointMake(0, 0)
        self.gameWorld.addChild(snakeHead)
        
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
        
        
        
        
        self.debris1 = SKSpriteNode(color: UIColor.greenColor(), size: CGSizeMake(15,15))
        self.debris1.position = CGPointMake(100, 100)
        self.gameWorld.addChild(debris1)
        self.debrisSprites.append(self.debris1)
        
        self.debris2 = SKSpriteNode(color: UIColor.purpleColor(), size: CGSizeMake(15,15))
        self.debris2.position = CGPointMake(-200, 125)
        self.gameWorld.addChild(debris2)
        self.debrisSprites.append(self.debris2)
        
        
        self.radialVelocity = 0
        self.directionInRadians = 0
        
        // These are the History entries for the head.
        self.snakeBodyPartHistories.append([SnakePartHistory]())
        
    }
    
    func setDebugMessage(message: String) {
        self.debugLabel.text = message
        
    }
    
    func updateDebugWithStats() {
        setDebugMessage("Turn Direction: " + String(self.currentTurnButton) + "; Speed: " + String(self.radialVelocity) + "; Rotation: " + String(self.directionInRadians / M_PI))
    }
    
    func addSnakeBodyPart() {
        let snakeBodyPart = SKSpriteNode(color: UIColor.blackColor(), size: CGSizeMake(15,15))
       
        let lastHistories = self.snakeBodyPartHistories.last!
        let firstEntry = lastHistories.first!
        
        snakeBodyPart.position = firstEntry.position
        snakeBodyPart.zRotation = firstEntry.rotation
        self.snakeBodyPartSprites.append(snakeBodyPart)
        self.gameWorld.addChild(snakeBodyPart)
        
        
        // Initialize the first 'historyEntryQueueSize' body parts with dummy values.
        var initialHistories = [SnakePartHistory]()
        for _ in 0..<historyEntryQueueSize {
            let initialHistory = SnakePartHistory()
            initialHistory.position = firstEntry.position
            initialHistory.rotation = firstEntry.rotation
            initialHistories.append(initialHistory)
        }
        self.snakeBodyPartHistories.append(initialHistories)
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
            
            if (self.addSnakePartButton.containsPoint(location)) {
                addSnakeBodyPart()
            }
        }
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            
            if (self.leftTurnButton.containsPoint(location)) {
                self.currentTurnButton = TurnDirection.None
            } else if (self.rightTurnButton.containsPoint(location)) {
                self.currentTurnButton = TurnDirection.None
            }
            
        }
        
        
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
                self.radialVelocity = self.radialVelocity + self.unturnIncremement
            } else if (self.radialVelocity > 0) {
                self.radialVelocity = self.radialVelocity - self.unturnIncremement
            }
            
            if (abs(self.radialVelocity) < self.unturnIncremement) {
                self.radialVelocity = 0
            }
        }
        
        let forwardVelocity = 3.0// maxTurnMagnitude - self.radialVelocity
        
        self.directionInRadians = self.directionInRadians + (((M_PI / 180) * (self.radialVelocity / 2)) * M_PI)
        
        self.rotationWrapper.zRotation = CGFloat(self.directionInRadians )
        
        // This is faking the rotation by using rotation based on radial velocity, so the snake's head
        // snaps back to 0 when he's not rotating.
        self.snakeHead.zRotation = CGFloat(0 - self.directionInRadians) + CGFloat(-1 * self.radialVelocity  * 0.1)
        
        let newXComponent = sin(self.directionInRadians)
        let newYComponent = cos( self.directionInRadians)
        
        
        self.snakeHead.position = CGPointMake(self.snakeHead.position.x + CGFloat(newXComponent * forwardVelocity), self.snakeHead.position.y + CGFloat(newYComponent * forwardVelocity))
        
        self.gameWorld.position = CGPointMake( -1 * self.snakeHead.position.x, -1 * self.snakeHead.position.y)
        self.rotationWrapper.anchorPoint = self.snakeHead.position
        
        
        let historyEntry = SnakePartHistory()
        historyEntry.position = self.snakeHead.position
        historyEntry.rotation = self.snakeHead.zRotation
        self.snakeBodyPartHistories[0].insert(historyEntry, atIndex: 0)
        
        if (self.snakeBodyPartHistories[0].count > self.historyEntryQueueSize) {
            let poppedHistoryEntry = self.snakeBodyPartHistories[0].removeLast()
            if (self.snakeBodyPartHistories.count > 1) {
                let newEntry = SnakePartHistory()
                newEntry.position = historyEntry.position
                newEntry.rotation = historyEntry.rotation
                self.snakeBodyPartHistories[1].insert(newEntry, atIndex: 0)
            }
        }
        
        if (self.snakeBodyPartSprites.count > 0) {
            for snakePartIndex in 0..<self.snakeBodyPartSprites.count {
                let snakePartSprite = self.snakeBodyPartSprites[snakePartIndex]
                let poppedHistoryEntry = self.snakeBodyPartHistories[snakePartIndex + 1].removeLast()
                snakePartSprite.position = poppedHistoryEntry.position
                snakePartSprite.zRotation = poppedHistoryEntry.rotation
                
                if (self.snakeBodyPartHistories.count > snakePartIndex + 2) {
                    // Add the item to the next snake part's queue.
                    self.snakeBodyPartHistories[snakePartIndex + 2].insert(poppedHistoryEntry, atIndex: 0)
                }
            }
        }
        
        updateDebugWithStats()
        
    }
    
    
    enum TurnDirection {
        case None
        case Left
        case Right
    }
    
    class SnakePartHistory {
        init() {
            position = CGPointMake(0,0)
        }
        var position: CGPoint
        var rotation: CGFloat = 0.0
    }
}
