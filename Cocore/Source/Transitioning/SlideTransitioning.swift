//
//  SlideTransitioning.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 04/04/16.
//  Copyright © 2016 Dmitry Shashlov. All rights reserved.
//

import Foundation
import UIKit

class SlideTransitioning : NSObject, UIViewControllerTransitioningDelegate { 
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideAnimator(presenting: true)
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideAnimator(presenting: false)
    }
}