//
//  Endpoint.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 30/03/16.
//  Copyright © 2016 Dmitry Shashlov. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import AlamofireObjectMapper
import ReactiveCocoa

enum EndpointError : ErrorType {
    
    // Server error
    case ServerError(String)
        
    // Endpoint failure
    case Failure(NSError, Any)
    
    // Can't handle response
    case UnhandledResponseType(Any.Type)
    
    // Wrong response type expected
    case UnexpectedResponseType
    
    // Endpoint not available with reason
    case NotAvailable(NSError)    
    
    // Endpoint busy (not responds within provided timeout)
    case Busy
}

enum EndpointRequestConstructorError : ErrorType {
    
    // Wrong input
    case WrongInput(expected: [Any.Type], received: Any.Type)
    
    // Wrong method
    case WrongMethod(expected: Any.Type, received: Any.Type)

}

// E.g. Service, Navigator - one that control which endpoint to fire after what completed
protocol EndpointOperator {
    
}

protocol EndpointType {
    
    associatedtype RequestType
    associatedtype MethodType
    
    func fire<M: MessageType, O>(input: M, method: MethodType) throws -> O
    func fire<O>(request request: RequestType) throws -> O
    
    /*
    // Fire Mappable to endpoint, e.g. JSON presentation of object
    func fire<I: Mappable, O: Mappable>(input: I, method: MethodType) throws -> Result<O, EndpointError>
    
    // Fire string to endpoint, e.g. /users/me or /users/15
    func fire<I: CustomStringConvertible, O: Mappable>(input: I, method: MethodType) throws -> Result<O, EndpointError>
    
    // Fire message type and receive message with the same type as input's message head 
    func fire<I: MessageType where I.Head: Mappable, I.Body: Mappable>(input: I, method: MethodType) throws -> Result<I.Head, EndpointError>
    
    // Fire message type and receive array of objects with the same type as input's message head
    func fire<I: MessageType, O where I.Head: Mappable, I.Body: Mappable, I.Head == O>(input: I, method: MethodType) throws -> Result<[O], EndpointError>
    */
    
    // func fire<I, O, K: Hashable>(input: I, method: MethodType) throws -> Result<[K: O], EndpointError>   
    
                
    // Response
    func handleResponse<O>(request: RequestType) throws -> O    
    // func handleResponse<O>(request: RequestType) throws -> [O]
    // func handleResponse<O, K: Hashable>(request: RequestType) throws -> [K: O]
}

protocol EndpointRequestConstructorType {
    
    associatedtype MethodType
    associatedtype RequestType
    associatedtype ParametersType
    
    // Parameters
    func constructParameters<M: MessageType>(input: M, method: MethodType) throws -> ParametersType?
    
    // Path
    // func constructPath<M: MessageType>(input: M, method: MethodType) -> CustomStringConvertible?
    
    // Request
    // func constructRequest<I: CustomStringConvertible>(input: I, method: MethodType) -> RequestType
    // func constructRequest<I: Mappable>(input: I, method: MethodType) -> RequestType
    // func constructRequest<I: MessageType where I.Head: Mappable, I.Body: Mappable>(input: I, method: MethodType) -> RequestType
    
    // Reqeust (parameters)
    func constructRequest(parameters: ParametersType?, method: MethodType) throws -> RequestType

}

extension EndpointType {
    
    // Fire with request
    func fire<O>(request request: RequestType) throws -> O {
        return try handleResponse(request)
    }    
    
}

extension EndpointType where Self: EndpointRequestConstructorType {
    
    // Fire with input
    func fire<M: MessageType, O>(input: M, method: MethodType) throws -> O {
        let params = try constructParameters(input, method: method)
        let request = try constructRequest(params, method: method)
        return try handleResponse(request)
    }
    
}

/*
extension EndpointType {

    // Construct request using string
    func constructRequest<I: CustomStringConvertible>(input: I, method: Alamofire.Method) -> Alamofire.Request {
        return self.constructRequest(input, parameters: nil, method: method)
    }
        
    // Construct request using mappable
    
    func constructRequest<I: Mappable>(input: I, method: Alamofire.Method) -> Alamofire.Request {
        return self.constructRequest(nil, parameters: constructParameters(input), method: method)        
    }

    // Construct request using message
    
    func constructRequest<I: MessageType where I.Head: Mappable, I.Body: Mappable>(input: I, method: Alamofire.Method) -> Alamofire.Request {
        return self.constructRequest(nil, parameters: constructParameters(input), method: method)
    }
}
*/

extension EndpointType {
    
    /*
    // Firing endpoint is pretty straithforward: constructing request and handling it's response.
    func fire<I: Mappable, O: Mappable>(input: I, method: MethodType) throws -> Result<O, EndpointError> {        
        
        // Request
        let request = self.constructRequest(input, method: method)
        
        // Response
        return Result.Success(try handleResponse(request))
    }
    
    func fire<I: CustomStringConvertible, O: Mappable>(input: I, method: MethodType) throws -> Result<O, EndpointError> {
        // Request
        let request = self.constructRequest(input, method: method)
        
        // Response
        return Result.Success(try handleResponse(request))
    }
    
    func fire<I: MessageType where I.Head: Mappable, I.Body: Mappable>(input: I, method: MethodType) throws -> Result<I.Head, EndpointError> {
        
        // Request
        let request = self.constructRequest(input, method: method)
        
        // Response
        return Result.Success(try handleResponse(request))
    }
    
    func fire<I: MessageType where I.Head: Mappable, I.Body: Mappable>(input: I, method: MethodType) throws -> Result<[I.Head], EndpointError> {
        
        // Request
        let request = self.constructRequest(input, method: method)
        
        // Response
        return Result.Success(try handleResponse(request))
    }
    */
    
    // Convert endpoint firing execution to SignalProducer
    /*
    func fireSignal<M: MessageType, O>(input: M, method: MethodType) -> SignalProducer<O, EndpointError> {
        return SignalProducer {
            (observer, disposable) in
            
            let result: Result<O, EndpointError> = try! self.fire(input, method: method)
            switch result {
                
                // Success
            case .Success(let output):
                observer.sendNext(output)
                observer.sendCompleted()
                
                // Failure
            case .Failure(let error):
                observer.sendFailed(error)
            }
        }
    }
    */
    
    // Throwing by default response handler
    
    func handleResponse<O>(request: RequestType) throws -> O {
        throw EndpointError.UnhandledResponseType(O.self)
    }
    
    /*
    func handleResponse<O>(request: RequestType) throws -> [O] {
        throw EndpointError.UnhandledResponseType(O.self)
    }
    */
    
    /*
    func handleResponse<O, K: Hashable>(request: RequestType) throws -> Dictionary<K, O> {
        throw EndpointError.UnhandledResponseType
    }
    */
}