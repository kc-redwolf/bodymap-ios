//
//  BodySystem.swift
//  BodyMap
//
//  Created by Michael Miller on 3/29/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class BodySystem {
    
    // MARK: Enums
    enum SystemType {
        case digestive
        case lymphatic
        case muscular
        case nervous
        case reproductive
        case respiratory
        case skeletory
        case vascular
    }
    
    // MARK: Values
    var name:String!
    var icon:UIImage!
    var color:UIColor!
    var system:SystemType = .skeletory {
        didSet {
            switch system {
            case .digestive:
                name = "Digestive"
                color = Constants.colorAmber
                icon = Constants.iconGuts
            case .lymphatic:
                name = "Lymphatic"
                color = Constants.colorGreen
                icon = Constants.iconConnect
            case .muscular:
                name = "Muscular"
                color = Constants.colorOrange
                icon = Constants.iconWeight
            case .nervous:
                name = "Nervous"
                color = Constants.colorPink
                icon = Constants.iconBrain
            case .reproductive:
                name = "Reproductive"
                color = Constants.colorPurple
                icon = Constants.iconGender
            case .respiratory:
                name = "Respiratory"
                color = Constants.colorBlue
                icon = Constants.iconLungs
            case .skeletory:
                name = "Skeletory"
                color = Constants.colorAqua
                icon = Constants.iconSkull
            case .vascular:
                name = "Vascular"
                color = Constants.colorRed
                icon = Constants.iconHeart
            }
        }
    }
    
    // MARK: Init
    init() {
        //
    }
    
    init(system: SystemType) {
        self.system = system
    }
}
