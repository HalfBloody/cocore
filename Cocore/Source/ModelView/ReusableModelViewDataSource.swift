//
//  ReusableModelViewDataSource.swift
//  PrizeArena
//
//  Created by Dmitry Shashlov on 14/02/16.
//  Copyright © 2016 Half Bloody. All rights reserved.
//

import Foundation
import UIKit

class StaticHeightReusableModelViewDataSource : ReusableModelViewDataSource {
    
    var configurableViewDummy: ModelConfigurableView?
    
    override func viewModelConfigurableForViewIdentifier(viewIdentifier: String, indexPath: NSIndexPath) -> ModelConfigurableView {
        let vmc = super.viewModelConfigurableForViewIdentifier(viewIdentifier, indexPath: indexPath)
        if case .None = configurableViewDummy {
            configurableViewDummy = vmc
        }
        return vmc
    }
    
    override func heightChange(indexPath: NSIndexPath) -> CGFloat {
        return 0.0
    }
}

class ReusableModelViewDataSource : ModelViewDataSource {
    
    private lazy var heightChange = [NSIndexPath: CGFloat]()
    
    func viewModelConfigurableForViewIdentifier(viewIdentifier: String, indexPath: NSIndexPath) -> ModelConfigurableView {
        
        if case .None = nibCache[viewIdentifier] {
            nibCache[viewIdentifier] = UINib(nibName: viewIdentifier, bundle: nil)
        }
        
        return nibCache[viewIdentifier]!.instantiateWithOwner(nil, options: nil).first as! ModelConfigurableView
    }
    
    func decoratorForIndexPath(indexPath: NSIndexPath) -> Decorator {
        return BasicDecorator()
    }
    
    // MARK: Nib caching
    
    var nibCache = [String: UINib]()
    
    // Height change
    
    func heightChange(indexPath: NSIndexPath) -> CGFloat? {
        return heightChange[indexPath]
    }
    
    func setHeightChange(change: CGFloat, indexPath: NSIndexPath) {
        heightChange[indexPath] = change
    }
    
    func clearHeightChange(indexPath: NSIndexPath) {
        heightChange[indexPath] = nil
    }
    
    // Insert / delete rows
    
    func insertRowAtIndexPath(indexPath: NSIndexPath) {
        
        let oldHeightChange = heightChange
        heightChange.removeAll()
        
        var newHeightChange = [NSIndexPath : CGFloat]()
        for (ip, hc) in oldHeightChange {
            
            switch (ip, indexPath) {
                
                // Index path inserted in another section
                case (let ip, let nip)
                    where ip.section != nip.section
                        || (ip.section == nip.section && ip.row < nip.row):
                    
                    newHeightChange[ip] = hc
                
                // Inserted index path stores no height change
                case (let ip, let nip)
                    where ip.section == nip.section && ip.row == nip.row:
                
                    newHeightChange[nip] = 0.0
                
                // Offset applied for height changes after inserted roe
                case (let ip, let nip)
                    where ip.section == nip.section && ip.row > nip.row:
                
                    let oip = NSIndexPath(forRow: ip.row + 1, inSection: ip.section)
                    newHeightChange[oip] = hc
                
                default: fatalError("Shouldn't be here")
                
            }
        }
        
        // Re-assign height change dicionary
        heightChange = newHeightChange
    }
    
    func deleteRowAtIndexPath(indexPath: NSIndexPath) {
       
        var newHeightChange = [NSIndexPath : CGFloat]()
        for (ip, hc) in heightChange {
            
            switch (ip, indexPath) {
                
            // Index path inserted in another section
            case (let ip, let nip)
                where ip.section != nip.section
                    || (ip.section == nip.section && ip.row < nip.row):
                
                newHeightChange[ip] = hc
                
            // Inserted index path stores no height change
            case (let ip, let nip)
                where ip.section == nip.section && ip.row == nip.row:
                
                break
                
            // Inserted index path stores no height change
            case (let ip, let nip)
                where ip.section == nip.section && ip.row > nip.row:
                
                let oip = NSIndexPath(forRow: ip.row - 1, inSection: ip.section)
                newHeightChange[oip] = heightChange(ip)
                
            default: fatalError("Shouldn't be here")
                
            }
        }
        
        // Re-assign height change dicionary
        heightChange = newHeightChange
    }
}