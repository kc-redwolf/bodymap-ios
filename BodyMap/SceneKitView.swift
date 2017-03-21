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
    func sceneViewItemDeselected()
}

// MARK: View
class SceneKitView: UIView, SCNSceneRendererDelegate, UIGestureRecognizerDelegate {
    
    // MARK: Variables
    private let delayedSelectionTime:Double = 0.333
    private var singleTapAction:DispatchWorkItem! = nil
    private var sceneIntiallyRendered:Bool = false
    private var lastPointY:Double! = nil
    public let sceneView:SCNView = SCNView()
    
    // Cameras
    var cameraOrbit = SCNNode()
    let cameraNode = SCNNode()
    let camera = SCNCamera()
    
    // MARK: Interaction Variables
    private var singlePanGesture:UIPanGestureRecognizer!
    private var doublePanGesture:UIPanGestureRecognizer!
    private var pinchGesture:UIPinchGestureRecognizer!
    private let pinchAttenuation:Double = 50.0 // 1.0: very fast - 100.0 very slow
    private let maxHeightRatioXDown:Float = -0.5
    private let maxHeightRatioXUp:Float = 0.5
    private var lastWidthRatio:Float = 0
    private var lastHeightRatio:Float = 0.2
    private var widthRatio:Float = 0
    private var heightRatio:Float = 0.2
    private let maxZoomDistance:Double = 0.8
    private let minZoomDistance:Double = 0.1
    private let animationDuration:Double = 0.33
    
    // Set scene
    public var scene: SCNScene? {
        didSet {
            
            // Create a camera
            camera.usesOrthographicProjection = true
            camera.orthographicScale = maxZoomDistance
            camera.zNear = 1
            camera.zFar = 100
            
            // Set position
            cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
            cameraNode.camera = camera
            cameraOrbit = SCNNode()
            cameraOrbit.addChildNode(cameraNode)
            scene!.rootNode.addChildNode(cameraOrbit)
            
            // Initial camera setup
            cameraOrbit.eulerAngles.y = Float(-2 * M_PI) * lastWidthRatio
            cameraOrbit.eulerAngles.x = Float(-M_PI) * lastHeightRatio
            
            // Disable default camera controls
            sceneView.allowsCameraControl = false
            
            // Single pan gesture recognizer
            singlePanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleSinglePan))
            singlePanGesture.maximumNumberOfTouches = 1
            singlePanGesture.delegate = self
            sceneView.addGestureRecognizer(singlePanGesture)
            
            // Double pan gesture recognizer
            doublePanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDoublePan))
            doublePanGesture.minimumNumberOfTouches = 2
            doublePanGesture.maximumNumberOfTouches = 2
            doublePanGesture.delegate = self
            sceneView.addGestureRecognizer(doublePanGesture)
            
            // Pinch gesture recognizer
            pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
            pinchGesture.delegate = self
            sceneView.addGestureRecognizer(pinchGesture)
            
            // Set the scene
            sceneView.scene = scene
            
//            // place the camera
//            let defaults = UserDefaults.standard
//            if let defaultX = defaults.object(forKey: Constants.scenePositionX) as? Float, let defaultY = defaults.object(forKey: Constants.scenePositionY) as? Float, let defaultZ = defaults.object(forKey: Constants.scenePositionZ) as? Float, let rotationX = defaults.object(forKey: Constants.sceneRotationX) as? Float, let rotationY = defaults.object(forKey: Constants.sceneRotationY) as? Float, let rotationZ = defaults.object(forKey: Constants.sceneRotationZ) as? Float, let rotationW = defaults.object(forKey: Constants.sceneRotationW) as? Float, let fovX = defaults.object(forKey: Constants.sceneFovX) as? Double, let fovY = defaults.object(forKey: Constants.sceneFovY) as? Double {
//                sceneView.pointOfView!.position = SCNVector3(x: defaultX, y: defaultY, z: defaultZ)
//                sceneView.pointOfView!.rotation = SCNVector4(x: rotationX, y: rotationY, z: rotationZ, w: rotationW)
//                sceneView.pointOfView!.camera!.xFov = fovX
//                sceneView.pointOfView!.camera!.yFov = fovY
//            } else {
//                sceneView.pointOfView!.position = SCNVector3(x: 0, y: 0, z: 15)
//            }
        }
    }
    
    // Delegate Variable
    public var delegate: SceneKitViewDelegate? {
        didSet {
            
            // Setup Scene
            sceneView.frame.size.width = bounds.width
            sceneView.frame.size.height = bounds.height
            addSubview(sceneView)
            sceneView.delegate = self
            
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
//            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
//            longPress.numberOfTapsRequired = 1
//            longPress.minimumPressDuration = 0.08
//            sceneView.addGestureRecognizer(longPress)
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
    
    // MARK: Handle Single Pan
    @objc private func handleSinglePan(gesture: UIPanGestureRecognizer) {
        
        // Get translation
        // ** the distance that the gesture has moved in view
        let translation = gesture.translation(in: gesture.view!)
        
        // Save ratios for later
        widthRatio = Float(translation.x) / Float(gesture.view!.frame.size.width) + lastWidthRatio
        heightRatio = Float(translation.y) / Float(gesture.view!.frame.size.height) + lastHeightRatio
        
        // Get panning state
        switch gesture.state {
            
        case .began:
            break
            
        case .changed:
            
            // Up limiation
            if (heightRatio >= maxHeightRatioXUp) {
                heightRatio = maxHeightRatioXUp
            }
            
            // Down limiation
            if (heightRatio <= maxHeightRatioXDown) {
                heightRatio = maxHeightRatioXDown
            }
            
            // Set camera position
            cameraOrbit.eulerAngles.y = Float(-2 * M_PI) * widthRatio
            cameraOrbit.eulerAngles.x = Float(-M_PI) * heightRatio
            
        case .ended:
            
            // Save ratios
            lastWidthRatio = widthRatio
            lastHeightRatio = heightRatio
            
        default:
            break
        }
    }
    
    private var lastAdjustHeightRatio:Float = 0.2
    private var adjustHeightRatio:Float = 0.2
    private let maxPanDown:Float = -1.0
    private let maxPanUp:Float = 1.0
    
    // MARK: Handle Double Pan
    @objc private func handleDoublePan(gesture: UIPanGestureRecognizer) {
        
        // Get translation
        // ** the distance that the gesture has moved in view
        let translation = gesture.translation(in: gesture.view!)
        
        // Get ratios
        adjustHeightRatio = Float(translation.y) / Float(gesture.view!.frame.size.height) + lastAdjustHeightRatio
        
        // Get panning state
        switch gesture.state {
            
        case .began:
            break
            
        case .changed:
            
            // Up limiation
            if (adjustHeightRatio >= maxPanUp) {
                adjustHeightRatio = maxPanUp
            }
            
            // Down limiation
            if (adjustHeightRatio <= maxPanDown) {
                adjustHeightRatio = maxPanDown
            }
            
            // Set postition of camera
            cameraOrbit.position.y = adjustHeightRatio
            
        case .ended:
            
            // Save ratios
            lastAdjustHeightRatio = adjustHeightRatio
            
        default:
            break
        }
        
        print(adjustHeightRatio)
        
    }
    
    // MARK: Handle Pinch
    @objc private func handlePinch(gesture: UIPinchGestureRecognizer) {
        
        // Get velocity
        let pinchVelocity = Double(gesture.velocity)
        
        // Subtract velocity / pin factor
        camera.orthographicScale -= (pinchVelocity / pinchAttenuation)
        
        // Set min pinch
        if (camera.orthographicScale <= minZoomDistance) {
            camera.orthographicScale = minZoomDistance
        }
        
        // Set max pinch
        if (camera.orthographicScale >= maxZoomDistance) {
            camera.orthographicScale = maxZoomDistance
        }
    }
    
    // Single Tap Gesture
    @objc private func singleTapped(gesture: UIGestureRecognizer) {
        
        // Check what nodes are tapped
        let p = gesture.location(in: self.sceneView)
        let hitResults = self.sceneView.hitTest(p, options: [:])
        
        // Call single tap action
        singleTapAction = DispatchWorkItem {
            
            // Check that we clicked on at least one object
            if (hitResults.count > 0) {
                
                // retrieved the first clicked object
                let result: AnyObject = hitResults[0]
                let currentNode: SCNNode = result.node
                
                // Call delegate for item
                if let d = self.delegate {
                    d.sceneViewItemSelected(name: result.node.name!)
                }
                
                // Begin Animation
                SCNTransaction.begin()
                SCNTransaction.animationDuration = self.animationDuration
                
                // Loop Child nodes
                self.sceneView.scene!.rootNode.enumerateChildNodes { (node, stop) -> Void in

                    // Set opacity
                    if let name = node.name {
                        if (name == Constants.skeletal || name == Constants.spot || node.name == currentNode.name) {
                            node.opacity = 1
                        } else {
                            node.opacity = 0.2
                        }
                    }
                }
                
                // End
                SCNTransaction.commit()

            } else {
                
                // Loop Child nodes
                SCNTransaction.begin()
                SCNTransaction.animationDuration = self.animationDuration
                self.sceneView.scene!.rootNode.enumerateChildNodes { (node, stop) -> Void in
                    node.opacity = 1
                }
                SCNTransaction.commit()
                
                // Call delegate for deselection
                if let d = self.delegate {
                    d.sceneViewItemDeselected()
                }
            }
        }
        
        // Perform delayed event
        DispatchQueue.main.asyncAfter(deadline: .now() + delayedSelectionTime, execute: singleTapAction)
    }
    
    // Double Tap Gesture
    @objc private func doubleTapped(gesture: UIGestureRecognizer) {
        
        // Cancel Single Tap Action
        if let tapAction = singleTapAction {
            tapAction.cancel()
        }
        
        // Zoom factor
        let zoomFactor = 0.1
        
        // Calc what change would be
        let calculatedChange = camera.orthographicScale - zoomFactor
        
        // Change camera scale
        if (calculatedChange > minZoomDistance) {
            
            // Begin Animation
            SCNTransaction.begin()
            SCNTransaction.animationDuration = animationDuration
            
            // Perform Change
            camera.orthographicScale -= zoomFactor
            
            // End
            SCNTransaction.commit()
            
        } else if (calculatedChange <= minZoomDistance) {
            
            // Begin Animation
            SCNTransaction.begin()
            SCNTransaction.animationDuration = animationDuration
            
            // Perform Change
            camera.orthographicScale = minZoomDistance
            
            // End
            SCNTransaction.commit()
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
    
    // MARK: Handle Multiple Gestures
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false // for now
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
        
        // Loop Child nodes
        scene.rootNode.enumerateChildNodes { (node, stop) -> Void in
            
            // Set opacity
            if let name = node.name {
                if (name.contains("Skeletal")) {
                    node.isHidden = true
                } else {
                    node.isHidden = false
                }
            }
        }
    }

}
