//
//  Logger.swift
//  Cocore
//
//  Created by Dmitry Shashlov on 7/30/16.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation
import CocoaLumberjack
import PaperTrailLumberjack
import Raven
import SwiftState

public enum LogContext : NSInteger {
    
    // MARK: Events
    case EVNS = 1000    // system events
    case EVNA = 1001    // application events
    
    // MARK: Navigation
    case NAVT = 2000    // navigation transitions
    case NAVL = 2001    // deep linking route resolutions
    
    // MARK: Service
    case SRVB = 3000    // backend service endpoints / actions
    case SRVT = 3001    // third-party services endpoint / actions
    
    // MARK: User
    case UACT = 9000    // user actions
    
    // MARK: Unknown
    case UKNW = 0       // unknown context
}

extension LogContext : CustomStringConvertible {
    public var description: String {
        switch self {
            case EVNS: return "EVNS"
            case EVNA: return "EVNA"
            case NAVT: return "NAVT"
            case NAVL: return "NAVL"
            case SRVB: return "SRVB"
            case SRVT: return "SRVT"
            case UACT: return "UACT"
            case UKNW: return "UKNW"
        }
    }
}

// MARK: Custom Lumberjack-Papertrail formatter

public class CustomLogFormatter : RMSyslogFormatter {
    
    let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM dd HH:mm:ss"
        formatter.timeZone = NSTimeZone.systemTimeZone()
        return formatter
    }()
    
    override public func formatLogMessage(logMessage: DDLogMessage!) -> String! {
        
        let logLevel: String = {
            switch logMessage.flag {
                case DDLogFlag.Error: return "11"
                case DDLogFlag.Warning: return "12"
                case DDLogFlag.Info: return "14"
                case DDLogFlag.Verbose: fallthrough
                case DDLogFlag.Debug: fallthrough
                default: return "15"
            }
        }()
        
        let rawFormatter = CustomRawLogFormatter()
        return "<\(logLevel)>\(dateFormatter.stringFromDate(logMessage.timestamp)) \(machineName!) \(programName!) \(rawFormatter.formatLogMessage(logMessage))"
    }
}

// MARK: Custom console log formatter 

public class CustomRawLogFormatter : NSObject, DDLogFormatter {
    public func formatLogMessage(logMessage: DDLogMessage!) -> String! {
        
        // Log level color
        let logColor: String = {
            switch logMessage.flag {
                case DDLogFlag.Error: return "31"       // red
                case DDLogFlag.Warning: return "33"     // yellow
                case DDLogFlag.Info: return "34"        // blue
                case DDLogFlag.Verbose: fallthrough     // cyan
                case DDLogFlag.Debug: fallthrough       // cyan
                default: return "36"                    // cyan
            }
        }()
        
        // Define context
        var context = LogContext(rawValue: logMessage.context)
        if case .None = context {
            context = LogContext.UKNW
        }
        
        return "\u{001b}[\(logColor)m\(context!.description)\u{001b}[0m: \(logMessage.message)"
    }
}

// MARK: Log level description

extension DDLogLevel : CustomStringConvertible {
    public var description: String {
        switch self {
            case .Error: return "Error"
            case .Warning: return "Warning"
            case .Info: return "Info"
            case .Verbose: return "Verbose"
            case .Debug: return "Debug"
            default: return ""
        }
    }
}

// MARK: Public functions

// Debug

public func DDLogDebug(@autoclosure message: () -> String,
                                    context: LogContext = .UKNW,
                                    publicData: [String: AnyObject]? = nil,
                                    privateData: [String: AnyObject]? = nil) {
    DDLogDebug(message().localized().injectData(publicData, privateData), context: context.rawValue)
}

// Info

public func DDLogInfo(@autoclosure message: () -> String,
                                   context: LogContext = .UKNW,
                                   publicData: [String: AnyObject]? = nil,
                                   privateData: [String: AnyObject]? = nil) {
    DDLogInfo(message().localized().injectData(publicData, privateData), context: context.rawValue)
}

// Warning

public func DDLogWarn(@autoclosure message: () -> String,
                                   context: LogContext = .UKNW,
                                   publicData: [String: AnyObject]? = nil,
                                   privateData: [String: AnyObject]? = nil) {
    
    let message = message().localized()
    logRavenMessage(message, level: .Warning, publicData: publicData)
    DDLogWarn(message.injectData(publicData, privateData), context: context.rawValue)
}

// Verbose

public func DDLogVerbose(@autoclosure message: () -> String,
                                      context: LogContext = .UKNW,
                                      publicData: [String: AnyObject]? = nil,
                                      privateData: [String: AnyObject]? = nil) {
    DDLogVerbose(message().localized().injectData(publicData, privateData), context: context.rawValue)
}

// Error

public func DDLogError(@autoclosure message: () -> String,
                                    context: LogContext = .UKNW,
                                    publicData: [String: AnyObject]? = nil,
                                    privateData: [String: AnyObject]? = nil) {
    let message = message().localized()
    logRavenMessage(message, level: .Error, publicData: publicData)
    DDLogError(message.injectData(publicData, privateData), context: context.rawValue)
}

// MARK: Raven

public func logRavenMessage(message: String, level: RavenClientCocore.RLogLevel, publicData: [String: AnyObject]?) {

    guard let customRavenClient = UIApplication.sharedApplication().delegate as? RavenClientFabric else {
        RavenClientCocore.sharedClient().message(level, text: message, data: publicData)
        return
    }

    customRavenClient.ravenClient().message(level, text: message, data: publicData)
}

// MARK: Dictionary extension

extension Dictionary {
    public init(_ pairs: [Element]) {
        self.init()
        for (k, v) in pairs {
            self[k] = v
        }
    }
}

extension Dictionary where Value: AnyObject {
    public func plainDict() -> [Key: String] {
        let dict = Dictionary<Key, String?>(
            self.map { (key, value) in
                switch value {
                    
                case is Dictionary<String, AnyObject>: fallthrough
                case is Array<AnyObject>:
                    let data = try! NSJSONSerialization.dataWithJSONObject(value, options: [])
                    return (key, String(data: data, encoding: NSUTF8StringEncoding)!)
                    
                case let string as CustomStringConvertible:
                    return (key, string.description.trimmedNewlinesAndTabsString())
                    
                default: return (key, nil)
                }
            })
            
        return Dictionary<Key, String>(dict
            .filter { (_, value) in value != nil }
            .map { (key, value) in (key, value!) })
    }
}

// MARK: String extension to inject private params

extension String {
    
    public func injectData(publicData: [String: AnyObject]?, _ privateData: [String: AnyObject]?) -> String {
        var combinedData = [String: AnyObject]()
        combinedData += publicData?.plainDict()
        
        // Inject private data only for DEBUG builds
        #if DEBUG
            combinedData += privateData?.plainDict()
        #endif
        
        return self.injectData(combinedData)
    }
    
    private func injectData(data: [String: AnyObject]?) -> String {
        guard let dt = data else {
            return self
        }
        
        if dt.keys.count > 0 {
            let dataDump = dt.map { "\($0.0): \($0.1)" }.joinWithSeparator(", ")
            return self + " (\(dataDump))"
        }
        
        return self
    }
}

// MARK: String extension for better localization

extension String {
    public func localized(comment: String = "", args: CVarArgType...) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: comment)
    }
}

// MARK: Dictionary extensions

public func += <K, V> (inout left: [K:V], right: [K:V]?) {
    
    guard let r = right else {
        return
    }
    
    for (k, v) in r {
        left.updateValue(v, forKey: k)
    }
}

// MARK: Public data protocol

public protocol DebugableContent {
    func publicData() -> [String: AnyObject]?
    func privateData() -> [String: AnyObject]?
}

extension DebugableContent {
    public func publicData() -> [String: AnyObject]? { return nil }
    public func privateData() -> [String: AnyObject]? { return nil }
}

// MARK: Inject public data from DebuggableContent

infix operator ^| { associativity left }

public func ^| (left: [String: AnyObject], right: Any?) -> [String: AnyObject] {
    var dict = left
    if let debugable = right as? DebugableContent {
        dict += debugable.publicData()
    }
    return dict
}

infix operator ^- { associativity left }

public func ^- (left: [String: AnyObject], right: (String, Any?)) -> [String: AnyObject] {
    var dict = left
    if let debugable = right.1 as? DebugableContent,
        let publicData = debugable.publicData() {
        for (k, v) in publicData {
            dict.updateValue(v, forKey: right.0 + "_" + k)
        }
    }
    return dict
}

infix operator ^^ { associativity left }

public func ^^ (left: [String: AnyObject], right: Any?) -> [String: AnyObject] {
    var dict = left
    if let debugable = right as? DebugableContent {
        dict += debugable.privateData()
    }
    return dict
}

infix operator ^^- { associativity left }

public func ^^- (left: [String: AnyObject], right: (String, Any?)) -> [String: AnyObject] {
    var dict = left
    if let debugable = right.1 as? DebugableContent,
        let publicData = debugable.privateData() {
        for (k, v) in publicData {
            dict.updateValue(v, forKey: right.0 + "_" + k)
        }
    }
    return dict
}
