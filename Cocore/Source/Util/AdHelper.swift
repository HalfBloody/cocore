//
//  AdHelper.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 1/12/17.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation
import AdSupport

public class AdHelper {

    public static var advertisingTrackingEnabled: Bool {
        get {
            return ASIdentifierManager.sharedManager().advertisingTrackingEnabled
        }
    }

    public static var advertisingIdentifier: String {
        get {
            return ASIdentifierManager.sharedManager().advertisingIdentifier.UUIDString
        }
    }

}