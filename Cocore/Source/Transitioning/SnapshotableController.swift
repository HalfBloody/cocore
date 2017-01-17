//
//  SnapshotableController.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 04/04/16.
//  Copyright © 2016 Dmitry Shashlov. All rights reserved.
//

import Foundation
import UIKit

public protocol SnapshotableController {
    var snapshotImage: UIImage? { get set }
    func takeSnapshot() -> UIImage
}

private var xoAssociationKey: UInt8 = 0

extension UIViewController: SnapshotableController { 
    
    public var snapshotImage: UIImage? {
        get {
            return objc_getAssociatedObject(self, &xoAssociationKey) as? UIImage
        }
        set(newValue) {
            objc_setAssociatedObject(self, &xoAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    public func takeSnapshot() -> UIImage {
        let scale = UIScreen.mainScreen().scale
        UIGraphicsBeginImageContext(CGSize(width: view.bounds.size.width * scale, height: view.bounds.size.height * scale))
        if let context = UIGraphicsGetCurrentContext() {        
            CGContextScaleCTM(context, scale, scale)
            
            // Render controller's view
            if let nc = self as? UINavigationController {
                nc.viewControllers.first?.view.layoutIfNeeded()
                /* TODO: dependency injection
                if let tlc = nc.viewControllers.first as? TaskListController {
                    tlc.taskCategorySegmentedControl?.selectCell(tlc.taskCategorySegmentedControl?.selectedIndex() ?? 0, animate: false)
                }
                 */
                view.layer.renderInContext(context)
            } else if let navigationController = navigationController {
                navigationController.view.layer.renderInContext(context)
            } else {
                view.layer.renderInContext(context)
            }
            
            snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        
        /*
        let imagePath = "\(NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0])/\(NSDate()).png"
        UIImagePNGRepresentation(snapshotImage!)?.writeToFile(imagePath, atomically: true)
        printd("Snapshot debug: \(imagePath)")
        */
        
        return snapshotImage!
    }
}