//
//  PopFadeAnimator.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 04/04/16.
//  Copyright © 2016 Dmitry Shashlov. All rights reserved.
//

import Foundation
import UIKit

public class PopFadeAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.33
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        
        transitionContext.containerView()?.insertSubview(toViewController.view, belowSubview: fromViewController.view)
        
        UIView.animateWithDuration(transitionDuration(transitionContext),
                                   animations: {
                                    fromViewController.view.alpha = 0.0
        }) { completed in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
        
    }
}