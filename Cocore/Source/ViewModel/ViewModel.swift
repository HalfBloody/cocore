//
//  ViewModel.swift
//  PrizeArena
//
//  Created by Dmitry Shashlov on 23/01/16.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation

public class ViewModel<M> {
    public let model: M
    
    public required init(model: M) {
        self.model = model
    }
}