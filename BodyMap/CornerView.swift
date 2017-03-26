//
//  CornerView.swift
//  BodyMap
//
//  Created by Michael Miller on 3/26/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

@IBDesignable
class CornerView: UIView {
    
    @IBInspectable var cornerRadius:CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }

}
