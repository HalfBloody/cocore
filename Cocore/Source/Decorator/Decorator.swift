//
//  Decorator.swift
//  PrizeArena
//
//  Created by Dmitry Shashlov on 24/01/16.
//  Copyright © 2016 Half Bloody. All rights reserved.
//

import Foundation
import UIKit

protocol Decorator {
    var contentEdgeInsets: UIEdgeInsets { get }
    func decorate(contentView: UIView, decoratedView: UIView)
}

class BasicDecorator : Decorator {
    
    var contentEdgeInsets: UIEdgeInsets = UIEdgeInsetsZero
    var decoratedViewBackgroundColor: UIColor?
    var contentViewBackgroundColor: UIColor?
    
    var decoratedViewHidden: Bool = false

    init() {
        // Nothing here        
    }
    
    init(edgeInsets: UIEdgeInsets) {
        self.contentEdgeInsets = edgeInsets
    }
    
    init(decoratedViewBackgroundColor: UIColor?, contentViewBackgroundColor: UIColor?) {
        self.decoratedViewBackgroundColor = decoratedViewBackgroundColor
        self.contentViewBackgroundColor = contentViewBackgroundColor
    }
    
    func decorate(contentView: UIView, decoratedView: UIView) {
        decoratedView.backgroundColor = decoratedViewBackgroundColor
        contentView.backgroundColor = contentViewBackgroundColor
        
        decoratedView.hidden = decoratedViewHidden
    }
}

////

enum RounderDecoratorAppliance {
    case Top // round only top corners
    case Bottom // round only bottom corners
}

class RounderDecorator : BasicDecorator {

    // Corners
    var corners: UIRectCorner
    
    init(decoratedViewBackgroundColor: UIColor?, contentViewBackgroundColor: UIColor?, corners: UIRectCorner) {
        self.corners = corners
        super.init(decoratedViewBackgroundColor: decoratedViewBackgroundColor, contentViewBackgroundColor: contentViewBackgroundColor)
    }
    
    override func decorate(contentView: UIView, decoratedView: UIView) {
        
        // Rounded corners
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(roundedRect: decoratedView.bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: 8.0, height: 8.0)).CGPath
        decoratedView.layer.mask = mask
        
        super.decorate(contentView, decoratedView: decoratedView)
    }
}