//
//  SMTSegmentedControl.swift
//  SportsmanTracker
//
//  Created by Michael Miller on 5/26/16.
//  Copyright © 2016 Sportsman Tracker. All rights reserved.
//

import Foundation
import UIKit

// Styled Segmented Control
class BodyMapSegmentedControl: UISegmentedControl {
    
    var color:UIColor?
    var oldValue:Int!
    var didReselect:Bool = false
    let FontSize:CGFloat = 15.0
    var indexPath:NSIndexPath?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.initialize()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        self.initialize()
    }
    
    // Style the view
    func initialize() {
        
        // Style the control
        let attr = NSDictionary(object: UIFont(name: Constants.ABeeZee, size: FontSize)!, forKey: NSFontAttributeName as NSCopying)
        setTitleTextAttributes(attr as [NSObject : AnyObject], for: .normal)
        
        // Set Layers
        layer.cornerRadius = 6
        layer.borderWidth = 1
        clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Set Color
        if let color = self.color {
            tintColor = color
            layer.borderColor = color.cgColor
        } else {
            tintColor = UIColor.white
            layer.borderColor = UIColor.white.cgColor
        }
    }
    
    // MARK: Handle Reselection
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        oldValue = selectedSegmentIndex
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        // Handle Reselection
        if (oldValue == selectedSegmentIndex) {
            didReselect = true
            sendActions(for: .valueChanged)
        }
        
        // Reset Reselect Check
        didReselect = false
    }

}
