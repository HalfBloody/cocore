//
//  StateMachineConductor.swift
//  Cocore
//
//  Created by Dmitry Shashlov on 10/04/16.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//
import Foundation
import SwiftState

// MARK: Protocol

public enum StateMachineError : ErrorType {
    case WrongConfiguration(String)
}

public protocol StateMachineConductor {
    associatedtype SType: StateType
    associatedtype EType: EventType
    
    // State machine
    var stateMachine: StateMachine<SType, EType> { get }
}

// MARK: <~ (tryState) operator

infix operator <~| { associativity left }

public func <~|<T: StateMachineConductor>(left: T, right: T.SType) -> StateMachine<T.SType, T.EType> {
    return left.stateMachine <- right
}

// MARK: <~ (canTryState) operator

infix operator <~? { associativity left }

public func <~?<T: StateMachineConductor>(left: T, right: T.SType) -> Bool {
    return left.stateMachine.canTryState(right)
}

// MARK: <~! (tryEvent) operator

infix operator <~! { associativity left }

public func <~!<T: StateMachineConductor>(left: T, right: T.EType) -> Machine<T.SType, T.EType> {
    return left.stateMachine <-! right
}

// MARK: <~! (canTryEvent) operator

infix operator <~!? { associativity left }

public func <~!?<T: StateMachineConductor>(left: T, right: T.EType) -> T.SType? {
    return left.stateMachine.canTryEvent(right)
}

public func <~!?<T: StateMachineConductor>(left: T, right: T.EType) -> Bool {
    return (left <~!? right) != nil
}

// MARK: Any conductor

public struct AnyStateMachineConductor<S: StateType, E: EventType> : StateMachineConductor {
    public let stateMachine: StateMachine<S, E>
    init<T: StateMachineConductor where T.SType == S, T.EType == E>(conductor: T) {
        self.stateMachine = conductor.stateMachine
    }
}