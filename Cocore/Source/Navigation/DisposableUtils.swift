//
//  DisposableUtils.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 10/04/16.
//  Copyright © 2016 Dmitry Shashlov. All rights reserved.
//
import Foundation
import SwiftState
import Result
import ReactiveCocoa

// MARK: Disposable utils

protocol DisposableHolder : class {
    associatedtype DType: SwiftState.Disposable
    var disposables: [ DType ] { get set }
}

extension DisposableHolder {
    internal func _disposeHandlers() {
        for handlerDisposable in (disposables.filter { !$0.disposed }) {
            handlerDisposable.dispose()
        }
    }
}

extension SwiftState.Disposable where Self: DisposableHolder {
    var disposed: Bool { return disposables.count == 0 ? true : false }
    func dispose() {
        _disposeHandlers()
        disposables.removeAll()
    }
}

infix operator << { associativity left }

func <<<T: DisposableHolder>(left: T, right: T.DType) {
    let holder = left
    holder.disposables.append(right)
}

func <<<T: DisposableHolder>(left: T, right: SwiftState.Disposable) {
    
    // Currently only ActionDisposable is supported
    if right is SwiftState.ActionDisposable {
        left << AnyDisposable(right as! SwiftState.ActionDisposable)
    }
}

func <<<T: DisposableHolder>(left: T, right: [SwiftState.Disposable]) {
    for disposable in right {
        left << disposable
    }
}

struct AnyDisposable<T: SwiftState.Disposable> : SwiftState.Disposable {

    private let _disposable: T
    
    init(_ disposable: T) {
        self._disposable  = disposable
    }
    
    var disposed: Bool {
        return _disposable.disposed
    }
    
    func dispose() {
        _disposable.dispose()
    }
}

// MARK: Abstract disposable disposable holder

class AbstractDisposableHolder : NSObject, DisposableHolder, SwiftState.Disposable {
    var disposables = [ AnyDisposable<SwiftState.ActionDisposable> ]()
}