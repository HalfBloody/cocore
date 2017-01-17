//
//  OperationEvent.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 10/04/16.
//  Copyright © 2016 Dmitry Shashlov. All rights reserved.
//
import Foundation
import SwiftState
import Result
import ReactiveCocoa

// MARK: Generic operation event

public enum GenericOperationEvent<T, E: ErrorType>: SwiftState.EventType {
    case Start
    case Next(T)
    case Complete
    case Error(E)
    case Cancel
}

extension GenericOperationEvent : CustomStringConvertible {
    public var description: String {
        switch self {
            case .Start: return "Start"
            case .Next/*(let next)*/: return "Next"                                 // NOTE: result not considered
            case .Complete: return "Complete"
            case .Error/*(let error)*/: return "Error"                              // NOTE: error not considered
            case .Cancel: return "Cancel"
        }
    }
}

extension GenericOperationEvent : Hashable {
    public var hashValue: Int {
        return description/*.injectData(publicData(), nil)*/.hashValue
    }
}

public func ==<T, E: ErrorType>(lhs: GenericOperationEvent<T, E>, rhs: GenericOperationEvent<T, E>) -> Bool {
    return lhs.hashValue == rhs.hashValue
}