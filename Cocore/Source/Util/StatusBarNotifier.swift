//
//  AppDelegate.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 28/03/16.
//  Copyright © 2016 Dmitry Shashlov. All rights reserved.
//

import UIKit
import JDStatusBarNotification

enum NotificationStyle : String {
    case Error = "Error"
    case Success = "Success"
    case NeutralDark = "NeutralDark"
}

class StatusBarNotifier {
    
    static func configureAppearance() {
        
        // Error, white text on red background
        _configureAppearance(.Error, barColor: Colors.purple, textColor: Colors.white, font: UIFont.customFont(.RamblaRegular, .Small))
        
        // Success, white text on green background
        _configureAppearance(.Success, barColor: UIColor(rgb: 0x25c306, alphaVal: 1.0), textColor: Colors.white, font: UIFont.customFont(.RamblaRegular, .Small))
        
        // Network connection is offline, white text on dark gray background
        _configureAppearance(.NeutralDark, barColor: UIColor(rgb: 0xacc0cd, alphaVal: 1.0), textColor: Colors.white, font: UIFont.customFont(.RamblaRegular, .Small))
    }
    
    // MARK: Explicit error, success and neutral
    
    static func error(status: String) {
        show(status, style: .Error)
    }
    
    static func error(status: String, dismissAfter timeInterval: NSTimeInterval) {
        show(status, style: .Error, dismissAfter: timeInterval)
    }
    
    static func success(status: String) {
        show(status, style: .Success)
    }
    
    static func success(status: String, dismissAfter timeInterval: NSTimeInterval) {
        show(status, style: .Success, dismissAfter: timeInterval)
    }
    
    static func neutral(status: String) {
        show(status, style: .NeutralDark)
    }
    
    static func neutral(status: String, dismissAfter timeInterval: NSTimeInterval) {
        show(status, style: .NeutralDark, dismissAfter: timeInterval)
    }
    
    // MARK: Show / dismiss
    
    static func show(status: String, style: NotificationStyle) {
        JDStatusBarNotification.showWithStatus(status, styleName: style.rawValue)
    }
    
    static func show(status: String, style: NotificationStyle, dismissAfter timeInterval: NSTimeInterval) {
        JDStatusBarNotification.showWithStatus(status, dismissAfter: timeInterval, styleName: style.rawValue)
    }
    
    static func dismiss() {
        JDStatusBarNotification.dismiss()
    }
    
    static func dismissAnimated(animated: Bool) {
        JDStatusBarNotification.dismissAnimated(animated)
    }
    
    static func dismissAfter(delay: NSTimeInterval) {
        JDStatusBarNotification.dismissAfter(delay)
    }
    
    // MARK: Private
    
    private static func _configureAppearance(style: NotificationStyle, barColor: UIColor, textColor: UIColor, font: UIFont) {
        JDStatusBarNotification.addStyleNamed(style.rawValue) { (style) -> JDStatusBarStyle! in
            style.barColor = barColor
            style.textColor = textColor
            style.font = font
            
            return style
        }
    }
}