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

enum OperatableState<S: StateType> : StateType {
    case Operation(OperationControlType, S)
    case State(S)
}

extension OperatableState : Hashable {
    var hashValue: Int {
        switch self {
        case .Operation(_, let state): return state.hashValue
        case .State(let state): return state.hashValue
        }
    }
}

func ==<S: StateType>(lhs: OperatableState<S>, rhs: OperatableState<S>) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

// MARK: Operation wrapper

protocol OperationWrapper {
    associatedtype WrappedSType: StateType
    static func wrap(state: WrappedSType) -> Self
    static func wrapOperation(disposable: OperationControlType, _ state: WrappedSType) -> Self
    func unwrap() -> WrappedSType
}

extension OperatableState : OperationWrapper {
    typealias WrappedSType = S
    
    static func wrap(state: S) -> OperatableState {
        return .State(state)
    }
    
    static func wrapOperation(disposable: OperationControlType, _ state: S) -> OperatableState {
        return .Operation(disposable, state)
    }
    
    func unwrap() -> WrappedSType {
        switch self {
            case .State(let state): return state
            case .Operation(_, let state): return state
        }
    }
}

// MARK: <~ Overrides

func <~<T: StateMachineConductor, S: StateType where T.SType: OperationWrapper, T.SType == OperatableState<S>>(left: T, right: T.SType.WrappedSType) {
    left <~ OperatableState.State(right)
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