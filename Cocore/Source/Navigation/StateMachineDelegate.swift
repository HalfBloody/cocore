//
//  StateMachineDelegate.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 10/04/16.
//  Copyright © 2016 Dmitry Shashlov. All rights reserved.
//
import Foundation
import SwiftState

// MARK: Protocol

public protocol StateMachineDelegate {
    associatedtype SType: StateType
    associatedtype EType: EventType
    
    // Configuration
    func addHandler(transition: SwiftState.Transition<SType>, order: HandlerOrder/* = _defaultOrder*/, handler: Machine<SType, EType>.Handler) -> Disposable
}

// Type-erased state machine delegate
/*
struct AnyStateMachineDelegate<S: StateType, E: EventType> : StateMachineDelegate {
    
}
*/