//
//  OperationQueue.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 10/04/16.
//  Copyright © 2016 Dmitry Shashlov. All rights reserved.
//
import Foundation
import SwiftState
import Result
import ReactiveCocoa
import ARSLineProgress

// MARK: Any operation

public struct AnyOperationControl : OperationControlType {
    
    let _start: () -> ReactiveCocoa.Disposable
    let _cancel: () -> ()
    
    init<O: OperationControlType>(_ operationControl: O) {
        _start = operationControl.start
        _cancel = operationControl.cancel
    }
    
    public func start() -> ReactiveCocoa.Disposable {
        return _start()
    }
    
    public func cancel() {
        _cancel()
    }
}

// MARK: Operation assistant

public class OperationQueue : AbstractDisposableHolder {
   
    var operations = [ AnyOperationControl ]()
    
    // Enqueue operation from signal
    public func enqueue<O, E: ErrorType>(operation: Operation<O, E>) {
        
        func __operationCleanup(op: Operation<O, E>) {
            
            // Dispose operation
            op.dispose()
            
            // Remove operation from queue
            self.operations.removeFirst()
            self.operations.first?.start()
        }
        
        // When enqueued operation is done
        operation.done { _ in
            __operationCleanup(operation)
        }
        
        // Operation cancelled
        operation.cancelled {
            __operationCleanup(operation)
        }
        
        // Error on operation
        operation.error { _ in
            __operationCleanup(operation)
        }
        
        // Store operation on queue
        _addOperation(operation)
        
        // If this enqueued operation is single operation on queue start it
        if operations.count == 1 {
            operation.start()
        }
    }
    
    // MARK: Private 
    
    private func _addOperation<O: OperationControlType>(operation: O) {
        operations.append(AnyOperationControl(operation))
    }
}

// MARK: Progress queue

public class ModalProgressOperationQueue : OperationQueue {
    
    override public func enqueue<O, E: ErrorType>(operation: Operation<O, E>) {
        
        operation.progressStarted {
            ARSLineProgress.show()
        }
        
        operation.error { _ in
            ARSLineProgress.showFail()
        }
        
        operation.done { _ in
            ARSLineProgress.hide()
        }
        
        operation.cancelled { _ in
            ARSLineProgress.hide()
        }
        
        super.enqueue(operation)
    }
    
}