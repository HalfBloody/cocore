//
//  OperationType.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 10/04/16.
//  Copyright © 2016 Dmitry Shashlov. All rights reserved.
//
import Foundation
import SwiftState
import Result
import ReactiveCocoa

// MARK: Operation type

public protocol OperationType {
    
    associatedtype OType
    associatedtype EType: ErrorType
    
    var stateMachine: StateMachine<GenericOperationState<OType, EType>, GenericOperationEvent<OType, EType>> { get }
}

// MARK: Operation control type

public protocol OperationControlType {
    func start() -> ReactiveCocoa.Disposable
    func cancel()
}

// MARK: OperationError

public enum OperationError : ErrorType {
    case InternalError
    case ProgramCancelled
    case WrongConfiguration(String)
}

func ==(left: OperationError, right: OperationError) -> Bool {
    switch (left, right) {
        case (.InternalError, .InternalError): return true
        case (.WrongConfiguration, .WrongConfiguration): return true
        default: return false
    }
}

func !=(left: OperationError, right: OperationError) -> Bool {
    return !(left == right)
}