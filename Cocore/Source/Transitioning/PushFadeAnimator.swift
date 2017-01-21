//
//  PushFadeAnimator.swift
//  Cocore
//
//  Created by Dmitry Shashlov on 04/04/16.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation
import UIKit

public class PushFadeAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.33
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        transitionContext.containerView()?.addSubview(toViewController.view)
        toViewController.view.alpha = 0.0
        
        UIView.animateWithDuration(transitionDuration(transitionContext),
                                   animations: {
                                    toViewController.view.alpha = 1.0
        }) { completed in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
}