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

class MainViewController: BodyMapViewController, ToggleButtonDelegate, InfoViewDelegate, SceneKitViewDelegate, ShadeViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Variables
    private let animatedZoomFactor:Double = 0.1
    let defaults = UserDefaults.standard
    
    // Body Systems
    let bodySystems:[BodySystem] = [
        BodySystem(system: .lymphatic),
        BodySystem(system: .respiratory),
        BodySystem(system: .digestive),
        BodySystem(system: .nervous),
        BodySystem(system: .reproductive),
        BodySystem(system: .muscular),
        BodySystem(system: .vascular),
        BodySystem(system: .skeletal)
    ]
    
    var currentBodySystem:BodySystem! {
        didSet {
            bodySystemButton.icon = currentBodySystem.icon
            sceneKitView.bodySystem = currentBodySystem
        }
    }
    
    let defaultBodySystemIndex:Int = 7 // Skeletory
    
    // MARK: View Delegates
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        // Get last body system from user defaults
        if let bodySystemDefault = defaults.object(forKey: Constants.selectedSystemIndex) as? Int {
            currentBodySystem = bodySystems[bodySystemDefault]
        } else {
            currentBodySystem = bodySystems[defaultBodySystemIndex]
        }
        
        // Segmented Control
        if let defaultGenderToggle = defaults.object(forKey: Constants.genderToggle) as? Int {
            segmentedControl.selectedSegmentIndex = defaultGenderToggle
        } else {
            segmentedControl.selectedSegmentIndex = 0
        }
        
        // Set model
        // Done on the segmented action
        segmentedValueChanged(segmentedControl)
        
        // Collection View
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: BodySystemCollectionViewCell.id, bundle: nil), forCellWithReuseIdentifier: BodySystemCollectionViewCell.id)
        
        // Shadow View
        shadeView.delegate = self
    }
    
    // MARK: CollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bodySystems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Row
        let row = indexPath.row
        
        // Build cell
        let cell:BodySystemCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: BodySystemCollectionViewCell.id, for: indexPath) as! BodySystemCollectionViewCell
        cell.setSystem(system: bodySystems[row])
        
        // Check for selected index
        var selectedIndex = defaultBodySystemIndex
        
        // Check for default
        if let bodySystemDefault = defaults.object(forKey: Constants.selectedSystemIndex) as? Int {
            selectedIndex = bodySystemDefault
        }
        
        // Set checked
        cell.setChecked(checked: row == selectedIndex)
        
        // Set
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 4, height: BodySystemCollectionViewCell.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Row
        let row = indexPath.row
        
        // Check for selected index
        var selectedIndex = defaultBodySystemIndex
        
        // Check for default
        if let bodySystemDefault = defaults.object(forKey: Constants.selectedSystemIndex) as? Int {
            selectedIndex = bodySystemDefault
        }
        
        // Get Previous Cell
        let previewCell:BodySystemCollectionViewCell = collectionView.cellForItem(at: IndexPath(row: selectedIndex, section: 0)) as! BodySystemCollectionViewCell
        previewCell.setChecked(checked: false)
        
        // Get New Cell
        let newCell:BodySystemCollectionViewCell = collectionView.cellForItem(at: indexPath) as! BodySystemCollectionViewCell
        newCell.setChecked(checked: true)
        
        // Set new default
        defaults.set(row, forKey: Constants.selectedSystemIndex)
        currentBodySystem = bodySystems[row]
    }
    
    // MARK Segmented Value Change
    @IBAction func segmentedValueChanged(_ sender: UISegmentedControl) {
        
        // Set default
        defaults.set(sender.selectedSegmentIndex, forKey: Constants.genderToggle)
        
        // Change model
        if (sender.selectedSegmentIndex == 0) {
            sceneKitView.setScene(delegate: self, scene: Constants.male)
        } else {
            sceneKitView.setScene(delegate: self, scene: Constants.female)
        }
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
        infoView.setContent(bodyPartName: name, system: currentBodySystem)
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
