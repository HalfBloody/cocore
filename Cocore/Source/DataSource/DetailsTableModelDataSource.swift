//
//  DetailsTableModelDataSource.swift
//  PrizeArena
//
//  Created by Dmitry Shashlov on 23/01/16.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation

public class DetailsTableModelDataSource<M> : TableModelDataSource {
    
    public /*internal(set) */var model: M
    public /*internal(set) */var viewIdentifiers: [String]
    
    public init (model: M, viewIdentifiers: [String]) {
        self.model = model
        self.viewIdentifiers = viewIdentifiers
    }
    
    public func numberOfSections() -> Int {
        return 1
    }
    
    public func numberOfRowsInSection(section: Int) -> Int {
        return self.viewIdentifiers.count
    }
    
    public func modelForIndexPath(indexPath: NSIndexPath) -> M {
        return self.model
    }
    
    public func viewModelForIndexPath(indexPath: NSIndexPath) -> ViewModel<M> {
        return ViewModel(model: modelForIndexPath(indexPath))
    }
    
    public func viewIdentifierForIndexPath(indexPath: NSIndexPath) -> String {
        return self.viewIdentifiers[indexPath.row]
    } 
    
    // Model assignment
    
    func assignModel(model: M) {
        self.model = model
    }
}

extension DetailsTableModelDataSource : SequenceType {
    public typealias Generator = AnyGenerator<(Int, NSIndexPath)>
}