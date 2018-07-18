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

class GameScene: SKScene {
  
  private var mTriangle : SKShapeNode?
  
  private var mMotionManager = CMMotionManager()
  
  private var mTimer : Timer?
  
  private var mRollBuffer = [Double]()
  private var mRollBufferIndex = 0
  private var mRollBufferSize = 20
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  override func sceneDidLoad() {
    
    for _ in 0 ..< mRollBufferSize { mRollBuffer.append(0) }
    
    startGyros()
    createTriangle()
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func createTriangle() {
    
    let base = 90
    let height = base * 2
    
    let path = UIBezierPath()
    path.move(to: CGPoint(x: 0, y: 0))
    path.addLine(to: CGPoint(x: -base / 2, y: height))
    path.addLine(to: CGPoint(x: base / 2, y: height))
    path.close()
    
    self.mTriangle = SKShapeNode.init(path: path.cgPath)
    self.mTriangle!.strokeColor = SKColor.green
    self.addChild(self.mTriangle!)
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func startGyros() {
    
    if self.mMotionManager.isGyroAvailable {
      self.mMotionManager.gyroUpdateInterval = 1.0 / 60.0
      self.mMotionManager.startGyroUpdates()
      
      // Configure a timer to fetch the accelerometer data.
      self.mTimer = Timer(
        fire: Date(),
        interval: (1.0/60.0),
        repeats: true,
        block: { (timer) in
                          
          // Get the gyro data.
          if let data = self.mMotionManager.gyroData {
            let pitch = data.rotationRate.x
            let roll = data.rotationRate.y
            let yaw = data.rotationRate.z
            print("Roll: \(roll), Pitch: \(pitch), Yaw: \(yaw)")
            
            self.addToRollBuffer(roll)
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
  func addToRollBuffer(_ roll : Double) {
    
    self.mRollBuffer[self.mRollBufferIndex] = roll
    if self.mRollBufferIndex == self.mRollBufferSize - 1 {
      self.mRollBufferIndex = 0
    } else {
      self.mRollBufferIndex += 1
    }
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func getMeanRoll() -> CGFloat {
    
    var sum = 0.0
    for roll in mRollBuffer {
      sum += roll
    }
    
    return CGFloat(sum / Double(mRollBufferSize))
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func tiltTriangle() {
    
    let roll = getMeanRoll()
    let tilt = SKAction.rotate(byAngle: roll * -.pi/180 / 10, duration: 0.1)
    let translate = SKAction.moveBy(x: roll, y: 0, duration: 0.1)
    
    let move = SKAction.sequence([tilt, translate])
    let loop = SKAction.repeatForever(move)
    
    // set horizontal to 0 roll
    
    
    
    mTriangle!.run(loop)
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  override func update(_ currentTime: TimeInterval) {
    // Called before each frame is rendered
    
    tiltTriangle()
  }
}
