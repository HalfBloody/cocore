//
//  ModelConfigurableView.swift
//  PrizeArena
//
//  Created by Dmitry Shashlov on 14/02/16.
//  Copyright © 2016 Half Bloody. All rights reserved.
//

import Foundation
import UIKit

class ModelConfigurableView : UIView, ViewModelConfigurable {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configureWithViewModel(viewModel: ViewModel<AnyObject>) {
        // Nothing here
    }

    // Multiline labels
    func multilineLabels() -> [UILabel?] {
        return [ ]
    }
    
    override func layoutSubviews() {
        
        for case .Some(let multilineLabel) in multilineLabels() {
            multilineLabel.preferredMaxLayoutWidth = multilineLabel.frame.size.width    
            multilineLabel.sizeToFit()
        }        
        
        super.layoutSubviews()
    }
}