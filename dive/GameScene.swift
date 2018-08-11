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

struct PhysicsCategory {
  static let player : UInt32 = 0x1 << 0
  static let square : UInt32 = 0x1 << 1
  static let floor : UInt32 = 0x1 << 2
  static let background : UInt32 = 0x1 << 3
}

class GameScene: SKScene, SKPhysicsContactDelegate {
  
  var mMotionManager = CMMotionManager()
  
  var mSquares : [SKShapeNode] = []
  
  var mFloor : SKShapeNode!
  var mPlayer : SKShapeNode!
  var mPlayerFloor : SKShapeNode!
  
  var mAccelTimer : Timer?
  var mSquareTimer : Timer?
  
  var mAx = CGFloat(0.0)
  var mAy = CGFloat(0.0)
  var mAz = CGFloat(0.0)
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  override func sceneDidLoad() {
    
    self.backgroundColor = .white
    
    physicsWorld.gravity = CGVector(dx: 0.0, dy: -1.0)
    physicsWorld.contactDelegate = self
    
    startAccel()
    createPlayer()
    startSquares()
    createFloor()
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  override func update(_ currentTime: TimeInterval) {
    // Called before each frame is rendered
    
    movePlayer()
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func didBegin(_ contact: SKPhysicsContact) {
    
    let firstBody = contact.bodyA.node as! SKShapeNode
    let secondBody = contact.bodyB.node as! SKShapeNode
    
    // delete squares that fall below screen and hit the floor
    if firstBody == mFloor {
      secondBody.removeFromParent()
    } else if secondBody == mFloor {
      firstBody.removeFromParent()
    }
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func touchDown(atPoint pos: CGPoint) {
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func touchMoved(toPoint pos: CGPoint) {
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func touchUp(atPoint pos: CGPoint) {
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    for t in touches { touchDown(atPoint: t.location(in: self)) }
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    for t in touches { touchMoved(toPoint: t.location(in: self)) }
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    for t in touches { touchUp(atPoint: t.location(in: self)) }
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    for t in touches { touchUp(atPoint: t.location(in: self)) }
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func startAccel() {
    if mMotionManager.isAccelerometerAvailable {
      mMotionManager.accelerometerUpdateInterval = 1.0 / 60.0
      mMotionManager.startAccelerometerUpdates()
      
      // Configure a timer to fetch the accel data.
      mAccelTimer = Timer(
        fire: Date(),
        interval: (1.0/60.0),
        repeats: true, block: {
          (timer) in if let data = self.mMotionManager.accelerometerData {
            self.mAx = CGFloat(data.acceleration.x)
            self.mAy = CGFloat(data.acceleration.y)
            self.mAz = CGFloat(data.acceleration.z)
          }
      })
      
      // Add the timer to the current run loop.
      RunLoop.current.add(mAccelTimer!, forMode: .defaultRunLoopMode)
    }
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func stopAccel() {
    
    if mAccelTimer != nil {
      mAccelTimer?.invalidate()
      mAccelTimer = nil
      
      mMotionManager.stopGyroUpdates()
    }
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
    mFloor.strokeColor = .green
    mFloor.lineWidth = 2.5
    mFloor.name = "floor"
    
    mFloor.physicsBody = SKPhysicsBody.init(edgeLoopFrom: rect)
    
    mFloor.physicsBody?.isDynamic = false
    
    mFloor.physicsBody?.categoryBitMask = PhysicsCategory.floor
    mFloor.physicsBody?.collisionBitMask =
      PhysicsCategory.square | PhysicsCategory.background
    mFloor.physicsBody?.contactTestBitMask =
      PhysicsCategory.square | PhysicsCategory.background
    
    self.addChild(mFloor)
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func createPlayer() {
    
    let base = CGFloat(180)
    let height = base / 4
    let origin = CGPoint(x: 0, y: 0)
    
    let path = UIBezierPath()
    path.move(to: origin)
    path.addLine(to: CGPoint(x: origin.x - base / 2, y: origin.y + height))
    path.addLine(to: CGPoint(x: origin.x + base / 2, y: origin.y + height))
    path.close()

    mPlayer = SKShapeNode.init(path: path.cgPath)
    mPlayer.fillColor = .green
    mPlayer.strokeColor = .black
    mPlayer.lineWidth = 1.5
    mPlayer.name = "player"
    
    mPlayer.physicsBody = SKPhysicsBody.init(polygonFrom: path.cgPath)
    
    mPlayer.physicsBody?.isDynamic = true
    mPlayer.physicsBody?.affectedByGravity = false
    mPlayer.physicsBody?.allowsRotation = true
    
    mPlayer.physicsBody!.friction = 0.9
    mPlayer.physicsBody!.linearDamping = 1.0 // stop from falling
    mPlayer.physicsBody!.restitution = 0.0
    mPlayer.physicsBody!.mass = 1.0
    
    mPlayer.physicsBody?.categoryBitMask = PhysicsCategory.player
    mPlayer.physicsBody?.collisionBitMask = PhysicsCategory.square
    mPlayer.physicsBody?.contactTestBitMask = PhysicsCategory.square
    
    // movement constraints
    let limit = frame.width / 3
    let xLim = SKConstraint.positionX(SKRange(
      lowerLimit: -limit,
      upperLimit: limit))
    let yLim = SKConstraint.positionY(SKRange(lowerLimit: 0, upperLimit: 0))
    
    let rot = CGFloat.pi / 8
    let faceUp = SKConstraint.zRotation(
      SKRange(lowerLimit: -rot, upperLimit: rot))
    
    mPlayer.constraints = [xLim, yLim, faceUp]
    
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
    square.fillColor = .red
    square.strokeColor = .black
    square.lineWidth = 1.5
    square.name = "square"
    
    let maxZ : CGFloat = 1.0
    let rand = CGFloat(arc4random_uniform(UInt32(maxZ * 2.0 + 1.0)))
    square.zPosition = rand - maxZ
    square.setScale(1.0 + square.zPosition * 0.3)
    
    square.physicsBody = SKPhysicsBody.init(rectangleOf: squareSize)
    
    square.physicsBody?.isDynamic = true
    
    square.physicsBody!.friction = 0.3
    square.physicsBody!.restitution = 0.1
    square.physicsBody!.mass = 0.5
    
    if (square.zPosition == 0.0) {
      square.physicsBody?.categoryBitMask = PhysicsCategory.square
      square.physicsBody?.collisionBitMask =
        PhysicsCategory.floor | PhysicsCategory.player | PhysicsCategory.square
      square.physicsBody?.contactTestBitMask =
        PhysicsCategory.floor | PhysicsCategory.player | PhysicsCategory.square
    } else {
      square.physicsBody?.categoryBitMask = PhysicsCategory.background
      square.physicsBody?.collisionBitMask = PhysicsCategory.floor
      square.physicsBody?.contactTestBitMask = PhysicsCategory.floor
    }
    
    let torque = (drand48() - 0.5) / 2.0
    let tilt = SKAction.applyTorque(CGFloat(torque), duration: 0.01)
    square.run(tilt)
    
    self.addChild(square)
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func startSquares() {
    
    self.mSquareTimer = Timer(
      fire: Date(),
      interval: (30.0 / 60.0),
      repeats: true,
      block: { (timer) in self.createSquare() })
    
    // Add the timer to the current run loop.
    RunLoop.current.add(self.mSquareTimer!, forMode: .defaultRunLoopMode)
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func movePlayer() {
    
    let force = CGVector(dx: 5000 * mAx, dy: 0)
    mPlayer.physicsBody?.applyForce(force)
    
//    for square in mSquares {
//      square.run(move)
//    }
  }
}
