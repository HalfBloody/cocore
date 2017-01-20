//
//  OperationHandlers.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 10/04/16.
//  Copyright © 2016 Dmitry Shashlov. All rights reserved.
//
import Foundation
import SwiftState
import Result
import ReactiveCocoa

// MARK: Operation handlers

extension OperationType {
    
    /*internal*/ func _progressStarted(handler: () -> ()) -> SwiftState.Disposable {
        return stateMachine.addHandler(event: .Any) { context in
            
            switch context.toState {
                case .InProgress:
                    handler()
                default: break
            }
        }
    }
    
    /*internal*/ func _done(handler: (OType) -> ()) -> SwiftState.Disposable {
        return stateMachine.addHandler(event: .Any) { context in
            
                // Handle value of .Done (e.g. push TaskDetailsController onto navigation stack)
                switch context.toState {
                    case .Done(let result) where result.value != nil:
                        handler(result.value!)
                default: break
            }
        }
    }
    
    /*internal*/ func _next(handler: (OType) -> ()) -> SwiftState.Disposable {
        return stateMachine.addHandler(event: .Any) { context in
            
            // Handle value of .Done (e.g. push TaskDetailsController onto navigation stack)
            switch context.toState {
                case .IntermediateResult(let result):
                    handler(result)
                default: break
            }
        }
    }
    
    /*internal*/ func _error(handler: (EType) -> ()) -> SwiftState.Disposable {
        return stateMachine.addHandler(event: .Any) { context in
            
            // Handle value of .Done (e.g. push TaskDetailsController onto navigation stack)
            switch context.toState {
                case .Done(let result) where result.error != nil:
                    handler(result.error!)
                default: break
            }
        }
    }
    
    /*internal*/ func _cancelled(handler: () -> ()) -> SwiftState.Disposable {
        return stateMachine.addHandler(event: .Any) { context in
            
            // Handle value of .Done (e.g. push TaskDetailsController onto navigation stack)
            switch context.toState {
                case .Cancelled:
                    handler()
                default: break
            }
        }
    }
}

/*
 * When uncommenting this code and removing same code from Operation<O, E> implementation compiler crashes
extension OperationType where Self: DisposableHolder {
    
    // Operation is started
    func progressStarted(handler: () -> ()) {
        self << _progressStarted(handler)
    }
    
    // Operation is done
    func done(handler: (OType) -> ()) {
        self << _done(handler)
    }
}
*/

extension OperationType where EType == EndpointError {
    
    // Server error
    /*internal*/ func _serverError(handler: (String) -> ()) -> SwiftState.Disposable {
        return stateMachine.addHandler(event: .Any) {
            context in
            
            guard let event = context.event else {
                return
            }
            
            // Handle server error
            switch event {
                case .Error(.ServerError(let errorText)):
                    handler(errorText)
                default: break
            }
        }
    }
}

extension OperationType where EType == EndpointError, Self: DisposableHolder {
    func serverError(handler: (String) -> ()) {
        self <<| _serverError(handler)
    }
}