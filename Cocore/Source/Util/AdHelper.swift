//
//  AdHelper.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 1/12/17.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation
import AdSupport

class AdHelper {

    static var advertisingTrackingEnabled: Bool {
        get {
            return ASIdentifierManager.sharedManager().advertisingTrackingEnabled
        }
    }

    static var advertisingIdentifier: String {
        get {
            return ASIdentifierManager.sharedManager().advertisingIdentifier.UUIDString
        }
    }

}