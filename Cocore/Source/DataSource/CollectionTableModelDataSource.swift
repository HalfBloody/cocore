//
//  CollectionTableModelDataSource.swift
//  PrizeArena
//
//  Created by Dmitry Shashlov on 23/01/16.
//  Copyright © 2016 Half Bloody. All rights reserved.
//

import Foundation

class CollectionTableModelDataSource<M> : TableModelDataSource {
    
    var models: [[M]]
    var viewIdentifier: String
    
    init(models: [[M]], viewIdentifier: String) {
        self.models = models
        self.viewIdentifier = viewIdentifier
    }
    
    func numberOfSections() -> Int {
        return self.models.count
    }
    
    func numberOfRowsInSection(section: Int)  -> Int {
        return self.models[section].count
    }
    
    func modelForIndexPath(indexPath: NSIndexPath)  -> M {
        return self.models[indexPath.section][indexPath.row]
    }
    
    func viewModelForIndexPath(indexPath: NSIndexPath)  -> ViewModel<M> {
        return ViewModel(model: modelForIndexPath(indexPath))
    }
    
    func viewIdentifierForIndexPath(indexPath: NSIndexPath)  -> String {
        return viewIdentifier
    }
    
    // Model assignment
    
    func assignModels(models: [M]) {
        self.models = [models];
    }
}

extension CollectionTableModelDataSource : SequenceType {
    typealias Generator = AnyGenerator<(Int, NSIndexPath)>
}