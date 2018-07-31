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
  
  var mPrevPos = CGPoint(x: 0, y: 0)
  
  var mSquareTimer : Timer?
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  override func sceneDidLoad() {
    
    physicsWorld.gravity = CGVector(dx: 0.0, dy: -2.0)
    physicsWorld.contactDelegate = self
    
    createPlayer()
    startSquares()
    createFloor()
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func touchDown(atPoint pos: CGPoint) {
    
    movePlayer(toPoint: pos)
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
    
    mPlayer.physicsBody = SKPhysicsBody.init(polygonFrom: path.cgPath)
    mPlayer.physicsBody?.allowsRotation = true
    mPlayer.physicsBody?.affectedByGravity = false
    mPlayer.physicsBody?.isDynamic = true
    mPlayer.physicsBody!.friction = 0.3
    mPlayer.physicsBody?.contactTestBitMask = 0
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
    square.physicsBody!.friction = 0.3
    square.physicsBody?.contactTestBitMask = 0
    square.physicsBody!.contactTestBitMask =
      square.physicsBody!.collisionBitMask
    
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
    
    //    let tilt = SKAction.rotate(byAngle: pos.x / 100, duration: 0.01)
    //    let move = SKAction.sequence([tilt])
    
    //    mPlayer!.run(move)
    
    let oldPos = mPlayer.position
    mPlayer.position = CGPoint(x: pos.x, y: oldPos.y)
    
    mPrevPos = pos
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  override func update(_ currentTime: TimeInterval) {
    // Called before each frame is rendered
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func didBegin(_ contact: SKPhysicsContact) {
    
    // delete squares that hit floor (fall below screen)
    if contact.bodyA.node == mFloor {
      contact.bodyB.node?.removeFromParent()
    } else if contact.bodyB.node == mFloor {
      contact.bodyA.node?.removeFromParent()
    }
  }
}
