//
//  Logger+Crashlytics.swift
//  Cocore
//
//  Created by Dmitry Shashlov on 1/17/17.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation
import Crashlytics
import CocoaLumberjack

// MARK: Crashlytics logger

public class CrashlyticsLogger : DDAbstractLogger {
    override public func logMessage(logMessage: DDLogMessage!) {
        CLSLogv("%@ %@ %@", getVaList([
            logMessage.level.description.uppercaseString,
            LogContext(rawValue: logMessage.context)!.description,
            logMessage.message]))
    }
}