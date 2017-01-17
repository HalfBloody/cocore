//
//  AdjustableVerticalDecorator.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 10/04/16.
//  Copyright © 2016 Dmitry Shashlov. All rights reserved.
//

import Foundation
import UIKit

public protocol AdjustableVerticalDecorator {
    func totalVerticalAdjustment() -> CGFloat
}