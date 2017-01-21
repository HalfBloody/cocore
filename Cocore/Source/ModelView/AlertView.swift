//
//  AlertView.swift
//  PrizeArena
//
//  Created by Dmitry Shashlov on 06/02/16.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation
import UIKit

public class AlertView : ModelConfigurableView {
    
    @IBOutlet var button: CustomButton?
    @IBOutlet var purpleButton: PurpleButton?
    @IBOutlet var grayButton: GrayButton?
    @IBOutlet var facebookButton: FacebookButton?
    
    @IBOutlet var cancelButton: CustomButton?
    @IBOutlet var label: UILabel?

    override public func awakeFromNib() {
        super.awakeFromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // Button
        button?.fontSize = .Small
        cancelButton?.fontFamily = .RamblaBold
        button?.color = Colors.purple
        button?.textColor = Colors.white
        button?.cornerRadius = 25.0
        
        // Cancel button
        cancelButton?.fontSize = .Large
        cancelButton?.fontFamily = .RamblaRegular
        cancelButton?.color = Colors.clear
        cancelButton?.textColor = Colors.lightGray
        
        // Label        
        updateLabel()
        
        // Add self as observer to button's states
        for btn in [ button, purpleButton, grayButton, facebookButton ] as Array<UIButton?> {
            btn?.addObserver(self, forKeyPath: "showShadow", options: .New, context: UnsafeMutablePointer<Int>(nil))
        }
        
        clipsToBounds = false
    }
    
    deinit {
        for btn in [ button, purpleButton, grayButton, facebookButton ] as Array<UIButton?> {
            btn?.removeObserver(self, forKeyPath: "showShadow")
        }
    }
    
    override public func configureWithViewModel(viewModel: ViewModel<AnyObject>) {
        if let alertModel = viewModel.model as? AlertButtonModel {
            let alertViewModel = ViewModel(model: alertModel)

            // Button color
            if let buttonColor = alertViewModel.buttonColor {
                button?.color = buttonColor
            }
            
            // Text color
            if let textColor = alertViewModel.textColor {
                button?.textColor = textColor
            }
                        
            // Button font size
            if let buttonFontSize = alertViewModel.buttonFontSize {
                button?.fontSize = buttonFontSize
            }
            
            // Left alignment
            if let textAlignment = alertViewModel.textAlignment {
                label?.textAlignment = textAlignment
            }
                        
            updateLabel()
            
            // Cancel text
            if let cancelAttributedString = alertViewModel.cancelButtonAttributedTitle {
                label?.attributedText = cancelAttributedString
            } else {
                label?.text = alertViewModel.buttonTitle
            }
            
            // Icon
            if let (buttonIcon, reversed) = alertViewModel.buttonImage {
                button?.setImage(buttonIcon, forState: .Normal)   
                button?.imageEdgeInsets = UIEdgeInsetsMake(2.0, pow(-1, reversed ? 1 : 0) * (label!.frame.size.width - button!.imageForState(.Normal)!.size.width - 40.0), 0.0, 0.0)
            }           
            
            // Corner radius
            if let cornerRadius = alertViewModel.cornerRadius {
                button?.cornerRadius = cornerRadius
            }
        }
    }
    
    // Private
    
    func updateLabel() {
        for case .Some(let btn) in [ self.button, self.purpleButton, self.grayButton, self.facebookButton, self.cancelButton ] as Array<UIButton?> {
            label?.font = btn.titleLabel?.font
            label?.userInteractionEnabled = false
            label?.textColor = btn.titleColorForState(.Normal)
        }
    }
    
    // Multiline labels
    override public func multilineLabels() -> [UILabel?] {
        return [
            label
        ]
    }
    
    // MARK: Observing
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        switch (keyPath, object) {
            case (.Some("showShadow"), let object) where object is UIButton:
                let button = object as! UIButton
                label?.textColor = button.titleColorForState(.Normal)?.colorWithAlphaComponent((change![NSKeyValueChangeNewKey] as! Bool) ? 1.0 : 0.75)
            default: break
        }
    }
}