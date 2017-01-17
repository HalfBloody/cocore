//
//  AlertModel.swift
//  PrizeArena
//
//  Created by Dmitry Shashlov on 06/02/16.
//  Copyright © 2016 Half Bloody. All rights reserved.
//

import Foundation
import UIKit 

public protocol AlertModelProtocol {
    var headerImage: UIImage? { get }
}

public class AlertModel : AlertModelProtocol {
    public let headerImage: UIImage?
    init(headerImage: UIImage?) {
        self.headerImage = headerImage
    }
}

////

public enum AlertButton {
    case Button(
        title: String, 
        color: UIColor, 
        textColor: UIColor, 
        fontSize: FontSize?, 
        image: (UIImage, Bool)?, 
        cornerRadius: CGFloat?,
        textAlignment: NSTextAlignment?)
    case CancelButton(attributedTitle: NSAttributedString)
}


public class AlertButtonModel {
    var button: AlertButton
    public init(_ button: AlertButton) {
        self.button = button
    }
}