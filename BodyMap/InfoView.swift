//
//  InfoView.swift
//  BodyMap
//
//  Created by Michael Miller on 3/26/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

protocol InfoViewDelegate {
    func infoViewDismissClick(infoView: InfoView)
}

class InfoView: BlurView {
    
    // Variables
    private var halfHeight:CGFloat = 0
    private let animationDuration:TimeInterval = 0.33
    var delegate:InfoViewDelegate?
    var bottomConstraint:NSLayoutConstraint?
    
    // Info components
    var iconView:UIImageView!
    var titleView:BodyMapLabel!
    var subtitleView:BodyMapLabel!
    var closeButton:UIButton!
    
    // View State
    enum State {
        case visible
        case hidden
    }
    var viewState:State = .hidden
    
    // View Style
    enum Style {
        case info
        case normal
    }
    var viewStyle:Style = .normal

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
        
        // Corners
        layer.cornerRadius = 8
        clipsToBounds = true
    }
    
    // MARK: Layout Subviews
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    
    private func setup() {
        
        // Build the view
        halfHeight = bounds.height / 2
        
        // Hide it by default? // CHANGE ME
        hide(animated: false)
        
        // Close Button
        closeButton = UIButton()
        closeButton.frame.size.height = 72 // Hardcoded 😱
        closeButton.frame.size.width = 64
        closeButton.frame.origin.x = bounds.width - 64
        closeButton.setImage(Constants.iconClose, for: .normal)
        closeButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        addSubview(closeButton)
        
        // Check style
        switch viewStyle {
        case .info:
            addInfoStyle()
        default:
            break
        }
    }
    
    // MARK: Add Info Style
    private func addInfoStyle() {
        
        // Remove all views
        for view in subviews {
            if (view is UIVisualEffectView || view == closeButton) {
                break
            } else {
                view.removeFromSuperview()
            }
        }
        
        // Icon view
        iconView = UIImageView()
        iconView.frame.size.height = 36
        iconView.frame.size.width = 36
        iconView.layer.cornerRadius = iconView.frame.size.height / 2
        iconView.backgroundColor = UIColor.green
        iconView.contentMode = .center
        iconView.image = Constants.something
        iconView.frame.origin.x = 16
        iconView.frame.origin.y = 18
        addSubview(iconView)
        
        // Title View
        titleView = BodyMapLabel()
        titleView.frame.origin.x = 16 + iconView.frame.size.width + iconView.frame.origin.x
        titleView.frame.origin.y = 16
        titleView.frame.size.height = 19
        titleView.frame.size.width = bounds.width - ((iconView.frame.origin.x * 2) + iconView.frame.size.width + closeButton.frame.size.width)
        titleView.textColor = UIColor.white
        titleView.font = titleView.font.withSize(16)
        titleView.numberOfLines = 1
        addSubview(titleView)
        
        // SubTitle View
        subtitleView = BodyMapLabel()
        subtitleView.frame.origin.x = 16 + iconView.frame.size.width + iconView.frame.origin.x
        subtitleView.frame.origin.y = 39
        subtitleView.frame.size.height = 17
        subtitleView.frame.size.width = bounds.width - ((iconView.frame.origin.x * 2) + iconView.frame.size.width + closeButton.frame.size.width)
        subtitleView.textColor = UIColor.white.withAlphaComponent(0.54)
        subtitleView.font = titleView.font.withSize(14)
        subtitleView.numberOfLines = 1
        addSubview(subtitleView)
    }
    
    // MARK: View Settings
    func show(animated: Bool) {
        
        // Set state
        viewState = .visible
        
        // Set constraint
        bottomConstraint?.constant = -halfHeight
        
        // Check animation
        if (!animated) {
            superview!.layoutIfNeeded()
            return
        }
        
        // Animate
        animateChange()
    }
    
    func hide(animated: Bool) {
        
        // Set state
        viewState = .hidden
        
        // Set constraint
        bottomConstraint?.constant = -bounds.height
        
        // Check animation
        if (!animated) {
            superview!.layoutIfNeeded()
            return
        }
        
        // Animate
        animateChange()
    }
    
    private func animateChange() {
        
        // Animate
        UIView.animate(
            withDuration: animationDuration,
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 1.1,
            options: .allowUserInteraction,
            animations: {
                self.superview!.layoutIfNeeded()
                
        }, completion: { (value: Bool) in
            //
        })
    }
    
    // MARK: Dismiss click
    @objc private func dismiss() {
        if let d = delegate {
            d.infoViewDismissClick(infoView: self)
        }
    }

}
