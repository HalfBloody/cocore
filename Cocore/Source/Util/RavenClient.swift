//
//  RavenClient.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 10/04/16.
//  Copyright © 2016 Dmitry Shashlov. All rights reserved.
//
import Foundation
import Raven

extension RavenClient {
    
    public enum RLogLevel {
        case Info
        case Warning
        case Error
        case Fatal
    }
    
    class func message(level: RLogLevel, text: String, data: [String: AnyObject]?) {
        
        // Log level
        let ravenLevel: RavenLogLevel
        switch level {
        case RavenClient.RLogLevel.Info: ravenLevel = kRavenLogLevelDebugInfo
        case RavenClient.RLogLevel.Warning: ravenLevel = kRavenLogLevelDebugWarning
        case RavenClient.RLogLevel.Error: ravenLevel = kRavenLogLevelDebugError
        case RavenClient.RLogLevel.Fatal: ravenLevel = kRavenLogLevelDebugFatal
        }
        
        // Basic extras
        var extra = [String: AnyObject]()
        
        // Current user's IDFA
        if let currentUser = UserModel.currentUser {
            extra["user_id"] = currentUser.id
            extra["user_idfa"] = currentUser.idfa
            extra["user_credits"] = currentUser.credits
        }
        
        // Append extra fro arguments
        if let data = data {
            for (key, value) in data {
                extra[key] = value
            }
        }
        
        // Message
        RavenClient.sharedClient()
            .captureMessage(text,
                            level: ravenLevel,
                            additionalExtra: extra,
                            additionalTags: nil)
    }
}