//
//  ModelConfigurableView.swift
//  PrizeArena
//
//  Created by Dmitry Shashlov on 14/02/16.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation
import UIKit

public class ModelConfigurableView : UIView, ViewModelConfigurable {
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    public func configureWithViewModel(viewModel: ViewModel<AnyObject>) {
        // Nothing here
    }

    // Multiline labels
    public func multilineLabels() -> [UILabel?] {
        return [ ]
    }
    
    override public func layoutSubviews() {
        
        for case .Some(let multilineLabel) in multilineLabels() {
            multilineLabel.preferredMaxLayoutWidth = multilineLabel.frame.size.width    
            multilineLabel.sizeToFit()
        }        
        
        super.layoutSubviews()
    }
}