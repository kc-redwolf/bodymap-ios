//
//  BodySystemCollectionViewCell.swift
//  BodyMap
//
//  Created by Michael Miller on 3/30/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class BodySystemCollectionViewCell: UICollectionViewCell {
    
    // MARK: Variables
    static let id = "BodySystemCollectionViewCell"
    static let height:CGFloat = 96

    // MARK: Outlets
    @IBOutlet weak var iconView: BodyImageView!
    @IBOutlet weak var titleView: BodyMapLabel!
    @IBOutlet weak var checkImageView: UIImageView!
    
    // MARK: Awake from Nib
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Style check view
        checkImageView.backgroundColor = Constants.colorGreen
        checkImageView.image = checkImageView.image!.withRenderingMode(.alwaysTemplate)
        checkImageView.tintColor = UIColor.white
        checkImageView.layer.cornerRadius = checkImageView.bounds.width / 2
        checkImageView.layer.shadowColor = UIColor.black.cgColor
        checkImageView.layer.shadowOpacity = 0.26
        checkImageView.layer.shadowOffset = CGSize(width: 0, height: 1)
        checkImageView.layer.shadowRadius = 3
        checkImageView.layer.shouldRasterize = true
        checkImageView.isHidden = true
    }
    
    // Set the styles
    func setSystem(system: BodySystem) {
        iconView.system = system
        titleView.text = system.name
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
    
    // MARK: Set Checked
    func setChecked(checked: Bool) {
        
        // Toggle
        self.checkImageView.isHidden = !checked
        
        // Animate news
        if (checked) {
            
            self.checkImageView.alpha = 0
            self.checkImageView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            
            // Animate
            UIView.animate(
                withDuration: 0.4,
                delay: 0.0,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 1.1,
                options: [],
                animations: {
                    
                    self.checkImageView.alpha = 1
                    self.checkImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
                    
            }, completion: { (value: Bool) in
                //
            })
        }
    }

}
