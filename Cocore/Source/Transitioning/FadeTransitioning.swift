//
//  FadeTransitioning.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 04/04/16.
//  Copyright © 2016 Dmitry Shashlov. All rights reserved.
//

import Foundation
import UIKit

class FadeTransitioning : NSObject, UIViewControllerTransitioningDelegate {
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PushFadeAnimator()
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PopFadeAnimator()
    }
}