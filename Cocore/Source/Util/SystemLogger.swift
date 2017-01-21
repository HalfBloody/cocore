//
//  SystemLogger.swift
//  Cocore
//
//  Created by Dmitry Shashlov on 1/12/17.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation

public func printd(items: Any...) {
    #if DEBUG
        print(items)
    #endif
}
