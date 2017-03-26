//
//  BodyMapLabel.swift
//  BodyMap
//
//  Created by Michael Miller on 3/26/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class BodyMapLabel: UILabel {

    // MARK: UILabel Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        initialize()
    }
    
    // MARK: Build
    private func initialize() {
        font = UIFont(name: Constants.ABeeZee, size: font.pointSize)
    }
}
