//
//  GameScene.swift
//  SnakeRun
//
//  Created by Dan Goyette on 1/3/16.
//  Copyright (c) 2016 Dan Goyette. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    var leftTurnButton: SKShapeNode!
    var rightTurnButton: SKShapeNode!
    
    var addSnakePartButton: SKShapeNode!
    
    var snakeHead: SKSpriteNode!
    
    
    var gameWorld: SKSpriteNode!
    var rotationWrapper: SKSpriteNode!
  
    
    var debrisSprites = [SKSpriteNode]()
    
    var snakeBodyPartSprites = [SKSpriteNode]()
    var snakeBodyPartHistories = [[SnakePartHistory]]()
    
    
    var radialVelocity: Double!
    var directionInRadians: Double!
    
    var debugLabel: SKLabelNode!
    var currentTurnButton = TurnDirection.None
    
    let maxTurnMagnitude = 2.0;
    let turnIncremement = 0.1
    let unturnIncremement = 0.2
    let forwardVelocityTurnSpeedMultiplier = 0.5
    let baseForwardVelocity = 4.0
    
    let historyEntryQueueSize = 4
    
    
    let snakeHeadCategory: UInt32 = 0x1 << 0
    let debrisCategory: UInt32 = 0x1 << 1
    let foodCategory: UInt32 = 0x1 << 2

    
    override func didMoveToView(view: SKView) {
        
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        /* Setup your scene here */
        self.leftTurnButton = SKShapeNode(circleOfRadius: screenSize.height / 12)
        self.leftTurnButton.fillColor = UIColor.redColor()
        self.leftTurnButton.position = CGPointMake(-1 * screenSize.width/2 + 50, -1 * screenSize.height/2 + 100)
        self.leftTurnButton.zPosition = 2
        self.addChild(self.leftTurnButton)
        
        self.rightTurnButton = SKShapeNode(circleOfRadius: screenSize.height / 12)
        self.rightTurnButton.fillColor = UIColor.redColor()
        self.rightTurnButton.position = CGPointMake( screenSize.width/2 - 50, -1 * screenSize.height/2 + 100)
        self.rightTurnButton.zPosition = 2
        self.addChild(self.rightTurnButton)
        
        self.addSnakePartButton = SKShapeNode(circleOfRadius: screenSize.height / 12)
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
        self.snakeHead.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(15,15))
        self.snakeHead.physicsBody?.usesPreciseCollisionDetection = true
        self.snakeHead.physicsBody?.categoryBitMask = snakeHeadCategory
        self.snakeHead.physicsBody?.dynamic = false
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
        
        
        
        self.radialVelocity = 0
        self.directionInRadians = 0
        
        // These are the History entries for the head.
        self.snakeBodyPartHistories.append([SnakePartHistory]())
        
        for _ in 0...10 {
            addDebris()
        }
        
        for _ in 0...40 {
            addFood()
        }
        
        
    }
    
    func addFood() {
        let food = SKShapeNode(circleOfRadius: CGFloat(5) )
        food.fillColor = UIColor.redColor()
        food.position = CGPointMake(CGFloat(arc4random_uniform(600)), CGFloat(arc4random_uniform(600)))
        food.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(5))
        food.physicsBody?.usesPreciseCollisionDetection = false
        food.physicsBody?.categoryBitMask = foodCategory
        food.physicsBody?.contactTestBitMask = snakeHeadCategory
        food.physicsBody?.collisionBitMask = snakeHeadCategory
        food.physicsBody?.dynamic = true
        self.gameWorld.addChild(food)
    }
    
    func addDebris() {
        let debris = SKSpriteNode(color: getRandomColor(), size: CGSizeMake(15,15))
        debris.position = CGPointMake(CGFloat(arc4random_uniform(300)), CGFloat(arc4random_uniform(300)))
        debris.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(15,15))
        debris.physicsBody?.usesPreciseCollisionDetection = false
        debris.physicsBody?.categoryBitMask = debrisCategory
        debris.physicsBody?.contactTestBitMask = snakeHeadCategory
        debris.physicsBody?.collisionBitMask = snakeHeadCategory
        self.gameWorld.addChild(debris)
        self.debrisSprites.append(debris)

    }
    
    func getRandomColor() -> UIColor{
        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
  
    
    func setDebugMessage(message: String) {
        self.debugLabel.text = message
        
    }
    
    func updateDebugWithStats() {
        setDebugMessage("Turn Direction: " + String(self.currentTurnButton) + "; Speed: " + String(self.radialVelocity) + "; Rotation: " + String(self.directionInRadians / M_PI))
    }
    
    func addSnakeBodyPart() {
        let snakeBodyPart = SKSpriteNode(color: UIColor.blackColor(), size: CGSizeMake(15,15))
        snakeBodyPart.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(15,15))
        snakeBodyPart.physicsBody?.usesPreciseCollisionDetection = true
        snakeBodyPart.physicsBody?.categoryBitMask = snakeHeadCategory
        snakeBodyPart.physicsBody?.dynamic = false
        
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
    
    func damageSnake() {
        // Remove half of the snakes parts
        
        if (self.snakeBodyPartSprites.count > 0) {
            let numberToRemove = (self.snakeBodyPartSprites .count / 2) + 1
            
            for _ in 1...numberToRemove {
                let spriteToRemove = self.snakeBodyPartSprites.removeLast()
                self.gameWorld.removeChildrenInArray([spriteToRemove])
                self.snakeBodyPartHistories.removeLast()
            }
        }
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
        
        // The idea here is that while turning, he only goes a certain percentage of his
        // base speed. The higher the forwardVelocityTurnSpeedMultiplier, the less reduction
        let percentageOfMaxSpeed = (maxTurnMagnitude - abs( self.radialVelocity)) / maxTurnMagnitude
        let forwardVelocityTurnSpeedMultiplier = 0.75
        let forwardVelocity = baseForwardVelocity * (forwardVelocityTurnSpeedMultiplier + (percentageOfMaxSpeed * (1 - forwardVelocityTurnSpeedMultiplier)))
        
        
        
        self.directionInRadians = self.directionInRadians + (((M_PI / 180) * (self.radialVelocity / 2)) * M_PI)
        
        self.rotationWrapper.zRotation = CGFloat(self.directionInRadians )
        
        // This is faking the rotation by using rotation based on radial velocity, so the snake's head
        // snaps back to 0 when he's not rotating.
        self.snakeHead.zRotation = CGFloat(0 - self.directionInRadians) + CGFloat(-1 * self.radialVelocity  * 0.4)
        
        let newXComponent = sin(self.directionInRadians)
        let newYComponent = cos( self.directionInRadians)
        
        
        self.snakeHead.position = CGPointMake(self.snakeHead.position.x + CGFloat(newXComponent * forwardVelocity), self.snakeHead.position.y + CGFloat(newYComponent * forwardVelocity))
        
        self.gameWorld.position = CGPointMake( -1 * self.snakeHead.position.x, -1 * self.snakeHead.position.y)
        self.rotationWrapper.anchorPoint = self.snakeHead.position
        
        // We don't use the snakeHead's actual zRotation here because we don't want the body
        // parts wobbling due to the overturning of the head.
        let historyEntry = SnakePartHistory()
        historyEntry.position = CGPointMake( self.snakeHead.position.x, self.snakeHead.position.y)
        historyEntry.rotation = CGFloat(0 - self.directionInRadians) + CGFloat(-1 * self.radialVelocity  * 0.15)
        self.snakeBodyPartHistories[0].insert(historyEntry, atIndex: 0)
        
        if (self.snakeBodyPartHistories[0].count > self.historyEntryQueueSize) {
            self.snakeBodyPartHistories[0].removeLast()
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
    
    
     func didBeginContact(contact: SKPhysicsContact) {
        
        if (contact.bodyA.categoryBitMask == snakeHeadCategory && contact.bodyB.categoryBitMask == foodCategory
            || contact.bodyA.categoryBitMask == foodCategory && contact.bodyB.categoryBitMask == snakeHeadCategory ) {
            if contact.bodyA.node is SKShapeNode {
                self.gameWorld.removeChildrenInArray([contact.bodyA.node!])
            } else if contact.bodyB.node is SKShapeNode {
                self.gameWorld.removeChildrenInArray([contact.bodyB.node!])
            }
                
            addSnakeBodyPart()
        }
        
        if (contact.bodyA.categoryBitMask == snakeHeadCategory && contact.bodyB.categoryBitMask == debrisCategory) {
            self.gameWorld.removeChildrenInArray([contact.bodyB.node!])
            self.debrisSprites.removeAtIndex(self.debrisSprites.indexOf(contact.bodyB.node as! SKSpriteNode)!)
            damageSnake()
        } else if (contact.bodyA.categoryBitMask == debrisCategory && contact.bodyB.categoryBitMask == snakeHeadCategory) {
            self.gameWorld.removeChildrenInArray([contact.bodyA.node!])
            self.debrisSprites.removeAtIndex(self.debrisSprites.indexOf(contact.bodyA.node as! SKSpriteNode)!)
            damageSnake()
        }
        
        
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
