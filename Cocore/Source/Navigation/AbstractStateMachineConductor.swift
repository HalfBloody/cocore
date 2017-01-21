//
//  AbstractStateMachineConductor.swift
//  Cocore
//
//  Created by Dmitry Shashlov on 10/04/16.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//
import Foundation
import SwiftState

public class AbstractStateMachineConductor<S: StateType, E: EventType> : StateMachineConductor {
 
    public private(set) var stateMachine: StateMachine<S, E>
    
    public init(initialState: S)/* throws */{
        stateMachine = StateMachine<S, E>(state: initialState)
    }
}