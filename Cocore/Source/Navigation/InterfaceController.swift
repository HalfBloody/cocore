//
//  InterfaceController.swift
//  Cocore
//
//  Created by Dmitry Shashlov on 10/04/16.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//
import Foundation
import UIKit
import SwiftState

// MARK: Interface controller

public protocol InterfaceController {
    
    /// Window
    var window: UIWindow { get }
    
    /// Present interface controller on window
    func takeControlOverPresentation(animated animated: Bool) throws
    
    /// Focus on navigation controller
    func focus(navigationController: AnyCustomNavigationController, animated: Bool)
    
    /// Present modal controller
    func presentModalController(viewController: UIViewController, animated: Bool)
    
    // Dismiss modal controller
    func dismissModalController(animated: Bool)
}

public class AbstractInterfaceController : AbstractDisposableHolder, InterfaceController {
    
    public var _presented = false
    public let window: UIWindow
    
    public internal(set) var currentNavigationController: AnyCustomNavigationController?
    public var modalControllerPresenter: UIViewController?

    // MARK: ----
    
    public init(window: UIWindow) {
        self.window = window
    }
        
    /*final*/ public func focus(navigationController: AnyCustomNavigationController, animated: Bool = false) {
        
        // First present navigation controller
        if _presented {
            presentNavigationController(navigationController, animated: animated)
        }
        
        // Then store reference to it
        self.currentNavigationController = navigationController
    }
    
    /*final*/ public func takeControlOverPresentation(animated animated: Bool) throws {
        
        guard case false = _presented else {
            throw InterfaceControllerError.AlreadyPresented
        }
        
        guard let navigationController = currentNavigationController else {
            throw InterfaceControllerError.MissingRepresentation
        }
        
        // Configure transition handlers
        configureInterfaceTransitionHandlers()
        
        // Present current navigation controller
        presentNavigationController(navigationController, animated: animated)

        // Present
        present()        
    }
    
    // MARK: Internal
    
    public func present() {
        _presented = true
    }
    
    public func configureInterfaceTransitionHandlers() {
        // Nothing here, override by subclasses
    }
    
    public func presentNavigationController(navigationController: AnyCustomNavigationController, animated: Bool) {
        window.rootViewController = navigationController.viewController()
    }
    
    // MARK: Modal controller

    public func presentModalController(
        viewController: UIViewController,
        animated: Bool = true) {
        self.presentModalController(viewController, animated: animated, modalControllerPresenterOverride: nil, modalTransitionStyle: nil, completion: nil)
    }
    
    public func presentModalController(
        viewController: UIViewController,
        animated: Bool = true,
        modalControllerPresenterOverride: UIViewController?,
        modalTransitionStyle: UIModalTransitionStyle?,
        completion: (() -> ())?) {
        
        if let controllerPresenter = modalControllerPresenterOverride ?? _modalControllerPresenter() {

            // Modal transition style
            if let modalTransitionStyle = modalTransitionStyle {
                viewController.modalTransitionStyle = modalTransitionStyle
            }

            controllerPresenter.presentViewController(viewController, animated: animated) {
                self.modalControllerPresenter = controllerPresenter
                completion?()
            }
        }
    }
    
    public func dismissModalController(animated: Bool = true) {
        dismissModalController(animated, completion: nil)
    }

    public func dismissModalController(animated: Bool = true, completion: (() -> ())?) {
        let controllerPresenter = modalControllerPresenter
        controllerPresenter?.dismissViewControllerAnimated(animated) {
            if self.modalControllerPresenter == controllerPresenter {
                self.modalControllerPresenter = nil
                completion?()
            }
        }
    }
    
    public func _modalControllerPresenter() -> UIViewController? {
        return currentNavigationController?.viewController()
    }
}

// MARK: Modal controller presentation

extension AbstractInterfaceController {

    public func presentModalController(
        viewController: UIViewController,
        animated: Bool,
        transitioning: UIViewControllerTransitioningDelegate?) {

        // Transitioning
        viewController.transitioningDelegate = transitioning
        viewController.modalPresentationStyle = .Custom

        // Push view controller on top of navigator's stack
        dispatch_async(dispatch_get_main_queue()) {
            self.presentModalController(viewController,
                                         animated: animated,
                                         modalControllerPresenterOverride: nil,
                                         modalTransitionStyle: nil) {
                                            viewController.transitioningDelegate = nil
            }
        }

    }

    public func dismissModalController(
        animated: Bool,
        transitioning: UIViewControllerTransitioningDelegate?) {

        if let hostController = modalControllerPresenter,
            intentController = hostController.presentedViewController {

            // Transitioning
            intentController.transitioningDelegate = transitioning
            hostController.modalPresentationStyle = .Custom

            // Push view controllre on top of navigator's stack
            dispatch_async(dispatch_get_main_queue()) {
                self.dismissModalController(animated) {
                    intentController.transitioningDelegate = nil
                }
            }
        }
    }

}

// MARK: Interface controller error

public enum InterfaceControllerError : ErrorType {
    case MissingRepresentation
    case NotInControl
    case AlreadyPresented
    case UnknownPresentation
}