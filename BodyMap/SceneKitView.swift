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
import AudioToolbox

// MARK: Protocols
protocol SceneKitViewDelegate {
    func sceneViewDidBeginMoving(position: SCNVector3)
    func sceneViewItemSelected(name: String)
    func sceneViewItemDeselected()
}

// MARK: View
class SceneKitView: UIView, SCNSceneRendererDelegate, UIGestureRecognizerDelegate {
    
    // For handling toggle
    var shouldPan:Bool = true
    
    // MARK: Variables
    private let delayedSelectionTime:Double = 0.333
    private let delayedDoubleTapTime:Double = 0.2
    private var singleTapAction:DispatchWorkItem! = nil
    private var doubleTapAction:DispatchWorkItem! = nil
    public let sceneView:SCNView = SCNView()
    
    // Cameras
    var cameraOrbit = SCNNode()
    let cameraNode = SCNNode()
    let camera = SCNCamera()
    
    // MARK: Interaction Variables
    private var singlePanGesture:UIPanGestureRecognizer!
    private var doublePanGesture:UIPanGestureRecognizer!
    private var pinchGesture:UIPinchGestureRecognizer!
    private let pinchAttenuation:Double = 200.0
    private let maxHeightRatioXDown:Float = -0.3
    private let maxHeightRatioXUp:Float = 0.3
    private var lastWidthRatio:Float = 0
    private var lastHeightRatio:Float = 0
    private var widthRatio:Float = 0
    private var heightRatio:Float = 0
    private let maxZoomDistance:Double = 0.8
    private let minZoomDistance:Double = 0.1
    private let animationDuration:Double = 0.33
    private var roundedRotation:Double = 0.5
    
    // Panning Variables
    private var lastAdjustWidthRatio:Float = 0
    private var lastAdjustHeightRatio:Float = 0
    private var adjustWidthRatio:Float = 0
    private var adjustHeightRatio:Float = 0
    private let maxPanDown:Float = -1.0
    private let maxPanUp:Float = 1.0
    private let maxPanLeft:Float = -0.8
    private let maxPanRight:Float = 0.8
    private var isFacingFront:Bool = true
    private var wasFacingFacingFrontLast:Bool = true
    private var lastLongPressLocation:CGPoint! = nil
    private var forcePressure:CGFloat = 0.6
    private var isTouchForced:Bool = false
    
    // Set scene
    public var scene: SCNScene? {
        didSet {
            
            // Create a camera
            camera.usesOrthographicProjection = true
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
            
            // Set the scene
            sceneView.scene = scene
            
            // place the camera
            let defaults = UserDefaults.standard
            
            // Read defaults
            if let defaultX = defaults.object(forKey: Constants.scenePositionX) as? Float,
                let defaultY = defaults.object(forKey: Constants.scenePositionY) as? Float,
                let heightRatio = defaults.object(forKey: Constants.sceneHeightRatio) as? Float,
                let widthRatio = defaults.object(forKey: Constants.sceneWidthRatio) as? Float,
                let zoom = defaults.object(forKey: Constants.sceneZoom) as? Double,
                let panX = defaults.object(forKey: Constants.scenePanX) as? Float,
                let panY = defaults.object(forKey: Constants.scenePanY) as? Float,
                let panWidth = defaults.object(forKey: Constants.scenePanWidthRatio) as? Float,
                let panHeight = defaults.object(forKey: Constants.scenePanHeightRatio) as? Float,
                let facingFront = defaults.object(forKey: Constants.sceneFacingFront) as? Bool {
                
                // Set camera position
                cameraOrbit.eulerAngles.y = defaultY
                cameraOrbit.eulerAngles.x = defaultX
                
                // Last pan ratios
                lastWidthRatio = widthRatio
                lastHeightRatio = heightRatio
                
                // Set zoom
                camera.orthographicScale = zoom
                
                // Set XY
                cameraOrbit.position.x = panX
                cameraOrbit.position.y = panY
                
                // Last XY pan
                lastAdjustWidthRatio = panWidth
                lastAdjustHeightRatio = panHeight
                
                // Check facing direction
                wasFacingFacingFrontLast = facingFront
                
            } else {
                
                // Fallback
                camera.orthographicScale = maxZoomDistance
                cameraOrbit.eulerAngles.y = Float(-2 * M_PI) * lastWidthRatio
                cameraOrbit.eulerAngles.x = Float(-M_PI) * lastHeightRatio
            }
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
            
            // Add triple tap
            let tripleTap = UITapGestureRecognizer(target: self, action: #selector(tripleTapped))
            tripleTap.numberOfTapsRequired = 3
            sceneView.addGestureRecognizer(tripleTap)
            
            // Add long press
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
            longPress.numberOfTapsRequired = 1
            longPress.minimumPressDuration = 0.12
            sceneView.addGestureRecognizer(longPress)
            
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
            doublePanGesture.minimumNumberOfTouches = 2
            doublePanGesture.maximumNumberOfTouches = 2
            pinchGesture.delegate = self
            sceneView.addGestureRecognizer(pinchGesture)
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
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Look for movement
        if let touch = touches.first, UIApplication.shared.keyWindow?.rootViewController?.traitCollection.forceTouchCapability == .available {
            
            // Check for
            let force = touch.force / touch.maximumPossibleForce
            
            // Force touch started
            if (force >= forcePressure) {
                
                // Enable forcing panning
                if (!isTouchForced) {
                    
                    // Set var
                    isTouchForced = true
                    
                    // Vibrate with "pop"
                    let pop = 1520
                    AudioServicesPlaySystemSound(SystemSoundID(pop))
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouchForced = false
    }
    
    // MARK: Handle Single Pan
    @objc private func handleSinglePan(gesture: UIPanGestureRecognizer) {
        
        // Get translation
        // ** the distance that the gesture has moved in view
        let translation = gesture.translation(in: sceneView)
        
        // Handle force touch
        if (isTouchForced || shouldPan) {
            panXY(gesture: gesture, translation: translation)
            return
        }
        
        // Save ratios for later
        widthRatio = Float(translation.x) / Float(gesture.view!.frame.size.width) + lastWidthRatio
        heightRatio = Float(translation.y) / Float(gesture.view!.frame.size.height) + lastHeightRatio
        
        // Up limitation
        if (heightRatio >= maxHeightRatioXUp) {
            heightRatio = maxHeightRatioXUp
        }
        
        // Down limitation
        if (heightRatio <= maxHeightRatioXDown) {
            heightRatio = maxHeightRatioXDown
        }
        
        // Get panning state
        switch gesture.state {
            
        case .began:
            break
            
        case .changed:
            
            // Set camera position
            cameraOrbit.eulerAngles.y = Float(-2 * M_PI) * widthRatio
            cameraOrbit.eulerAngles.x = Float(-M_PI) * heightRatio
            
            // Save current rotation
            roundedRotation = Double((widthRatio - round(widthRatio)) + 0.5)
            
            // Check for rotation
            if (roundedRotation < 0.25 || roundedRotation > 0.75) {
                isFacingFront = false
            } else {
                isFacingFront = true
            }
            
        case .ended:
            
            // Save ratios
            lastWidthRatio = widthRatio
            lastHeightRatio = heightRatio
            
            // Check if rotation was changed
            if (wasFacingFacingFrontLast != isFacingFront) {
                lastAdjustWidthRatio = -lastAdjustWidthRatio
            }
            
            // Save rotation side
            wasFacingFacingFrontLast = isFacingFront
            
            // Save the camera positions
            UserDefaults.standard.set(cameraOrbit.eulerAngles.x, forKey: Constants.scenePositionX)
            UserDefaults.standard.set(cameraOrbit.eulerAngles.y, forKey: Constants.scenePositionY)
            UserDefaults.standard.set(lastHeightRatio, forKey: Constants.sceneHeightRatio)
            UserDefaults.standard.set(lastWidthRatio, forKey: Constants.sceneWidthRatio)
            UserDefaults.standard.set(wasFacingFacingFrontLast, forKey: Constants.sceneFacingFront)
            
        default:
            break
        }
    }
    
    // MARK: Handle Double Pan
    @objc private func handleDoublePan(gesture: UIPanGestureRecognizer) {
        
        // Get translation
        let translation = gesture.translation(in: gesture.view!)
        
        // Handle panning
        panXY(gesture: gesture, translation: translation)
    }
    
    // Long Press Gesture
    @objc private func longPressed(gesture: UIGestureRecognizer) {
        
        // Cancel Single Tap Action
        if let tapAction = singleTapAction {
            tapAction.cancel()
        }
        
        // Cancel Double Tap Action
        if let doubleTapAction = doubleTapAction {
            doubleTapAction.cancel()
        }
        
        // Get translation
        let location = gesture.location(in: sceneView)
        
        // Set location for nil
        if (lastLongPressLocation == nil) {
            lastLongPressLocation = location
        }
        
        // Get translation
        let translation = CGPoint(x: location.x - lastLongPressLocation.x, y: location.y - lastLongPressLocation.y)
        
        // Handle panning
        panXY(gesture: gesture, translation: translation)
    }
    
    var previousLocation:SCNVector3!
    
    // MARK: Pan the view X and Y
    private func panXY(gesture: UIGestureRecognizer, translation: CGPoint) {
        
        // Get ratios
        adjustWidthRatio = Float(translation.x) / Float(sceneView.frame.size.width) + lastAdjustWidthRatio
        adjustHeightRatio = Float(translation.y) / Float(sceneView.frame.size.height) + lastAdjustHeightRatio
        
        // Up limitation
        if (adjustHeightRatio >= maxPanUp) {
            adjustHeightRatio = maxPanUp
        }
        
        // Down limitation
        if (adjustHeightRatio <= maxPanDown) {
            adjustHeightRatio = maxPanDown
        }
        
        // Right limitation
        if (adjustWidthRatio >= maxPanRight) {
            adjustWidthRatio = maxPanRight
        }
        
        // Left limitation
        if (adjustWidthRatio <= maxPanLeft) {
            adjustWidthRatio = maxPanLeft
        }
        
        // Get panning state
        switch gesture.state {
            
        case .began:
            break
            
        case .changed:
            
            // Set position of camera
            cameraOrbit.position.y = adjustHeightRatio
            
            // Check for rotation
            if (roundedRotation < 0.25 || roundedRotation > 0.75) {
                cameraOrbit.position.x = adjustWidthRatio
            } else {
                cameraOrbit.position.x = -adjustWidthRatio
            }
            
        case .ended:
            
            isTouchForced = false
            
            // Save ratios
            lastAdjustWidthRatio = adjustWidthRatio
            lastAdjustHeightRatio = adjustHeightRatio
            
            // Reset last location
            lastLongPressLocation = nil
            
            // Save the camera positions
            UserDefaults.standard.set(cameraOrbit.position.x, forKey: Constants.scenePanX)
            UserDefaults.standard.set(cameraOrbit.position.y, forKey: Constants.scenePanY)
            UserDefaults.standard.set(lastAdjustWidthRatio, forKey: Constants.scenePanWidthRatio)
            UserDefaults.standard.set(lastAdjustHeightRatio, forKey: Constants.scenePanHeightRatio)
            
        default:
            break
        }
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
        
        // Save zoom
        if (gesture.state == .ended) {
            UserDefaults.standard.set(camera.orthographicScale, forKey: Constants.sceneZoom)
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
        
        // Save double tap action
        doubleTapAction = DispatchWorkItem {
        
            // Zoom factor
            let zoomFactor = 0.1
            
            // Calc what change would be
            let calculatedChange = self.camera.orthographicScale - zoomFactor
            
            // Change camera scale
            if (calculatedChange > self.minZoomDistance) {
                
                // Begin Animation
                SCNTransaction.begin()
                SCNTransaction.animationDuration = self.animationDuration
                
                // Perform Change
                self.camera.orthographicScale -= zoomFactor
                
                // End
                SCNTransaction.commit()
                
            } else if (calculatedChange <= self.minZoomDistance) {
                
                // Begin Animation
                SCNTransaction.begin()
                SCNTransaction.animationDuration = self.animationDuration
                
                // Perform Change
                self.camera.orthographicScale = self.minZoomDistance
                
                // End
                SCNTransaction.commit()
            }
            
            // Save zoom
            UserDefaults.standard.set(self.camera.orthographicScale, forKey: Constants.sceneZoom)
        }
        
        // Perform delayed event
        DispatchQueue.main.asyncAfter(deadline: .now() + delayedDoubleTapTime, execute: doubleTapAction)
    }
    
    // Triple Tap Gesture
    @objc private func tripleTapped(gesture: UIGestureRecognizer) {
        
        // Cancel Single Tap Action
        if let singleTapAction = singleTapAction {
            singleTapAction.cancel()
        }
        
        // Cancel Single Tap Action
        if let doubleTapAction = doubleTapAction {
            doubleTapAction.cancel()
        }
        
        // Zoom factor
        let zoomFactor = 0.1
        
        // Calc what change would be
        let calculatedChange = camera.orthographicScale - zoomFactor
        
        // Change camera scale
        if (calculatedChange < maxZoomDistance) {
            
            // Begin Animation
            SCNTransaction.begin()
            SCNTransaction.animationDuration = animationDuration
            
            // Perform Change
            camera.orthographicScale += zoomFactor
            
            // End
            SCNTransaction.commit()
            
        } else if (calculatedChange >= maxZoomDistance) {
            
            // Begin Animation
            SCNTransaction.begin()
            SCNTransaction.animationDuration = animationDuration
            
            // Perform Change
            camera.orthographicScale = maxZoomDistance
            
            // End
            SCNTransaction.commit()
        }
        
        // Save zoom
        UserDefaults.standard.set(camera.orthographicScale, forKey: Constants.sceneZoom)
    }
    
    // MARK: Handle Multiple Gestures
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false // for now
    }
    
    // MARK: SceneKit Render Delegates
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
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
