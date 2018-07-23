//
//  GameScene.swift
//  dive
//
//  Created by Greg Grant on 7/8/18.
//  Copyright © 2018 Dumb Cheap Games. All rights reserved.
//

import CoreMotion
import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
  
  private var mPlayer : SKShapeNode!
  
  private var mMotionManager = CMMotionManager()
  
  private var mGyroTimer : Timer?
  private var mSquareTimer : Timer?
  
  private var mPitch = CGFloat(0.0)
  private var mRoll = CGFloat(0.0)
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  override func sceneDidLoad() {
    
    physicsWorld.gravity = CGVector(dx: 0.0, dy: -2.0)
    physicsWorld.contactDelegate = self
    
    startGyros()
    createPlayer()
    startSquares()
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func touchDown(atPoint pos: CGPoint) {
    
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func touchUp(atPoint pos: CGPoint) {
    
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
    
    let player = SKShapeNode.init(path: path.cgPath)
    player.strokeColor = SKColor.green
    player.lineWidth = 2.5
    
    player.physicsBody = SKPhysicsBody(edgeChainFrom: path.cgPath)
    player.physicsBody!.contactTestBitMask = player.physicsBody!.collisionBitMask
    player.physicsBody?.isDynamic = false
    player.physicsBody?.contactTestBitMask = 0
    player.physicsBody!.friction = 0.0
    
    self.mPlayer = player
    self.addChild(self.mPlayer)
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func createSquare() {
    
    let side = 30
    let squareSize = CGSize(width: side, height: side)
    
    let square = SKShapeNode.init(rectOf: squareSize)
    
    let screen = UIScreen.main.bounds
    let randX = CGFloat(arc4random_uniform(UInt32(screen.width))) - screen.width / 2
    square.position = CGPoint(x: randX, y: screen.height + 10)
    square.strokeColor = .red
    square.lineWidth = 2.5
    
    square.physicsBody = SKPhysicsBody.init(rectangleOf: squareSize)
    square.physicsBody!.contactTestBitMask = square.physicsBody!.collisionBitMask
    square.physicsBody?.isDynamic = true
    square.physicsBody?.contactTestBitMask = 0
    square.physicsBody!.friction = 0.0
    
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
      self.mMotionManager.gyroUpdateInterval = 1.0 / 60.0
      self.mMotionManager.startGyroUpdates()
      
      // Configure a timer to fetch the gyro data.
      self.mGyroTimer = Timer(fire: Date(), interval: (1.0/60.0),
                              repeats: true, block: { (timer) in
                                // Get the gyro data.
                                if let data = self.mMotionManager.gyroData {
                                  self.mPitch = CGFloat(data.rotationRate.x)
                                  self.mRoll = CGFloat(data.rotationRate.y)
                                  let yaw = data.rotationRate.z
                                }
      })
      
      // Add the timer to the current run loop.
      RunLoop.current.add(self.mGyroTimer!, forMode: .defaultRunLoopMode)
    }
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func stopGyros() {
    
    if self.mGyroTimer != nil {
      self.mGyroTimer?.invalidate()
      self.mGyroTimer = nil
      
      self.mMotionManager.stopGyroUpdates()
    }
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func tiltPlayer() {
    
    let tilt = SKAction.rotate(byAngle: mRoll / 100, duration: 0.01)
    let translate = SKAction.moveBy(
      x: mRoll * 10,
      y: 0,//-mPitch * 20,
      duration: 0.1)
    
    let move = SKAction.sequence([translate, tilt])
    
    mPlayer!.run(move)
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  override func update(_ currentTime: TimeInterval) {
    // Called before each frame is rendered
    
    tiltPlayer()
  }
}
