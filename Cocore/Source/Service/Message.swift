//
//  Message.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 01/04/16.
//  Copyright © 2016 Dmitry Shashlov. All rights reserved.
//

import Foundation

public protocol MessageType {
    associatedtype Head
    associatedtype Body
    var head: Head? { get }
    var body: Body? { get }
}

public class Message<T, M> : MessageType {
    public var head: T?
    public var body: M?
    
    init(head: T?, body: M?) {
        self.head = head
        self.body = body
    }
}