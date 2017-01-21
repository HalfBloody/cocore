//
//  ImageRepresentable.swift
//  Cocore
//
//  Created by Dmitry Shashlov on 31/03/16.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation
import ObjectMapper

// Protocol that represents model representable via image
protocol ImageRepresentable {
    var smallImageUrl : NSURL? { get set }
    var mediumImageUrl : NSURL? { get set }
    var largeImageUrl : NSURL? { get set }
}

// Image representable extension for ComponentType
extension ComponentType where ObjectType: ImageRepresentable {
    
    // Image mapping
    func imageMapping(representable: ImageRepresentable) -> Map -> () {
        var representable = representable
        return { map in
            representable.smallImageUrl <- (map["small_image_path"], URLTransform())
            representable.mediumImageUrl <- (map["medium_image_path"], URLTransform())
            representable.largeImageUrl <- (map["large_image_path"], URLTransform())
        }
    }
    
}