//
//  Decorator.swift
//  PrizeArena
//
//  Created by Dmitry Shashlov on 24/01/16.
//  Copyright © 2016 Half Bloody. All rights reserved.
//

import Foundation
import UIKit

public protocol Decorator {
    var contentEdgeInsets: UIEdgeInsets { get }
    func decorate(contentView: UIView, decoratedView: UIView)
}

public class BasicDecorator : Decorator {
    
    public var contentEdgeInsets: UIEdgeInsets = UIEdgeInsetsZero
    var decoratedViewBackgroundColor: UIColor?
    var contentViewBackgroundColor: UIColor?
    
    public var decoratedViewHidden: Bool = false

    public init() {
        // Nothing here        
    }
    
    public init(edgeInsets: UIEdgeInsets) {
        self.contentEdgeInsets = edgeInsets
    }
    
    public init(decoratedViewBackgroundColor: UIColor?, contentViewBackgroundColor: UIColor?) {
        self.decoratedViewBackgroundColor = decoratedViewBackgroundColor
        self.contentViewBackgroundColor = contentViewBackgroundColor
    }
    
    public func decorate(contentView: UIView, decoratedView: UIView) {
        decoratedView.backgroundColor = decoratedViewBackgroundColor
        contentView.backgroundColor = contentViewBackgroundColor
        
        decoratedView.hidden = decoratedViewHidden
    }
}

////

public enum RounderDecoratorAppliance {
    case Top // round only top corners
    case Bottom // round only bottom corners
}

public class RounderDecorator : BasicDecorator {

    // Corners
    var corners: UIRectCorner
    
    init(decoratedViewBackgroundColor: UIColor?, contentViewBackgroundColor: UIColor?, corners: UIRectCorner) {
        self.corners = corners
        super.init(decoratedViewBackgroundColor: decoratedViewBackgroundColor, contentViewBackgroundColor: contentViewBackgroundColor)
    }
    
    override public func decorate(contentView: UIView, decoratedView: UIView) {
        
        // Rounded corners
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(roundedRect: decoratedView.bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: 8.0, height: 8.0)).CGPath
        decoratedView.layer.mask = mask
        
        super.decorate(contentView, decoratedView: decoratedView)
    }
}