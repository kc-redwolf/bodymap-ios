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
class SceneKitView: UIView, SCNSceneRendererDelegate {
    
    // MARK: Variables
    private let delayedSelectionTime:Double = 0.333
    private var singleTapAction:DispatchWorkItem! = nil
    private var sceneIntiallyRendered:Bool = false
    private var lastPointY:Double! = nil
    public let sceneView: SCNView = SCNView()
    
    var cameraOrbit = SCNNode()
    let cameraNode = SCNNode()
    let camera = SCNCamera()
    
    //HANDLE PAN CAMERA
    var lastWidthRatio: Float = 0
    var lastHeightRatio: Float = 0.2
    var widthRatio: Float = 0
    var heightRatio: Float = 0.2
    var fingersNeededToPan = 1
    var fingersNeededToAdjust = 2
    //    var maxWidthRatioRight: Float = 0.2
    //    var maxWidthRatioLeft: Float = -0.2
    var maxHeightRatioXDown: Float = -0.5
    var maxHeightRatioXUp: Float = 0.5
    
    var lastAdjustWidthRatio: Float = 0
    var lastAdjustHeightRatio: Float = 0
    
    let maxZoomDistance = 0.8
    
    //HANDLE PINCH CAMERA
    var pinchAttenuation = 50.0  //1.0: very fast ---- 100.0 very slow
    var lastFingersNumber = 0
    
    public var scene: SCNScene? {
        didSet {
            
            //Create a camera like Rickster said
            camera.usesOrthographicProjection = true
            camera.orthographicScale = maxZoomDistance
            camera.zNear = 1
            camera.zFar = 100
            
            cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
            cameraNode.camera = camera
            cameraOrbit = SCNNode()
            cameraOrbit.addChildNode(cameraNode)
            scene!.rootNode.addChildNode(cameraOrbit)
            
            //initial camera setup
            self.cameraOrbit.eulerAngles.y = Float(-2 * M_PI) * lastWidthRatio
            self.cameraOrbit.eulerAngles.x = Float(-M_PI) * lastHeightRatio
            
            //allows the user to manipulate the camera
            sceneView.allowsCameraControl = false  //not needed
            
            // add a tap gesture recognizer
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            sceneView.addGestureRecognizer(panGesture)
            
            // add a pinch gesture recognizer
            let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
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
    
    func handlePan(gestureRecognize: UIPanGestureRecognizer) {
        
        let numberOfTouches = gestureRecognize.numberOfTouches
        
        let translation = gestureRecognize.translation(in: gestureRecognize.view!)
        
        if (numberOfTouches==fingersNeededToPan) {
            
            widthRatio = Float(translation.x) / Float(gestureRecognize.view!.frame.size.width) + lastWidthRatio
            heightRatio = Float(translation.y) / Float(gestureRecognize.view!.frame.size.height) + lastHeightRatio
            
            //  HEIGHT constraints
            if (heightRatio >= maxHeightRatioXUp ) {
                heightRatio = maxHeightRatioXUp
            }
            if (heightRatio <= maxHeightRatioXDown ) {
                heightRatio = maxHeightRatioXDown
            }
            
            
            //            //  WIDTH constraints
            //            if(widthRatio >= maxWidthRatioRight) {
            //                widthRatio = maxWidthRatioRight
            //            }
            //            if(widthRatio <= maxWidthRatioLeft) {
            //                widthRatio = maxWidthRatioLeft
            //            }
            
            self.cameraOrbit.eulerAngles.y = Float(-2 * M_PI) * widthRatio
            self.cameraOrbit.eulerAngles.x = Float(-M_PI) * heightRatio
            
            print("Height: \(round(heightRatio*100))")
            print("Width: \(round(widthRatio*100))")
            
            
            //for final check on fingers number
            lastFingersNumber = fingersNeededToPan
        }
        
        if (numberOfTouches==fingersNeededToAdjust) {
            
            widthRatio = Float(translation.x) / Float(gestureRecognize.view!.frame.size.width)
            heightRatio = Float(translation.y) / Float(gestureRecognize.view!.frame.size.height)
            
            print("Height: \(self.cameraOrbit.position.y) \(heightRatio)")
            print("Width : \(self.cameraOrbit.position.x) \(widthRatio)")
            
//            //  HEIGHT constraints
//            if (heightRatio >= maxHeightRatioXUp ) {
//                heightRatio = maxHeightRatioXUp
//            }
//            if (heightRatio <= maxHeightRatioXDown ) {
//                heightRatio = maxHeightRatioXDown
//            }
//            
//            self.cameraOrbit.position.y = self.cameraOrbit.position.y + heightRatio
            self.cameraOrbit.position.x = self.cameraOrbit.position.x + -widthRatio
            
            //for final check on fingers number
            lastFingersNumber = fingersNeededToAdjust
        }
        
        lastFingersNumber = (numberOfTouches>0 ? numberOfTouches : lastFingersNumber)
        
        if (gestureRecognize.state == .ended && lastFingersNumber==fingersNeededToPan) {
            lastWidthRatio = widthRatio
            lastHeightRatio = heightRatio
            print("Pan with \(lastFingersNumber) finger\(lastFingersNumber>1 ? "s" : "")")
        }
        
        if (gestureRecognize.state == .ended && lastFingersNumber==fingersNeededToPan) {
            lastAdjustWidthRatio = widthRatio
            lastAdjustHeightRatio = heightRatio
            print("Pan with \(lastFingersNumber) finger\(lastFingersNumber>1 ? "s" : "")")
        }
    }
    
    func handlePinch(gestureRecognize: UIPinchGestureRecognizer) {
        let pinchVelocity = Double.init(gestureRecognize.velocity)
        //print("PinchVelocity \(pinchVelocity)")
        
        camera.orthographicScale -= (pinchVelocity/pinchAttenuation)
        
        if camera.orthographicScale <= 0.1 {
            camera.orthographicScale = 0.1
        }
        
        if camera.orthographicScale >= maxZoomDistance {
            camera.orthographicScale = maxZoomDistance
        }
        
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public var delegate: SceneKitViewDelegate? {
        didSet {
            
            // Setup Scene
            sceneView.frame.size.width = bounds.width
            sceneView.frame.size.height = bounds.height
            addSubview(sceneView)
            sceneView.allowsCameraControl = true
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
                let currentNode: SCNNode = result.node
                
                // Call delegate for item
                if let d = self.delegate {
                    d.sceneViewItemSelected(name: result.node.name!)
                }
                
                // Begin Animation
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.33
                
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
                SCNTransaction.animationDuration = 0.33
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
