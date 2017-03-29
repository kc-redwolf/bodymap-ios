//
//  ToggleButton.swift
//  BodyMap
//
//  Created by Michael Miller on 3/25/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

// MARK: Protocols
protocol ToggleButtonDelegate {
    func didToggleButton(toggled: Bool)
}

// Class init
@IBDesignable
class ToggleButton: ActionButton {
    
    // Variables
    var delegate:ToggleButtonDelegate?
    var toggledOn:Bool = true {
        didSet {
            
            // Call delegate
            if let d = delegate {
                d.didToggleButton(toggled: toggledOn)
            } else {
                print("No delegate set 🤗")
            }
        }
    }
    
    // Icons
    @IBInspectable var iconOn:UIImage?
    @IBInspectable var iconOff:UIImage?
    
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
        
        // Attach listener
        addTarget(self, action: #selector(toggle), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Set icon
        if (toggledOn) {
            setImage(iconOn, for: .normal)
        } else {
            setImage(iconOff, for: .normal)
        }
    }
    
    // Toggle Button
    @objc private func toggle() {
        
        // Set status
        toggledOn = !toggledOn
        
        // Check for icon
        if (iconOn == nil || iconOff == nil) {
            print("Can use nil icon(s) 🤗")
        }
        
        // Set icon
        if (toggledOn) {
            setImage(iconOn, for: .normal)
        } else {
            setImage(iconOff, for: .normal)
        }
    }

}
