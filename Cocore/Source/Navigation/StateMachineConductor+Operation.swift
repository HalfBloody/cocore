//
//  StateMachineConductor+Operation.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 10/04/16.
//  Copyright © 2016 Dmitry Shashlov. All rights reserved.
//
import Foundation
import SwiftState

/**
 * TODO
 *  + implement 'next' and 'error' for StateMachineConductor+Operation.swift
 *  + implement handling OperationException.ExitMachineScope exception on operation (dispose operation)
 *  + if any of the 'started', 'next', 'done' or 'error' handlers are not provided state machine operation supervised
 *    state machine is not switched
 */

extension StateMachineConductor where SType: OperationWrapper {

    // MARK: handleOperation
    
    public func handleOperationEvent<O, E: ErrorType>(
        operationSpawner operationSpawner: (event: EType, fromState: SType, toState: SType, userInfo: Any?) -> (Operation<O, E>?),
                         operationQueue: OperationQueue,
                         started: ((EType) throws -> (SType.WrappedSType?))? = nil,
                         next: ((O, EType) throws -> (SType.WrappedSType?))? = nil,
                         done: ((O, EType) throws -> (SType.WrappedSType?))? = nil,
                         error: ((E, EType) throws -> (SType.WrappedSType?))? = nil) {
        
        stateMachine.addAnyHandler(.Any => .Any) {
            context in
            
            guard let event = context.event else {
                return
            }
            
            // Create operation from event if possible
            guard let operation = operationSpawner(event: event,
                                                   fromState: context.fromState,
                                                   toState: context.toState,
                                                   userInfo: context.userInfo) else {
                return
            }
            
            // HANDLER: started { event in ... } .Operation
            self.__operationHandler(operation.progressStarted, handler: started, event: event, operation: operation)
 
            // HANDLER: next { value, event in ... } .Operation
            self.__operationHandler(operation.next, handler: next, event: event, operation: operation)
            
            // HANDLER: done { value, event in ... } .State
            self.__stateHandler(operation.done, handler: done, event: event, operation: operation)
            
            // HANDLER: error { error, event in ... }
            self.__stateHandler(operation.error, handler: error, event: event, operation: operation)
            
            // Enqueue operation
            operationQueue.enqueue(operation)
        }
    }
    
    // MARK: __operationHandler - .State
    
    private func __stateHandler(operationHandler: (() -> ()) -> (), handler: ((EType) throws -> (SType.WrappedSType?))?, event: EType, operation: OperationControlType) {
        if let handler = handler {
            operationHandler {
                self.__tryHandler(operation, handler: handler, value: event) {
                    return SType.wrap($0)
                }
            }
        } else {
            operationHandler {
                self <~| SType.wrap(self.stateMachine.state.unwrap())
            }
        }
    }
    
    private func __stateHandler<T>(operationHandler: ((T) -> ()) -> (), handler: ((T, EType) throws -> (SType.WrappedSType?))?, event: EType, operation: OperationControlType) {
        if let handler = handler {
            operationHandler {
                self.__tryHandler(operation, handler: handler, value: ($0, event)) {
                    return SType.wrap($0)
                }
            }
        } else {
            operationHandler { _ in
                self <~| SType.wrap(self.stateMachine.state.unwrap())
            }
        }
    }
    
    // MARK: __operationHandler - .Operation
    
    private func __operationHandler(operationHandler: (() -> ()) -> (), handler: ((EType) throws -> (SType.WrappedSType?))?, event: EType, operation: OperationControlType) {
        if let handler = handler {
            operationHandler {
                self.__tryHandler(operation, handler: handler, value: event) {
                    return SType.wrapOperation(operation, $0)
                }
            }
        } else {
            operationHandler {
                self <~| SType.wrapOperation(operation, self.stateMachine.state.unwrap())
            }
        }
    }
    
    private func __operationHandler<T>(operationHandler: ((T) -> ()) -> (), handler: ((T, EType) throws -> (SType.WrappedSType?))?, event: EType, operation: OperationControlType) {
        if let handler = handler {
            operationHandler {
                self.__tryHandler(operation, handler: handler, value: ($0, event)) {
                    return SType.wrapOperation(operation, $0)
                }
            }
        } else {
            operationHandler { _ in
                self <~| SType.wrapOperation(operation, self.stateMachine.state.unwrap())
            }
        }
    }
    
    // MARK: __tryHandler
    
    private func __tryHandler<T>(operation: OperationControlType, handler: (T) throws -> SType.WrappedSType?, value: T, wrapper: (SType.WrappedSType) -> SType) {
        
        do {
            
            guard let state = try handler(value) else {
                self <~| wrapper(self.stateMachine.state.unwrap())
                return
            }
            
            self <~| wrapper(state)
            
        } catch (OperationError.ProgramCancelled) {
            
            // Return to .State
            self <~| SType.wrap(self.stateMachine.state.unwrap())
            
            // Cancel operation
            operation.cancel()
            
        } catch (_) {
            fatalError("Can't throw anything but OperationException.ParentExitEvent")
        }
        
    }

}