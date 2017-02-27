//
//  SceneKitView.swift
//  ModelTest
//
//  Created by Michael Miller on 2/14/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

// MARK: Protocols
protocol SceneKitViewDelegate {
    func sceneViewDidBeginMoving(position: SCNVector3)
    func sceneViewItemSelected(name: String)
}

// MARK: View
class SceneKitView: UIView, SCNSceneRendererDelegate {
    
    // MARK: Variables
    private let delayedSelectionTime:Double = 0.333
    private var singleTapAction:DispatchWorkItem! = nil
    private var sceneIntiallyRendered:Bool = false
    private var lastPointY:Double! = nil
    public let sceneView: SCNView = SCNView()
    
    public var scene: SCNScene? {
        didSet {
            
            // Set the scene
            sceneView.scene = scene
            
            // place the camera
            let defaults = UserDefaults.standard
            if let defaultX = defaults.object(forKey: Constants.scenePositionX) as? Float, let defaultY = defaults.object(forKey: Constants.scenePositionY) as? Float, let defaultZ = defaults.object(forKey: Constants.scenePositionZ) as? Float, let rotationX = defaults.object(forKey: Constants.sceneRotationX) as? Float, let rotationY = defaults.object(forKey: Constants.sceneRotationY) as? Float, let rotationZ = defaults.object(forKey: Constants.sceneRotationZ) as? Float, let rotationW = defaults.object(forKey: Constants.sceneRotationW) as? Float, let fovX = defaults.object(forKey: Constants.sceneFovX) as? Double, let fovY = defaults.object(forKey: Constants.sceneFovY) as? Double {
                sceneView.pointOfView!.position = SCNVector3(x: defaultX, y: defaultY, z: defaultZ)
                sceneView.pointOfView!.rotation = SCNVector4(x: rotationX, y: rotationY, z: rotationZ, w: rotationW)
                sceneView.pointOfView!.camera!.xFov = fovX
                sceneView.pointOfView!.camera!.yFov = fovY
            } else {
                sceneView.pointOfView!.position = SCNVector3(x: 0, y: 0, z: 15)
            }
        }
    }
    
    public var delegate: SceneKitViewDelegate? {
        didSet {
            
            // Setup Scene
            sceneView.frame.size.width = bounds.width
            sceneView.frame.size.height = bounds.height
            addSubview(sceneView)
            sceneView.allowsCameraControl = true
            sceneView.delegate = self
            sceneView.play(self)
            
            // Set colors
            backgroundColor = UIColor.clear
            sceneView.backgroundColor = UIColor.clear
            
            // Add single tap
            let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapped))
            sceneView.addGestureRecognizer(singleTap)
            
            // Add double tap
            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
            doubleTap.numberOfTapsRequired = 2
            sceneView.addGestureRecognizer(doubleTap)
            
            // Add long press
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
            longPress.numberOfTapsRequired = 1
            longPress.minimumPressDuration = 0.08
            sceneView.addGestureRecognizer(longPress)
        }
    }
    
    // MARK: Init
    func setScene(delegate: SceneKitViewDelegate, scene: SCNScene) {
        self.delegate = delegate
        self.scene = scene
    }
    
    // MARK: Handle Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Check for SceneKit view
        if (!subviews.contains(sceneView)) {
            return
        }
        
        // Handle Touches
        if let d = delegate {
            d.sceneViewDidBeginMoving(
                position: sceneView.pointOfView!.position)
        }
    }
    
    // Double Tap Gesture
    @objc private func singleTapped(gestureRecognize: UIGestureRecognizer) {
        
        // Check what nodes are tapped
        let p = gestureRecognize.location(in: self.sceneView)
        let hitResults = self.sceneView.hitTest(p, options: [:])
        
        // Call single tap action
        singleTapAction = DispatchWorkItem {
            
            // Check that we clicked on at least one object
            if (hitResults.count > 0) {
                
                // retrieved the first clicked object
                let result: AnyObject = hitResults[0]
                
                // Call delegate for item
                if let d = self.delegate {
                    d.sceneViewItemSelected(name: result.node.name!)
                }
                
                // Get the first material
                if let material = result.node.geometry!.firstMaterial {
                    
                    // highlight it
                    SCNTransaction.begin()
                    SCNTransaction.animationDuration = 0.5
                    
                    // on completion - unhighlight
                    SCNTransaction.completionBlock = {
                        SCNTransaction.begin()
                        SCNTransaction.animationDuration = 0.5
                        material.emission.contents = UIColor.black
                        SCNTransaction.commit()
                    }
                    
                    material.emission.contents = UIColor.red
                    SCNTransaction.commit()
                }
            }
        }
        
        // Perform delayed event
        DispatchQueue.main.asyncAfter(deadline: .now() + delayedSelectionTime, execute: singleTapAction)
    }
    
    // Double Tap Gesture
    @objc private func doubleTapped(gestureRecognize: UIGestureRecognizer) {
        
        // Cancel Single Tap Action
        if let tapAction = singleTapAction {
            tapAction.cancel()
        }
        
        // Calc division
        let division:Double = 10
        let preFovY = sceneView.pointOfView!.camera!.yFov - division
        
        // Zoom in or out on panning
        if (preFovY <= 115 && preFovY >= 5) {
            sceneView.pointOfView!.camera!.xFov.subtract(division)
            sceneView.pointOfView!.camera!.yFov.subtract(division)
        }
    }
    
    // Long Press Gesture
    @objc private func longPressed(gestureRecognize: UIGestureRecognizer) {
        
        // Cancel Single Tap Action
        if let tapAction = singleTapAction {
            tapAction.cancel()
        }
        
        // Handle Gesture
        if (gestureRecognize.state == .changed) {
            
            // Get touch point
            let pointY:Double = Double(gestureRecognize.location(in: sceneView).y)
            
            // Check for existing touch point
            if (lastPointY == nil) {
                lastPointY = pointY
                return
            }
            
            // Calc a division
            let division = lastPointY - pointY
            let preFovY = sceneView.pointOfView!.camera!.yFov + division
            
            // Zoom in or out on panning
            if (preFovY <= 115 && preFovY >= 5) {
                sceneView.pointOfView!.camera!.xFov.add(division)
                sceneView.pointOfView!.camera!.yFov.add(division)
                
                // Save new point
                lastPointY = pointY
            }
            
        } else if (gestureRecognize.state == .ended) {
            lastPointY = nil
        }
    }
    
    // MARK: SceneKit Render Delegates
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
        // Check if view has rendered before
        if (!sceneIntiallyRendered) {
            sceneIntiallyRendered = true
        } else {
            
            // Point of view
            UserDefaults.standard.set(sceneView.pointOfView!.position.x, forKey: Constants.scenePositionX)
            UserDefaults.standard.set(sceneView.pointOfView!.position.y, forKey: Constants.scenePositionY)
            UserDefaults.standard.set(sceneView.pointOfView!.position.z, forKey: Constants.scenePositionZ)
            
            // Rotation
            UserDefaults.standard.set(sceneView.pointOfView!.rotation.x, forKey: Constants.sceneRotationX)
            UserDefaults.standard.set(sceneView.pointOfView!.rotation.y, forKey: Constants.sceneRotationY)
            UserDefaults.standard.set(sceneView.pointOfView!.rotation.z, forKey: Constants.sceneRotationZ)
            UserDefaults.standard.set(sceneView.pointOfView!.rotation.w, forKey: Constants.sceneRotationW)
            
            // Field of view
            UserDefaults.standard.set(sceneView.pointOfView!.camera!.xFov, forKey: Constants.sceneFovX)
            UserDefaults.standard.set(sceneView.pointOfView!.camera!.yFov, forKey: Constants.sceneFovY)
        }
    }

}
