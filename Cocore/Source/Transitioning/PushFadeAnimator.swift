//
//  PushFadeAnimator.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 04/04/16.
//  Copyright © 2016 Dmitry Shashlov. All rights reserved.
//

import Foundation
import UIKit

class PushFadeAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.33
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
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