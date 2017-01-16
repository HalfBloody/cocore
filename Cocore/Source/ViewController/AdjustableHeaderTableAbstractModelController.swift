//
//  TaskDetailsController.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 23/04/16.
//  Copyright © 2016 Dmitry Shashlov. All rights reserved.
//

import Foundation
import UIKit

class AdjustableHeaderTableAbstractModelController : TableViewAbstractModelController {
    
    var topBackgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Don't clip table view
        tableView?.clipsToBounds = false
        
        let navigationBarHeight = __navigationBarHeight()
        let statusBarFrame = (UIApplication.sharedApplication().delegate as! AppDelegate).statusBarFrame
        
        // Table background color
        topBackgroundView = UIView(frame: 
            CGRect(
                x: 0, 
                y: -(statusBarFrame.size.height + navigationBarHeight),
                width: view.bounds.size.width, 
                height: statusBarFrame.size.height + navigationBarHeight)
        )
        topBackgroundView.backgroundColor = Colors.blue
        view!.insertSubview(topBackgroundView, aboveSubview: tableView!)
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
       
        // Top background view height
        if case let offset = scrollView.contentOffset.y
            where offset < 0 {
            
            // Replace topBackgroundView
            if view.subviews.indexOf(topBackgroundView) < view.subviews.indexOf(tableView!) {
                topBackgroundView.removeFromSuperview()
                view.insertSubview(topBackgroundView, aboveSubview: tableView!)
            }
            
            let navigationBarHeight = __navigationBarHeight()
            let statusBarFrame = (UIApplication.sharedApplication().delegate as! AppDelegate).statusBarFrame
            
            // Adjust it's frame
            topBackgroundView?.frame = CGRect(
                x: 0,
                y: -(statusBarFrame.size.height + navigationBarHeight),
                width: view.bounds.size.width,
                height: statusBarFrame.size.height + navigationBarHeight - offset
            )
        } else if view.subviews.indexOf(topBackgroundView) > view.subviews.indexOf(tableView!) {
            
            // Replace topBackgroundView
            topBackgroundView.removeFromSuperview()
            view.insertSubview(topBackgroundView, belowSubview: tableView!)
        }        
        
        // Fade out navigation bar on content offset more than navigation bar height
        // navigationController.navigationBar.alpha = 1 - min(1, scrollView.contentOffset.y / navigationController.navigationBar.frame.size.height)
    }
    
    // MARK: Private
    
    private func __navigationBarHeight() -> CGFloat {
        guard let nc = navigationController else {
            return 0.0
        }
        
        return nc.navigationBar.frame.size.height
    }
}
