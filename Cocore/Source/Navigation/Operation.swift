//
//  Operation.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 10/04/16.
//  Copyright © 2016 Dmitry Shashlov. All rights reserved.
//
import Foundation
import SwiftState
import Result
import ReactiveCocoa

// MARK: Abstract operation state machine conductor

class OperationStateMachineConductor<T, E: ErrorType> : AbstractStateMachineConductor<GenericOperationState<T, E>, GenericOperationEvent<T, E>> {
    
    typealias OperationStateType = GenericOperationState<T, E>
    typealias OperationResultType = Result<T, E>
    
    // Each time operation handles .Next(T) event it's result stacked in results
    var results = [T]()
    
    // How to convert array of received intermediate results to .Done when operation is complete (last on taken by default)
    var resultsMapping: [T] -> T = { results in results.last! }
    
    // Initialize state machine with .Idle state
    init() {
        super.init(initialState: .Idle)
        
        // Only eventless transition supported is to .IntegrityError
        stateMachine.addStateComparatorRouteMapping {
            fromState, userInfo -> [StateTypeComparator<GenericOperationState<T, E>>]? in
            return [
                GenericOperationState<T, E>.modestIntegrityErrorComparator()
            ]
        }
        
        // Event based route mappings
        stateMachine.addRouteMapping {
            event, fromState, userInfo -> GenericOperationState<T, E>? in
            
            // No transition performed without event
            guard let event = event else {
                return nil
            }
            
            switch (event, fromState) {
                
                // Start operation only from idle state
                case (.Start, .Idle):
                    return .InProgress
            
                // Intermediate result
                case (.Next(let result), .InProgress):
                    return .IntermediateResult(result)
                
                case (.Next(let result), .IntermediateResult):
                    return .IntermediateResult(result)
                
                // Complete after intermediate result has been received
                case (.Complete, .IntermediateResult(let result)):
                    return .Done(OperationResultType(value: result))
                
                // Error received regardless of the state
                case (.Error(let error), _):
                    return .Done(OperationResultType(error: error))
                
                // Cancel operation regardless of the state
                case (.Cancel, .Idle): fallthrough
                case (.Cancel, .InProgress): fallthrough
                case (.Cancel, .IntermediateResult):
                    return .Cancelled
                
                // Unknown transition
                default:
                    return nil
            }
        }
        
        // Event based error handler
        stateMachine.addErrorHandler {
            event, fromState, toState, userInfo in
            
            var errorDescription: String!
            
            // Configuration above ignores eventless state transitions
            switch (event!, fromState) {
                
                // Complete received, no intermediate results was received before that
                case (.Complete, .Idle): fallthrough
                case (.Complete, .InProgress):
                    errorDescription = "Cannot complete operation until any value is received"
                    
                // Cannot complete cancelled operation
                case (.Next, .Cancelled): fallthrough
                case (.Complete, .Cancelled):
                    errorDescription = "Operation cancelled"
                
                // Operation is already completed
                case (.Next, .Done): fallthrough
                case (.Complete, .Done):
                    errorDescription = "Operation is already completed"
                
                // Operation was failed, can't complete
                case (.Next, .IntegrityError): fallthrough
                case (.Complete, .IntegrityError):
                    errorDescription = "Operation failed, thus cannot receive '.Next' and '.Complete' events"
                
                // Operation not started
                case (.Cancel, .Idle): fallthrough
                case (.Next, .Idle):
                    errorDescription = "Operation was not started"
                
                // Operation was already started before
                case (.Start, .InProgress): fallthrough
                case (.Start, .IntermediateResult): fallthrough
                case (.Start, .Done): fallthrough
                case (.Start, .Cancelled): fallthrough
                case (.Start, .IntegrityError):
                    errorDescription = "Operation was already started before"
                
                // Unknown event
                default:
                    errorDescription = "Unknown operation event received \(event) for state \(fromState)."
            }
            
            // Push integrity error on state machine
            self <~ .IntegrityError(.WrongConfiguration(errorDescription))
        }
    }
}


// MARK: Abstract operation with input / error types

class Operation<O, E: ErrorType> : OperationStateMachineConductor<O, E>, OperationType, SwiftState.Disposable, DisposableHolder {
    
    private var signalProducer: SignalProducer<O, E>?
    
    // Disposables
    private var _signalDisposable: ReactiveCocoa.Disposable?
    var disposables = [ AnyDisposable<SwiftState.ActionDisposable> ]()
    
    init(signalProducer: SignalProducer<O, E>) {
        
        // Super inits operation state machine with .Idle state
        super.init()
        
        // Configure state machine
        self.signalProducer = signalProducer.on(
            started: {
                self <~! .Start
            },
            failed: { error in
                self <~! .Error(error)
            },
            interrupted: {
                self <~ .IntegrityError(.InternalError)
            },
            completed: {
                self <~! .Complete
            }, next: { (value) in
                self <~! .Next(value)
        })
    }
    
    // MARK: Disposable
    
    var disposed: Bool {
        get {
            // self allowed for disposal only when signla disposable is not disposed
            return _signalDisposable?.disposed ?? true
        }
    }
    
    func dispose() {
        if !disposed {
            _signalDisposable?.dispose()
            _disposeHandlers()
        }
    }
    
    // MARK: Operation handlers

    /**
     * This could should be at OperationHanlders.swift, but compiler crashes when extending Operation class with handlers, 
     * which uses specialized private functions (e.g. _progressStarted(..))
     */
    
    // Operation is started
    func progressStarted(handler: () -> ()) {
        self << _progressStarted(handler)
    }
    
    // Operation is done
    func done(handler: (O) -> ()) {
        self << _done(handler)
    }
    
    // Operation done with an error
    func next(handler: (O) -> ()) {
        self << _next(handler)
    }
    
    // Operation done with an error
    func error(handler: (E) -> ()) {
        self << _error(handler)
    }
    
    // Operation cancelled
    func cancelled(handler: () -> ()) {
        self << _cancelled(handler)
    }
    
}

extension Operation : OperationControlType {
    
    /// Start opoeration
    func start() -> ReactiveCocoa.Disposable {
        _signalDisposable = signalProducer?.start()
        return _signalDisposable!
    }
    
    /// Cancel operation
    func cancel() {
        self <~! .Cancel
    }
}