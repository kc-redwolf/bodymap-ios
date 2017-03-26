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
    static let sceneHeightRatio:String = "sceneHeightRatio"
    static let sceneWidthRatio:String = "sceneWidthRatio"
    static let sceneZoom:String = "sceneZoom"
    static let scenePanX:String = "scenePanX"
    static let scenePanY:String = "scenePanY"
    static let scenePanHeightRatio:String = "scenePanHeightRatio"
    static let scenePanWidthRatio:String = "scenePanWidthRatio"
    static let sceneFacingFront:String = "sceneFacingFront"
    
    // SceneKit
    static let car:SCNScene = SCNScene(named: "art.scnassets/car.dae")! // For testing
    static let male:SCNScene = SCNScene(named: "art.scnassets/male.dae")!
    static let female:SCNScene = SCNScene(named: "art.scnassets/female.dae")!
    
    // Nodes
    static let skeletal:String = "skeletal"
    static let spot:String = "spot"
    
    // Icons
    static let something:UIImage = UIImage(named: "icon_pan")!
    static let iconClose:UIImage = UIImage(named: "icon_close")!
    
    // Fonts
    static let ABeeZee:String = "ABeeZee-Regular"
}
