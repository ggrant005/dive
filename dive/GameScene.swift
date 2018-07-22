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
  
  private var mRoll = CGFloat(0.0)
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  override func sceneDidLoad() {
    
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
    if mMotionManager.isGyroAvailable {
      self.mMotionManager.gyroUpdateInterval = 1.0 / 60.0
      self.mMotionManager.startGyroUpdates()
      
      // Configure a timer to fetch the accelerometer data.
      self.mTimer = Timer(fire: Date(), interval: (1.0/60.0),
                         repeats: true, block: { (timer) in
                          // Get the gyro data.
                          if let data = self.mMotionManager.gyroData {
                            let pitch = data.rotationRate.x
                            let roll = data.rotationRate.y
                            let yaw = data.rotationRate.z
                            
                            // Use the gyroscope data in your app.
                            self.mRoll = CGFloat(roll)
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
  func tiltTriangle() {
    
    let roll = mRoll
    let tilt = SKAction.rotate(byAngle: -roll / 100, duration: 0.01)
    let translate = SKAction.moveBy(x: roll * 2, y: 0, duration: 0.1)
    
    let move = SKAction.sequence([translate, tilt])
    
    mTriangle!.run(move)
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  override func update(_ currentTime: TimeInterval) {
    // Called before each frame is rendered
    
    tiltTriangle()
  }
}
