//
//  UserDefaults.swift
//  PrizeArena
//
//  Created by Dmitry Shashlov on 06/03/16.
//  Copyright © 2016 Half Bloody. All rights reserved.
//

import Foundation
import Cocore
import UIKit

public class UserDefaults {

    private static let _firstLaunch = "firstLaunch"

    // MARK: Is first launch
    
    public static var firstLaunch: Bool {
        get { return defaults.valueForKey(_firstLaunch) as? Bool ?? true }
        set { defaults.setValue(newValue, forKey: _firstLaunch); defaults.synchronize() }
    }

    // Private
    
    public class var defaults: NSUserDefaults {
        return NSUserDefaults.standardUserDefaults()
    }
}