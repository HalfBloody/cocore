//
//  SlideAnimator.swift
//  Cocore
//
//  Created by Dmitry Shashlov on 04/04/16.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation
import UIKit

public class SlideAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    
    let presenting: Bool
    
    init(presenting: Bool) {
        self.presenting = presenting
    }
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.33
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        printd("SLIDE \(presenting ? "PRESENTING" : "DISMISSING")")
                
        //  View controllers
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        
        // Get snapshot controller
        var snapshotController: SnapshotableController! = (presenting ? fromViewController : toViewController) as? SnapshotableController
        snapshotController.takeSnapshot()
                
        ////
        
        let scale = UIScreen.mainScreen().scale
        let statusBarFrame = presenting ? UIApplication.sharedApplication().statusBarFrame : (UIApplication.sharedApplication().delegate as! AppDelegate).statusBarFrame
                        
        // Container view
        let containerView = transitionContext.containerView()!
        
        // Snapshot image view
        let snapshotImage = snapshotController.snapshotImage
        let snapshotImageView = UIImageView(image: snapshotImage)
        snapshotImageView.contentMode = .ScaleAspectFit
        snapshotImageView.frame = CGRect(x: 0, y: presenting ? statusBarFrame.size.height - 20 : statusBarFrame.size.height, width: (snapshotController as! UIViewController).view.bounds.size.width, height: (snapshotController as! UIViewController).view.bounds.size.height)
                
        // Calculate travel distance for snapshotImageView
        let travelDistance = transitionContext.containerView()!.bounds.size.width * 0.75
        let travel = CGAffineTransformMakeTranslation(travelDistance, 0.0)
        
        // Insert toView on containerView
        if presenting {
            containerView.addSubview(snapshotImageView)
            
            toViewController?.view.frame = snapshotImageView.bounds
            containerView.insertSubview(toViewController!.view, belowSubview: snapshotImageView)
        } else {
            containerView.addSubview(snapshotImageView)            
            snapshotImageView.transform = travel
        }
        
        // Get snapshot from main screen
        let statusBarView = presenting ? UIScreen.mainScreen().snapshotViewAfterScreenUpdates(false) : (UIApplication.sharedApplication().delegate as! AppDelegate).statusBarSnapshot!
        
        // Manually setup snapshot bounds (when using snapshot from scale == 2 for interface with scale == 3)
        statusBarView.frame = UIScreen.mainScreen().bounds
        
        // Create container view to clip status bar only
        let statusBarContainerView = UIView(frame: CGRect(x: 0, y: 0, width: snapshotImage!.size.width / scale, height: statusBarFrame.size.height))
        statusBarContainerView.clipsToBounds = true
        
        // Add status bar or palceholder for it
        switch UIDevice.currentDevice().model {
            
            // Phone
            case let phoneOrPod
                where phoneOrPod.hasPrefix("iPhone")
                    || phoneOrPod.hasPrefix("iPod"):
            
                statusBarContainerView.addSubview(statusBarView)
                
            // All other
            case let pad
                where pad.hasPrefix("iPad"):
            
                let statusBarDummyView = UIView(frame: statusBarContainerView.bounds)
                statusBarDummyView.backgroundColor = Colors.blue
                statusBarContainerView.addSubview(statusBarDummyView)
                
            // Not implemented
            default:
                fatalError("Not implemented yet!")
        }
        
        if !presenting {
            statusBarContainerView.transform = travel
        }
        
        // Add status bar view to animation container view
        containerView.addSubview(statusBarContainerView)
        
        // Hide status bar globally on application
        if presenting {
            (UIApplication.sharedApplication().delegate as! AppDelegate).statusBarSnapshot = statusBarView
            (UIApplication.sharedApplication().delegate as! AppDelegate).statusBarFrame = statusBarFrame
            UIApplication.sharedApplication().statusBarHidden = true
        }
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext),
            animations: {

                // Animate snapshot image view
                snapshotImageView.transform = self.presenting ? travel : CGAffineTransformIdentity
                statusBarContainerView.transform = self.presenting ? travel : CGAffineTransformIdentity
                
            }, completion: { finished in        
                
                // Hide status bar globally on application
                if !self.presenting {
                    UIApplication.sharedApplication().statusBarHidden = false
                }
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        })
            
    }
}