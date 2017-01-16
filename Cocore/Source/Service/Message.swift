//
//  Message.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 01/04/16.
//  Copyright © 2016 Dmitry Shashlov. All rights reserved.
//

import Foundation

protocol MessageType {
    associatedtype Head
    associatedtype Body
    var head: Head? { get }
    var body: Body? { get }
}

class Message<T, M> : MessageType {
    var head: T?
    var body: M?
    
    init(head: T?, body: M?) {
        self.head = head
        self.body = body
    }
}