//
//  CreditsButton.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 08/05/16.
//  Copyright © 2016 Dmitry Shashlov. All rights reserved.
//

import Foundation
import UIKit

class TwoLineNavigationView : UIView {
    
    @IBOutlet var firstTitleLabel: UILabel?
    @IBOutlet var secondTitleLabel: UILabel?    
    
    // MARK: Construction
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Clear background color
        backgroundColor = UIColor.clearColor()
    }
    
    // MARK: Class
    
    class func instantiateFromNib() -> TwoLineNavigationView {
        return NSBundle.mainBundle().loadNibNamed(String(TwoLineNavigationView.self), owner: nil, options: nil).first as! TwoLineNavigationView
    }    
    
}