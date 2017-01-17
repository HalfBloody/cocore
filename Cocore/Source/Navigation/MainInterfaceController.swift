//
//  MainInterfaceController.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 10/04/16.
//  Copyright © 2016 Dmitry Shashlov. All rights reserved.
//
import Foundation
import UIKit
import SwiftState

public class MainInterfaceController : AbstractInterfaceController {

    // MARK: Transitionings

    public let alertTransitioning = AlertTransitioning()
    public internal(set) var slideTransitioning = SlideTransitioning()
    public let fadeTransitioning = FadeTransitioning()

    // MARK: ----
    
    override public func takeControlOverPresentation(animated animated: Bool) throws {
        
        // Focus on navigator for initial appNavigator state
        try _focusInitialNavigationController()
        
        // Present interface controller on window
        try super.takeControlOverPresentation(animated: animated)

        // Setup initial controller
        try _setupInitialController()
    }

    /// Basically means to present focused navigation controller on window
    public func _focusInitialNavigationController() throws {
        // Nothing here, override in subclasses
    }
    
    public func _setupInitialController() throws {
        // Nothing here, override in subclasses
    }
}

// MARK: Alert

extension MainInterfaceController {

    override public func presentModalController(viewController: UIViewController, animated: Bool = true) {
        presentModalController(viewController, animated: animated, transitioning: self.alertTransitioning)
    }

    override public func dismissModalController(animated: Bool = true) {
        dismissModalController(animated, transitioning: self.alertTransitioning)
    }

}

// MARK: Menu

extension MainInterfaceController {

    public func presentMenuController(viewController: UIViewController, animated: Bool, completion: (() -> ())? = nil) {

        // Transitioning
        viewController.transitioningDelegate = self.slideTransitioning
        viewController.modalPresentationStyle = .OverFullScreen

        // Push view controller on top of navigator's stack
        _modalControllerPresenter()?.presentViewController(viewController, animated: animated, completion: {
            viewController.transitioningDelegate = nil
            completion?()
        })

    }

    public func dismissMenuController(animated: Bool, completion: (() -> ())? = nil) {

        if let hostController = _modalControllerPresenter(),
            intentController = hostController.presentedViewController {

            // Transitioning
            hostController.transitioningDelegate = self.slideTransitioning
            hostController.modalPresentationStyle = .OverFullScreen

            // Push view controllre on top of navigator's stack
            intentController.dismissViewControllerAnimated(animated, completion: {
                intentController.transitioningDelegate = nil
                completion?()
            })
        }
    }
}

// MARK: Slide replace transitions 

extension MainInterfaceController {

    public func _performBaseReplaceTransition(intentController: UIViewController, dismiss: Bool = false) {

        let transitionController = OrientationLockedViewController()
        transitionController.view.translatesAutoresizingMaskIntoConstraints = false

        //// MODAL CONTROLLER

        if let modalController = window.rootViewController?.presentedViewController {
            modalController.takeSnapshot()

            // Intent snapshot image
            let modalSnapshotImage = modalController.snapshotImage
            let modalSnapshotImageView = UIImageView(image: modalSnapshotImage)
            modalSnapshotImageView.frame = modalController.view.frame

            // Add snapshot image view
            transitionController.view.addSubview(modalSnapshotImageView)
        }

        //// TARGET INTENT CONTROLLER

        // Temporarily add targetIntentController to rootViewController to adjust appearance
        let targetIntentController = intentController.navigationController ?? intentController

        if !dismiss {
            window.rootViewController?.view.addSubview(targetIntentController.view)
        }

        // Remove targetIntentController from rootViewController
        targetIntentController.view.removeFromSuperview()
        targetIntentController.view.hidden = false

        // Intent snapshot image
        let scale = UIScreen.mainScreen().scale
        let statusBarFrame = /*CGRect(x: 0, y: 0, width: 320, height: 20)*/(UIApplication.sharedApplication().delegate as! AppDelegate).statusBarFrame
        let snapshotImage = targetIntentController.takeSnapshot()
        let snapshotImageView = UIImageView(image: snapshotImage)
        snapshotImageView.frame = CGRect(x: 0, y: UIApplication.sharedApplication().statusBarHidden ? statusBarFrame.size.height : 0.0, width: snapshotImage.size.width / scale, height: snapshotImage.size.height / scale)

        // Add snapshot image view
        transitionController.view.addSubview(snapshotImageView)

        // Calculate travel distance for snapshotImageView
        let travelDistance = UIScreen.mainScreen().bounds.size.width * 0.75
        let travel = CGAffineTransformMakeTranslation(travelDistance, 0.0)
        snapshotImageView.transform = travel

        // Add status bar snapshot
        let statusBarView: UIView!
        let statusBarContainerView = UIView(frame: CGRect(x: 0, y: 0, width: snapshotImage.size.width / scale, height: statusBarFrame.size.height))
        statusBarContainerView.clipsToBounds = true

        // Add status bar or palceholder for it
        switch UIDevice.currentDevice().model {

        // Phone
        case let phoneOrPod
            where phoneOrPod.hasPrefix("iPhone")
                || phoneOrPod.hasPrefix("iPod"):

            statusBarView = /*UIScreen.mainScreen().snapshotViewAfterScreenUpdates(false)*/(UIApplication.sharedApplication().delegate as! AppDelegate).statusBarSnapshot!

            // Manually setup snapshot bounds (when using snapshot from scale == 2 for interface with scale == 3)
            statusBarView.frame = CGRect(x: travelDistance, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: UIScreen.mainScreen().bounds.size.height)

            statusBarContainerView.addSubview(statusBarView)

        // All other
        case let pad
            where pad.hasPrefix("iPad"):

            statusBarView = UIView(frame: statusBarContainerView.bounds)
            statusBarView.backgroundColor = Colors.blue
            statusBarView.frame = CGRect(x: travelDistance, y: 0, width: statusBarContainerView.frame.size.width, height: statusBarContainerView.frame.size.height)
            statusBarContainerView.addSubview(statusBarView)

        // Not implemented
        default:
            fatalError("Not implemented yet!")
        }

        transitionController.view.addSubview(statusBarContainerView)

        // Dismiss modal controller
        window.rootViewController?.dismissViewControllerAnimated(false, completion: nil)

        // Assign transition controller as window's root controller
        window.rootViewController = transitionController

        UIView.animateWithDuration(0.33,
                                   animations: {

                                    // Animate snapshot image view
                                    snapshotImageView.transform = CGAffineTransformIdentity
                                    statusBarView.frame = UIScreen.mainScreen().bounds

            }, completion: { finished in

                UIApplication.sharedApplication().statusBarHidden = false
                self.window.rootViewController = targetIntentController
        })

    }

    public func _performSlideReplaceTransition(intentController: UIViewController) {

        // TRANSITION_CONTROL4LER
        let transitionController = OrientationLockedViewController()
        transitionController.view.translatesAutoresizingMaskIntoConstraints = false
        transitionController.view.backgroundColor = UIColor.blackColor()

        // HOST_CONTROLLER
        let hostController = window.rootViewController ?? OrientationLockedViewController()

        let hostImage = hostController.takeSnapshot()
        let hostSnapshot = UIImageView(image: hostImage)
        hostSnapshot.frame = hostController.view.bounds

        transitionController.view.addSubview(hostSnapshot)

        // HOST_CONTROLLER - MODAL PRESENTED CONTROLLER

        var hostModalSnapshot: UIImageView?
        if let hmc = hostController.presentedViewController {
            hostModalSnapshot = UIImageView(image: hmc.takeSnapshot())
            hostModalSnapshot!.frame = hmc.view.frame

            // Blurred view
            let blurredView = UIView(frame: hmc.view.frame)
            blurredView.backgroundColor = UIColor(rgb: 0x282b2d, alphaVal: 0.8)
            transitionController.view.addSubview(blurredView)

            transitionController.view.addSubview(hostModalSnapshot!)
        }

        // INTENT_CONTROLLER
        let intentController = intentController.navigationController ?? intentController

        // FIXME: this ugly check - it checks whether intentController was adopted app's appearance (colors, fonts, etc..)
        let uglyCheck = (intentController as? UINavigationController)?.navigationBar.barTintColor == Colors.blue ?? false
        if !uglyCheck {
            //      if !intentController.isViewLoaded() {
            if let pvc = window.rootViewController?.presentedViewController {
                pvc.view.addSubview(intentController.view)
            } else {
                window.rootViewController?.view.addSubview(intentController.view)
            }
        }

        let intentImage = intentController.takeSnapshot()

        if !uglyCheck {
            intentController.view.removeFromSuperview()
        }

        let intentSnapshot = UIImageView(image: intentImage)
        intentSnapshot.frame = intentController.view.frame

        transitionController.view.addSubview(intentSnapshot)

        intentSnapshot.transform = CGAffineTransformMakeTranslation(intentSnapshot.bounds.size.width, 0.0)

        //

        window.rootViewController = transitionController

        UIView.animateWithDuration(0.33,
                                   animations: {

                                    // INTENT
                                    intentSnapshot.transform = CGAffineTransformIdentity

                                    // HOST
                                    hostSnapshot.alpha = 0.0
                                    hostSnapshot.transform = CGAffineTransformMakeScale(0.75, 0.75)

                                    hostModalSnapshot?.alpha = 0.0
                                    hostModalSnapshot?.transform = CGAffineTransformMakeScale(0.75, 0.75)

            }, completion: { finished in

                self.window.rootViewController = intentController
        })
    }
    
}