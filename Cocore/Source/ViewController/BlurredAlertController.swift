//
//  BlurredAlertController.swift
//  PrizeArena
//
//  Created by Dmitry Shashlov on 23/02/16.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation
import UIKit

public class BlurredAlertController : AlertController {
    
    // Blur view
    
    lazy var blurredView: UIView = {
        /*
         * Uncomment to enable blurred view
        let blurredView = UIVisualEffectView(effect: self.blurEffect)
        blurredView.frame = self.view.bounds
        return blurredView
         */
        return UIView()
    }()
    
    var blurEffect: UIBlurEffect { 
        get {
            return UIBlurEffect(style: UIBlurEffectStyle.Dark)
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Add blur effect  
        view.insertSubview(self.blurredView, aboveSubview: backgroundView!)
    }
    
    override public func decoratorForIndexPath(indexPath: NSIndexPath) -> Decorator {
        switch (indexPath.section, indexPath.row, footerSection) {

            case (headerSection!.section, 0, _):
                return BasicDecorator(decoratedViewBackgroundColor: UIColor.clearColor(), contentViewBackgroundColor: UIColor.clearColor())
            
            // First in header section
            case (contentSectionRange().startIndex, 0, _):
                return RounderDecorator(decoratedViewBackgroundColor: Colors.white, 
                    contentViewBackgroundColor: nil, 
                    corners: [.TopLeft, .TopRight])
            
            // Last in buttons section
            case (buttonsSectionRange().endIndex - 1, 0, .None):
                return RounderDecorator(decoratedViewBackgroundColor: Colors.white, 
                    contentViewBackgroundColor: nil, 
                    corners: [.BottomLeft, .BottomRight])
            
            // Last in buttons section
            case (footerSection!.section, 0, .Some):
                return RounderDecorator(decoratedViewBackgroundColor: Colors.white, 
                    contentViewBackgroundColor: nil, 
                    corners: [.BottomLeft, .BottomRight])
            
            case (headerSection!.section, _, _): fallthrough
            case (contentSectionRange(), _, _): fallthrough
            case (buttonsSectionRange(), _, _): 
                return BasicDecorator(decoratedViewBackgroundColor: nil, contentViewBackgroundColor: Colors.white)
            default: return super.decoratorForIndexPath(indexPath)
        }
    }
}