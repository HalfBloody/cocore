//
//  HTTPEndpoint.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 02/04/16.
//  Copyright © 2016 Dmitry Shashlov. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import ReactiveCocoa
import RealmSwift
import Raven

typealias HTTPParameters = (path: CustomStringConvertible?, params: Dictionary<String, AnyObject>?)

// Foreground endpoint
class HTTPEndpoint : EndpointType, EndpointRequestConstructorType {
    
    // URL session manager
    var manager: Manager
    
    // Base url to endpoint
    var baseUrl: NSURL
    
    // Path to endpoint
    var path: String?
    
    // Authorization token
    var authToken: String?
    
    // Full URL to endpoint
    var url: NSURL {
        if let path = path {
            return baseUrl.URLByAppendingPathComponent(path)
        }
        return baseUrl
    }
    
    // Timeout to return NotAvailable error in seconds
    let timeout: NSTimeInterval = 10.0
    
    init(baseUrl: NSURL, path: String?) {
        self.baseUrl = baseUrl
        self.path = path
        self.manager = Manager.sharedInstance
    }

    // MARK: EndpointRequestConstructorType

    func constructParameters<M: MessageType>(input: M, method: Alamofire.Method) throws -> HTTPParameters? {

        /*
         guard let stringConvertible = input.head() as? CustomStringConvertible else {
         return Result.Failure(EndpointRequestConstructorError.WrongInput(input.dynamicType, identifiable.dynamicType))
         }
         */

        var parameters: HTTPParameters = (nil, nil)

        // Check which part of message to parameterize
        switch (input.head, input.body) {

        // Mappable head
        case (.Some(let head), _)
            where head is Dictionary<String, AnyObject>:

            parameters = (nil, head as? Dictionary<String, AnyObject>)

        // Mappable head without parameters
        case (.Some(let head), .None)
            where head is CustomStringConvertible:

            parameters = (head as? CustomStringConvertible, [:])

        // Mappable head with parameters dictionary
        case (.Some(let head), .Some(let params))
            where head is CustomStringConvertible:

            parameters = (head as? CustomStringConvertible, params as? Dictionary<String, AnyObject>)

        // Mappable body
        case (.None, .Some(let message))
            where message is Mappable:

            parameters = (nil, (message as! Mappable).toJSON()) // TODO: construct path

        // None of message can be used
        default:
            break
        }

        return parameters
    }

    func constructRequest(parameters: HTTPParameters?, method: Alamofire.Method) throws -> Alamofire.Request {

        // Target endpoint parameters.path for .GET and .POST methods
        var url = self.url
        if let path = parameters?.path {
            url = url.URLByAppendingPathComponent("\(path)")
        }

        // Additional request headers
        let headers: [String: String]? =  {
            guard let token = authToken else {
                return nil
            }
            return [
                "X-Authorization" : token
            ]
        }()

        // Return request created using session manager
        let request = manager.request(
            method,
            url,
            parameters: parameters?.params,
            encoding: self.parametersEncoding(method),
            headers: headers)

        // Log
        logRequest(request, parameters: parameters)

        return request
            .debugLog()
    }

    // Private

    private func parametersEncoding(method: Alamofire.Method) -> Alamofire.ParameterEncoding {
        switch method {
        case .GET: return Alamofire.ParameterEncoding.URL
        default: return Alamofire.ParameterEncoding.JSON
        }
    }

    /*
    private func constructPath<M: MessageType>(input: M, method: Alamofire.Method) -> CustomStringConvertible? {
        switch input.head() {
        case let identifiable as Identifiable where identifier.head() is CustomStringConvertible:
            return identifiable.identifier
        }
        return nil
    }

    func constructPath<M: Identifiable>(input: M) -> CustomStringConvertible? {
        return input.identifier
    }

    func constructPath<M: CustomStringConvertible>(input: M) -> CustomStringConvertible? {
        return input
    }
    */

    // MARK: Logging

    private func logRequest(request: Request, parameters: HTTPParameters?) {
        if let urlRequest = request.request {

            let params = Dictionary(parameters!.params!.plainDict()
                .filter { (key, _) in
                    ![ "token", "fb_token", ].contains(key)
                })

            var path = self.path!
            if let paramsPath = parameters?.path
                where paramsPath.description.characters.count > 0 {
                path = "\(path)/\(paramsPath)"
            }

            DDLogVerbose("\(urlRequest.HTTPMethod!) \(path)",
                         context: .SRVB,
                         publicData: params)
        }
    }
}

// Background endpoint
class HTTPEndpointBackground : HTTPEndpoint {
    override init(baseUrl: NSURL, path: String?) {
        super.init(baseUrl: baseUrl, path: path)
        
        // Override session manager
        self.manager = Manager.backgroundInstance
    }
}

extension Request {
    public func debugLog() -> Self {
        #if DEBUG
        debugPrint(self)
        #endif
        return self
    }
    
    // MARK: Private
    
    public func responseRoot<R where R: Mappable>(successHandler: (R) -> Void) -> Self {
        return responseObject {
            (response: Response<R, NSError>) -> Void in
            switch response.result {
            case .Success(let response):
                successHandler(response)
            default: break
            }
        }
    }
        
    public func responseCustom<R where R: Mappable>(keypath: String, _ successHandler: (R) -> Void) -> Self {
        return responseObject(keypath, completionHandler: { 
            (response: Response<R, NSError>) -> Void in
            switch response.result {
            case .Success(let response):
                successHandler(response)
            default: break
            }
        })
    }
    
    public func responseArrayCustom<R where R: Mappable>(keypath: String, _ successHandler: ([R]) -> Void) -> Self {
        return responseArray(keypath, completionHandler: { 
            (response: Response<[R], NSError>) -> Void in
            switch response.result {
            case .Success(let response):
                successHandler(response)
            default: break
            }
        })
    }
    
    // MARK: Error handling
    
    public func handleErrors(scenario: String) -> Self {
        return response { (httpRequest, httpResponse, responseData, error) -> Void in
            
            // e.g. "-1009:The Internet connection appears to be offline"
            if case .Some = error {
                return
            }
            
            switch httpResponse!.statusCode {
                
                // Not auhtorized
                case 401: break
                
                // 4xx and 5xx errors
                case 400...499: fallthrough
                case 500...599: 
            
                    var data = [String: AnyObject]()
                    
                    // Request
                    data["request-method"] = httpRequest!.HTTPMethod
                    data["request-url"] = "\(httpRequest!.URL!)"
                    
                    // All request headers, including default session's ones
                    var requestHeaders = self.session.configuration.HTTPAdditionalHeaders ?? [String:String]()
                    for (headerName, headerValue) in httpRequest!.allHTTPHeaderFields ?? [String:String]() {
                        requestHeaders[headerName] = headerValue
                    }                    
                    data["request-headers"] = requestHeaders
                    
                    // Request data
                    if let requestData = httpRequest!.HTTPBody {
                        do {
                            data["request-data"] = try NSJSONSerialization.JSONObjectWithData(requestData, options: [])
                        } catch(_) {
                            data["request-data"] = NSString(data: requestData, encoding: NSUTF8StringEncoding)
                        }
                    }
                    
                    // Response
                    data["response-code"] = httpResponse!.statusCode
                    data["response-headers"] = httpResponse!.allHeaderFields
                    
                    // Response data
                    if let responseData = responseData {
                        do {
                            data["response-data"] = try NSJSONSerialization.JSONObjectWithData(responseData, options: [])
                        } catch(_) {
                            
                            // That's usually HTML
                            if let responseString = NSString(data: responseData, encoding: NSUTF8StringEncoding) as? String {
                                data["response-data"] = responseString
                            }
                        }
                    }
                    
                    // Scenario
                    data["scenario"] = scenario
                    
                    // Handle survey incositency
                    DDLogError("Server error (\(httpResponse!.statusCode)) on \(scenario)",
                        context: .EVNA,
                        publicData: data)
                
                default: 
                    break
            }            
        }
    }
}

// Response handling
extension EndpointType where RequestType == Alamofire.Request, MethodType == Alamofire.Method {
    
    // Handle object response
    func handleResponse<M: Mappable>(request: RequestType) throws -> M {
        
        var result: M? = nil
        var error: EndpointError? = nil
        request.responseObject { (response: Response<M, NSError>) in
            
            switch response.result {
                
            case .Success(let object):
                result = object
                
            case .Failure(let err):
                error = EndpointError.Failure(err, response)
                
            }
        }
        
        if case .Some(let error) = error { throw error }
        
        return result!
    }
    
    // Handle array response
    func handleResponse<M: Mappable>(request: RequestType) throws -> [M] {
        
        var result: [M]? = nil
        var error: EndpointError? = nil
                
        request.responseArray { (response: Response<[M], NSError>) in
            
            switch response.result {
                
            case .Success(let object):
                result = object
                
            case .Failure(let err):
                error = EndpointError.Failure(err, response)
                
            }
        }
        
        if case .Some(let error) = error { throw error }
        
        return result!
    }
    
    ////
    
    // Handle object response from keypath
    func handleResponse<M: Mappable>(request: RequestType) throws -> SignalProducer<M, EndpointError> {        
        return SignalProducer {
            (observer, disposable) in
            
            // Response to custom errors
            self.responseCustomErrors(request, observer: observer, disposable: disposable)
            
            request
                .responseObject { (response: Response<M, NSError>) in
                
                switch response.result {
                    
                case .Success(let object):
                    observer.sendNext(object)
                    observer.sendCompleted()
                    
                case .Failure(let err):
                    observer.sendFailed(EndpointError.Failure(err, response))
                    
                }
            }
        }
    }
    
    // Handle object response from keypath
    func handleResponse<M: Mappable>(request: RequestType, keypath: String) throws -> SignalProducer<M, EndpointError> {        
        return SignalProducer {
            (observer, disposable) in
            
            // Response to custom errors
            self.responseCustomErrors(request, observer: observer, disposable: disposable)
            
            request
                .responseObject(keypath.description) { (response: Response<M, NSError>) in
                
                switch response.result {
                    
                case .Success(let array):
                    observer.sendNext(array)
                    observer.sendCompleted()
                    
                case .Failure(let err):
                    observer.sendFailed(EndpointError.Failure(err, response))
                    
                }
            }
        }
    }
    
    // Handle array response from keypath
    func handleResponse<M: Mappable>(request: RequestType, keypath: String) throws -> SignalProducer<[M], EndpointError> {        
        return SignalProducer {
            (observer, disposable) in
            
            // Response to custom errors
            self.responseCustomErrors(request, observer: observer, disposable: disposable)
            
            request
                .responseArray(keypath.description) { (response: Response<[M], NSError>) in
                
                switch response.result {
                    
                case .Success(let array):
                    observer.sendNext(array)
                    observer.sendCompleted()
                    
                case .Failure(let err):
                    observer.sendFailed(EndpointError.Failure(err, response))
                    
                }
            }
        }
    }
    
    // MARK: Bool response
    
    // Handle boolean response from keypath
    func handleBoolResponse(request: RequestType) throws -> SignalProducer<Bool, EndpointError> {        
        return SignalProducer {
            (observer, disposable) in
            
            // Response to custom errors
            self.responseCustomErrors(request, observer: observer, disposable: disposable)
            
            request.response(completionHandler: { (_, _, _, _) -> Void in
                observer.sendNext(true)
observer.sendCompleted()
            })
        }
    }
    
    //MARK: Response cutsom errors
    
    private func responseCustomErrors<M>(request: RequestType, observer: Observer<M, EndpointError>, disposable: CompositeDisposable) {
        request
            .response { request, response, responseData, error in 
                
                switch (error, responseData) {
                    
                    // Error returned from Alamofire
                    case (.Some(let error), _):
                        observer.sendFailed(EndpointError.Failure(error, response))                    
                    
                    // Response data contains 'error' key
                    case (.None, .Some(let data)) 
                        where data.length > 0:
                        do {
                            let JSON = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? Dictionary<String, AnyObject>
                            if let error = JSON?["error"],
                                errorMessage = error["message"] as? String {
                                    
                                    observer.sendFailed(EndpointError.ServerError(errorMessage))
                                    
                            } else if let errors = JSON?["errors"] as? Array<String>,
                                errorMessage = errors.first {
                                    
                                    observer.sendFailed(EndpointError.ServerError(errorMessage))
                                    
                            } else if let errors = JSON?["errors"] as? Array<Dictionary<String, AnyObject>>,
                                errorMessage = errors.first?["message"] as? String {
                                    
                                    observer.sendFailed(EndpointError.ServerError(errorMessage))
                                    
                            } else if let errorMessage = JSON?["error"] as? String {
                                
                                observer.sendFailed(EndpointError.ServerError(errorMessage))
                            }                        
                        } catch _ {
                            observer.sendFailed(EndpointError.ServerError("Operation couldn't be completed"))
                        }
                    
                    // No error
                    default: break
                }
        }
    }
}

extension Manager {
    public static let backgroundInstance: Manager = {
        let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(NSUUID().UUIDString)
        configuration.HTTPAdditionalHeaders = Manager.defaultHTTPHeaders
        return Manager(configuration: configuration)
    }()
}