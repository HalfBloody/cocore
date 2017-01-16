//
//  PrizeDetailsView.swift
//  PrizeArena
//
//  Created by Dmitry Shashlov on 31/01/16.
//  Copyright © 2016 Half Bloody. All rights reserved.
//

import Foundation
import UIKit

// MARK: Type

enum ZeroViewType {
    case Empty(title: String, text: String)
    case Lock(title: String, text: String, boldText: String, buttonTitle: String, buttonHandler: ActionHandler)
}

class ZeroView : ModelConfigurableView {
    
    // MARK: Handler
    
    var buttonHandler: ActionHandler?
    
    // MARK: -
    
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var textLabel: UILabel?
    @IBOutlet var button: PurpleButton?
    @IBOutlet var imageView: UIImageView?
        
    // MARK: Construction
    
    class func construct(type: ZeroViewType) -> ZeroView {

        let zeroView: ZeroView
        switch type {
            
            // Empty
            case .Empty(let title, let text): 
                zeroView = NSBundle.mainBundle().loadNibNamed("Zero_Empty", owner: nil, options: [:]).first as! ZeroView
                zeroView.titleLabel?.text = title
                zeroView.textLabel?.text = text               
            
            // Lock
            case .Lock(let title, let text, let boldText, let buttonTitle, let buttonHandler):
                zeroView = NSBundle.mainBundle().loadNibNamed("Zero_Lock", owner: nil, options: [:]).first as! ZeroView
                zeroView.titleLabel?.text = title
                zeroView.button?.setTitle(buttonTitle, forState: .Normal)
                zeroView.buttonHandler = buttonHandler            
            
                // Text
                let attributedString = NSMutableAttributedString(
                    string: text, 
                    attributes: [ 
                        NSFontAttributeName : UIFont.customFont(.RamblaRegular, .Larger),
                        NSForegroundColorAttributeName : Colors.lightGray
                    ])
                
                // Bold text
                attributedString.appendAttributedString(
                    NSAttributedString(
                        string: " \(boldText)", // Whitespace between regular and bold string
                        attributes: [ 
                            NSFontAttributeName : UIFont.customFont(.RamblaBold, .Larger),
                            NSForegroundColorAttributeName : Colors.black
                        ]))
                
                // Attributed string
                zeroView.textLabel?.attributedText = attributedString
        }
        
        return zeroView
    }
    
    // MARK: Layout
        
    override func awakeFromNib() {
        super.awakeFromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // Clear all label's backgrounds
        for case .Some(let label) in [
                textLabel
            ] {
                label.backgroundColor = UIColor.clearColor()
        }
        
        // Background
        backgroundColor = Colors.background

        // Title
        titleLabel?.textColor = Colors.black
        titleLabel?.font = UIFont.customFont(.RamblaBold, .XXLarge)

        // Text
        textLabel?.textColor = UIColor(rgb: 0x9ea5a8, alphaVal: 1.0)
        textLabel?.font = UIFont.customFont(.RamblaRegular, .Larger)        
    }
    
    override func configureWithViewModel(viewModel: ViewModel<AnyObject>) {
        // Nothing here
    }
    
    // Multiline labels
    override func multilineLabels() -> [UILabel?] {
        return [
            textLabel
        ]
    }
    
    // MARK: Actions
    
    @IBAction func buttonAction() {
        buttonHandler?()
    }
}