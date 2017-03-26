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

class MainViewController: BodyMapViewController, ToggleButtonDelegate, InfoViewDelegate, SceneKitViewDelegate, SCNSceneRendererDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var sceneKitView: SceneKitView!
    @IBOutlet weak var toggleButton: ToggleButton!
    @IBOutlet weak var infoView: InfoView!
    @IBOutlet weak var infoViewBottom: NSLayoutConstraint!
    
    // MARK: View Delegates
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Toggle button
        toggleButton.delegate = self
        toggleButton.toggledOn = true
        
        infoView.delegate = self
        infoView.bottomConstraint = infoViewBottom
        
        // Setup delegates and scene
        sceneKitView.setScene(delegate: self, scene: Constants.male)
    }
    
    // MARK: Info View Delegate
    func infoViewDismissClick() {
        sceneKitView.deselectAllNodes()
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
        infoView.show(title: name, subtitle: "TEST")
    }
    
    func sceneViewItemDeselected() {
        //dummyLabel.text = nil
        infoView.hide()
    }
}
