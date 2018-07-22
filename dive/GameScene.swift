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
  
  private var mTimer : Timer?
  
  private var mPitch = CGFloat(0.0)
  private var mRoll = CGFloat(0.0)
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  override func sceneDidLoad() {
    
    physicsWorld.gravity = CGVector(dx: 0.0, dy: -1.0)
    physicsWorld.contactDelegate = self
    
    startGyros()
    createPlayer()
    createSquare()
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func touchDown(atPoint pos: CGPoint) {
    
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func touchUp(atPoint pos: CGPoint) {
    
    createSquare()
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func createPlayer() {
    
    let base = 90
    let height = base / 2
    
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
    square.position = CGPoint(x: 100, y: screen.height + 10)
    square.strokeColor = .red
    square.name = "square 1"
    square.lineWidth = 2.5
    
    square.physicsBody = SKPhysicsBody.init(rectangleOf: squareSize)
    square.physicsBody!.contactTestBitMask = square.physicsBody!.collisionBitMask
    square.physicsBody?.isDynamic = true
    square.physicsBody?.contactTestBitMask = 0
    
    self.addChild(square)
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func startGyros() {
    if mMotionManager.isGyroAvailable {
      self.mMotionManager.gyroUpdateInterval = 1.0 / 60.0
      self.mMotionManager.startGyroUpdates()
      
      // Configure a timer to fetch the accelerometer data.
      self.mTimer = Timer(fire: Date(), interval: (1.0/60.0),
                         repeats: true, block: { (timer) in
                          // Get the gyro data.
                          if let data = self.mMotionManager.gyroData {
                            self.mPitch = CGFloat(data.rotationRate.x)
                            self.mRoll = CGFloat(data.rotationRate.y)
                            let yaw = data.rotationRate.z
                          }
      })
      
      // Add the timer to the current run loop.
      RunLoop.current.add(self.mTimer!, forMode: .defaultRunLoopMode)
    }
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func stopGyros() {
    
    if self.mTimer != nil {
      self.mTimer?.invalidate()
      self.mTimer = nil
      
      self.mMotionManager.stopGyroUpdates()
    }
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func tiltPlayer() {
    
    let tilt = SKAction.rotate(byAngle: -mRoll / 500, duration: 0.01)
    let translate = SKAction.moveBy(
      x: mRoll * 10,
      y: -mPitch * 20,
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
