//
//  FontSizes.swift
//  PrizeArena
//
//  Created by Jens Disselhoff on 18/01/16.
//  Copyright © 2016 Half Bloody. All rights reserved.
//

import Foundation
import UIKit

public enum FontSize: CGFloat {
    case XXXLarge = 60.0
    case XXLarge = 25.0
    case XLarger = 23.0
    case XLarge = 21.0
    case Larger = 17.0
    case Large = 16.0
    case Mediumer = 15.0
    case Medium = 14.0
    case Smaller = 13.0
    case Small = 12.0
    case XSmall = 11.0
}

public enum FontFamily: String {
    case RamblaRegular = "Rambla-Regular"
    case RamblaBold = "Rambla-Bold"
    case RamblaItalic = "Rambla-Italic"
    case RamblaBoldItalic = "Rambla-BoldItalic"
}

extension UIFont {
    public class func customFont(fontFamily: FontFamily, _ size: FontSize) -> UIFont {
        return UIFont(name: fontFamily.rawValue, size: size.rawValue)!
    }
}