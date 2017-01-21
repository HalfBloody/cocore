//
//  TableViewAbstractModelController.swift
//  PrizeArena
//
//  Created by Dmitry Shashlov on 23/01/16.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation
import UIKit

public struct TableSection<T: TableModelDataSource> {
    public let section: Int
}

public class TableViewAbstractModelController : UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    private var viewIdentifiers = [String]()
    @IBOutlet public var tableView: UITableView?

    // Zero view
    var zeroView: ZeroView?
    
    // Zero label
    public var zeroTitle: String = "No data" {
        didSet {
            zeroLabel?.text = zeroTitle
        }
    }
    public var zeroHidden: Bool = true {
        didSet {
            zeroLabel?.hidden = zeroHidden
            adjustZeroLabel(self.tableView!)
        }
    }
    @IBOutlet var zeroLabelVerticalOffsetConstraint: NSLayoutConstraint?
    @IBOutlet var zeroLabel: UILabel?
        
    // let modelDataSources: [ AnyObject ]
    private var modelDataSources = [ AnyObject ]()
    private var modelDataSourceThunks = [ TableModelDataSourceThunk ]()
    private var modelViewDataSources = [ ModelViewDataSource ]()

    ///
    
    public func addDataSource<T: TableModelDataSource where T.ModelType: AnyObject>(modelDataSource: T, modelViewDataSource: ModelViewDataSource) -> TableSection<T> {
        
        // Add model provider to array
        modelDataSources.append(modelDataSource as! AnyObject)
        modelDataSourceThunks.append(TableModelDataSourceThunk(modelDataSource))
        
        // Setup reusable identifiers
        setupReusableIdentifiers(modelDataSource)
        
        // Add model view data source
        modelViewDataSources.append(modelViewDataSource)
        
        return TableSection(section: modelDataSources.count - 1)
    }
    
    public func modelDataSourceForSection<T: TableModelDataSource>(tableSection: TableSection<T>) -> T {
        return modelDataSources[tableSection.section] as! T
    }
    
    public func modelDataSourceThunkForSection(section: Int) -> TableModelDataSourceThunk {
        return modelDataSourceThunks[section]
    }
    
    //

    public init(nibName nibName: String) {
        super.init(nibName: nibName, bundle: NSBundle.bundleForNib(nibName))
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // View
    
    override public func viewDidLoad() {
        super.viewDidLoad()  
        
        // Setup table view
        if (tableView == nil) {
            let tableView = UITableView(frame: self.view.bounds)
            tableView.delegate = self
            tableView.dataSource = self
            self.view.addSubview(tableView)
            self.tableView = tableView;
        }
        
        // Register view identifiers
        registerReusableIdentifiers()
                
        // Hide cell separator by default
        tableView?.separatorColor = UIColor.clearColor()
        
        // Customize zero label
        zeroLabel?.font = UIFont.customFont(.RamblaRegular, .Medium)
        zeroLabel?.textColor = Colors.lightGray
        
        // Hide zero label by default
        zeroHidden = false
    }
    
    // View identifiers registration
    
    public func setupReusableIdentifiers<T: TableModelDataSource>(modelDataSource: T) {
        switch modelDataSource {
            case let collectionModelDataSource as CollectionTableModelDataSource<T.ModelType>:
                viewIdentifiers.append(collectionModelDataSource.viewIdentifier)
            case let detailsModelDataSource as DetailsTableModelDataSource<T.ModelType>:
                for viewIdentifier in detailsModelDataSource.viewIdentifiers {
                    viewIdentifiers.append(viewIdentifier)
                }
            default: fatalError("Can't register view identifiers from data source.")
        }
    }
    
    public func registerReusableIdentifiers() {
        for viewIdentifier in viewIdentifiers {
            tableView?.registerClass(DecoratedTableViewCell.self, forCellReuseIdentifier: viewIdentifier)
        }
    }
    
    // UITableViewDataSource
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelDataSourceThunkForSection(section).totalNumberOfRows()
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return modelDataSources.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Dequeue cell
        let viewIdentifier = viewIdentifierForIndexPath(indexPath)
        let decoratedCell = self.tableView!.dequeueReusableCellWithIdentifier(viewIdentifier) as! DecoratedTableViewCell
        decoratedCell.backgroundColor = UIColor.clearColor()
        
        // Setup decorated cell's width with tableView's width
        decoratedCell.frame = CGRectMake(0, 0, tableView.frame.size.width, decoratedCell.frame.size.height)
        
        switch modelViewDataSourceForIndexPath(indexPath) {
            case is StaticHeightReusableModelViewDataSource: break
            default: setupDecoratedCell(decoratedCell, indexPath: indexPath)
        }
                
        return decoratedCell
    } 
    
    public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        switch (cell, modelViewDataSourceForIndexPath(indexPath)) {
            
            case (let decoratedCell as DecoratedTableViewCell, is StaticHeightReusableModelViewDataSource):
                setupDecoratedCell(decoratedCell, indexPath: indexPath)
            
            default:
                break
        }
        
        // Disable selection style
        cell.selectionStyle = .None
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        var totalHeight: CGFloat!
        
        // Height change offset
        switch modelViewDataSourceForIndexPath(indexPath) {
            case let staticHeightDataSource as StaticHeightReusableModelViewDataSource:
                totalHeight = staticHeightDataSource.configurableViewDummy?.frame.size.height ?? viewModelConfigurableForIndexPath(indexPath).frame.size.height
            case let reusableDataSource as ReusableModelViewDataSource:
                totalHeight = viewModelConfigurableForIndexPath(indexPath).frame.size.height + (reusableDataSource.heightChange(indexPath) ?? 0.0)
            default: break
        }        
        
        // Decorator offset
        switch decoratorForIndexPath(indexPath) {
            case let prizeListDecorator as AdjustableVerticalDecorator: 
                totalHeight = totalHeight + prizeListDecorator.totalVerticalAdjustment()
            default: break
        }
        
        return CGFloat(ceilf(Float(totalHeight)))
    }
    
    // MARK: Setup cell
    
    private func setupDecoratedCell(decoratedCell: DecoratedTableViewCell, indexPath: NSIndexPath) {
        if let mcv = decoratedCell.contentView.subviews.first as? ModelConfigurableView,
            let _ = modelViewDataSourceForIndexPath(indexPath) as? StaticHeightReusableModelViewDataSource {
            setupViewModelConfigurableForIndexPath(mcv, indexPath: indexPath)
        } else {
           
            // View model configurable
            let configurable = viewModelConfigurableForIndexPath(indexPath)
            
            // Configure cell
            configureCellWithViewModelConfigurable(
                decoratedCell,
                modelConfigurableView: configurable,
                decorator: decoratorForIndexPath(indexPath))
            
            // Configure with view model
            setupViewModelConfigurableForIndexPath(configurable, indexPath: indexPath)
        }
    }
    
    // 
    
    public func anyModelForIndexPath(indexPath: NSIndexPath) -> AnyObject {
        return modelDataSourceThunkForSection(indexPath.section).modelForIndex(indexPath.row)
    }
        
    public func modelForIndexPath<T: TableModelDataSource>(indexPath: NSIndexPath, tableSection: TableSection<T>) -> T.ModelType {
        return modelDataSourceForSection(tableSection).modelForIndex(indexPath.row)
    }
    
    public func viewIdentifierForIndexPath(indexPath: NSIndexPath) -> String {
        return modelDataSourceThunkForSection(indexPath.section).viewIdentifierForIndex(indexPath.row)
    }
    
    //
    
    public func configureCellWithViewModelConfigurable(containerTableViewCell: DecoratedTableViewCell, modelConfigurableView: ModelConfigurableView, decorator: Decorator) {
        // Add model configurable view as cell's contentView subview
        containerTableViewCell.setupDecoratedView(modelConfigurableView, decorator: decorator)
    }
    
    //
    
    public func viewModelConfigurableForIndexPath(indexPath: NSIndexPath) -> ModelConfigurableView {
        return modelViewDataSourceForIndexPath(indexPath).viewModelConfigurableForViewIdentifier(viewIdentifierForIndexPath(indexPath), indexPath: indexPath)
    }
    
    public func setupViewModelConfigurableForIndexPath(modelConfigurableView: ModelConfigurableView, indexPath: NSIndexPath) -> ModelConfigurableView {
        
        // Model view data source
        let modelViewDataSource = modelViewDataSourceForIndexPath(indexPath)
               
        // Configure it with model
        modelConfigurableView.configureWithViewModel(ViewModel(model: anyModelForIndexPath(indexPath)))
        
        // Height adjustment
        if let reusableModelViewDataSource = modelViewDataSource as? ReusableModelViewDataSource {
            switch (reusableModelViewDataSource, reusableModelViewDataSource.heightChange(indexPath)) {
                
                // Height is not changeable
                case (is StaticHeightReusableModelViewDataSource, _):
                    break
                    
                case (_, .None):
                    
                    let multilineLabels = modelConfigurableView.multilineLabels()
                    
                    // Original label heights array
                    let originalLabelHeights: [CGFloat?]
                        = multilineLabels
                            .map { $0?.frame.size.height }
                    
                    // Layout subviews on configurable view
                    modelConfigurableView.layoutSubviews()
                    
                    // Label heights when layouted
                    let adjustedLabelHeights : [CGFloat?]
                        = multilineLabels
                            .map { $0?.frame.size.height }
                    
                    // Calculate height change for indexPath
                    let heightChange: CGFloat
                        = zip(originalLabelHeights, adjustedLabelHeights)
                            .filter { $0.0 != nil }
                            .map { CGFloat(ceil($0.1! - $0.0!)) }
                            .filter { $0 > 0 }
                            .reduce(0) { $0 + $1 }
                    
                    // Store height change for indexPath
                    reusableModelViewDataSource.setHeightChange(heightChange, indexPath: indexPath)
                
                default:
                    break
            }
        }
        
        return modelConfigurableView
    }
    
    public func decoratorForIndexPath(indexPath: NSIndexPath) -> Decorator {
        return BasicDecorator()
    }
    
    public func modelViewDataSourceForIndexPath(indexPath: NSIndexPath) -> ModelViewDataSource {
        return modelViewDataSources[indexPath.section]
    }
    
    // Zero label adjustments
    
    func zeroLabelOffsetY() -> CGFloat {
        return 0.0
    }
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        adjustZeroLabel(scrollView)
    }
    
    private func adjustZeroLabel(scrollView: UIScrollView) {
        if isViewLoaded() {
            if let verticalConstraint = zeroLabelVerticalOffsetConstraint {
                let offsetY = zeroLabelOffsetY()
                let centerY = offsetY + (
                    scrollView.frame.size.height
                        - scrollView.contentOffset.y 
                        - (navigationController?.navigationBar.frame.size.height ?? 0.0) 
                        - UIApplication.sharedApplication().statusBarFrame.height
                        - offsetY
                        + (tabBarController?.tabBar.frame.size.height ?? 0.0)
                        - scrollView.contentInset.bottom) / 2.0
                verticalConstraint.constant = centerY - scrollView.frame.size.height / 2
            }
        }
    }
}

// Private extension to handle table view reloads
extension TableViewAbstractModelController {
    
    public func totalIndexPathsForSection<T: TableModelDataSource>(tableSection: TableSection<T>) -> [NSIndexPath] {
        return (0..<modelDataSourceForSection(tableSection).totalNumberOfRows()).map { NSIndexPath(forRow: $0, inSection: tableSection.section) }
    }
    
    public func updateTableView<T: TableModelDataSource>(
        tableSection: TableSection<T>,
        beforeCount: Int,
        afterCount: Int,
        finalIndexPaths: [NSIndexPath]?,
        cellAnimationType: UITableViewRowAnimation = .Fade) {
        
        let reverseAnimationType: UITableViewRowAnimation = {
            switch cellAnimationType {
                case .Left: return .Right
                case .Right: return .Left
                default: return .Fade
            }
        }()
        
        // Begin table view updates
        tableView?.beginUpdates()

        switch (beforeCount, afterCount, finalIndexPaths) {
            
            // More models that cells
            case (let bc, let ac, _) where ac > bc:
                
                // Insert rows
                let indexPathsToInsert = (beforeCount..<afterCount).map { NSIndexPath(forRow: $0, inSection: tableSection.section) }
                tableView?.insertRowsAtIndexPaths(indexPathsToInsert, withRowAnimation: reverseAnimationType)
                
                // Reload rows
                let indexPathsToReload = (0..<beforeCount).map { NSIndexPath(forRow: $0, inSection: tableSection.section) }
                tableView?.reloadRowsAtIndexPaths(indexPathsToReload, withRowAnimation: cellAnimationType)
            
            // More cells that models
            case (let bc, let ac, _) where ac < bc:

                // Delete rows
                let indexPathsToRemove = (afterCount..<beforeCount).map{ NSIndexPath(forRow: $0, inSection: tableSection.section) }
                tableView?.deleteRowsAtIndexPaths(indexPathsToRemove, withRowAnimation: cellAnimationType)
                
                // Reload rows
                let indexPathsToReload = (0..<afterCount).map { NSIndexPath(forRow: $0, inSection: tableSection.section) }
                tableView?.reloadRowsAtIndexPaths(indexPathsToReload, withRowAnimation: cellAnimationType)
            
            // Number of rows not changed, just reload
            case (let bc, let ac, .Some(let indexPaths)) 
                where ac == bc && indexPaths.count > 0:
                tableView?.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: cellAnimationType)
            
            default: break
        }
        
        // End table view updates
        tableView?.endUpdates()
    }    
}

// Collection data source
extension TableViewAbstractModelController {
    
    // Returns true if every model is the same in the same order, otherwise false
    public func assignCollectionModels<M: Equatable>(tableSection: TableSection<CollectionTableModelDataSource<M>>, models: [M]) -> [NSIndexPath]? {
        
        let collectionDataSource = modelDataSourceForSection(tableSection)
        
        // Assign model results
        let currentModels = collectionDataSource.models.flatMap { $0 }
        collectionDataSource.assignModels(models)
                
        // Determine whether objects changed or not
        var eachEqual = false
        if currentModels.count == models.count {
            eachEqual = (0..<currentModels.count)
                .map { currentModels[$0] == models[$0] }
                .reduce(true){ $0 && $1 }
        }
        
        // If every prize model equals to every assigned
        if eachEqual {
            return nil
        }
        
        return totalIndexPathsForSection(tableSection)
    }
    
    // Assign models and perform animations
    public func assignModels<M: Equatable>(
        tableSection: TableSection<CollectionTableModelDataSource<M>>,
        models: [M],
        cellAnimationType: UITableViewRowAnimation = .Fade,
        reloadTableView: Bool = true) {
                
        let beforeCount = modelDataSourceForSection(tableSection).totalNumberOfRows()
        
        // Update table view
        if reloadTableView {
            updateTableView(tableSection,
                beforeCount: beforeCount, 
                afterCount: models.count, 
                finalIndexPaths: assignCollectionModels(tableSection, models: models),
                cellAnimationType: cellAnimationType)
        } else {
            assignCollectionModels(tableSection, models: models)
        }
    }
    
    public func assignCollectionIdentifier<T: TableModelDataSource>(tableSection: TableSection<T>, identifier: String) {
        if let buttonsDataSource = modelDataSourceForSection(tableSection) as? CollectionTableModelDataSource<T.ModelType> {
            buttonsDataSource.viewIdentifier = identifier
            setupReusableIdentifiers(buttonsDataSource)
            
            // Register identifiers
            if isViewLoaded() {
                registerReusableIdentifiers()
            }
        }
    }
}

// Details data source
extension TableViewAbstractModelController {
    
    public func assignDetailsIdentifiers<T: TableModelDataSource>(
        tableSection: TableSection<T>,
        identifiers: [String],
        cellAnimationType: UITableViewRowAnimation = .Fade) {
        if let detailsDataSource = modelDataSourceForSection(tableSection) as? DetailsTableModelDataSource<T.ModelType> { 
                        
            // Before count
            let beforeCount = detailsDataSource.totalNumberOfRows()
            detailsDataSource.viewIdentifiers = identifiers
            setupReusableIdentifiers(detailsDataSource)
            
            // Register identifiers
            if isViewLoaded() {
                registerReusableIdentifiers()
            }
            
            // Update table view
            updateTableView(tableSection, 
                beforeCount: beforeCount, 
                afterCount: identifiers.count, 
                finalIndexPaths: totalIndexPathsForSection(tableSection),
                cellAnimationType: cellAnimationType)
        }
    }
}

extension TableViewAbstractModelController {
    public func assignDetailsModel<M: Equatable>(detailsDataSource: DetailsTableModelDataSource<M>, model: M) -> Bool {
        let equal = detailsDataSource.model == model
        detailsDataSource.assignModel(model)
        
        return equal
    }
    
    public func assignModel<T: TableModelDataSource, M: Equatable where T.ModelType == M>(tableSection: TableSection<T>, model: M) {
        let modelDataSource = modelDataSourceForSection(tableSection)        
        if let detailsDataSource = modelDataSource as? DetailsTableModelDataSource<M> {            
            
            // Reload row only if model to assign not equal to already assigned one
            if !assignDetailsModel(detailsDataSource, model: model) {
                
                // Reload rows
                let indexPathsToReload = (0..<modelDataSource.totalNumberOfRows()).map { NSIndexPath(forRow: $0, inSection: tableSection.section) }
                tableView?.reloadRowsAtIndexPaths(indexPathsToReload, withRowAnimation: .None)
            }
        }
    }
}

// Zero view
extension TableViewAbstractModelController {
    
    public func setupZeroView(zeroView: ZeroView) {
        
        // Remove it from superview
        let previousZeroView = self.zeroView
        
        // Assign and add to view
        self.zeroView = zeroView
        
        // Insert zero view below previous zero view or above tableView
        if let pzv = previousZeroView {
            self.view.insertSubview(zeroView, belowSubview: pzv)
        } else {
            self.view.insertSubview(zeroView, aboveSubview: tableView!)
        }
        
        // Constraints
        self.view.addConstraints([
            
            // X
            NSLayoutConstraint(item: zeroView,
                attribute: .Leading,
                relatedBy: .Equal,
                toItem: self.view,
                attribute: .Leading,
                multiplier: 1.0,
                constant: 0.0),
            NSLayoutConstraint(item: zeroView,
                attribute: .Trailing,
                relatedBy: .Equal,
                toItem: self.view,
                attribute: .Trailing,
                multiplier: 1.0,
                constant: 0.0),
            
            // Y
            NSLayoutConstraint(item: zeroView,
                attribute: .Height,
                relatedBy: .Equal,
                toItem: nil,
                attribute: .NotAnAttribute,
                multiplier: 1.0,
                constant: zeroView.frame.size.height),
            NSLayoutConstraint(item: zeroView,
                attribute: .CenterY,
                relatedBy: .Equal,
                toItem: self.tableView,
                attribute: .CenterY,
                multiplier: 1.0,
                constant: 0.0)
            ])
        
        // Fade in zero view
        zeroView.alpha = 0.00
        UIView.animateWithDuration(0.33, animations: {
            zeroView.alpha = 1.0
            previousZeroView?.alpha = 0.0
            }, completion: { 
                completed in
                previousZeroView?.removeFromSuperview()
        })
    }
    
    public func removeZeroView() {
    
        if let zv = zeroView {
            self.zeroView = nil
            UIView.animateWithDuration(0.33, animations: {
                zv.alpha = 0.0
                }, completion: { _ in
                    zv.removeFromSuperview()
            })
        }
    }
}