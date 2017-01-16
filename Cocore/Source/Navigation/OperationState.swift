//
//  OperationState.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 10/04/16.
//  Copyright © 2016 Dmitry Shashlov. All rights reserved.
//
import Foundation
import SwiftState
import Result
import ReactiveCocoa

// MARK: Generic operation state

enum GenericOperationState<T, E: ErrorType>: SwiftState.StateType
{
    case Idle
    case InProgress
    case IntermediateResult(T)
    case Done(Result<T, E>)
    case Cancelled
    case IntegrityError(OperationError)
}

extension GenericOperationState : CustomStringConvertible {
    var description: String {
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
    var hashValue: Int {
        return description/*.injectData(publicData(), nil)*/.hashValue
    }
}

func ==<T, E: ErrorType>(lhs: GenericOperationState<T, E>, rhs: GenericOperationState<T, E>) -> Bool {
    return lhs.hashValue == rhs.hashValue
}