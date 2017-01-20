//
//  OperatableState.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 10/04/16.
//  Copyright © 2016 Dmitry Shashlov. All rights reserved.
//
import Foundation
import SwiftState

// MARK: Operatable state

public enum OperatableState<S: StateType> : StateType {
    case Operation(OperationControlType, S)
    case State(S)
}

extension OperatableState : Hashable {
    public var hashValue: Int {
        switch self {
        case .Operation(_, let state): return state.hashValue
        case .State(let state): return state.hashValue
        }
    }
}

public func ==<S: StateType>(lhs: OperatableState<S>, rhs: OperatableState<S>) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

// MARK: Operation wrapper

public protocol OperationWrapper {
    associatedtype WrappedSType: StateType
    static func wrap(state: WrappedSType) -> Self
    static func wrapOperation(disposable: OperationControlType, _ state: WrappedSType) -> Self
    func unwrap() -> WrappedSType
}

extension OperatableState : OperationWrapper {
    public typealias WrappedSType = S
    
    public static func wrap(state: S) -> OperatableState {
        return .State(state)
    }
    
    public static func wrapOperation(disposable: OperationControlType, _ state: S) -> OperatableState {
        return .Operation(disposable, state)
    }
    
    public func unwrap() -> WrappedSType {
        switch self {
            case .State(let state): return state
            case .Operation(_, let state): return state
        }
    }
}

// MARK: <~ Overrides

public func <~|<T: StateMachineConductor, S: StateType where T.SType: OperationWrapper, T.SType == OperatableState<S>>(left: T, right: T.SType.WrappedSType) {
    left <~| OperatableState.State(right)
}

// MARK: Custom string convertible

extension OperatableState where S: CustomStringConvertible {
    var description: String {
        switch self {
            case let .Operation(_, state): return "Operation<\(state.description)>"
            case let .State(state): return "State<\(state.description)>"
        }
    }
}