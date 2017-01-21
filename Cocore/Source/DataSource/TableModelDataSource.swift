//
//  TableModelDataSource.swift
//  PrizeArena
//
//  Created by Dmitry Shashlov on 23/01/16.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation

public protocol TableModelDataSource {
    associatedtype ModelType
    
    func numberOfSections() -> Int
    func numberOfRowsInSection(section: Int) -> Int    
    func modelForIndexPath(indexPath: NSIndexPath) -> ModelType
    func viewModelForIndexPath(indexPath: NSIndexPath) -> ViewModel<ModelType>
    func viewIdentifierForIndexPath(indexPath: NSIndexPath) -> String
    
    func indexPath(index: Int) -> NSIndexPath?
    func totalNumberOfRows() -> Int
    func modelForIndex(index: Int) -> ModelType
    func viewModelForIndex(index: Int) -> ViewModel<ModelType>
    func viewIdentifierForIndex(index: Int) -> String
}

extension TableModelDataSource {
    
    // Returns total number of rows for data source
    public func totalNumberOfRows() -> Int {
        var totalRows = 0
        for section in 0..<numberOfSections() {
            totalRows += numberOfRowsInSection(section)
        }
        
        return totalRows
    }
    // Get model for index
    public func modelForIndex(index: Int) -> ModelType {            
        return modelForIndexPath(indexPath(index)!)
    }
    
    // Get view model for index
    public func viewModelForIndex(index: Int) -> ViewModel<ModelType> {
        return viewModelForIndexPath(indexPath(index)!)
    }
    
    // Get view identifier for index
    public func viewIdentifierForIndex(index: Int) -> String {
        return viewIdentifierForIndexPath(indexPath(index)!)
    }    
}

extension TableModelDataSource where Self: SequenceType, Self.Generator.Element == (Int, NSIndexPath) {
    public func generate() -> AnyGenerator<(Int, NSIndexPath)> {
        
        var countableIndex = 0
        var countableRow = 0
        var indexPath = NSIndexPath(forItem: 0, inSection: 0)
        
        return AnyGenerator {
            
            if countableIndex == self.totalNumberOfRows() {
                return nil
            }
            
            if countableIndex != 0 && indexPath.row == (self.numberOfRowsInSection(indexPath.section) - 1) {
                countableRow = 0
                indexPath = NSIndexPath(forRow: countableRow, inSection: indexPath.section + 1); countableRow += 1
            } else {
                indexPath = NSIndexPath(forRow: countableRow , inSection: indexPath.section); countableRow += 1
            }
            
            let returnValue = (countableIndex, indexPath); countableIndex += 1
            return returnValue
        }
    }
    
    public func indexPath(index: Int) -> NSIndexPath? {
        var indexPath: NSIndexPath? = nil
        
        for (idx, ip) in self {
            if idx == index {
                indexPath = ip
                break
            }
        } 
        
        return indexPath
    }
}

public struct TableModelDataSourceThunk: TableModelDataSource {
    
    let _numberOfSections: () -> Int
    let _numberOfRowsInSection: (Int) -> Int
    let _modelForIndexPath: (NSIndexPath) -> AnyObject
    let _viewModelForIndexPath: (NSIndexPath) -> ViewModel<AnyObject>
    let _viewIdentifierForIndexPath: (NSIndexPath) -> String
    
    let _indexPath: (Int) -> NSIndexPath?
    let _totalNumberOfRows: () -> Int
    let _modelForIndex: (Int) -> AnyObject
    let _viewModelForIndex: (Int) -> ViewModel<AnyObject>
    let _viewIdentifierForIndex: (Int) -> String
    
    init<T: TableModelDataSource where T.ModelType: AnyObject>(_ dataSource: T) {          
        _numberOfSections = dataSource.numberOfSections
        _numberOfRowsInSection = dataSource.numberOfRowsInSection
        _modelForIndexPath = dataSource.modelForIndexPath
        _viewIdentifierForIndexPath = dataSource.viewIdentifierForIndexPath

        let viewModelForIndexPath = { indexPath -> ViewModel<AnyObject> in
            return ViewModel(model: dataSource.viewModelForIndexPath(indexPath))
        }
        _viewModelForIndexPath = viewModelForIndexPath
        
        _indexPath = dataSource.indexPath
        _totalNumberOfRows = dataSource.totalNumberOfRows
        _modelForIndex = dataSource.modelForIndex
        _viewIdentifierForIndex = dataSource.viewIdentifierForIndex        

        let viewModelForIndex = { index -> ViewModel<AnyObject> in 
            return ViewModel(model: dataSource.viewModelForIndex(index))
        }
        _viewModelForIndex = viewModelForIndex
    }  
    
    public func numberOfSections() -> Int {
        return _numberOfSections()
    }
    
    public func numberOfRowsInSection(section: Int) -> Int {
        return _numberOfRowsInSection(section)
    }
    
    public func modelForIndexPath(indexPath: NSIndexPath) -> AnyObject {
        return _modelForIndexPath(indexPath)
    }
    
    public func viewModelForIndexPath(indexPath: NSIndexPath) -> ViewModel<AnyObject> {
        return _viewModelForIndexPath(indexPath)
    }
    
    public func viewIdentifierForIndexPath(indexPath: NSIndexPath) -> String {
        return _viewIdentifierForIndexPath(indexPath)
    }
    
    public func indexPath(index: Int) -> NSIndexPath? {
        return _indexPath(index)
    }
    
    public func totalNumberOfRows() -> Int {
        return _totalNumberOfRows()
    }
    
    public func modelForIndex(index: Int) -> AnyObject {
        return _modelForIndex(index)
    }
    
    public func viewModelForIndex(index: Int) -> ViewModel<AnyObject> {
        return _viewModelForIndex(index)
    }
    
    public func viewIdentifierForIndex(index: Int) -> String {
        return _viewIdentifierForIndex(index)
    }    
}  