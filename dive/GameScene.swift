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
    
    if self.mMotionManager.isDeviceMotionAvailable {
      
      mMotionManager.startDeviceMotionUpdates(
        to: OperationQueue.current!, withHandler: {
          (deviceMotion, error) -> Void in
          
          if(error == nil) {
            self.handleDeviceMotionUpdate(deviceMotion: deviceMotion!)
          } else {
            //handle the error
          }
      })
    }
  }
  
  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  func handleDeviceMotionUpdate(deviceMotion : CMDeviceMotion) {
    let roll = deviceMotion.attitude.roll
    let pitch = deviceMotion.attitude.pitch
    let yaw = deviceMotion.attitude.yaw
    print("Roll: \(roll), Pitch: \(pitch), Yaw: \(yaw)")
    
    mRoll = CGFloat(roll)
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
    let tilt = SKAction.rotate(byAngle: -roll / 10, duration: 0.01)
    let translate = SKAction.moveBy(x: 0, y: 0, duration: 0.1)
    
    let move = SKAction.sequence([tilt, translate])
    
    mTriangle!.run(move)
    print("Roll: \(String(describing: mTriangle?.zRotation))")
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------
  override func update(_ currentTime: TimeInterval) {
    // Called before each frame is rendered
    
    tiltTriangle()
  }
}
