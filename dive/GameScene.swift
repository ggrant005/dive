//
//  GameScene.swift
//  dive
//
//  Created by Greg Grant on 7/8/18.
//  Copyright © 2018 Dumb Cheap Games. All rights reserved.
//

import CoreMotion
import GameplayKit
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
  
  var mSquares : [SKShapeNode] = []
  
  var mFloor : SKShapeNode!
  var mPlayer : SKShapeNode!
  
  var mMotionManager = CMMotionManager()
  
  var mGyroTimer : Timer?
  var mSquareTimer : Timer?
  
  var mRoll = CGFloat(0.0)
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  override func sceneDidLoad() {
    
    physicsWorld.gravity = CGVector(dx: 0.0, dy: -2.0)
    physicsWorld.contactDelegate = self
    
    startGyros()
    createPlayer()
    startSquares()
    createFloor()
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func createFloor() {
    
    let rect = CGRect(
      x: -frame.width * 2,
      y: -frame.height,
      width: frame.width * 4,
      height: 10)
    
    mFloor = SKShapeNode.init(rect: rect)
    mFloor.strokeColor = .blue
    mFloor.lineWidth = 2.5
    mFloor.name = "floor"
    
    mFloor.physicsBody = SKPhysicsBody.init(edgeLoopFrom: rect)
    mFloor.physicsBody?.isDynamic = false
    mFloor.physicsBody?.contactTestBitMask = 0
    mFloor.physicsBody!.contactTestBitMask =
      mFloor.physicsBody!.collisionBitMask
    
    self.addChild(mFloor)
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func createPlayer() {
    
    let base = 180
    let height = base / 4
    
    let path = UIBezierPath()
    path.move(to: CGPoint(x: 0, y: 0))
    path.addLine(to: CGPoint(x: -base / 2, y: height))
    path.addLine(to: CGPoint(x: base / 2, y: height))
    path.close()
    
    mPlayer = SKShapeNode.init(path: path.cgPath)
    mPlayer.strokeColor = SKColor.green
    mPlayer.lineWidth = 2.5
    mPlayer.name = "player"
    
    mPlayer.physicsBody = SKPhysicsBody(edgeChainFrom: path.cgPath)
    mPlayer.physicsBody?.isDynamic = false
    mPlayer.physicsBody?.contactTestBitMask = 0
    mPlayer.physicsBody!.friction = 0.3
    mPlayer.physicsBody!.contactTestBitMask =
      mPlayer.physicsBody!.collisionBitMask
    
    addChild(mPlayer)
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func createSquare() {
    
    let side = 30
    let squareSize = CGSize(width: side, height: side)
    
    let square = SKShapeNode.init(rectOf: squareSize)
    
    let randX = CGFloat(arc4random_uniform(UInt32(frame.width))) - frame.width / 2
    square.position = CGPoint(x: randX, y: frame.height + 10)
    square.strokeColor = .red
    square.lineWidth = 2.5
    square.name = "square"
    
    square.physicsBody = SKPhysicsBody.init(rectangleOf: squareSize)
    square.physicsBody?.isDynamic = true
    square.physicsBody?.contactTestBitMask = 0
    square.physicsBody!.friction = 0.3
    square.physicsBody!.contactTestBitMask =
      square.physicsBody!.collisionBitMask
    
    mSquares.append(square)
    
    self.addChild(square)
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func startSquares() {
    
    self.mSquareTimer = Timer(fire: Date(), interval: (30.0/60.0),
                              repeats: true, block: { (timer) in
                                self.createSquare()
    })
    
    // Add the timer to the current run loop.
    RunLoop.current.add(self.mSquareTimer!, forMode: .defaultRunLoopMode)
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func startGyros() {
    if mMotionManager.isGyroAvailable {
      mMotionManager.gyroUpdateInterval = 1.0 / 60.0
      mMotionManager.startGyroUpdates()
      
      // Configure a timer to fetch the gyro data.
      mGyroTimer = Timer(fire: Date(), interval: (1.0/60.0),
                         repeats: true, block: { (timer) in
                          // Get the gyro data.
                          if let data = self.mMotionManager.gyroData {
                            // let pitch = data.rotationRate.x
                            self.mRoll = CGFloat(data.rotationRate.y)
                            // let yaw = data.rotationRate.z
                          }
      })
      
      // Add the timer to the current run loop.
      RunLoop.current.add(mGyroTimer!, forMode: .defaultRunLoopMode)
    }
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func stopGyros() {
    
    if mGyroTimer != nil {
      mGyroTimer?.invalidate()
      mGyroTimer = nil
      
      mMotionManager.stopGyroUpdates()
    }
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func tiltPlayer() {
    
    let tilt = SKAction.rotate(byAngle: mRoll / 100, duration: 0.01)
    
    mPlayer.physicsBody?.applyImpulse(CGVector(dx: 100, dy: 0))
    
//    let translate = SKAction.moveBy(
//      x: mRoll * 10,
//      y: 0,//-mPitch * 20,
//      duration: 0.1)
    
    let move = SKAction.sequence([tilt])
    
    mPlayer!.run(move)
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  override func update(_ currentTime: TimeInterval) {
    // Called before each frame is rendered
    
    tiltPlayer()
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func didBegin(_ contact: SKPhysicsContact) {
    
    if contact.bodyA.node?.name == "square" &&
      contact.bodyB.node == mFloor {
      contact.bodyA.node?.removeFromParent()
    } else if contact.bodyB.node?.name == "square" &&
      contact.bodyA.node == mFloor {
      contact.bodyB.node?.removeFromParent()
    }
  }
}
