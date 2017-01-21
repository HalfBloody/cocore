//
//  SnapshotableController.swift
//  Cocore
//
//  Created by Dmitry Shashlov on 04/04/16.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation
import UIKit

public protocol SnapshotableController {
    var snapshotImage: UIImage? { get set }
    func takeSnapshot() -> UIImage
}

public protocol SnapshotPreAdjustable {
    func adjustBeforeSnapshoting()
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
                if let vc = nc.viewControllers.first {
                    vc.view.layoutIfNeeded()
                    if let vcp = vc as? SnapshotPreAdjustable {
                        vcp.adjustBeforeSnapshoting()
                    }
                }
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