//
//  OperationState.swift
//  Cocore
//
//  Created by Dmitry Shashlov on 10/04/16.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//
import Foundation
import SwiftState
import Result
import ReactiveCocoa

// MARK: Generic operation state

public enum GenericOperationState<T, E: ErrorType>: SwiftState.StateType
{
    case Idle
    case InProgress
    case IntermediateResult(T)
    case Done(Result<T, E>)
    case Cancelled
    case IntegrityError(OperationError)
}

extension GenericOperationState : CustomStringConvertible {
    public var description: String {
        switch self {
            case .Idle: return "Idle"
            case .InProgress: return "InProgress"
            case .IntermediateResult/*(let result)*/: return "IntermediateResult"   // NOTE: result not considered
            
            case .Done(let result):
                switch result {
                    case .Success: return "Done(Success)"
                    case .Failure: return "Done(Error)"
                }
            
            case .Cancelled: return "Cancelled"
            case .IntegrityError: return "IntegrityError"                           // NOTE: error not considered
        }
    }
}

extension GenericOperationState : Hashable {
    public var hashValue: Int {
        return description/*.injectData(publicData(), nil)*/.hashValue
    }
}

public func ==<T, E: ErrorType>(lhs: GenericOperationState<T, E>, rhs: GenericOperationState<T, E>) -> Bool {
    return lhs.hashValue == rhs.hashValue
}