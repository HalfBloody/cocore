//
//  FadeTransitioning.swift
//  Cocore
//
//  Created by Dmitry Shashlov on 04/04/16.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation
import UIKit

public class FadeTransitioning : NSObject, UIViewControllerTransitioningDelegate {
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PushFadeAnimator()
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PopFadeAnimator()
    }
}