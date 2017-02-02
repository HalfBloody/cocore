//
//  StaticHeightConfigurable.swift
//  Cocore
//
//  Created by Dmitry Shashlov on 2/2/17.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation

/// Protocol that defines intreaction with data sources which holds static height configurables
public protocol StaticHeightConfigurable {
    var configurableViewDummy: ModelConfigurableView? { get }
}

/// Static height reusable data source which has no configuration ability
public class StaticHeightReusableModelViewDataSource : ReusableModelViewDataSource, StaticHeightConfigurable {

    public var configurableViewDummy: ModelConfigurableView?

    override public func viewModelConfigurableForViewIdentifier(viewIdentifier: String, indexPath: NSIndexPath) -> ModelConfigurableView {
        let vmc = super.viewModelConfigurableForViewIdentifier(viewIdentifier, indexPath: indexPath)
        if case .None = configurableViewDummy {
            configurableViewDummy = vmc
        }
        return vmc
    }

    override public func heightChange(indexPath: NSIndexPath) -> CGFloat {
        return 0.0
    }
}

/// Static height configurable reusable data source
public class StaticHeightConfigurableModelViewDataSource<T: ModelConfigurableView> : ConfigurableModelViewDataSource<T>, StaticHeightConfigurable {

    public var configurableViewDummy: ModelConfigurableView?

    override public func viewModelConfigurableForViewIdentifier(viewIdentifier: String, indexPath: NSIndexPath) -> ModelConfigurableView {
        let vmc = super.viewModelConfigurableForViewIdentifier(viewIdentifier, indexPath: indexPath)
        if case .None = configurableViewDummy {
            configurableViewDummy = vmc
        }
        return vmc
    }

    public override init() {
        super.init()
    }

    override public func heightChange(indexPath: NSIndexPath) -> CGFloat {
        return 0.0
    }
    
}