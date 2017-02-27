//
//  Resources.swift
//  BodyMap
//
//  Created by Michael Miller on 2/25/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import SceneKit

// MARK: Constants
// Mostly strings
struct Constants {
    
    // User Defaults
    static let scenePositionX:String = "scenePositionX"
    static let scenePositionY:String = "scenePositionY"
    static let scenePositionZ:String = "scenePositionZ"
    static let sceneRotationX:String = "sceneRotationX"
    static let sceneRotationY:String = "sceneRotationY"
    static let sceneRotationZ:String = "sceneRotationZ"
    static let sceneRotationW:String = "sceneRotationW"
    static let sceneFovX:String = "sceneFovX"
    static let sceneFovY:String = "sceneFovY"
    
    // SceneKit
    static let car:SCNScene = SCNScene(named: "art.scnassets/car.dae")!
}
