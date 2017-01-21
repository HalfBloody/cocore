//
//  UIWebView+UserAgent.swift
//  PrizeArena
//
//  Created by Dmitry Shashlov on 16/03/16.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation
import UIKit

extension UIWebView {
    public func userAgent() -> String {
        return stringByEvaluatingJavaScriptFromString("navigator.userAgent")!
    }
}
