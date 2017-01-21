//
//  AlertAnimator.swift
//  Cocore
//
//  Created by Dmitry Shashlov on 04/04/16.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation
import UIKit

public class AlertAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    
    let presenting: Bool
    
    init(presenting: Bool) {
        self.presenting = presenting
    }
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.33
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        printd("ALERT \(presenting ? "PRESENTING" : "DISMISSING")")
        
        // Views
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)
                                                                    
        // Container view
        let blurredView = UIView()
        let containerView = transitionContext.containerView()!
        
        // Create blur effect view
        if presenting {
            
            // Blurred view
            blurredView.backgroundColor = UIColor(rgb: 0x282b2d, alphaVal: 0.8)
            blurredView.frame = UIScreen.mainScreen().bounds
            blurredView.alpha = presenting ? 0.0 : 1.0
            containerView.addSubview(blurredView)
            
            // Add toView to container view
            toView!.frame = UIScreen.mainScreen().bounds
            containerView.addSubview(toView!)
        }
        
        // Calculate travel distance
        let travelDistance = containerView.bounds.size.height
        let travel = CGAffineTransformMakeTranslation(0.0, pow(-1, presenting ? 1 : 0) * travelDistance)
        
        toView?.alpha = 0;
        toView?.transform = CGAffineTransformInvert(travel);
        
        // Perform animations
        UIView.animateWithDuration(self.transitionDuration(transitionContext),
            animations: {
                
                // Perform views movement
                fromView?.transform = travel
                toView?.transform = CGAffineTransformIdentity

                // Animate opacity of views
                for subview in containerView.subviews {
                    subview.alpha = self.presenting ? 1.0 : 0.0
                }
            }, completion: { finished in 
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        })
    }
}