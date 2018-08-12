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
  static let box : UInt32 = 0x1 << 1
  static let floor : UInt32 = 0x1 << 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
  
  var mMotionManager = CMMotionManager()
  
  var mJoints : [SKPhysicsJointLimit] = []
  let mLimitJointLength : CGFloat = 25
  
  var mJoinedBoxes : [SKShapeNode] = []
  
  var mBoxes : [SKShapeNode] = []
  
  var mFloor : SKShapeNode!
  var mPlayer : SKShapeNode!
  var mPlayerFloor : SKShapeNode!
  
  var mAccelTimer : Timer?
  var mBoxTimer : Timer?
  
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
    startBoxes()
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
    
    // connect boxes that hit player
    if firstBody == mPlayer && secondBody.name == "box" {
      connectBox(bodyA: secondBody, bodyB: firstBody)
    } else if firstBody.name == "box" && secondBody == mPlayer {
      connectBox(bodyA: firstBody, bodyB: secondBody)
    }
    
    // delete boxes that fall below screen and hit the floor
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
    mFloor.physicsBody?.collisionBitMask = PhysicsCategory.box
    mFloor.physicsBody?.contactTestBitMask = PhysicsCategory.box
    
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
    mPlayer.physicsBody?.collisionBitMask = PhysicsCategory.box
    mPlayer.physicsBody?.contactTestBitMask = PhysicsCategory.box
    
    // movement constraints
    let limit = frame.width / 3
    let xLim = SKConstraint.positionX(SKRange(
      lowerLimit: -limit,
      upperLimit: limit))
    let yLim = SKConstraint.positionY(SKRange(lowerLimit: 0, upperLimit: 0))
    
    let rot = CGFloat(0)//CGFloat.pi / 8
    let faceUp = SKConstraint.zRotation(
      SKRange(lowerLimit: -rot, upperLimit: rot))
    
    mPlayer.constraints = [xLim, yLim, faceUp]
    
    addChild(mPlayer)
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func createBox() {
    
    let side = 30
    let boxSize = CGSize(width: side, height: side)
    
    let box = SKShapeNode.init(rectOf: boxSize)
    
    let randX = CGFloat(arc4random_uniform(UInt32(frame.width))) - frame.width / 2
    box.position = CGPoint(x: randX, y: frame.height + 10)
    box.fillColor = .red
    box.strokeColor = .black
    box.lineWidth = 1.5
    box.name = "box"
    
    box.physicsBody = SKPhysicsBody.init(rectangleOf: boxSize)
    
    box.physicsBody?.isDynamic = true
    
    box.physicsBody!.friction = 0.3
    box.physicsBody!.restitution = 0.1
    box.physicsBody!.mass = 0.5
    
    box.physicsBody?.categoryBitMask = PhysicsCategory.box
    box.physicsBody?.collisionBitMask =
      PhysicsCategory.floor | PhysicsCategory.player | PhysicsCategory.box
    box.physicsBody?.contactTestBitMask =
      PhysicsCategory.floor | PhysicsCategory.player | PhysicsCategory.box
    
    let torque = (drand48() - 0.5) / 2.0
    let tilt = SKAction.applyTorque(CGFloat(torque), duration: 0.01)
    box.run(tilt)
    
    self.addChild(box)
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func startBoxes() {
    
    self.mBoxTimer = Timer(
      fire: Date(),
      interval: (30.0 / 60.0),
      repeats: true,
      block: { (timer) in self.createBox() })
    
    // Add the timer to the current run loop.
    RunLoop.current.add(self.mBoxTimer!, forMode: .defaultRunLoopMode)
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func movePlayer() {
    
    let force = CGVector(dx: 5000 * mAx, dy: 0)
    mPlayer.physicsBody?.applyForce(force)
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func connectBox(bodyA : SKShapeNode!, bodyB : SKShapeNode!) {
    
    if mJoinedBoxes.count == 0 {
      connectNodes(bodyA: bodyA, bodyB: bodyB)
    } else {
      connectNodes(bodyA: bodyA, bodyB: mJoinedBoxes.last)
    }
    
    mJoinedBoxes.append(bodyA)
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func connectNodes(bodyA : SKShapeNode!, bodyB : SKShapeNode!) {
    
    let joint = SKPhysicsJointLimit.joint(
      withBodyA: bodyA.physicsBody!,
      bodyB: bodyB.physicsBody!,
      anchorA: bodyA.position,
      anchorB: bodyB.position)
    
    joint.maxLength = mLimitJointLength
    
    mJoints.append(joint)
    
    physicsWorld.add(joint)
  }
}
