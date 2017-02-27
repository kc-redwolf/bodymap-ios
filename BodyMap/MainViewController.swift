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

class MainViewController: UIViewController, SceneKitViewDelegate, SCNSceneRendererDelegate {

    // MARK: Outlets
    @IBOutlet weak var sceneKitView: SceneKitView!
    
    // MARK: View Delegates
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup delegates and scene
        sceneKitView.setScene(delegate: self, scene: Constants.car)
    }
    
    // MARK: SceneView Delegate
    func sceneViewDidBeginMoving(position: SCNVector3) {
        //        print("\(position.x) : \(position.y) : \(position.z)")
    }
    
    func sceneViewItemSelected(name: String) {
        print(name)
    }

}
