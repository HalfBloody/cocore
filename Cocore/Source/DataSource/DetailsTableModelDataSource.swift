//
//  DetailsTableModelDataSource.swift
//  PrizeArena
//
//  Created by Dmitry Shashlov on 23/01/16.
//  Copyright © 2016 Half Bloody. All rights reserved.
//

import Foundation

class DetailsTableModelDataSource<M> : TableModelDataSource {
    
    var model: M
    var viewIdentifiers: [String]
    
    init (model: M, viewIdentifiers: [String]) {
        self.model = model
        self.viewIdentifiers = viewIdentifiers
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        return self.viewIdentifiers.count
    }
    
    func modelForIndexPath(indexPath: NSIndexPath) -> M {
        return self.model
    }
    
    func viewModelForIndexPath(indexPath: NSIndexPath) -> ViewModel<M> {
        return ViewModel(model: modelForIndexPath(indexPath))
    }
    
    func viewIdentifierForIndexPath(indexPath: NSIndexPath) -> String {
        return self.viewIdentifiers[indexPath.row]
    } 
    
    // Model assignment
    
    func assignModel(model: M) {
        self.model = model
    }
}

extension DetailsTableModelDataSource : SequenceType {
    typealias Generator = AnyGenerator<(Int, NSIndexPath)>
}