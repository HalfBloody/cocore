//
//  AdHelper.swift
//  Cocore
//
//  Created by Dmitry Shashlov on 1/12/17.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation
import AdSupport

public class AdHelper {

    // MARK: Public

    public static var adTrackingEnabled: Bool? {
        get {
            return _getAdManagerSafe()?.advertisingTrackingEnabled
        }
    }

    public static var adIdentifier: NSUUID? {
        get {
            return _getAdIdentifierSafe()
        }
    }

    // MARK: Private

    private static func _getAdManagerSafe() -> ASIdentifierManager? {

        let message = "Advertisement manager cannot be determined"

        guard let adManager = ASIdentifierManager.sharedManager() else {
            DDLogError("\(message): `ASIdentifierManager.sharedManager()` is nil")
            return nil
        }

        return adManager
    }

    private static func _getAdIdentifierSafe() -> NSUUID? {

        let message = "Advertisement identifier cannot be determined"

        // If manager is nil then identifier would also be nil, error logged from _getAdManagerSafe()
        guard let adManager = _getAdManagerSafe() else {
            return nil
        }

        guard let adIdentifier = adManager.advertisingIdentifier else {
            DDLogError("\(message): `ASIdentifierManager.sharedManager().advertisingIdentifier` is nil")
            return nil
        }

        return adIdentifier
    }
}