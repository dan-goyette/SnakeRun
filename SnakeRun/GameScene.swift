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
    
    
    var objectWrap: SKSpriteNode!
    var objectWrap2: SKSpriteNode!
    var debris1: SKSpriteNode!
    var debris2: SKSpriteNode!
    
    var debrisSprites = [SKSpriteNode]()
    
    var snakeBodyPartSprites = [SKSpriteNode]()
    var snakeBodyPartPositionDeltas = [[SnakePartHistory]]()
    
    
    var radialVelocity: Double!
    var directionInRadians: Double!
    
    var debugLabel: SKLabelNode!
    var currentTurnButton = TurnDirection.None
    
    var maxTurnMagnitude: Double! = 2.0;
    var turnIncremement: Double! = 0.1
    var unturnIncremement: Double! = 0.2
    
    
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
        
        
        
        self.objectWrap2 = SKSpriteNode()
        self.objectWrap2.position = CGPointMake(0, -1 * screenSize.height/4)
        self.addChild(objectWrap2)
        
        self.objectWrap = SKSpriteNode()
        self.objectWrap.position = CGPointMake(0, -1 * screenSize.height/4)
        self.objectWrap2.addChild(objectWrap)
        
        
        
        self.snakeHead = SKSpriteNode(color: UIColor.blackColor(), size: CGSizeMake(15,15))
        self.snakeHead.position = CGPointMake(0, 0)
        self.objectWrap.addChild(snakeHead)
        
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
        self.objectWrap.addChild(debris1)
        self.debrisSprites.append(self.debris1)
        
        self.debris2 = SKSpriteNode(color: UIColor.purpleColor(), size: CGSizeMake(15,15))
        self.debris2.position = CGPointMake(-200, 125)
        self.objectWrap.addChild(debris2)
        self.debrisSprites.append(self.debris2)
        
        
        self.radialVelocity = 0
        self.directionInRadians = 0
        
        //self.snakeBodyPartPositionDeltas.append([SnakePartHistory]())
        
    }
    
    func setDebugMessage(message: String) {
        self.debugLabel.text = message
        
    }
    
    func updateDebugWithStats() {
        setDebugMessage("Turn Direction: " + String(self.currentTurnButton) + "; Speed: " + String(self.radialVelocity) + "; Rotation: " + String(self.directionInRadians / M_PI))
    }
    
    func addSnakeBodyPart() {
        
        let snakeBodyPart = SKSpriteNode(color: UIColor.blackColor(), size: CGSizeMake(15,15))
        snakeBodyPart.position = CGPointMake(0, -15)
        self.snakeBodyPartSprites.append(snakeBodyPart)
        self.objectWrap.addChild(snakeBodyPart)
        
        self.snakeBodyPartPositionDeltas.append([SnakePartHistory]())
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        //        if (self.snakeBodyPartSprites.count == 0) {
        //            addSnakeBodyPart()
        //        }
        
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
        
        self.objectWrap2.zRotation = CGFloat(self.directionInRadians )
        
        // This is faking the rotation by using rotation based on radial velocity, so the snake's head
        // snaps back to 0 when he's not rotating.
        self.snakeHead.zRotation = CGFloat(0 - self.directionInRadians) + CGFloat(-1 * self.radialVelocity  * 0.1)
        
        let newXComponent = sin(self.directionInRadians)
        let newYComponent = cos( self.directionInRadians)
        
        //        let newXComponentZ = sin( self.directionInRadians)
        //        let newYComponentZ = cos( self.directionInRadians)
        
        //        let snakePartHistory = SnakePartHistory()
        //        snakePartHistory.velocity = CGPointMake(CGFloat(newXComponentZ * forwardVelocity), CGFloat(newYComponentZ * forwardVelocity ))
        //        snakePartHistory.rotation = CGFloat(M_PI - self.directionInRadians )
        //
        //        self.snakeBodyPartPositionDeltas[0].append(snakePartHistory)
        //        var snakePositionsText = "";
        //        for position in self.snakeBodyPartPositionDeltas[0] {
        //            let xPart = String( position.x)
        //            let yPart = String( position.y)
        //
        //            snakePositionsText = snakePositionsText + "[" + xPart + ", " + yPart + "];";
        //        }
        //        debugPrint(snakePositionsText)
        
        
        //for debris in self.objectWrap.children {
        
        
        self.snakeHead.position = CGPointMake(self.snakeHead.position.x + CGFloat(newXComponent * forwardVelocity), self.snakeHead.position.y + CGFloat(newYComponent * forwardVelocity))
        
        
        // Determine the difference adjust the position of the
        
        self.objectWrap.position = CGPointMake( -1 * self.snakeHead.position.x, -1 *    self.snakeHead.position.y)
        self.objectWrap2.anchorPoint = self.snakeHead.position
        
        //        debugPrint("x: " + String(newXComponent) + "; y: " + String(newYComponent))
        //}
        
        //        var snakeIndex = 0;
        //        for snakeBodyPart in self.snakeBodyPartSprites {
        //            if (self.snakeBodyPartPositionDeltas[snakeIndex].count > 0) {
        //                let nextHistory = self.snakeBodyPartPositionDeltas[snakeIndex].removeFirst()
        //                snakeBodyPart.position = CGPointMake (snakeBodyPart.position.x + nextHistory.velocity.x, snakeBodyPart.position.y + nextHistory.velocity.y);
        //                snakeBodyPart.zRotation = nextHistory.rotation
        //            }
        //
        //            snakeIndex++
        //        }
        
        
        updateDebugWithStats()
        
    }
    
    
    enum TurnDirection {
        case None
        case Left
        case Right
    }
    
    class SnakePartHistory {
        init() {
            velocity = CGPointMake(0,0)
        }
        var velocity: CGPoint
        var rotation: CGFloat = 0.0
    }
}
