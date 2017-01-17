//
//  Colors.swift
//  PrizeArena
//
//  Created by Jens Disselhoff on 18/01/16.
//  Copyright © 2016 Half Bloody. All rights reserved.
//

import Foundation
import UIKit

extension UIColor{
    public convenience init(rgb: UInt32, alphaVal: CGFloat) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(alphaVal)
        )
    }
}

public struct Colors {
    public static let clear = UIColor.clearColor()
    
    public static let pink = UIColor(rgb: 0xe85798, alphaVal: 1.0)
    public static let blue = UIColor(rgb: 0x0083d1, alphaVal: 1.0)
    public static let yellow = UIColor(rgb: 0xfecd40, alphaVal: 1.0)
    public static let purple = UIColor(rgb: 0xf2444f, alphaVal: 1.0)
    public static let violet = UIColor(rgb: 0x6950ab, alphaVal: 1.0)
    
    public static let almostWhite = UIColor(rgb: 0xf7f7f7, alphaVal: 1.0)
    public static let white = UIColor(rgb: 0xffffff, alphaVal: 1.0)
    public static let black = UIColor(rgb: 0x344148, alphaVal: 1.0)        // check
    public static let blueTint = UIColor(rgb: 0x0072d0, alphaVal: 1.0)     // check
    public static let lightGray = UIColor(rgb: 0xadb0b2, alphaVal: 1.0)    // check
    public static let mediumGray = UIColor(rgb: 0xa3a3a3, alphaVal: 1.0)
    public static let darkGray = UIColor(rgb: 0x7d7d7d, alphaVal:  1.0)
    public static let background = UIColor(rgb: 0xf4f8fb, alphaVal: 1.0)   // check
    public static let lightBackground = UIColor(rgb: 0xededed, alphaVal: 1.0)
    public static let buttonBackground = UIColor(rgb: 0xe2e2e2, alphaVal: 1.0)
    public static let formBackground = UIColor(rgb: 0xf6f6f6, alphaVal: 1.0)
}