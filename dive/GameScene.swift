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
  static let playerFloor : UInt32 = 0x1 << 3
}

class GameScene: SKScene, SKPhysicsContactDelegate {
  
  var mSquares : [SKShapeNode] = []
  
  var mFloor : SKShapeNode!
  var mPlayer : SKShapeNode!
  var mPlayerFloor : SKShapeNode!
  
  let mPlayerBaseY = 0
  
  var mPrevPos = CGPoint(x: 0, y: 0)
  
  var mSquareTimer : Timer?
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  override func sceneDidLoad() {
    
    physicsWorld.gravity = CGVector(dx: 0.0, dy: -1.0)
    physicsWorld.contactDelegate = self
    
    createPlayer()
    createPlayerFloor()
    startSquares()
    createFloor()
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  override func update(_ currentTime: TimeInterval) {
    // Called before each frame is rendered
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
    
    //movePlayer(toPoint: pos)
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func touchMoved(toPoint pos: CGPoint) {
    
    movePlayer(toPoint: pos)
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
    
    mFloor.physicsBody?.categoryBitMask = PhysicsCategory.floor
    mFloor.physicsBody?.collisionBitMask = PhysicsCategory.square
    mFloor.physicsBody?.contactTestBitMask = PhysicsCategory.square
    
    self.addChild(mFloor)
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func createPlayerFloor() {
    
    let rect = CGRect(
      x: -frame.width,
      y: 0,
      width: frame.width * 2,
      height: 10)
    
    mPlayerFloor = SKShapeNode.init(rect: rect)
    mPlayerFloor.strokeColor = .blue
    mPlayerFloor.lineWidth = 2.5
    mPlayerFloor.name = "player-floor"
    
    mPlayerFloor.physicsBody = SKPhysicsBody.init(edgeLoopFrom: rect)
    
    mPlayerFloor.physicsBody?.isDynamic = false
    
    mPlayerFloor.physicsBody?.categoryBitMask = PhysicsCategory.playerFloor
    mPlayerFloor.physicsBody?.collisionBitMask = PhysicsCategory.player
    mPlayerFloor.physicsBody?.contactTestBitMask = PhysicsCategory.player
    
    //self.addChild(mPlayerFloor)
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func createPlayer() {
    
    let base = 180
    let height = base / 4
    
    let path = UIBezierPath()
    path.move(to: CGPoint(x: 0, y: mPlayerBaseY))
    path.addLine(to: CGPoint(x: -base / 2, y: height))
    path.addLine(to: CGPoint(x: base / 2, y: height))
    path.close()

    mPlayer = SKShapeNode.init(path: path.cgPath)
    mPlayer.strokeColor = SKColor.green
    mPlayer.lineWidth = 2.5
    mPlayer.name = "player"
    
    mPlayer.physicsBody = SKPhysicsBody.init(polygonFrom: path.cgPath)
    
    mPlayer.physicsBody?.isDynamic = true
    mPlayer.physicsBody?.affectedByGravity = false
    mPlayer.physicsBody?.allowsRotation = true
    
    mPlayer.physicsBody!.friction = 0.3
    mPlayer.physicsBody!.linearDamping = 1.0 // stop from falling
    mPlayer.physicsBody!.restitution = 0.0
    
    mPlayer.physicsBody?.categoryBitMask = PhysicsCategory.player
    mPlayer.physicsBody?.collisionBitMask =
      PhysicsCategory.playerFloor | PhysicsCategory.square
    mPlayer.physicsBody?.contactTestBitMask =
      PhysicsCategory.playerFloor | PhysicsCategory.square
    
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
    square.physicsBody!.friction = 0.3
    square.physicsBody!.restitution = 0.0
    
    square.physicsBody?.categoryBitMask = PhysicsCategory.square
    square.physicsBody?.collisionBitMask =
      PhysicsCategory.floor | PhysicsCategory.player
    square.physicsBody?.contactTestBitMask =
      PhysicsCategory.floor | PhysicsCategory.player
    
    let torque = (drand48() - 0.5) / 2.0
    let tilt = SKAction.applyTorque(CGFloat(torque), duration: 0.01)
    square.run(tilt)
    
    mSquares.append(square)
    
    self.addChild(square)
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func startSquares() {
    
    self.mSquareTimer = Timer(fire: Date(), interval: (30.0 / 60.0),
                              repeats: true, block: { (timer) in
                                self.createSquare()
    })
    
    // Add the timer to the current run loop.
    RunLoop.current.add(self.mSquareTimer!, forMode: .defaultRunLoopMode)
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func movePlayer(toPoint pos: CGPoint) {
    
    let oldPos = mPlayer.position
    mPlayer.position = CGPoint(x: pos.x, y: oldPos.y)
    
    mPrevPos = pos
  }
}
