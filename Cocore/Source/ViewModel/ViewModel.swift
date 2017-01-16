//
//  ViewModel.swift
//  PrizeArena
//
//  Created by Dmitry Shashlov on 23/01/16.
//  Copyright © 2016 Half Bloody. All rights reserved.
//

import Foundation

class ViewModel<M> {
    let model: M
    
    required init(model: M) {
        self.model = model
    }
}