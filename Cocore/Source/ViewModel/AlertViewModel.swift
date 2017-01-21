//
//  AlertViewModel.swift
//  PrizeArena
//
//  Created by Dmitry Shashlov on 06/02/16.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation
import UIKit

extension ViewModel where M: AlertModelProtocol {    
    var headerImage: UIImage? {
        return self.model.headerImage
    }        
}

extension ViewModel where M: AlertButtonModel {
    var buttonTitle: String? { 
        switch self.model.button {
            case .Button(let title, _, _, _, _, _, _): return title
            default: return nil
        }
    }
    
    var cancelButtonAttributedTitle: NSAttributedString? {
        switch self.model.button {
            case .CancelButton(let attributedString): return attributedString
            default: return nil
        }
    }
    
    var buttonImage: (UIImage, Bool)? {
        switch self.model.button {
            case .Button(_, _, _, _, let image, _, _): return image
            default: return nil
        }
    }
        
    var buttonColor: UIColor? {
        switch self.model.button {
            case .Button(_, let color, _, _, _, _, _): return color
            default: return nil;
        }
    }
    
    var textColor: UIColor? {
        switch self.model.button {
            case .Button(_, _, let textColor, _, _, _, _): return textColor
            default: return nil;
        }
    }
    
    var textAlignment: NSTextAlignment? {
        switch self.model.button {
            case .Button(_, _, _, _, _, _, let textAlignment): return textAlignment
            default: return nil;
        }
    }
    
    var buttonFontSize: FontSize? {
        switch self.model.button {
            case .Button(_, _, _, .Some(let fontSize), _, _, _): return fontSize
            default: return nil
        }
    }
    
    var cornerRadius: CGFloat? {
        switch self.model.button {
            case .Button(_, _, _, _, _, .Some(let cornerRadius), _): return cornerRadius
            default: return nil
        }
    }
}