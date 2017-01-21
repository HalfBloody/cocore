//
//  AdjustableVerticalDecorator.swift
//  Cocore
//
//  Created by Dmitry Shashlov on 10/04/16.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation
import UIKit

public protocol AdjustableVerticalDecorator {
    func totalVerticalAdjustment() -> CGFloat
}