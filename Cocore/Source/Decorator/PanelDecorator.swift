//
//  PanelDecorator.swift
//  PrizeArena
//
//  Created by Dmitry Shashlov on 24/01/16.
//  Copyright © 2016 Half Bloody. All rights reserved.
//

import Foundation
import UIKit

public class PanelDecorator : BasicDecorator {
    override public func decorate(contentView: UIView, decoratedView: UIView) {
        
        // Background color
        decoratedView.backgroundColor = UIColor.whiteColor()
                
        // Shadow
        /*
        contentView.layer.masksToBounds = true
        contentView.layer.shadowOffset = CGSizeMake(1, 3)
        contentView.layer.shadowColor = Colors.darkGray.CGColor
        contentView.layer.shadowRadius = 5
        contentView.layer.shadowOpacity = 0.25
        */
    }
}