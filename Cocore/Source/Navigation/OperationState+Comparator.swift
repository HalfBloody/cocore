//
//  OperationState+Comparator.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 10/04/16.
//  Copyright © 2016 Dmitry Shashlov. All rights reserved.
//
import Foundation
import SwiftState

extension GenericOperationState : StateTypeComparable {
    
    public static func modestComparator() -> (GenericOperationState<T, E>, GenericOperationState<T, E>) -> Bool {
        return { left, right in
            switch (left, right) {
                
                // Idle
                case (.Idle, .Idle): return true
                case (.Idle, _): return false
                    
                // InProgress
                case (.InProgress, .InProgress): return true
                case (.InProgress, _): return false
                    
                // IntermediateResult
                case (.IntermediateResult, .IntermediateResult): return true
                case (.IntermediateResult, _): return false
                    
                // Done
                case (.Done, .Done): return true
                case (.Done, _): return false
                    
                // Cancelled
                case (.Cancelled, .Cancelled): return true
                case (.Cancelled, _): return false
                    
                // IntermediateResult
                case (.IntegrityError, .IntegrityError): return true
                case (.IntegrityError, _): return false
                
            }
        }
    }
    
    public static func greedyComparator() -> (GenericOperationState<T, E>, GenericOperationState<T, E>) -> Bool {
        return { left, right in
            switch (left, right) {
                
                // Idle
                case (.Idle, .Idle): return true
                case (.Idle, _): return false
                    
                // InProgress
                case (.InProgress, .InProgress): return true
                case (.InProgress, _): return false
                    
                // IntermediateResult
                case (.IntermediateResult/*(let v1)*/, .IntermediateResult/*(let v2)*/)/*where v1 == v2*/: return true // FIXME: How to compare result of unspecialized type T?
                case (.IntermediateResult, _): return false
                    
                // Done
                case (.Done(.Success/*(let s1)*/), .Done(.Success/*(let s2)*/))/*where s1 == s2*/: return true // FIXME: How to compare result of unspecialized type T?
                case (.Done(.Failure/*(let e1)*/), .Done(.Failure/*(let e2)*/))/*where e1 == e2*/: return true // FIXME: How to compare error of unspecialized type E?
                case (.Done(.Success), .Done(.Failure)): return false
                case (.Done(.Failure), .Done(.Success)): return false
                case (.Done, _): return false
                    
                // Cancelled
                case (.Cancelled, .Cancelled): return true
                case (.Cancelled, _): return false
                    
                // IntermediateResult
                case (.IntegrityError(let e1), .IntegrityError(let e2)) where e1 == e2: return true
                case (.IntegrityError(let e1), .IntegrityError(let e2)) where e1 != e2: return false
                case (.IntegrityError, _): return false
                
            }
        }
    }
}


// MARK: Custom comparators

extension GenericOperationState {
    
    // MARK: Modest comparators
    
    static func modestIntegrityErrorComparator() -> StateTypeComparator<GenericOperationState<T, E>> {
        return StateTypeComparator(dummyState: .IntegrityError(.WrongConfiguration("")), comparator: GenericOperationState<T, E>.modestComparator())
    }
   
}