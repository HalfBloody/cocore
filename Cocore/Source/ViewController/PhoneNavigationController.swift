//
//  PhoneNavigationController.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 1/15/17.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation

// MARK: Phone navigation controller

public class PhoneNavigationController : UINavigationController {
    override public func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
}