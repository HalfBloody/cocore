//
//  PanelDecorator.swift
//  PrizeArena
//
//  Created by Dmitry Shashlov on 24/01/16.
//  Copyright © 2016 Half Bloody. All rights reserved.
//

import Foundation
import UIKit

public class OpacityGradientView : UIView {
    
    var color: CGColorRef?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        userInteractionEnabled = false
        backgroundColor = UIColor.clearColor()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func drawRect(rect: CGRect) {
        
        let componentCount: Int = 2
        let maskColors = [
            0.0, 0.0, 0.0, 1.0,
            1.0, 1.0, 1.0, 1.0,
        ].map { $0 as CGFloat }

        // Create an image of a solid slab in the desired color
        let frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.mainScreen().scale);
        var context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, color ?? Colors.background.CGColor);
        CGContextFillRect(UIGraphicsGetCurrentContext(), frame);
        let colorRef = UIGraphicsGetImageFromCurrentImageContext().CGImage;
        
        // Create an image of a gradient from black to white
        let rgb = CGColorSpaceCreateDeviceRGB();
        let gradientRef = CGGradientCreateWithColorComponents(rgb, maskColors, nil, componentCount);
        
        CGContextDrawLinearGradient(context, gradientRef, CGPointMake(0.0, 0.0), CGPointMake(0.0, bounds.size.height), .DrawsAfterEndLocation);
        let maskRef = UIGraphicsGetImageFromCurrentImageContext().CGImage;
        UIGraphicsEndImageContext();
        
        // Blend the solid image and the gradient to produce the final gradient.
        let tmpMask = CGImageMaskCreate(
            CGImageGetWidth(maskRef),
            CGImageGetHeight(maskRef),
            CGImageGetBitsPerComponent(maskRef),
            CGImageGetBitsPerPixel(maskRef),
            CGImageGetBytesPerRow(maskRef),
            CGImageGetDataProvider(maskRef),
            nil,
            false);
        
        // Draw the resulting mask.
        context = UIGraphicsGetCurrentContext();
        CGContextDrawImage(context, rect, CGImageCreateWithMask(colorRef, tmpMask));
        UIGraphicsEndImageContext();
    }
}

public class OpacityGradientDecorator : BasicDecorator {
    override public func decorate(contentView: UIView, decoratedView: UIView) {        
        
        // Background color
        decoratedView.backgroundColor = UIColor.whiteColor()

        // Add gradient view
        let gradientView = OpacityGradientView(frame: CGRect(x: 0, y: 235, width: 320, height: 30))
        gradientView.color = Colors.white.CGColor

        /*
         * Where opacity decorator used in PocketFlip? 
        if let prizeDetailsView = decoratedView as? PrizeDetailsView,
            prizeTitleLabel = prizeDetailsView.titleLabel {
            decoratedView.insertSubview(gradientView, belowSubview: prizeTitleLabel)
        }
        */
    }
}
