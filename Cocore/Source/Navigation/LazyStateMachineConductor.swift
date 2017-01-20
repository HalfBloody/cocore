//
//  LazyStateMachineConductor.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 10/04/16.
//  Copyright © 2016 Dmitry Shashlov. All rights reserved.
//
import Foundation
import SwiftState

public class LazyStateMachineConductor<S: StateType, E: EventType> : StateMachineConductor, StateMachineConfigurator {
    
    private var initialState: S?
    private func _setInitialState(state: S) throws {
        initialState = state
        _stateMachine = try _configureStateMachine(state)
    }
    
    private let initialRoutes: [ Route<S, E> ]
    
    private var _stateMachine: StateMachine<S, E>?
    public var stateMachine: StateMachine<S, E> {
        get {
            if _stateMachine == nil {
                _stateMachine = try! _configureStateMachine(initialState!)
            }
            return _stateMachine!
        }
    }
    
    public init(routes: [ Route<S, E> ] = []) {
        self.initialState = nil
        self.initialRoutes = routes
    }
    
    public init(initialState: S? = nil, routes: [ Route<S, E> ]) throws {
        
        self.initialRoutes = routes
        
        // Check state machine configuration on initialization
        self.initialState = initialState
        if let state = initialState {
            try _configureStateMachine(state)
        }
    }
    
    // MARK: Configurator
    
    public func stateMachineRoutes() -> [ Route<S, E> ] {
        return initialRoutes
    }
}

// MARK: <~ operator support

public func <~|<S: StateType, E: EventType>(left: LazyStateMachineConductor<S, E>, right: S) throws -> StateMachine<S, E> {
    if case .None = left.initialState {
        try left._setInitialState(right)
    } else {
        left.stateMachine <- right
    }
    
    return left.stateMachine
}