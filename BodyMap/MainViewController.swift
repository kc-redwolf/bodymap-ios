//
//  GameViewController.swift
//  BodyMap
//
//  Created by Michael Miller on 2/25/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class MainViewController: BodyMapViewController, ToggleButtonDelegate, InfoViewDelegate, SceneKitViewDelegate, ShadeViewDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var sceneKitView: SceneKitView!
    @IBOutlet weak var toggleButton: ToggleButton!
    @IBOutlet weak var infoView: InfoView!
    @IBOutlet weak var infoViewBottom: NSLayoutConstraint!
    @IBOutlet weak var bodySystemView: InfoView!
    @IBOutlet weak var bodySystemViewBottom: NSLayoutConstraint!
    @IBOutlet weak var bodySystemButton: ActionButton!
    @IBOutlet weak var shadeView: ShadeView!
    
    // MARK: Variables
    private let animatedZoomFactor:Double = 0.1
    
    // MARK: View Delegates
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Toggle button
        toggleButton.delegate = self
        toggleButton.toggledOn = true
        
        // InfoView
        infoView.delegate = self
        infoView.viewStyle = .info
        infoView.bottomConstraint = infoViewBottom
        
        // Body System View
        bodySystemView.delegate = self
        bodySystemView.bottomConstraint = bodySystemViewBottom
        
        // Shadow View
        shadeView.delegate = self
        
        // Setup delegates and scene
        sceneKitView.setScene(delegate: self, scene: Constants.male)
    }
    
    // MARK: Body System Action
    @IBAction func bodySystemButtonAction(_ sender: Any) {
        shadeView.show(animated: true)
        bodySystemView.show(animated: true)
        sceneKitView.zoomIn(zoomFactor: animatedZoomFactor)
    }
    
    // MARK: Info View Delegate
    func infoViewDismissClick(infoView: InfoView) {
        
        // Handle proper info view
        if (infoView == self.infoView) {
            sceneKitView.deselectAllNodes()
        } else {
            shadeViewTapped()
        }
    }
    
    // MARK: Toggle Button
    func didToggleButton(toggled: Bool) {
        sceneKitView.shouldPan = toggled
    }
    
    // MARK: SceneView Delegate
    func sceneViewDidBeginMoving(position: SCNVector3) {
        //        print("\(position.x) : \(position.y) : \(position.z)")
    }
    
    func sceneViewItemSelected(name: String) {
        infoView.titleView.text = name
        infoView.subtitleView.text = "TESTEST"
        infoView.show(animated: true)
    }
    
    func sceneViewItemDeselected() {
        infoView.hide(animated: true)
    }
    
    // MARK: Shade View Delegate
    func shadeViewTapped() {
        shadeView.hide(animated: true)
        bodySystemView.hide(animated: true)
        sceneKitView.zoomOut(zoomFactor: animatedZoomFactor)
    }
}
