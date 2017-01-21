//
//  ComponentMapping.swift
//  Cocore
//
//  Created by Dmitry Shashlov on 30/03/16.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation
import ObjectMapper

// Component type protocol
public protocol ComponentType {
    associatedtype ObjectType
    func componentMapping() -> Map -> ()
}

// Make array of components mappable itself
extension Array where Element: ComponentType {    
    // Map each of array's component
    public func mapping(map: Map) {
        for component in self {
            component.componentMapping()(map)
        }
    }    
}

/*
class MappableAssembly<T: Mappable> : Mappable {
    
    typealias ComponentMapping = T -> Map -> ()
    
    let object: T?
    var componentMapping: [ComponentType]?
    
    init (object: T, componentMapping: [ComponentType]) {
        self.object = object
        self.componentMapping = componentMapping
    }
    
    /*
    required init?(_ map: Map) {
    // Nothing here
    }
    */
    
    func mapping(map: Map) {        
        for component in componentMapping! {
            component(object!)(map)
        }
    }   
}
*/
