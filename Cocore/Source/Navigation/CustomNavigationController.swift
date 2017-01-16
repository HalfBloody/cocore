//
//  CustomNavigationController.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 10/04/16.
//  Copyright © 2016 Dmitry Shashlov. All rights reserved.
//
import Foundation
import UIKit

// MARK: Custom navigation controller 

protocol CustomNavigationController {
    
    /// Push view controller
    func pushViewController(viewController: UIViewController, animated: Bool, transitioning: UIViewControllerAnimatedTransitioning?)
    
    /// Pop view controller
    func popViewControllerAnimated(animated: Bool, transitioning: UIViewControllerAnimatedTransitioning?) -> UIViewController?
    
    /// Pop to root view controller, no transitioning yet
    func popToRootViewControllerAnimated(animated: Bool) -> [UIViewController]?
    
    func viewController() -> UIViewController
}

struct AnyCustomNavigationController : CustomNavigationController, Hashable {
    let _pushViewController: (UIViewController, Bool, UIViewControllerAnimatedTransitioning?) -> ()
    let _popViewControllerAnimated: (Bool, UIViewControllerAnimatedTransitioning?) -> UIViewController?
    let _viewController: () -> UIViewController
    let _popToRootViewControllerAnimated: (Bool) -> [UIViewController]?
    
    // Hashable
    let hashValue: Int
    
    init<T: CustomNavigationController where T: Hashable>(_ navigationController: T) {
        _pushViewController = navigationController.pushViewController
        _popViewControllerAnimated = navigationController.popViewControllerAnimated
        _viewController = navigationController.viewController
        _popToRootViewControllerAnimated = navigationController.popToRootViewControllerAnimated
        hashValue = navigationController.hashValue
    }
    
    func pushViewController(viewController: UIViewController, animated: Bool, transitioning: UIViewControllerAnimatedTransitioning?) {
        _pushViewController(viewController, animated, transitioning)
    }
    
    func popViewControllerAnimated(animated: Bool, transitioning: UIViewControllerAnimatedTransitioning?) -> UIViewController? {
        return _popViewControllerAnimated(animated, transitioning)
    }
    
    func viewController() -> UIViewController {
        return _viewController()
    }
    
    func popToRootViewControllerAnimated(animated: Bool) -> [UIViewController]? {
        return _popToRootViewControllerAnimated(animated)
    }
}

func ==(left: AnyCustomNavigationController, right: AnyCustomNavigationController) -> Bool {
    return left.hashValue == right.hashValue
}

// MARK: OBJC Association

func associatedObject<ValueType: AnyObject>(base: AnyObject, key: UnsafePointer<UInt8>) -> ValueType? {
    return objc_getAssociatedObject(base, key) as? ValueType
}

func associateObject<ValueType: AnyObject>(base: AnyObject, key: UnsafePointer<UInt8>, value: ValueType?) {
    objc_setAssociatedObject(base, key, value, .OBJC_ASSOCIATION_RETAIN)
}

// MARK: UINavigationController

extension UINavigationController : CustomNavigationController, UINavigationControllerDelegate {
    
    // MARK: Transitioning
    
    private static var __currentTransitioningKey: UInt8 = 0
    private var __currentTransitioning: UIViewControllerAnimatedTransitioning? {
        get {
            return associatedObject(self, key: &UINavigationController.__currentTransitioningKey)
        }
        set {
            associateObject(self, key: &UINavigationController.__currentTransitioningKey, value: newValue)
        }
    }
    
    // MARK: --
    
    func viewController() -> UIViewController {
        return self
    }
    
    // MARK: Push / pop
    
    func pushViewController(viewController: UIViewController, animated: Bool, transitioning: UIViewControllerAnimatedTransitioning?) {
        delegate = self
        __currentTransitioning = transitioning
        pushViewController(viewController, animated: animated)
    }
    
    func popViewControllerAnimated(animated: Bool, transitioning: UIViewControllerAnimatedTransitioning?) -> UIViewController? {
        delegate = self
        __currentTransitioning = transitioning
        return popViewControllerAnimated(animated)
    }
    
    // MARK: UINavigationControllerDelegate
    
    public func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return __currentTransitioning
    }
    
    public func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        
        __currentTransitioning = nil
        delegate = nil
    }
}