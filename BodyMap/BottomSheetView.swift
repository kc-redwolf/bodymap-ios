//
//  BottomSheetView.swift
//  BodyMap
//
//  Created by Michael Miller on 2/26/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class BottomSheetView: UIView, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    // MARK: Variables
    private let headerHeight:CGFloat = 68
    private let statusBarHeight:CGFloat = 20
    private var initialTouchPoint:CGFloat = 0
    private var pinnedPoint:CGFloat = 0
    private var scrollView:UIScrollView! = nil
    
    // View State
    enum State {
        case opened
        case pinned
    }
    var viewState:State = .pinned
    
    // MARK: Layout Subviews
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    
    // MARK: Setup
    private func setup() {
        
        // Set pin point
        pinnedPoint = superview!.bounds.height - headerHeight
        frame.origin.y = pinnedPoint
        
        // Set view pinned
        viewState = .pinned
        
        // Setup a pan gesture recognizer
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(viewPan))
        addGestureRecognizer(panGesture)
        
        // Setup a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTap))
        addGestureRecognizer(tapGesture)
        
        // Check for a scroll view subview
        for subview in subviews {
            
            // Find the scroll view and break
            if (subview.isKind(of: UIScrollView.self)) {
                
                // Get View
                scrollView = subview as! UIScrollView
                scrollView.delegate = self
                
                // Add pan gesture
                let scrollPanGesture = UIPanGestureRecognizer(target: self, action: #selector(scrollViewPan))
                scrollPanGesture.delegate = self
                scrollView.addGestureRecognizer(scrollPanGesture)
                
                // End
                continue
            }
        }
    }
    
    // MARK: View Settings
    func open(animated: Bool) {
        
        // Set state
        viewState = .opened
        
        // Handle non-animated
        if (!animated) {
            frame.origin.y = statusBarHeight
            return
        }
        
        // Animate
        UIView.animate(
            withDuration: 0.33,
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 1.1,
            options: .allowUserInteraction,
            animations: {
                self.frame.origin.y = self.statusBarHeight
                
        }, completion: { (value: Bool) in
            //
        })
    }
    
    func pin(animated: Bool) {
        
        // Set state
        viewState = .pinned
        
        // Handle non-animated
        if (!animated) {
            frame.origin.y = pinnedPoint
            return
        }
        
        // Animate
        UIView.animate(
            withDuration: 0.33,
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 1.1,
            options: .allowUserInteraction,
            animations: {
                self.frame.origin.y = self.pinnedPoint
                
        }, completion: { (value: Bool) in
            //
        })
    }
    
    // MARK: Touches
    @objc private func viewPan(gestureRecognize: UIPanGestureRecognizer) {
        
        // Get point
        let superLocation = gestureRecognize.location(in: superview).y
        let velocity = gestureRecognize.velocity(in: self).y
        
        // Get states
        let isAboveStatusBar = frame.origin.y <= statusBarHeight
        let isBelowPinnedPoint = frame.origin.y >= pinnedPoint
        let threshold = superview!.bounds.height / 2
        
        // Handle interaction
        switch (gestureRecognize.state) {
        case .began:
            
            // Get initial touch location
            initialTouchPoint = gestureRecognize.location(in: self).y
            
        case .changed:
            
            // Get the actual location of the user's input
            let calculatedLocation = superLocation - initialTouchPoint
            
            // Resistence Variables
            let calcHeight = superview!.bounds.height - statusBarHeight - headerHeight
            let downwardResistenceLocation = calcHeight * (1 + log10(calculatedLocation / calcHeight))
            
            // Determine if we need to apply resistence
            if (isBelowPinnedPoint) {
                frame.origin.y = downwardResistenceLocation
            } else {
                frame.origin.y = calculatedLocation
            }
            
        case .ended:
            
            // Get calulated touch location
            let calcTouchLocation = superLocation - initialTouchPoint
            
            // Set postition
            if (isAboveStatusBar) {
                open(animated: true)
            } else if (isBelowPinnedPoint) {
                pin(animated: true)
            } else if (velocity > 800) {
                pin(animated: true)
            } else if (velocity < -800) {
                open(animated: true)
            } else if (calcTouchLocation < threshold) {
                open(animated: true)
            } else if (calcTouchLocation >= threshold) {
                pin(animated: true)
            }
            
        default:
            print("State unsupported 🤓")
        }
    }
    
    // MARK: Touches
    @objc private func viewTap(gestureRecognize: UITapGestureRecognizer) {
        switch (viewState) {
        case .opened:
            pin(animated: true)
        case .pinned:
            open(animated: true)
        }
    }
    
    var scrollTouchLocation:CGFloat! = nil
    @objc private func scrollViewPan(gestureRecognize: UIPanGestureRecognizer) {
        
        let offset = scrollView.contentOffset.y
        if (offset > 0) {
            return
        }
        
        // Get point
        let superLocation = gestureRecognize.location(in: superview).y
        
        // Get states
        let isAboveStatusBar = frame.origin.y <= statusBarHeight
        let isBelowPinnedPoint = frame.origin.y >= pinnedPoint
        let threshold = superview!.bounds.height / 2
        let velocity = gestureRecognize.velocity(in: self).y
        
        // Handle interaction
        switch (gestureRecognize.state) {
        case .began:
            
            print("began")
            
            // Get initial touch location
//            scrollTouchLocation = gestureRecognize.location(in: self).y
            
//            print(scrollTouchLocation)
            
        case .changed:
            
            if (scrollTouchLocation == nil) {
                scrollTouchLocation = gestureRecognize.location(in: self).y
            }
            
            // Get the actual location of the user's input
            let calculatedLocation = superLocation - scrollTouchLocation
            
            frame.origin.y = calculatedLocation
            
            if (frame.origin.y < statusBarHeight) {
                frame.origin.y = statusBarHeight
                scrollView.bounces = true
            } else {
                scrollView.bounces = false
            }
            
        case .ended:
            
            scrollView.bounces = true
            
            // Set postition
            if (isAboveStatusBar) {
                open(animated: true)
            } else if (isBelowPinnedPoint) {
                pin(animated: true)
            } else if (velocity > 800) {
                pin(animated: true)
            } else if (velocity < -800) {
                open(animated: true)
            } else if (frame.origin.y < threshold) {
                open(animated: true)
            } else if (frame.origin.y >= threshold) {
                pin(animated: true)
            }
            
            scrollTouchLocation = nil
            
        default:
            print("State unsupported 🤓")
        }
    }
    
    // MARK: Gesture Recognizer Delegates
    // Needed to make scrollView gesture detectable
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
//    // MARK: ScrollView Delegate
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        
//        let offset = scrollView.contentOffset.y
//        
//        if (offset <= 0) {
//            scrollView.bounces = false
//        } else {
//            scrollView.bounces = true
//        }
//    }

}
