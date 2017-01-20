//
//  AlertController.swift
//  PrizeArena
//
//  Created by Dmitry Shashlov on 05/02/16.
//  Copyright © 2016 Half Bloody. All rights reserved.
//

import Foundation
import UIKit

public protocol AlertControllerDelegate {
    func alertControllerButtonClicked(alertController: AlertController, buttonIndex: Int)
    func alertControllerAlternativeButtonClicked(alertController: AlertController)
    func alertControllerDismissed(alertController: AlertController)
}

public struct AlertButtonConfiguration {
    public let item: AlertController.AlertItem
    public let title: String
    public let color: UIColor?
    public let textColor: UIColor?
    public let fontSize: FontSize?
    public let iconImage: (UIImage, Bool)?
    public let cornerRadius: CGFloat?
    public let textAlignment: NSTextAlignment?

    public init(item: AlertController.AlertItem, title: String, color: UIColor?, textColor: UIColor?, fontSize: FontSize?, iconImage: (UIImage, Bool)?, cornerRadius: CGFloat, textAlignment: NSTextAlignment?) {
        self.item = item
        self.title = title
        self.color = color
        self.textColor = textColor
        self.fontSize = fontSize
        self.iconImage = iconImage
        self.cornerRadius = cornerRadius
        self.textAlignment = textAlignment
    }
}

public class AlertController : TableViewAbstractModelController {
    
    var cellHeights = Dictionary<NSIndexPath,CGFloat>()
    public var shouldCenterVertically = true
    
    @IBOutlet var dismissButton: UIButton?
    @IBOutlet var backgroundView: UIImageView?
    
    let headerImage: UIImage?
    @IBOutlet var headerImageViewTopOffset: NSLayoutConstraint?
    @IBOutlet var headerImageView: UIImageView?
    
    // Buttons
    var buttons = [AlertView]()
    
    var headerImageViewTopPadding: CGFloat = CGFloat(0.0)
    @IBOutlet var headerImageViewTopConstraint: NSLayoutConstraint?
    public var alertDelegate: AlertControllerDelegate?
    
    public enum AlertItem: String {
        case Margin = "Alert_Margin"
        case Button = "Alert_Button"
        case ButtonAccent = "Alert_ButtonAccent"
        case PurpleButton = "Alert_PurpleButton"
        case GrayButton = "Alert_GrayButton"
        case FacebookButton = "Alert_FacebookButton"
        case CancelButton = "Alert_CancelButton"
    }
    
    // let buttonsDataSource: CollectionTableModelDataSource<AnyObject>
    let alertModelViewDataSource = ConfigurableModelViewDataSource<AlertView>()
    
    // Sections
    var headerSection: TableSection<DetailsTableModelDataSource<AlertModel>>?
    var buttonsSections = Array<TableSection<DetailsTableModelDataSource<AlertButtonModel>>>()
    var cancelButtonSection: TableSection<DetailsTableModelDataSource<AlertButtonModel>>?
    var footerSection: TableSection<DetailsTableModelDataSource<AlertModel>>?
    
    // Init
    
    public init(_ headerImage: UIImage?,
        buttonTitles: [AlertButtonConfiguration], 
        cancelButtonTitle: String?, 
        dismissAllowed: Bool,
        nibName: String,
        setupContentDataSources: (AlertController) -> ()) {
            
            // Header iamge
            self.headerImage = headerImage
            
            super.init(nibName: nibName)

            // Header section
            let headerModel = AlertModel(headerImage: headerImage)
            let headerModelDataSource = DetailsTableModelDataSource(model: headerModel, 
                viewIdentifiers: [ AlertItem.Margin.rawValue, AlertItem.Margin.rawValue ])            
            headerSection = addDataSource(headerModelDataSource, modelViewDataSource: alertModelViewDataSource)             
            
            // Content sections
            setupContentDataSources(self)
            
            // Button section
            for buttonConfiguration in buttonTitles {
                let buttonModel = AlertButtonModel(
                    AlertButton.Button(
                        title: buttonConfiguration.title, 
                        color: buttonConfiguration.color ?? Colors.purple, 
                        textColor: buttonConfiguration.textColor ?? Colors.black, 
                        fontSize: buttonConfiguration.fontSize, 
                        image: buttonConfiguration.iconImage, 
                        cornerRadius: buttonConfiguration.cornerRadius, 
                        textAlignment: buttonConfiguration.textAlignment ?? .Center))
                let buttonsDataSource = DetailsTableModelDataSource(model: buttonModel, viewIdentifiers: [buttonConfiguration.item.rawValue])
                buttonsSections.append(addDataSource(buttonsDataSource, modelViewDataSource: alertModelViewDataSource))
            }
            
            // Cancel button section
            if let cancelButtonTitle = cancelButtonTitle {
                let attributedTitle = NSAttributedString(string: cancelButtonTitle,
                                                         attributes: [
                                                            NSFontAttributeName : UIFont.customFont(.RamblaRegular, .Large),
                                                            NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleSingle.rawValue
                                                        ])
                let cancelButtonModel = AlertButtonModel(AlertButton.CancelButton(attributedTitle: attributedTitle))
                let cancelButtonDataSource = DetailsTableModelDataSource(model: cancelButtonModel, viewIdentifiers: [ AlertItem.CancelButton.rawValue ] );
                cancelButtonSection = addDataSource(cancelButtonDataSource, modelViewDataSource: alertModelViewDataSource)
            } else {
                // Footer data source
                let footerDataSource = DetailsTableModelDataSource(model: headerModel, viewIdentifiers: [ AlertItem.Margin.rawValue ])
                footerSection = addDataSource(footerDataSource, modelViewDataSource: alertModelViewDataSource)
            }
            
            // Alert configurator
            alertModelViewDataSource.configurator = { 
                [unowned self] (alertView: AlertView, indexPath: NSIndexPath) -> AlertView? in
                switch (self.cancelButtonSection, indexPath.section, indexPath.row) {
                    
                    // buttons
                    case (_, self.rawButtonsSectionRange() ?? 999...999/*FIXME!*/, _):
                        alertView.button?.selectionEnabled = false
                        
                        let buttonIndex = indexPath.section - self.buttonsSections.first!.section
                        
                        // Handle button taps
                        for btn in [ alertView.button, alertView.purpleButton, alertView.grayButton, alertView.facebookButton ] as Array<UIButton?> {
                            btn?.rac_signalForControlEvents(.TouchUpInside)
                                .subscribeNext { _ in
                                    self.alertDelegate?.alertControllerButtonClicked(self, buttonIndex: buttonIndex)
                                }
                        }
                        
                        if self.buttons.count < buttonTitles.count {
                            self.buttons.append(alertView)
                        }
                        return self.buttons[buttonIndex]
                    
                    // cancel button
                    case (.Some(let cancelButtonSection), let section, _) where section == cancelButtonSection.section: 
                        alertView.cancelButton?.selectionEnabled = false
                        alertView.cancelButton?.rac_signalForControlEvents(.TouchUpInside)
                        .subscribeNext { _ in
                            self.alertDelegate?.alertControllerAlternativeButtonClicked(self)
                        }
                    default: break
                }
                
                return nil
            }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Buttons
    
    public func selectAllButtons(selected selected: Bool) {
        for buttonIndex in 0..<buttons.count {
            selectButton(buttonIndex, selected: selected)
        }
    }
    
    public func selectButton(index: Int, selected: Bool) {
        if let button = buttons[index].button {            
            if selected {
                button.selectionEnabled = selected
                button.selected = selected
                button.selectionEnabled = false
                buttons[index].label?.textColor = button.selectedTextColor
            } else {
                button.selectionEnabled = true
                button.selected = selected
                button.selectionEnabled = false
                buttons[index].label?.textColor = button.textColor
            }
        }
    }
    
    // View
    
    override public func viewDidLoad() {        
        super.viewDidLoad()
        
        // Header image view top offset
        headerImageViewTopOffset?.constant = UIScreen.mainScreen().bounds.size.height / 4
        
        // Header image
        if let topContant = headerImageViewTopConstraint?.constant {
            headerImageViewTopPadding = topContant
        }
        headerImageView?.image = headerImage
        
        // Table view
        tableView?.separatorStyle = .None
        
        // Simply dismiss controller by clickeing dismiss button
        dismissButton?.rac_signalForControlEvents(.TouchDown).subscribeNext { _ in
            self.alertDelegate?.alertControllerDismissed(self)
        }        
    }
        
    // Table View Delegate
        
    override public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
            case (headerSection!.section, 0): return self.shouldCenterVertically ? UIApplication.sharedApplication().statusBarFrame.size.height : 0.0
            case (headerSection!.section, 1): return (headerImage?.size.height ?? 0.0) / 2.0
            default: return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
    
    /*
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        // Move header image along with content offset
        headerImageViewTopConstraint?.constant = headerImageViewTopPadding - tableView!.contentOffset.y
        
        // Fade out navigation bar on content offset more than navigation bar height
        navigationController?.navigationBar.alpha = 1 - min(1, scrollView.contentOffset.y / navigationController!.navigationBar.frame.size.height)
    }
    */
        
    // Decoration
    
    override public func decoratorForIndexPath(indexPath: NSIndexPath) -> Decorator {
        switch (indexPath.section, indexPath.row) {
            default: return super.decoratorForIndexPath(indexPath)
        }
    }
    
    // Helper
    
    func contentSectionRange() -> Range<Int> {
        return (headerSection!.section+1)..<buttonsSectionRange().startIndex
    }
    
    func buttonsSectionRange() -> Range<Int>  {
        if let footerSection = footerSection {
            if let rawButtonsStartIndex = rawButtonsSectionRange()?.startIndex {
                return rawButtonsStartIndex...footerSection.section
            } else {
                return 999...999
            }
        } else if let cancelButtonSection = cancelButtonSection {
            if let rawButtonsStartIndex = rawButtonsSectionRange()?.startIndex {
                return rawButtonsStartIndex...cancelButtonSection.section
            } else {
                return 999...999
            }
        }
        return buttonsSections.first!.section...buttonsSections.last!.section
    }
    
    // MARK: ---
    
    func rawButtonsSectionRange() -> Range<Int>? {
        if buttonsSections.count > 0 {
            return buttonsSections.first!.section...buttonsSections.last!.section
        }
        
        return .None
    }
    
    // MARK: Table view
    
    override public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(tableView, willDisplayCell: cell, forRowAtIndexPath: indexPath)
        
        cellHeights[indexPath] = cell.frame.size.height
        printd("Cell height \(indexPath.section):\(indexPath.row): \(cell.frame.size.height)")
        
        // When every cell is displayed
        var totalNumberOfCells = 0
        for section in 0..<tableView.numberOfSections {
            totalNumberOfCells += tableView.numberOfRowsInSection(section)
        }
        
        // Center vertically
        if shouldCenterVertically
            && cellHeights.keys.count == totalNumberOfCells {
            let totalTableViewHeight: CGFloat = cellHeights.reduce(0.0, combine: { totalHeight, iterator in totalHeight + iterator.1 })
            printd("Total (\(totalNumberOfCells) cells) table view height: \(totalTableViewHeight)")
            
            tableView.contentInset = UIEdgeInsets(top: (view.frame.size.height - totalTableViewHeight) / 2, left: 0, bottom: 0, right: 0)
        }
    }
}