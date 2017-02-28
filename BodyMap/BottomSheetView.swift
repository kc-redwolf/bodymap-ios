//
//  BottomSheetView.swift
//  BodyMap
//
//  Created by Michael Miller on 2/26/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class BottomSheetView: UIView {
    
    // MARK: Variables
    private let headerHeight:CGFloat = 68
    private let statusBarHeight:CGFloat = 20
    private var initialTouchPoint:CGPoint! = nil
    private var pinnedPoint:CGFloat = 0
    
    // View State
    enum State {
        case opened
        case pinned
    }
    var viewState:State = .pinned {
        didSet {
            switch viewState {
            case .opened:
                open(animated: true)
            case .pinned:
                pin(animated: true)
            }
        }
    }
    
    // MARK: Layout Subviews
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    
    // MARK: Setup
    private func setup() {
        
        // Set pin point
        pinnedPoint = superview!.bounds.height - (headerHeight + statusBarHeight)
        frame.origin.y = pinnedPoint
        
        // Set view pinned
        viewState = .pinned
    }
    
    // MARK: View Settings
    private func open(animated: Bool) {
        
        // Handle non-animated
        if (!animated) {
            frame.origin.y = statusBarHeight
            return
        }
        
        // Animate
        UIView.animate(
            withDuration: 0.33,
            delay: 0.0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 1.0,
            options: .allowUserInteraction,
            animations: {
                
                self.frame.origin.y = self.statusBarHeight
                
        }, completion: { (value: Bool) in
            //
        })
    }
    
    private func pin(animated: Bool) {
        
        // Handle non-animated
        if (!animated) {
            frame.origin.y = pinnedPoint
            return
        }
        
        // Animate
        UIView.animate(
            withDuration: 0.33,
            delay: 0.0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 1.0,
            options: .allowUserInteraction,
            animations: {
                
                self.frame.origin.y = self.pinnedPoint
                
        }, completion: { (value: Bool) in
            //
        })
    }
    
    // MARK: Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let bottomSheetLocation = touch.location(in: self)
            initialTouchPoint = bottomSheetLocation
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            
            // Get point
            let superLocation = touch.location(in: superview)
            let calcTouchLocation = superLocation.y - initialTouchPoint.y
            
            // Get states
//            let isAboveStatusBar = frame.origin.y <= statusBarHeight
            let isBelowPinnedPoint = frame.origin.y >= pinnedPoint
            
            // Resistence Variables
            let calcHeight = superview!.bounds.height - statusBarHeight - headerHeight
            let downwardResistenceLocation = calcHeight * (1 + log10(calcTouchLocation / calcHeight))
//            let upwardResistenceLocation = statusBarHeight * (1 + log10(frame.origin.y / statusBarHeight))
            
            if (isBelowPinnedPoint) {
                frame.origin.y = downwardResistenceLocation
            } else {
                frame.origin.y = calcTouchLocation
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
        
            // Get states
            let isAboveStatusBar = frame.origin.y <= statusBarHeight
            let isBelowPinnedPoint = frame.origin.y >= pinnedPoint
            let superLocation = touch.location(in: superview)
            let calcTouchLocation = superLocation.y - initialTouchPoint.y
            let threshold = superview!.bounds.height / 2
            
            // Set postition
            if (isAboveStatusBar) {
                viewState = .opened
            } else if (isBelowPinnedPoint) {
                viewState = .pinned
            } else if (calcTouchLocation < threshold) {
                viewState = .opened
            } else if (calcTouchLocation >= threshold) {
                viewState = .pinned
            }
            
        }
    }

}
