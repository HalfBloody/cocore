//
//  CustomButton.swift
//  PrizeArena
//
//  Created by Dmitry Shashlov on 18/02/16.
//  Copyright © 2016 Half Bloody. All rights reserved.
//

import Foundation
import UIKit

class PurpleButton : UIButton {
    
    var originalImage: UIImage?
            
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Don't adjust image when highlighted
        adjustsImageWhenHighlighted = false
        adjustsImageWhenDisabled = false
        
        // Font
        titleLabel?.font = UIFont.customFont(.RamblaBold, .Large)
        
        // Normal
        setTitleColor(Colors.white, forState: .Normal)
        tintColor = UIColor.clearColor()
        layer.cornerRadius = 6.0
        
        // Highlighted
        setTitleColor(UIColor(rgb: 0xffffff, alphaVal: 0.75), forState: .Highlighted)
        
        // Enabled by default
        enabled = true
    }
    
    dynamic var showShadow: Bool = true {
        didSet {
            if showShadow {
                layer.shadowRadius = 8.0
                layer.shadowColor = UIColor.blackColor().CGColor
                layer.shadowOffset = CGSize(width: 0, height: 6)
                layer.shadowOpacity = 0.25
            } else {
                layer.shadowRadius = 0.0
                layer.shadowOpacity = 0.0
                layer.shadowColor = UIColor.clearColor().CGColor
            }
        }
    }
    
    // MARK: 
 
    override var highlighted: Bool {
        didSet {
            backgroundColor = highlighted ? UIColor(rgb: 0xc93640, alphaVal: 1.0) : Colors.purple
            showShadow = !highlighted
        }
    }    
    
    override var enabled: Bool {
        didSet {
            showShadow = enabled
            backgroundColor = enabled ? Colors.purple : UIColor(rgb: 0xbed5e4, alphaVal: 1.0)
        }
    }
}