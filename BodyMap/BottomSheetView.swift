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
    
    // View State
    enum State {
        case opened
        case pinned
    }
    var viewState:State = .pinned {
        didSet {
            switch viewState {
            case .opened:
                open(animated: false)
            case .pinned:
                pin(animated: false)
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
        viewState = .pinned
    }
    
    // MARK: View Settings
    private func open(animated: Bool) {
        frame.origin.y = 20
    }
    
    private func pin(animated: Bool) {
        frame.origin.y = superview!.bounds.height - (headerHeight + statusBarHeight)
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
            
            print(frame.origin.y)
            
            // Check if we can change position
            if (frame.origin.y > statusBarHeight && calcTouchLocation < bounds.height - (headerHeight + statusBarHeight)) {
                frame.origin.y = calcTouchLocation
            }
        }
    }

}
