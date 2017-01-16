//
//  AlertTransitioning.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 04/04/16.
//  Copyright © 2016 Dmitry Shashlov. All rights reserved.
//

import Foundation
import UIKit

class AlertTransitioning : NSObject, UIViewControllerTransitioningDelegate { 
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AlertAnimator(presenting: true)
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AlertAnimator(presenting: false)
    }
}