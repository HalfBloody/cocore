//
//  UserAgent.swift
//  PrizeArena
//
//  Created by Dmitry Shashlov on 16/03/16.
//  Copyright © 2016 Half Bloody. All rights reserved.
//

import Foundation
import UIKit

extension UIWebView {
    func userAgent() -> String {
        return stringByEvaluatingJavaScriptFromString("navigator.userAgent")!
    }
}
