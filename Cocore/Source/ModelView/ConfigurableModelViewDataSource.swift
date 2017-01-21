//
//  ConfigurableModelViewDataSource.swift
//  PrizeArena
//
//  Created by Dmitry Shashlov on 22/02/16.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation

public class ConfigurableModelViewDataSource<T: ModelConfigurableView> : ReusableModelViewDataSource {
    
    public var configurator: ((T, NSIndexPath) -> T?)?
    
    public override init() {
        super.init()
    }
    
    public init(_ configurator: (T, NSIndexPath) -> T?) {
        super.init()
        self.configurator = configurator
    }
    
    override public func viewModelConfigurableForViewIdentifier(viewIdentifier: String, indexPath: NSIndexPath) -> ModelConfigurableView {        
        let modelConfigurableView = super.viewModelConfigurableForViewIdentifier(viewIdentifier, indexPath: indexPath)
        
        if let configurableView = modelConfigurableView as? T, 
            configurator = configurator,
            configurable = configurator(configurableView, indexPath) {
                return configurable
        }
        
        return modelConfigurableView
    }    
}