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
  
  var mPitch = CGFloat(0.0)
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
    
    let floor = SKShapeNode.init(rect: rect)
    floor.strokeColor = .blue
    floor.lineWidth = 2.5
    
    floor.physicsBody = SKPhysicsBody.init(edgeLoopFrom: rect)
    floor.physicsBody!.contactTestBitMask = floor.physicsBody!.collisionBitMask
    floor.physicsBody?.isDynamic = false
    floor.physicsBody?.contactTestBitMask = 0
    
    mFloor = floor
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
    
    let randX = CGFloat(arc4random_uniform(UInt32(frame.width))) - frame.width / 2
    square.position = CGPoint(x: randX, y: frame.height + 10)
    square.strokeColor = .red
    square.lineWidth = 2.5
    
    square.physicsBody = SKPhysicsBody.init(rectangleOf: squareSize)
    square.physicsBody!.contactTestBitMask = square.physicsBody!.collisionBitMask
    square.physicsBody?.isDynamic = true
    square.physicsBody?.contactTestBitMask = 0
    square.physicsBody!.friction = 0.0
    
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
