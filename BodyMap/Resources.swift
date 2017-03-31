//
//  Resources.swift
//  BodyMap
//
//  Created by Michael Miller on 2/25/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import SceneKit

// MARK: Constants
struct Constants {
    
    // Fonts
    static let ABeeZee = "ABeeZee-Regular"
    
    // User Defaults
    static let scenePositionX      = "scenePositionX"
    static let scenePositionY      = "scenePositionY"
    static let sceneHeightRatio    = "sceneHeightRatio"
    static let sceneWidthRatio     = "sceneWidthRatio"
    static let sceneZoom           = "sceneZoom"
    static let scenePanX           = "scenePanX"
    static let scenePanY           = "scenePanY"
    static let scenePanHeightRatio = "scenePanHeightRatio"
    static let scenePanWidthRatio  = "scenePanWidthRatio"
    static let sceneFacingFront    = "sceneFacingFront"
    static let interactionToggle   = "interactionToggle"
    static let genderToggle        = "genderToggle"
    static let selectedSystemIndex = "selectedSystemIndex"
    
    // SceneKit
    static let car    = SCNScene(named: "art.scnassets/car.dae")! // For testing
    static let male   = SCNScene(named: "art.scnassets/male.dae")!
    static let female = SCNScene(named: "art.scnassets/female.dae")!
    
    // Nodes
    static let skeletal = "skeletal"
    static let spot     = "spot"
    
    // Icons
    static let something   = UIImage(named: "icon_pan")!
    static let iconClose   = UIImage(named: "icon_close")!
    static let iconBrain   = UIImage(named: "icon_brain")!
    static let iconConnect = UIImage(named: "icon_connect")!
    static let iconGender  = UIImage(named: "icon_gender")!
    static let iconGuts    = UIImage(named: "icon_guts")!
    static let iconHeart   = UIImage(named: "icon_heart")!
    static let iconLungs   = UIImage(named: "icon_lungs")!
    static let iconSkull   = UIImage(named: "icon_skull")!
    static let iconWeight  = UIImage(named: "icon_weight")!
    
    // Colors
    static let colorAqua      = UIColor(hex: 0x1CD0A8)
    static let colorBlue      = UIColor(hex: 0x0DA5F2)
    static let colorRed       = UIColor(hex: 0xF13A3A)
    static let colorAmber     = UIColor(hex: 0xFFB300)
    static let colorGreen     = UIColor(hex: 0x39BA3E)
    static let colorOrange    = UIColor(hex: 0xFF5722)
    static let colorPurple    = UIColor(hex: 0xAB47BC)
    static let colorPink      = UIColor(hex: 0xEC407A)
    static let colorDarkGrey  = UIColor(hex: 0x565656)
    static let colorLightGrey = UIColor(hex: 0x999999)
}

// MARK: Extensions
extension UIColor {
    
    convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
}
