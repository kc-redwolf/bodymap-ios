//
//  ActionButton.swift
//  BodyMap
//
//  Created by Michael Miller on 3/28/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

@IBDesignable
class ActionButton: UIButton {
    
    // Views
    let iconView = UIImageView()
    let labelView = BodyMapLabel()
    
    // Variables
    @IBInspectable var titled:Bool = false
//    {
//        didSet {
//            if (titled) {
//                backgroundColor = UIColor.white.withAlphaComponent(0.26)
//            } else {
//                backgroundColor = UIColor.black.withAlphaComponent(0.26)
//            }
//        }
//    }
    
    var title:String! {
        didSet {
            
            // Add if doesn't exist
            if (!subviews.contains(labelView)) {
                labelView.frame.size.width = bounds.width - 20
                labelView.frame.size.height = 18
                labelView.frame.origin.y = (bounds.height / 2) + 6
                labelView.frame.origin.x = 10
                labelView.adjustsFontSizeToFitWidth = true
                labelView.minimumScaleFactor = 0.5
                labelView.textColor = UIColor.white
                labelView.textAlignment = .center
                addSubview(labelView)
            }
            
            // Set label
            labelView.text = title
        }
    }
    
    var icon:UIImage! {
        didSet {
            
            // Set Icon
            if (titled) {
                
                // Check if label exists
                if (!subviews.contains(iconView)) {
                    iconView.frame.size.width = bounds.width
                    iconView.frame.size.height = (bounds.height / 2)
                    iconView.frame.origin.y = 8
                    iconView.image = icon.withRenderingMode(.alwaysTemplate)
                    iconView.contentMode = .center
                    addSubview(iconView)
                }
                
                // Set icon
                iconView.image = icon.withRenderingMode(.alwaysTemplate)
                    
            } else {
                let image = icon.withRenderingMode(.alwaysTemplate)
                setImage(image, for: .normal)
            }
            
            // Set tint
            tintColor = UIColor.white
        }
    }

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
        
        // Set styles
        layer.cornerRadius = 8
        clipsToBounds = true
        
        // Set Background
        if (!titled) {
            backgroundColor = UIColor.black.withAlphaComponent(0.26)
        }
    }
    
    // MARK: Selections
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animateContent(pressed: true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        animateContent(pressed: false)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        animateContent(pressed: false)
    }
    
    // Animate Changes
    private func animateContent(pressed: Bool) {
        if (pressed) {
            UIView.animate(
                withDuration: 0.1,
                delay: 0.0,
                options: .allowUserInteraction,
                animations: {
                    self.alpha = 0.8
                    self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }, completion: nil)
        } else {
            UIView.animate(
                withDuration: 0.1,
                delay: 0.0,
                options: .allowUserInteraction,
                animations: {
                    self.alpha = 1
                    self.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
        }
    }

}
