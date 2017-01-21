//
//  CustomButton.swift
//  PrizeArena
//
//  Created by Dmitry Shashlov on 18/02/16.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation
import UIKit

let kLockNotification = "com.prizeArena.lockButtons"
let kUnlockNotification = "com.prizeArena.unlockButtons"

public class ProfileButton : CustomButton {
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        // Don't subscribe to lock / unlock notifications
        NSNotificationCenter.defaultCenter().removeObserver(self)        
    }
}

public class CustomButton : UIButton {
    
    public var selectionEnabled: Bool = true
    public var allowTransitionToSelectedState: Bool = true
    
    public static var enabledButtons = true {
        didSet {
            if enabledButtons {
                printd("BUTTONS ENABLED")
                NSNotificationCenter.defaultCenter().postNotificationName(kUnlockNotification, object: nil)
            } else {
                printd("BUTTONS DISABLED")
                NSNotificationCenter.defaultCenter().postNotificationName(kLockNotification, object: nil)
            }
        }
    }
        
    public var textColor: UIColor? {
        didSet {
            setTitleColor(textColor, forState: .Normal)
        }
    }
    
    public var selectedTextColor: UIColor? {
        didSet {
            setTitleColor(selectedTextColor, forState: .Selected)
        }
    }
    
    public var color: UIColor? {
        didSet {
            backgroundColor = color
        }
    }
    
    public var selectedColor: UIColor?
    
    public var fontSize = FontSize.Large {
        didSet {
            updateLabelFont()
        }
    }
    
    public var fontFamily = FontFamily.RamblaBold {
        didSet {
            updateLabelFont()
        }
    }
    
    public var cornerRadius: CGFloat? {
        didSet {
            layer.cornerRadius = cornerRadius!
        }
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        updateLabelFont()
        
        // Don't adjust image when highlighted
        adjustsImageWhenHighlighted = false
        adjustsImageWhenDisabled = false
        
        // Add self as target
        addTarget(self, action: #selector(CustomButton.buttonClicked(_:)), forControlEvents: .TouchDown)
        
        // Notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CustomButton.lockNotification(_:)), name: kLockNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CustomButton.unlockNotification(_:)), name: kUnlockNotification, object: nil)
        
        // Border
        // layer.borderColor = Colors.white.CGColor
        // layer.borderWidth = 3.0
        
        // Shadow
        // showShadow = true
    }
    
    public var showShadow: Bool = true {
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
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()        
        
        switch cornerRadius {
            case .None: layer.cornerRadius = 5.0
            default: break
        }
    }
    
    // Highlighted / selected
    
    override public var selected: Bool {
        didSet {
            
            // Setup selected color if not provided
            checkSelectedColor()
        
            // Setup background color
            if selectionEnabled {
                if selected {
                    backgroundColor = selectedColor
                    setTitleColor(Colors.white, forState: .Selected)
                    layer.borderColor = Colors.blue.CGColor
                    layer.borderWidth = 1.0
                } else {
                    backgroundColor = color
                    setTitleColor(textColor, forState: .Normal)
                    layer.borderColor = Colors.white.CGColor
                    layer.borderWidth = 3.0
                }
            }
        }
    }
    
    // Private: Selected color
    
    private func checkSelectedColor() {
        let selectedBackgroundColor = selectedColor
        if case .None = selectedBackgroundColor {
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            backgroundColor?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)                               
            
            // Setup selected color (don't use clear color)
            if !(red == 0 && green == 0 && blue == 0 && alpha == 0) {
                selectedColor = UIColor(red: red, green: green, blue: blue, alpha: 0.5)
            }
        }
    }
    
    // Private
    
    private func updateLabelFont() {
        titleLabel?.font = UIFont.customFont(fontFamily, fontSize)
    }
        
    // Notifications
    
    func lockNotification(notification: NSNotification) {
        enabled = false
    }
    
    func unlockNotification(notification: NSNotification) {
        enabled = true
    }
    
    // Button clicked
    
    func buttonClicked(sender: AnyObject?) {
        if allowTransitionToSelectedState {
            selected = !selected
        }
    }
}