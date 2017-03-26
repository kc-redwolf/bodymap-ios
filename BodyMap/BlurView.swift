//
//  BlurView.swift
//  BodyMap
//
//  Created by Michael Miller on 3/3/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

@IBDesignable
class BlurView: UIView {
    
    // Effect value
    @IBInspectable var lightEffect:Bool = false

    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        style()
    }
    
    // MARK: Style
    private func style() {
        
        // Only apply the blur if the user hasn't disabled transparency effects
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            
            // Add blur view
            backgroundColor = UIColor.clear
            var blurEffect = UIBlurEffect(style: .dark)
            
            // Check for light
            if (lightEffect) {
                blurEffect = UIBlurEffect(style: .light)
            }
            
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(blurEffectView)
            
            // Check for views
            for view in subviews {
                
                // Skip blur view
                if (view != blurEffectView) {
                    bringSubview(toFront: view)
                }
            }
            
        } else {
            backgroundColor = UIColor.black
        }
    }

}
