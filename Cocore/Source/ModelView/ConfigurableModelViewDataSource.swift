//
//  ConfigurableModelViewDataSource.swift
//  PrizeArena
//
//  Created by Dmitry Shashlov on 22/02/16.
//  Copyright © 2016 Half Bloody. All rights reserved.
//

import Foundation

class ConfigurableModelViewDataSource<T: ModelConfigurableView> : ReusableModelViewDataSource {
    
    var configurator: ((T, NSIndexPath) -> T?)?
    
    override init() {
        super.init()
    }
    
    init(_ configurator: (T, NSIndexPath) -> T?) {
        super.init()
        self.configurator = configurator
    }
    
    override func viewModelConfigurableForViewIdentifier(viewIdentifier: String, indexPath: NSIndexPath) -> ModelConfigurableView {        
        let modelConfigurableView = super.viewModelConfigurableForViewIdentifier(viewIdentifier, indexPath: indexPath)
        
        if let configurableView = modelConfigurableView as? T, 
            configurator = configurator,
            configurable = configurator(configurableView, indexPath) {
                return configurable
        }
        
        return modelConfigurableView
    }    
}