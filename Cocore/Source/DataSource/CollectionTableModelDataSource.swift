//
//  CollectionTableModelDataSource.swift
//  PrizeArena
//
//  Created by Dmitry Shashlov on 23/01/16.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation

public class CollectionTableModelDataSource<M> : TableModelDataSource {
    
    public /*internal(set) */var models: [[M]]
    public /*internal(set) */var viewIdentifier: String
    
    public init(models: [[M]], viewIdentifier: String) {
        self.models = models
        self.viewIdentifier = viewIdentifier
    }
    
    public func numberOfSections() -> Int {
        return self.models.count
    }
    
    public func numberOfRowsInSection(section: Int)  -> Int {
        return self.models[section].count
    }
    
    public func modelForIndexPath(indexPath: NSIndexPath)  -> M {
        return self.models[indexPath.section][indexPath.row]
    }
    
    public func viewModelForIndexPath(indexPath: NSIndexPath)  -> ViewModel<M> {
        return ViewModel(model: modelForIndexPath(indexPath))
    }
    
    public func viewIdentifierForIndexPath(indexPath: NSIndexPath)  -> String {
        return viewIdentifier
    }
    
    // Model assignment
    
    func assignModels(models: [M]) {
        self.models = [models];
    }
}

extension CollectionTableModelDataSource : SequenceType {
    public typealias Generator = AnyGenerator<(Int, NSIndexPath)>
}