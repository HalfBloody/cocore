//
//  TabletNavigationController.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 10/04/16.
//  Copyright © 2016 Dmitry Shashlov. All rights reserved.
//
import Foundation
import UIKit

// MARK: Custom navigation controller 

/**
 * About:
 *  - details controller should always be UINavigationController
 */
public class TabletNavigationController : UISplitViewController, CustomNavigationController {
    
    /// Navigation controller for details on split view controller
    let detailsNavigationController = UINavigationController()

    var mainOnly: Bool! {
        didSet {
            if mainOnly! {
                self.preferredPrimaryColumnWidthFraction = 1.0
            } else {
                self.preferredPrimaryColumnWidthFraction = 0.5
            }
            
            view.setNeedsLayout()
            view.layoutIfNeeded()
        }
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil) // UISplitViewController's designated init
        
        // Max column width
        self.maximumPrimaryColumnWidth = CGFloat(MAXFLOAT)
        
        // Take full width of allowed space
        mainOnly = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Background color
        view.backgroundColor = Colors.background
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Update display mode
        self._updatePreferredDisplayMode()
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // FIXME: Without calling this two lines primary column's controller doesn't want to fill space given to it on iOS 8
        // pushViewController(UIViewController(), animated: false)
        // popViewControllerAnimated(false)
    }
    
    // MARK: View controller
    
    public func viewController() -> UIViewController {
        return self
    }
    
    // MARK: Push / pop navigation
    
    public func pushViewController(viewController: UIViewController, animated: Bool, transitioning: UIViewControllerAnimatedTransitioning?) {
        
        // Present details on UISplitViewController if navigation stack was empty before
        if viewControllers.count == 0 {
            mainOnly = true
            viewControllers = [ viewController ]
        } else {
            
            var animated = animated
            if viewControllers.count == 1 {
                mainOnly = false
                viewControllers = [ viewControllers.first!, detailsNavigationController ]
                animated = false
            } else {
                mainOnly = true
            }
            
            // Push view controller onto detail's navigation stack
            detailsNavigationController.pushViewController(viewController, animated: animated, transitioning: transitioning)
        }
        
        // Update display mode
        self._updatePreferredDisplayMode()
    }
    
    public func popViewControllerAnimated(animated: Bool, transitioning: UIViewControllerAnimatedTransitioning?) -> UIViewController? {
        
        // If details navigation controller contains only last controller hide detail controller on UISplitVIewController
        // completely, otherwise only pop last controller from detail's navigation stack
        var result: UIViewController? = nil
        if detailsNavigationController.viewControllers.count == 1 {
            result = popToRootViewControllerAnimated(animated)!.last
        } else {
            result = detailsNavigationController.popViewControllerAnimated(animated, transitioning: transitioning)
        }
        
        // Update display mode
        self._updatePreferredDisplayMode()
        
        return result
    }
    
    public func popToRootViewControllerAnimated(animated: Bool) -> [UIViewController]? {
        
        // Don't pop is split view controller is not configured properly yet
        guard case let cc = viewControllers.count
            where cc > 0 else {
            return nil
        }
        
        // Remove all view controllers from detailsNavigationController navigation stack
        let poppedControllers = detailsNavigationController.viewControllers
        detailsNavigationController.viewControllers.removeAll()
        
        // Show primary column only
        mainOnly = true
        
        // Show only main controller on split view controller
        viewControllers = [ viewControllers.first! ]
        
        // Update display mode
        self._updatePreferredDisplayMode()
        
        return poppedControllers
    }
    
    private func _updatePreferredDisplayMode() {
        
        let displayMode: UISplitViewControllerDisplayMode = {
            switch (viewControllers.count, detailsNavigationController.viewControllers.count) {
                
                case (_, let ncc) where ncc <= 1:
                    return .AllVisible
                case (let cc, _) where cc > 1:
                    return .PrimaryHidden
                    
                default:
                    return self.preferredDisplayMode
                
            }
        }()
        
        if displayMode != self.preferredDisplayMode {
            self.preferredDisplayMode = displayMode
        }

    }
    
}