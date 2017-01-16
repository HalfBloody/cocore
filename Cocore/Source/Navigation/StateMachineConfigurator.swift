//
//  StateMachineConfigurator.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 10/04/16.
//  Copyright © 2016 Dmitry Shashlov. All rights reserved.
//
import Foundation
import SwiftState

// MARK: Protocol

protocol StateMachineConfigurator {
    associatedtype SType: StateType
    associatedtype EType: EventType
    
    // Configuration
    func stateMachineRoutes() -> [ Route<SType, EType> ]
}

// Configuring machine
extension StateMachineConfigurator {
    
    /*internal*/ static func _checkMachineConfiguration(stateMachine: StateMachine<SType, EType>) throws {
        
        /**
         * FIXME: transition .. => .Any not allowed for hasRoute check!
        if !stateMachine.hasRoute(stateMachine.state => .Any) {
            throw StateMachineError.WrongConfiguration("State machine has no transitions configured from initial state")
        }
         */
        
    }
    
    /*internal*/ static func _configureStateMachine(initialState: SType, routes: [ Route<SType, EType> ] = []) throws -> StateMachine<SType, EType> {
        // Initializae state machine with initial state
        let machine: StateMachine<SType, EType> = StateMachine(state: initialState)
        
        // Add routes to machine
        machine.addRoutes(routes)
        
        // Chech machine configuration
        try Self._checkMachineConfiguration(machine)
        
        return machine
    }
}

extension StateMachineConductor where Self: StateMachineConfigurator {
    /*internal*/ func _configureStateMachine(initialState: SType) throws -> StateMachine<SType, EType> {
        return try Self._configureStateMachine(initialState, routes: stateMachineRoutes())
    }
}

// MARK: State machine extensions

extension StateMachine {
    func addRoutes(routes: [ Route<S, E> ]) {
        for route in routes {
            addRoute(route)
        }
    }
}