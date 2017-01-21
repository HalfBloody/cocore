//
//  SlideTransitioning.swift
//  Cocore
//
//  Created by Dmitry Shashlov on 04/04/16.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation
import UIKit

public class SlideTransitioning : NSObject, UIViewControllerTransitioningDelegate { 
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideAnimator(presenting: true)
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideAnimator(presenting: false)
    }
}