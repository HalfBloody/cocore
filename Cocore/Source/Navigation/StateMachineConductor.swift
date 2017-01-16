//
//  StateMachineConductor.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 10/04/16.
//  Copyright © 2016 Dmitry Shashlov. All rights reserved.
//
import Foundation
import SwiftState

// MARK: Protocol

enum StateMachineError : ErrorType {
    case WrongConfiguration(String)
}

protocol StateMachineConductor {
    associatedtype SType: StateType
    associatedtype EType: EventType
    
    // State machine
    var stateMachine: StateMachine<SType, EType> { get }
}

// MARK: <~ (tryState) operator

infix operator <~ { associativity left }

func <~<T: StateMachineConductor>(left: T, right: T.SType) -> StateMachine<T.SType, T.EType> {
    return left.stateMachine <- right
}

// MARK: <~ (canTryState) operator

infix operator <~? { associativity left }

func <~?<T: StateMachineConductor>(left: T, right: T.SType) -> Bool {
    return left.stateMachine.canTryState(right)
}

// MARK: <~! (tryEvent) operator

infix operator <~! { associativity left }

func <~!<T: StateMachineConductor>(left: T, right: T.EType) -> Machine<T.SType, T.EType> {
    return left.stateMachine <-! right
}

// MARK: <~! (canTryEvent) operator

infix operator <~!? { associativity left }

func <~!?<T: StateMachineConductor>(left: T, right: T.EType) -> T.SType? {
    return left.stateMachine.canTryEvent(right)
}

func <~!?<T: StateMachineConductor>(left: T, right: T.EType) -> Bool {
    return (left <~!? right) != nil
}

// MARK: Any conductor

struct AnyStateMachineConductor<S: StateType, E: EventType> : StateMachineConductor {
    let stateMachine: StateMachine<S, E>
    init<T: StateMachineConductor where T.SType == S, T.EType == E>(conductor: T) {
        self.stateMachine = conductor.stateMachine
    }
}