//
//  ActionButton.swift
//  BodyMap
//
//  Created by Michael Miller on 3/28/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class ActionButton: UIButton {

    // Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        create()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        create()
    }
    
    // Create the view
    private func create() {
        backgroundColor = UIColor.black.withAlphaComponent(0.26)
        layer.cornerRadius = 8
        tintColor = UIColor.white
        clipsToBounds = true
    }

}
