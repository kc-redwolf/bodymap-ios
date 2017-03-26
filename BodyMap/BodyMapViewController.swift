//
//  BodyMapViewController.swift
//  BodyMap
//
//  Created by Michael Miller on 3/26/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

protocol BodyMapViewControllerDelegate {
    func viewControllerDidLayoutSubviews()
}

class BodyMapViewController: UIViewController {
    
    // MARK: Variables
    var delegate:BodyMapViewControllerDelegate?

    // MARK: Subview layout
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Check for delegate
        if let d = delegate {
            d.viewControllerDidLayoutSubviews()
        }
    }

}
