//
//  RootViewController.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 1/16/17.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation

// MARK: Custom split view controller which allows only landscape orientation

class RootViewController : UIViewController {
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
}