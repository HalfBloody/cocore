//
//  OperatableState+Comparator.swift
//  Cocore
//
//  Created by Dmitry Shashlov on 10/04/16.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//
import Foundation
import SwiftState

// MARK: Operatable state

extension OperatableState where S: StateTypeComparable, S.SType == S {
    
    public static func _modestComparator() -> (OperatableState<S>, OperatableState<S>) -> Bool {
        return {
            left, right in
            
            switch (left, right) {
                case (.State(let s1), .State(let s2)):
                    return S.modestComparator()(s1, s2)
                case (.Operation(_, let s1), .Operation(_, let s2)):
                    return S.modestComparator()(s1, s2)
                case (.State(let s1), .Operation(_, let s2)):
                    return S.modestComparator()(s1, s2)
                case (.Operation(_, let s1), .State(let s2)):
                    return S.modestComparator()(s1, s2)
            }
        }
    }
    
    public static func _greedyComparator() -> (OperatableState<S>, OperatableState<S>) -> Bool {
        return {
            left, right in
            
            switch (left, right) {
                case (.State(let s1), .State(let s2)):
                    return S.greedyComparator()(s1, s2)
                case (.Operation(_, let s1), .Operation(_, let s2)):
                    return S.greedyComparator()(s1, s2)
                case (.State(let s1), .Operation(_, let s2)):
                    return S.greedyComparator()(s1, s2)
                case (.Operation(_, let s1), .State(let s2)):
                    return S.greedyComparator()(s1, s2)
            }
        }
    }
}
