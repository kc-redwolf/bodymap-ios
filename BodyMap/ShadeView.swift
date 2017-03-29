//
//  ShadeView.swift
//  BodyMap
//
//  Created by Michael Miller on 3/28/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

protocol ShadeViewDelegate {
    func shadeViewTapped()
}

class ShadeView: UIView {
    
    // Variables
    var delegate:ShadeViewDelegate?
    private let opacity:CGFloat = 0.5
    private let animationDuration:TimeInterval = 0.33

    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        build()
    }
    
    // MARK: Style
    private func build() {
        
        // Add gesture
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        addGestureRecognizer(singleTap)
        
        // Hide view
        hide(animated: false)
    }
    
    // Single Tap Gesture
    @objc private func viewTapped(gesture: UIGestureRecognizer) {
        
        // Check for delegate
        if let d = delegate {
            d.shadeViewTapped()
        } else {
            print("No ShadeViewDelegate 😅")
        }
    }
    
    // MARK: Show / Hide
    func show(animated: Bool) {
        
        // Enable Interaction
        isUserInteractionEnabled = true
        
        // No animation
        if (!animated) {
            backgroundColor = UIColor.black.withAlphaComponent(opacity)
        }
        
        // With animation
        backgroundColor = UIColor.clear
        UIView.animate(withDuration: animationDuration, animations: {
            self.backgroundColor = UIColor.black.withAlphaComponent(self.opacity)
        })
    }
    
    func hide(animated: Bool) {
        
        // Disable Interaction
        isUserInteractionEnabled = false
        
        // No animation
        if (!animated) {
            backgroundColor = UIColor.clear
        }
        
        // With animation
        backgroundColor = UIColor.black.withAlphaComponent(opacity)
        UIView.animate(withDuration: animationDuration, animations: {
            self.backgroundColor = UIColor.clear
        })
    }

}
