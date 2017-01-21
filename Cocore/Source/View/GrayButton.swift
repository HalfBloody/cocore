//
//  GrayButton.swift
//  PrizeArena
//
//  Created by Dmitry Shashlov on 18/02/16.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation
import UIKit

public class GrayButton : UIButton {
    
    var originalImage: UIImage?
            
    override public func awakeFromNib() {
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
    
    dynamic public var showShadow: Bool = true {
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
 
    override public var highlighted: Bool {
        didSet {
            backgroundColor = highlighted ? UIColor(rgb: 0x98abb9, alphaVal: 1.0) : UIColor(rgb: 0xb9cede, alphaVal: 1.0)
            showShadow = !highlighted
        }
    }    
    
    override public var enabled: Bool {
        didSet {
            showShadow = enabled
            backgroundColor = enabled ? UIColor(rgb: 0xb9cede, alphaVal: 1.0) : UIColor(rgb: 0xbed5e4, alphaVal: 1.0)
        }
    }
}