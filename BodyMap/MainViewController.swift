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
    @IBOutlet weak var segmentedControl: BodyMapSegmentedControl!
    
    // MARK: Variables
    private let animatedZoomFactor:Double = 0.1
    let defaults = UserDefaults.standard
    
    let exampleSystem:BodySystem = BodySystem()
    
    // MARK: View Delegates
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        exampleSystem.system = .muscular
        
        
        // Toggle button
        toggleButton.delegate = self
        
        // Get the interaction toggle from user defaults
        if let defaultInteractionToggle = defaults.object(forKey: Constants.interactionToggle) as? Bool {
            toggleButton.toggledOn = defaultInteractionToggle
        } else {
            toggleButton.toggledOn = true
        }
        
        // InfoView
        infoView.delegate = self
        infoView.viewStyle = .info
        infoView.bottomConstraint = infoViewBottom
        
        // Body System View
        bodySystemView.delegate = self
        bodySystemView.bottomConstraint = bodySystemViewBottom
        
        // Body System Button
        bodySystemButton.icon = exampleSystem.icon
        
        // Segmented Control
        if let defaultGenderToggle = defaults.object(forKey: Constants.genderToggle) as? Int {
            segmentedControl.selectedSegmentIndex = defaultGenderToggle
        } else {
            segmentedControl.selectedSegmentIndex = 0
        }
        
        // Shadow View
        shadeView.delegate = self
        
        // Setup delegates and scene
        sceneKitView.setScene(delegate: self, scene: Constants.male)
    }
    
    // MARK Segmented Value Change
    @IBAction func segmentedValueChanged(_ sender: UISegmentedControl) {
        defaults.set(sender.selectedSegmentIndex, forKey: Constants.genderToggle)
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
        defaults.set(toggled, forKey: Constants.interactionToggle)
    }
    
    // MARK: SceneView Delegate
    func sceneViewItemSelected(name: String) {
        infoView.titleView.text = name
        infoView.subtitleView.text = "\(exampleSystem.name!) System"
        infoView.iconView.system = exampleSystem
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
