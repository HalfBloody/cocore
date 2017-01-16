//
//  Service.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 26/04/16.
//  Copyright © 2016 Dmitry Shashlov. All rights reserved.
//

import Foundation
import ObjectMapper
import ReactiveCocoa

protocol Service {
    init(baseURL: NSURL)
}

protocol Authorized {
    var authToken: String? { get set }
}

// MARK: Service mocks

extension Service {
    
    func mockData<T: Mappable>(mockName: String, keypath: String) -> [T] {
        let mockData = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource(mockName, ofType: "json")!)!
        let jsonString = try! NSJSONSerialization.JSONObjectWithData(mockData, options: .AllowFragments)
        return Mapper<T>().mapArray(jsonString[keypath])!
    }
    
    func mockDataSignal<T: Mappable>(mockName: String, keypath: String) -> SignalProducer<[T], EndpointError> {
        return SignalProducer(value: mockData(mockName, keypath: keypath))
    }
}