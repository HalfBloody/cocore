//
//  TwoLineNavigationView.swift
//  Cocore
//
//  Created by Dmitry Shashlov on 08/05/16.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation
import UIKit

public class TwoLineNavigationView : UIView {
    
    @IBOutlet var firstTitleLabel: UILabel?
    @IBOutlet var secondTitleLabel: UILabel?    
    
    // MARK: Construction
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        // Clear background color
        backgroundColor = UIColor.clearColor()
    }
    
    // MARK: Class
    
    class func instantiateFromNib() -> TwoLineNavigationView {
        return NSBundle.loadCoreNibView(String(TwoLineNavigationView.self))
    }    
    
}