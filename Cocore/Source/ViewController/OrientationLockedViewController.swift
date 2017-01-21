//
//  OrientationLockedViewController.swift
//  Cocore
//
//  Created by Dmitry Shashlov on 1/15/17.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation

// MARK: Orientation locked view controller

public class OrientationLockedViewController : UIViewController {
    override public func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        switch UIDevice.currentDevice().userInterfaceIdiom {
        case .Pad:
            return .Landscape
        default:
            return .Portrait
        }
    }
}