//
//  _Transport.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 28/03/16.
//  Copyright © 2016 Dmitry Shashlov. All rights reserved.
//

import Foundation
import ObjectMapper
import ReactiveCocoa
import Alamofire
import AlamofireObjectMapper
import RealmSwift

public protocol Identifiable {
    associatedtype IdentifierType: CustomStringConvertible
    var identifier: IdentifierType { get }
}

public protocol CRUD {
    
    associatedtype Error: ErrorType
    
    // Retrieve mappable object by path
    func retrieve<T: CustomStringConvertible, O: Mappable>(path: T, scenario: String) -> Result<O, Error>
    
    // Retrieve one object by identifier
    // func retrieve<T: protocol<Identifiable, Mappable>>(identifiable: T) throws -> Result<T, Error>
    
    // Retrieve collection by path
    func retrieve<T: Mappable>(path: CustomStringConvertible, scenario: String) -> Result<[T], Error>
    
    // Retrieve collection by path from keypath
    // func retrieve<T: Mappable>(path: String, keypath: String) -> Result<[T], Error>
}

public protocol CRUDIdentifiable {
    
}

public protocol CRUDMutable : CRUD {

    // Create mappable leader -> get leader
    func create<T: Mappable, O: protocol<Identifiable, Mappable>>(object: T, scenario: String) -> Result<O, Error>
    
    // Create mappable leader -> get message
    // func create<T: Mappable, O: Mappable where T.Body == O>(object: T) -> Result<O, Error>
    
    // Create leader -> get CollectionType of Leaders
    // func create<T: LeaderType, O: Mappable where T.Leader == O>(object: T) -> Result<Array<O>, Error>
    
    // Update with message
    func update<T: MessageType where T.Head: Identifiable, T.Body: Mappable>(message: T, scenario: String) -> Result<T.Head, Error>
    // func update<T: MessageType where T.Head: CustomStringConvertible, T.Body: Mappable>(message: T) -> Result<T, Error>
    
    // func update<T: protocol<LeaderCompetence, Mappable>>(object: T) -> Result<T, Error>
    // func update<T>(objects: [T])
    
    // func delete<T>(object: T)
    // func delete<T>(objects: [T])
}

extension HTTPEndpoint : CRUD {
    
    // Retrieve object by path
    public func retrieve<T: CustomStringConvertible, O: Mappable>(path: T, 
        scenario: String) -> Result<O, EndpointError> {        
            
        let request = try! constructRequest(nil, method: .GET)
        return Result.Success(try! fire(request: request.handleErrors(scenario)))
    }
    
    // Retrieve mappable by identifier
    public func retrieve<T: Mappable>(id id: String,
        scenario: String) -> SignalProducer<T, EndpointError> {
        
        let method = Alamofire.Method.GET
        let message = Message<String, AnyObject>(head: id, body: nil)
        let parameters: HTTPParameters? = try! constructParameters(message, method: method)
        let request = try! constructRequest(parameters, method: method)
        return try! handleResponse(request.handleErrors(scenario))
    }
    
    // Retrieve mappable collection by identifier
    public func retrieve<T: Mappable>(path: CustomStringConvertible, 
        scenario: String) -> Result<[T], EndpointError> {
            
        let method = Alamofire.Method.GET
        let message = Message<CustomStringConvertible, AnyObject>(head: path, body: nil)
        let parameters: HTTPParameters? = try! constructParameters(message, method: method)
        let request = try! constructRequest(parameters, method: method)
        return Result.Success(try! fire(request: request.handleErrors(scenario)))
    }
    
    // MARK: Signal Producers
    
    // Retrieve object by path
    public func retrieve<T: CustomStringConvertible, O: Mappable>(path: T,
        keypath: String, scenario: String) -> SignalProducer<O, EndpointError> {        
            
        let message = Message<CustomStringConvertible, AnyObject>(head: path, body: nil)
        let parameters: HTTPParameters? = try! constructParameters(message, method: .GET)
        let request = try! constructRequest(parameters, method: .GET)
        return try! handleResponse(request.handleErrors(scenario), keypath: keypath)
    }
    
    // Retrieve mappable collection from keypath
    public func retrieve<T: Mappable>(path: String,
        keypath: String, 
        scenario: String) -> SignalProducer<[T], EndpointError> {
        
        let method = Alamofire.Method.GET
        let message = Message<CustomStringConvertible, AnyObject>(head: path, body: nil)
        
        let parameters: HTTPParameters? = try! constructParameters(message, method: method)
        let request = try! constructRequest(parameters, method: method)
        return try! handleResponse(request.handleErrors(scenario), keypath: keypath)
        
        // TODO: Should use fire instead of manually handling response
        // return try! fire(request: request)
    }
    
    // Retrieve mappable collection from keypath
    public func retrieve<T: Mappable>(path: String,
        keypath: String, 
        parameters: Dictionary<String, AnyObject>, 
        scenario: String) -> SignalProducer<[T], EndpointError> {
        
        let method = Alamofire.Method.GET
        let message = Message<CustomStringConvertible, Dictionary<String, AnyObject>>(head: path, body: parameters)
        
        let parameters: HTTPParameters? = try! constructParameters(message, method: method)
        let request = try! constructRequest(parameters, method: method)
        return try! handleResponse(request.handleErrors(scenario), keypath: keypath)
        
        // TODO: Should use fire instead of manually handling response
        // return try! fire(request: request)
    }
    
    // More examples
    
    // func retrieve() -> SignalProducer<
    
    
    /*
    // Retrieve object by string, e.g. /users/me
    func retrieve<T: CustomStringConvertible, O: Mappable>(object: T) -> Result<O, EndpointError> {
        return try! self.fire(object, method: .GET)
    }
    
    // Retrieve object by identifier, e.g. /users/14
    func retrieve<T: Identifiable, O: Mappable>(object: T) -> Result<O, EndpointError> {
        return try! self.fire(object.identifier, method: .GET)
    }
    */
    
}

// Touche endpoints
extension HTTPEndpoint {
    
    // E.g. POST /task_transactions
    public func touch<T: Mappable>(path: CustomStringConvertible,
        keypath: String, 
        parameters: Dictionary<String, AnyObject>,
        scenario: String) -> SignalProducer<T, EndpointError> {
            
        let method = Alamofire.Method.POST
        let message = Message<CustomStringConvertible, AnyObject>(head: path, body: parameters)
        
        let parameters: HTTPParameters? = try! constructParameters(message, method: method)
        let request = try! constructRequest(parameters, method: method)
        return try! handleResponse(request.handleErrors(scenario), keypath: keypath)
    }
    
    // E.g. POST /gift_card
    public func touch(path: CustomStringConvertible,
        parameters: Dictionary<String, AnyObject>, 
        scenario: String) -> SignalProducer<Bool, EndpointError> {
            
        let method = Alamofire.Method.POST
        let message = Message<CustomStringConvertible, AnyObject>(head: path, body: parameters)
        
        let parameters: HTTPParameters? = try! constructParameters(message, method: method)
        let request = try! constructRequest(parameters, method: method)
        return try! handleBoolResponse(request.handleErrors(scenario))
    }
    
    // E.g. PATCH /gift_card
    public func update(path: CustomStringConvertible,
        parameters: Dictionary<String, AnyObject>, 
        scenario: String) -> SignalProducer<Bool, EndpointError> {
            
            let method = Alamofire.Method.PATCH
            let message = Message<CustomStringConvertible, AnyObject>(head: path, body: parameters)
            
            let parameters: HTTPParameters? = try! constructParameters(message, method: method)
            let request = try! constructRequest(parameters, method: method)
            return try! handleBoolResponse(request.handleErrors(scenario))
    }
    
    // E.g. POST /devices/me
    public func create<T: Mappable>(object: Dictionary<String, AnyObject>,
        keypath: String,
        scenario: String) -> SignalProducer<T, EndpointError> {
            
        let method = Alamofire.Method.POST
        let message = Message<Dictionary<String, AnyObject>, AnyObject>(head: object, body: nil)
        let parameters: HTTPParameters? = try! constructParameters(message, method: method)
        let request = try! constructRequest(parameters, method: method)
        return try! handleResponse(request.handleErrors(scenario), keypath: keypath)
    }
    
    // E.g. PATCH /devices/me
    public func update(path: String, 
        object: Dictionary<String, AnyObject>,
        scenario: String) -> SignalProducer<Bool, EndpointError> {
            
        let method = Alamofire.Method.PATCH
        let message = Message<String, Dictionary<String, AnyObject>>(head: path, body: object)
        let parameters: HTTPParameters? = try! constructParameters(message, method: method)
        let request = try! constructRequest(parameters, method: method)
        return try! handleBoolResponse(request.handleErrors(scenario))
    }
}

// extension HTTPEndpoint : CRUDMutable {
        
    // Create Mappable object and receive it as Identifiable object as a result
    /*
    func create<T: Mappable, O: protocol<Identifiable, Mappable>>(object: T) -> Result<O, EndpointError> {        
        return try! self.fire(object, method: .POST)
    }
    */
    
    // Update identifiable object with mappable message
    /*
    func update<T: MessageType where T.Head: Identifiable, T.Head.IdentifierType: CustomStringConvertible, T.Body: Mappable>(message: T) -> Result<T.Head, EndpointError> {
        
        let request = self.constructRequest(input, method: .PATCH)
        
        // Response
        return Result.Success(try handleResponse(request))
        return try! self.fire(T, method: .PATCH)
    }
    */
    
    /*
    func create<T: Mappable, O: Mappable where T.Body == O>(object: T) -> Result<O, EndpointError> {
        return try! self.fire(object, method: .POST)
    }
    */
    
    /*
    func create<T: LeaderType, O: Mappable where T.Leader == O>(object: T) -> Result<Array<O>, EndpointError> {
        let request = self.constructRequest(object, method: .POST)
        return Result.Success(try! handleResponse(request))
    }
    */
    
    /*
    func retrieve<T>(object: T) -> T {
        let rt: T = self.fire(object, method: .GET)
    }
    
    func update<T>(object: T) {
        
    }
    
    func delete<T>(object: T) {
        
    } 
    */
// }