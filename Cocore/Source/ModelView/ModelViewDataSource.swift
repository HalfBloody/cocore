//
//  ModelViewDataSource.swift
//  PrizeArena
//
//  Created by Dmitry Shashlov on 14/02/16.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation

public protocol ModelViewDataSource {
    func viewModelConfigurableForViewIdentifier(viewIdentifier: String, indexPath: NSIndexPath) -> ModelConfigurableView
    func decoratorForIndexPath(indexPath: NSIndexPath) -> Decorator
}