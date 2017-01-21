//
//  DecoratedTableViewCell.swift
//  PrizeArena
//
//  Created by Dmitry Shashlov on 23/01/16.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation
import UIKit

public class DecoratedTableViewCell : UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func setupDecoratedView(decoratedView: UIView, decorator: Decorator) {
        
        // Clean content view
        for subview in self.contentView.subviews {
            if case .Some(_) = subview as? SnapshotView { return } else {
                subview.removeFromSuperview()
            }
        }
        
        let heightConstraint
            = NSLayoutConstraint(item: decoratedView,
                                                  attribute: .Height,
                                                  relatedBy: .GreaterThanOrEqual,
                                                  toItem: nil,
                                                  attribute: .NotAnAttribute,
                                                  multiplier: 1.0,
                                                  constant: decoratedView.frame.size.height)
        
        // Add as subview
        self.contentView.addSubview(decoratedView)
        self.contentView.addConstraints([           
            NSLayoutConstraint(item: decoratedView, 
                attribute: .Leading,
                relatedBy: .Equal,
                toItem: self.contentView,
                attribute: .Leading,
                multiplier: 1.0,
                constant: decorator.contentEdgeInsets.left),
            NSLayoutConstraint(item: decoratedView, 
                attribute: .Top,
                relatedBy: .Equal,
                toItem: self.contentView,
                attribute: .Top,
                multiplier: 1.0,
                constant: decorator.contentEdgeInsets.top),
            NSLayoutConstraint(item: decoratedView, 
                attribute: .Trailing,
                relatedBy: .Equal,
                toItem: self.contentView,
                attribute: .Trailing,
                multiplier: 1.0,
                constant: -decorator.contentEdgeInsets.right),
            heightConstraint ])
        
        self.layoutIfNeeded()
        
        self.contentView.removeConstraint(heightConstraint)
        self.contentView.addConstraints([
            NSLayoutConstraint(item: decoratedView,
                attribute: .Bottom,
                relatedBy: .Equal,
                toItem: self.contentView,
                attribute: .Bottom,
                multiplier: 1.0,
                constant: -decorator.contentEdgeInsets.bottom) ])
        
        // Decorate
        decorator.decorate(self.contentView, decoratedView: decoratedView)        
    }

}