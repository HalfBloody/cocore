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

public protocol DisposableHolder : class {
    associatedtype DType: SwiftState.Disposable
    var disposables: [ DType ] { get set }
}

extension DisposableHolder {
    public func _disposeHandlers() {
        for handlerDisposable in (disposables.filter { !$0.disposed }) {
            handlerDisposable.dispose()
        }
    }
}

extension SwiftState.Disposable where Self: DisposableHolder {
    public var disposed: Bool { return disposables.count == 0 ? true : false }
    public func dispose() {
        _disposeHandlers()
        disposables.removeAll()
    }
}

infix operator << { associativity left }

public func <<<T: DisposableHolder>(left: T, right: T.DType) {
    let holder = left
    holder.disposables.append(right)
}

public func <<<T: DisposableHolder>(left: T, right: SwiftState.Disposable) {
    
    // Currently only ActionDisposable is supported
    if right is SwiftState.ActionDisposable {
        left << AnyDisposable(right as! SwiftState.ActionDisposable)
    }
}

public func <<<T: DisposableHolder>(left: T, right: [SwiftState.Disposable]) {
    for disposable in right {
        left << disposable
    }
}

public struct AnyDisposable<T: SwiftState.Disposable> : SwiftState.Disposable {

    private let _disposable: T
    
    public init(_ disposable: T) {
        self._disposable  = disposable
    }
    
    public var disposed: Bool {
        return _disposable.disposed
    }
    
    public func dispose() {
        _disposable.dispose()
    }
}

// MARK: Abstract disposable disposable holder

public class AbstractDisposableHolder : NSObject, DisposableHolder, SwiftState.Disposable {
    public var disposables = [ AnyDisposable<SwiftState.ActionDisposable> ]()
}