//
//  ApplicationSettings.swift
//  PrizeArena
//
//  Created by Dmitry Shashlov on 07/03/16.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation
import Cocore

public class ApplicationSettings : DebugableContent {

    public static let settings = NSDictionary(contentsOfFile:
        NSBundle.mainBundle().pathForResource("ApplicationSettings", ofType: "plist")!)!

    // MARK: Backend
    
    public class var baseUrl: String {
        return settings.valueForKey("baseUrl") as! String
    }
    
    public class var staticBaseUrl: String {
        return settings.valueForKey("staticBaseUrl") as! String
    }
    
    public class var apiBaseUrl: String {
        return baseUrl + (settings.valueForKey("apiPath") as! String)
    }

    // MARK: Sentry (Raven)

    public class var sentryDSN: String {
        return settings.valueForKey("sentryDSN") as! String
    }

    // MARK: Papertrail
    
    public class var papertrailHost: String {
        return settings.valueForKey("papertrailHost") as! String
    }
    
    public class var papertrailPort: UInt {
        return settings.valueForKey("papertrailPort") as! UInt
    }
    
    // MARK: Helpshift
    
    public class var helpshiftAPIKey: String {
        return settings.valueForKey("helpshiftAPIKey") as! String
    }
    
    public class var helpshiftDomainName: String {
        return settings.valueForKey("helpshiftDomainName") as! String
    }
    
    public class var helpshiftAppID: String {
        return settings.valueForKey("helpshiftAppID") as! String
    }

    // MARK: OneSignal
    
    public class var oneSignalAppID: String {
        return settings.valueForKey("oneSignalAppID") as! String
    }

    // MARK: UXCam

    public class var uxcamKey: String {
        return settings.valueForKey("uxcamKey") as! String
    }

    // MARK: DebugableContent conformance

    public class func publicData() -> [String : AnyObject]? {
        return [
            "base_url" : ApplicationSettings.baseUrl,
            "static_base_url" : ApplicationSettings.staticBaseUrl,
            "api_base_url" : ApplicationSettings.apiBaseUrl,
        ]
    }

    public class func privateData() -> [String : AnyObject]? {
        return [
            // Sentry
            "sentry_dsn" : ApplicationSettings.sentryDSN,

            // Papertrail
            "papertrail_host" : ApplicationSettings.papertrailHost,
            "papertrail_port" : ApplicationSettings.papertrailPort,

            // HelpShift
            "helpshift_api_key" : ApplicationSettings.helpshiftAPIKey,
            "helpshift_domain_name" : ApplicationSettings.helpshiftDomainName,
            "helpshift_app_id" : ApplicationSettings.helpshiftAppID,

            // OneSignal
            "onesignal_app_id" : ApplicationSettings.oneSignalAppID,

            // UXCam
            "uxcam_key" : ApplicationSettings.uxcamKey
        ]
    }
}