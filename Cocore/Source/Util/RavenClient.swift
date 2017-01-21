//
//  RavenClient.swift
//  Cocore
//
//  Created by Dmitry Shashlov on 10/04/16.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//
import Foundation
import Raven

public protocol RavenClientFabric {
    func ravenClient() -> RavenClientProtocol
}

public protocol RavenClientProtocol {
    func message(level: RavenClientCocore.RLogLevel, text: String, data: [String: AnyObject]?)
}

public class RavenClientCocore : RavenClient, RavenClientProtocol {
    
    public enum RLogLevel {
        case Info
        case Warning
        case Error
        case Fatal
    }
    
    public func message(level: RLogLevel, text: String, data: [String: AnyObject]?) {
        
        // Log level
        let ravenLevel: RavenLogLevel
        switch level {
        case RavenClientCocore.RLogLevel.Info: ravenLevel = kRavenLogLevelDebugInfo
        case RavenClientCocore.RLogLevel.Warning: ravenLevel = kRavenLogLevelDebugWarning
        case RavenClientCocore.RLogLevel.Error: ravenLevel = kRavenLogLevelDebugError
        case RavenClientCocore.RLogLevel.Fatal: ravenLevel = kRavenLogLevelDebugFatal
        }
        
        // Basic extras
        var extra = [String: AnyObject]()

        // Append extra fro arguments
        if let data = data {
            for (key, value) in data {
                extra[key] = value
            }
        }
        
        // Message
        captureMessage(text,
                       level: ravenLevel,
                       additionalExtra: extra,
                       additionalTags: nil)
    }
}