//
//  RootViewController.swift
//  Cocore
//
//  Created by Dmitry Shashlov on 1/16/17.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation

// MARK: Custom split view controller which allows only landscape orientation

public class RootViewController : UIViewController {
    override public func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
}