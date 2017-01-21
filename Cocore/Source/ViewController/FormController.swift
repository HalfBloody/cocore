//
//  FormController.swift
//  PrizeArena
//
//  Created by Dmitry Shashlov on 23/02/16.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import ReactiveCocoa

public protocol FormField: AnyObject {
    var control: UIControl? { get }

    // Value
    var value: AnyObject { get }
    func setValue(value: AnyObject)
    
    // Placeholder
    var placeholder: String? { get } 
    func setPlaceholder(placeholder: String)
    
    // Keyboard
    func setKeyboardType(keyboardType: UIKeyboardType)
    func setAutocapitalizationType(capitalizationType: UITextAutocapitalizationType)
    func setAutocorrectionType(correctionType: UITextAutocorrectionType)
}

func ==(lhs: FormField, rhs: FormField) -> Bool {
    return lhs.placeholder == rhs.placeholder
}

////

public protocol FormFieldHeader: AnyObject {
    func setName(name: String)
    func setBoldName(name: String)
    func setImage(image: UIImage)
}

public class CustomTextField : UITextField {
    override public func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 10, 10)
    }
    
    override public func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 10, 10)
    }
}

class SinglelineFormFieldView : ModelConfigurableView, FormField, FormFieldHeader {
    
    @IBOutlet var textField: CustomTextField?
    @IBOutlet var nameLabel: UILabel?
    @IBOutlet var imageView: UIImageView?

    // Form field
    var control: UIControl? {
        return textField
    }

    // Value
    var value: AnyObject { return textField?.text ?? "" }
    func setValue(value: AnyObject) { textField?.text = (value as? String) ?? "" }    

    // Placeholder
    var placeholder: String? { return textField?.placeholder }
    func setPlaceholder(placeholder: String) { textField?.placeholder = placeholder }
    
    // Keyboard
    func setKeyboardType(keyboardType: UIKeyboardType) { textField?.keyboardType = keyboardType }
    func setAutocapitalizationType(capitalizationType: UITextAutocapitalizationType) { textField?.autocapitalizationType = capitalizationType }
    func setAutocorrectionType(correctionType: UITextAutocorrectionType) { textField?.autocorrectionType = correctionType }
    
    // FormFieldHeader
    func setName(name: String) { nameLabel?.text = name }
    func setBoldName(name: String) { fatalError("Bold label not set") }
    func setImage(image: UIImage) { imageView?.image = image }
    
    // Responder
    
    override func resignFirstResponder() -> Bool {
        textField?.resignFirstResponder()
        return super.resignFirstResponder()
    }
        
    // Configuration
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // Clear all label's backgrounds
        for case .Some(let view) in [
            // textField as UIView?,
            nameLabel as UIView?,
            imageView as UIView?
            ] {
            view.backgroundColor = UIColor.clearColor()
        }
        
        // Text field
        textField?.contentVerticalAlignment = .Top
        textField?.font = UIFont.customFont(.RamblaRegular, .Large)
        textField?.textColor = Colors.black
        textField?.layer.cornerRadius = 5
        textField?.layer.borderColor = Colors.blue.CGColor
        textField?.layer.borderWidth = 1.0
        
        // Name label
        nameLabel?.font = UIFont.customFont(.RamblaRegular, .Large)
        nameLabel?.textColor = Colors.black
    }
}

////

public class FormFieldHeaderView : ModelConfigurableView, FormFieldHeader {
    @IBOutlet var nameLabel: UILabel?  
    @IBOutlet var boldNameLabel: UILabel?  
    @IBOutlet var imageView: UIImageView?
    
    // FormFieldHeader
    public func setName(name: String) { nameLabel?.text = name }
    public func setBoldName(name: String) { boldNameLabel?.text = name }
    public func setImage(image: UIImage) { imageView?.image = image }
    
    // Configuration
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.translatesAutoresizingMaskIntoConstraints = false
        
        // Clear all label's backgrounds
        for case .Some(let view) in [
            nameLabel as UIView?,
            boldNameLabel as UIView?
            ] {
                view.backgroundColor = UIColor.clearColor()
        }
        
        /*
        // Name label
        nameLabel?.font = UIFont.customFont(.RamblaRegular, .Medium)
        nameLabel?.textColor = Colors.darkGray
        
        // Bold label
        boldNameLabel?.font = UIFont.customFont(.RamblaBold, .Medium)
        boldNameLabel?.textColor = Colors.black
        */
    }
    
    override public func multilineLabels() -> [UILabel?] {
        return [
            // nameLabel,
            boldNameLabel
        ]
    }
}

////

public enum FieldType {
    public typealias LimitConfigurator = (String) -> (Bool)
    case SinglelineStringInput(placeholder: String, keyboardType: UIKeyboardType, capitalizationType: UITextAutocapitalizationType, correctionType: UITextAutocorrectionType, limitConfigurator: LimitConfigurator?)
    case SinglelineStringInputCompact(image: UIImage?, name: String, placeholder: String, keyboardType: UIKeyboardType, capitalizationType: UITextAutocapitalizationType, correctionType: UITextAutocorrectionType, limitConfigurator: LimitConfigurator)
    case MultilineStringInput(placeholder: String, numberOfLines: Int, keyboardType: UIKeyboardType, capitalizationType: UITextAutocapitalizationType, correctionType: UITextAutocorrectionType, limitConfigurator: LimitConfigurator)
    case Selection(image: UIImage?, name: String)
    
    func viewIdentifier() -> String {
        switch self {
            
            // Singleline
            case .SinglelineStringInput: return "FormField_Singleline"
            
            // Singleline compact
            case .SinglelineStringInputCompact: return "FormField_SinglelineCompact"
            
            // Multiline
            case .MultilineStringInput: return "FormField_Multiline"
            
            // Selection
            case .Selection(.Some(_), _): return "FormField_SelectionImage"
            case .Selection: return "FormField_Selection"
        }
    }
}

////

public enum FieldHeaderType {
    case Padding
    case Title(String)
    case BoldTitle(String)
    case SurveyQuestion(String, String)
    
    func viewIdentifier() -> String {
        switch self {
            case .Padding: return "FormFieldHeader_Padding"
            case .Title(_): return "FormFieldHeader_Title"
            case .BoldTitle(_): return "FormFieldHeader_BoldTitle"
            case .SurveyQuestion: return "FormFieldHeader_SurveyQuestion"
        }
    }
}

////

public protocol FieldConfigurable {
    associatedtype ModelType
    associatedtype ValueType
    func extractValue(model: ModelType) -> ValueType?
    func setupValue(value: ValueType, model: ModelType)
}

public struct FieldConfiguration<M: AnyObject, T> : FieldConfigurable {
    public let type: FieldType
    public var headerType: FieldHeaderType?
    public var extract: ((M) -> T)?
    public var setup: ((T, M) -> ())?

    public init(type: FieldType, headerType: FieldHeaderType?, extract: ((M) -> T)?, setup: ((T, M) -> ())?) {
        self.type = type
        self.headerType = headerType
        self.extract = extract
        self.setup = setup
    }
}

extension FieldConfiguration where M: AnyObject {
    public func extractValue(model: M) -> T? {
        return extract?(model)
    }
    
    public func setupValue(value: T, model: M) { 
        try! (try! Realm()).write { 
            setup?(value, model) 
        }
    }
}

/*
* FIXME: wrap realm transaction for M: Object
extension FieldConfiguration where M: Object {    
    func setupValue(value: T, model: M) -> () { 
        try! (try! Realm()).write { 
            setup(value, model) 
        }
    }    
}
*/

public enum FieldConfigurationError: ErrorType {
    case WrongHeaderIdentifier(String)
    case WrongFieldIdentifier(String)
}

////

public class FormFieldViewDataSource<M: Object> : ConfigurableModelViewDataSource<ModelConfigurableView> {
    
    lazy var fieldsConfigurations = [ NSIndexPath : FieldConfiguration<M, AnyObject> ]()
    lazy var fieldHeaders = [ NSIndexPath : FormFieldHeader ]()
    lazy var fieldViews = [ NSIndexPath : FormField ]()
    
    public init(_ fields: [ FieldConfiguration<M, AnyObject> ]) throws {
        super.init()
        
        var index = 0
        for configuration in fields {
                        
            // Form field header
            if case .Some(let headerType) = configuration.headerType {
                let headerIndexPath = NSIndexPath(forRow: index, inSection: 0); index += 1
                let headerViewIdentifier = headerType.viewIdentifier()
                guard let formFieldHeaderView = viewModelConfigurableForViewIdentifier(headerViewIdentifier, indexPath: headerIndexPath) as? FormFieldHeader else {
                    throw FieldConfigurationError.WrongHeaderIdentifier(headerViewIdentifier)
                }

                fieldHeaders[headerIndexPath] = formFieldHeaderView
            }
            
            // Store configuration
            let indexPath = NSIndexPath(forRow: index, inSection: 0); index += 1
            fieldsConfigurations[indexPath] = configuration
            
            // Form field
            let viewIdentifier = configuration.type.viewIdentifier()
            guard let formFieldView = viewModelConfigurableForViewIdentifier(viewIdentifier, indexPath: indexPath) as? FormField else {
                throw FieldConfigurationError.WrongFieldIdentifier(viewIdentifier)
            }
            fieldViews[indexPath] = formFieldView
        }
    }
    
    func indexPathForFormField(formField: FormField) -> NSIndexPath? {
        for case (let indexPath, let field) in fieldViews {
            if formField == field {
                return indexPath
            }
        }
        return nil
    }
}

public enum ServiceTransportError : ErrorType {
    case EmptyResponse
    case ServerError(error: NSError, response: NSHTTPURLResponse?, details: String?)
    
    var localizedDescription: String {
        switch (self)  {
        case .EmptyResponse: return "Empty response"
        case .ServerError(let error, _, .None): return error.localizedDescription
        case .ServerError(let error, _, .Some(let details)): return error.localizedDescription + "\nServer details: \(details)"
        }
    }
}

public enum FormError : ErrorType {
    case TransportError(ServiceTransportError, [NSIndexPath])
}

public protocol FormControllerDelegate {
    func formChanged()
}

public class FormController<M: Object> : TableViewAbstractModelController, FormControllerDelegate {
    
    var cellHeightCache = [NSIndexPath: CGFloat]()
    
    var delegate: FormControllerDelegate?

    lazy var modelCopies = [ NSIndexPath : M ]()
    let formViewModelDataSource: FormFieldViewDataSource<M>    
    
    typealias Spawner = (String, M -> SignalProducer<M, ServiceTransportError>)
    private var signalProducerSpawner = [NSIndexPath : Spawner ]()
    
    // Sections
    var fieldsSection: TableSection<DetailsTableModelDataSource<AnyObject>>?
    
    // Limit configurators
    var limitConfigurators = Dictionary<NSIndexPath, FieldType.LimitConfigurator>()

    public var originalTableInset: UIEdgeInsets?
    
    public init(model: M, fields: [ FieldConfiguration<M, AnyObject> ], nibName: String) {
        
        // Create form fields
        formViewModelDataSource = try! FormFieldViewDataSource(fields)

        // Construct view identifiers (prepend with header identifier if needed)
        let viewIdentifiers = fields.map { field -> [String] in
            var viewIdentifiers = [ field.type.viewIdentifier() ]
            if case .Some(let headerType) = field.headerType {
                viewIdentifiers.append(headerType.viewIdentifier())
            }             
            return viewIdentifiers.reverse()
        }.flatMap { $0 }        
        
        super.init(nibName: nibName)

        // Assign self as delegate
        delegate = self
        
        // Section
        fieldsSection = addDataSource(DetailsTableModelDataSource<AnyObject>(model: model, viewIdentifiers: viewIdentifiers ),
            modelViewDataSource: formViewModelDataSource)
        
        formViewModelDataSource.configurator = {
            [unowned self] (modelConfigurableView: ModelConfigurableView, indexPath: NSIndexPath) -> ModelConfigurableView? in
            
            switch (self.formViewModelDataSource.fieldHeaders[indexPath], self.formViewModelDataSource.fieldViews[indexPath]) {
                
                // Header
                case (.Some(let fieldHeader), .None):
                    let configurationIndexPath = NSIndexPath(forItem: indexPath.row + 1, inSection: indexPath.section)
                    let configuration = self.formViewModelDataSource.fieldsConfigurations[configurationIndexPath]!
                    
                    switch configuration.headerType {
                        
                        // Title
                        case .Some(.Title(let name)):
                            fieldHeader.setName(name)                        
                            
                        // Bold title
                        case .Some(.BoldTitle(let name)):
                            fieldHeader.setBoldName(name)
                        
                        // Survey question header
                        case .Some(.SurveyQuestion(let title, let text)):
                            fieldHeader.setName(title)
                            fieldHeader.setBoldName(text)
                        
                        default: break
                    }
                            
                    return fieldHeader as? ModelConfigurableView

                case (.None, .Some(let field)):
                    // Setup value changed handler
                    let formField = self.formViewModelDataSource.fieldViews[indexPath]
                    field.control?.addTarget(self, action: #selector(FormController.formFieldChanged(_:)), forControlEvents: .EditingChanged)
                    
                    // Configuration
                    let configuration = self.formViewModelDataSource.fieldsConfigurations[indexPath]!                    
                    
                    // Setup field properties
                    if let fieldHeader = field as? FormFieldHeader {
                        switch configuration.type {
                            
                            // Selection
                            case .Selection(_, let name):
                                fieldHeader.setName(name)
                            
                            // Singleline
                            case .SinglelineStringInput(let placeholder, let keyboardType, let capitalizationType, let correctionType, let limitConfigurator):
                                field.setPlaceholder(placeholder)
                                field.setKeyboardType(keyboardType)
                                field.setAutocapitalizationType(capitalizationType) 
                                field.setAutocorrectionType(correctionType)
                                self.limitConfigurators[indexPath] = limitConfigurator
                            
                            // Singleline compact
                            case .SinglelineStringInputCompact(let image, let name, let placeholder, let keyboardType, let capitalizationType, let correctionType, let limitConfigurator):
                                fieldHeader.setName(name)
                                fieldHeader.setImage(image ?? UIImage())
                                field.setPlaceholder(placeholder)
                                field.setKeyboardType(keyboardType)
                                field.setAutocapitalizationType(capitalizationType) 
                                field.setAutocorrectionType(correctionType)
                                self.limitConfigurators[indexPath] = limitConfigurator
                            
                            // Multiline
                            case .MultilineStringInput(let placeholder, _, let keyboardType, let capitalizationType, let correctionType,  let limitConfigurator):
                                field.setPlaceholder(placeholder)
                                field.setKeyboardType(keyboardType)
                                field.setAutocapitalizationType(capitalizationType) 
                                field.setAutocorrectionType(correctionType)
                                self.limitConfigurators[indexPath] = limitConfigurator
                        }
                    }
                    
                    // Setup value from model
                    let model: M = self.anyModelForIndexPath(indexPath) as! M
                    if let extractedValue = configuration.extractValue(model) {
                        field.setValue(extractedValue)
                    }
                    
                    return formField as? ModelConfigurableView
                
                default: return nil
            }
        }

        // Setup all header views to calculate cell heights
        for (indexPath, _) in formViewModelDataSource.fieldHeaders {
            let view = viewModelConfigurableForIndexPath(indexPath)
            setupViewModelConfigurableForIndexPath(view, indexPath: indexPath)
        }

    }
        
    // View
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Obser keyboard notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FormController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FormController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove keyboard notification observation
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // MARK: FormControllerDelegate
    
    public func formChanged() {
        // Setup "Save" navigation item
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: #selector(FormController.save(_:)))        
    }
    
    // Actions
    
    func formFieldChanged(textField: UITextField) {
        if let formField = textField.superview as? FormField {
            
            let indexPath = formViewModelDataSource.indexPathForFormField(formField)!
            let model: M = configurableModelForIndexPath(indexPath, forceCreate: true)!
            let configuration = formViewModelDataSource.fieldsConfigurations[indexPath]!
            
            if let limitConfigurator = self.limitConfigurators[indexPath],
                formFieldValue = formField.value as? String
                where !limitConfigurator(formFieldValue) {
                
                printd("Form field won't be changed due to limit configurator.")
                
                // Extract and trim value from model
                if var trimmedValue = configuration.extractValue(model) {
                    trimmedValue = trimmedValue.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    trimmedValue = trimmedValue.stringByAppendingString(" ")
                    formField.setValue(trimmedValue)
                }
            } else {
            
                // Setup value on model
                configuration.setupValue(formField.value, model: model)
                
                // Form changed delegate action
                delegate?.formChanged()
                
                printd("Form field value: \(formField.value), indexPath: \(indexPath.row):\(indexPath.section)")
            }
        }
    }
    
    func save(sender: AnyObject?) {
        var spawners = [ NSIndexPath : Spawner ]()
        
        // Merge values from copies to original models for all configurations
        var backupModels = [ NSIndexPath : M]()
        for (indexPath, configuration) in formViewModelDataSource.fieldsConfigurations {
            
            let originalModel = originalModelForIndexPath(indexPath)            
            if let modelCopy = configurableModelForIndexPath(indexPath, forceCreate: false) {
                
                // Create backup model
                let backupModel = M()
                mergeModelProperties(originalModel, backupModel, configuration: configuration)
                backupModels[indexPath] = backupModel
                
                // Merge properties from copy to original model
                mergeModelProperties(modelCopy, originalModel, configuration: configuration)
             
                // Spawner for index path
                if let spawner = signalProducerSpawner[indexPath] {
                    spawners[indexPath] = spawner
                }
            }            
        }        
        
        var seen = [String: Bool]()
        var spawnerIndexPaths = [String: [NSIndexPath]]()
        let uniqueSpawners = spawners.filter { 
            (indexPath, spawner) in 

            // Merge index paths
            if var array = spawnerIndexPaths[spawner.0] {
                array.append(indexPath)
                spawnerIndexPaths[spawner.0] = array                
            } else {
                spawnerIndexPaths[spawner.0] = [ indexPath ]
            }

            return seen.updateValue(true, forKey: spawner.0) == nil
        }.map {
            (indexPath, spawner) in (spawnerIndexPaths[spawner.0]!, spawner)
        }
                
        let signalProducers = uniqueSpawners.map { (indexPaths, spawner) in
            spawner.1(originalModelForIndexPath(indexPaths.first!)).mapError { 
                serviceTransportError in FormError.TransportError(serviceTransportError, indexPaths)
            }
        }
        
        // Resign all responders for every field
        let resignResponders = {
            self.resignAllFormFields()
        }
                
        // Completion
        let completion = {
            // Clear "Save" item
            self.navigationItem.rightBarButtonItem = nil
         
            // Resign responders
            resignResponders()
        }
        
        if signalProducers.count > 0 {
            SignalProducer(values: signalProducers)
                .flatten(.Concat)
                .on(started: resignResponders,
                    failed: {
                    formError in                    
                        // Handle error
                        switch formError {
                            case .TransportError(.ServerError(let serverError, _, _), let indexPaths):
                                // Merge original model properties back (need backup for original model)
                                for indexPath in indexPaths {
                                    self.mergeModelProperties(backupModels[indexPath]!, self.originalModelForIndexPath(indexPath), configuration: self.formViewModelDataSource.fieldsConfigurations[indexPath]!)
                                }
                            
                                // Show alert
                                UIAlertView(title: "Can't save data", message: serverError.localizedDescription, delegate: nil, cancelButtonTitle: "Ok").show()
                            
                            default: break
                        }
                    }, completed: completion)
                .startWithCompleted(completion)
        } else {
            completion()
        }     
    }
    
    // MARK: Confirm model changes
    
    public func mergeModelChanges() {
        for (indexPath, configuration) in formViewModelDataSource.fieldsConfigurations {
            
            let originalModel = originalModelForIndexPath(indexPath)            
            if let modelCopy = configurableModelForIndexPath(indexPath, forceCreate: false) {
                
                // Merge properties from copy to original model
                mergeModelProperties(modelCopy, originalModel, configuration: configuration)
            }            
        } 
    }
        
    // MARK: Resign responders
    
    public func resignAllFormFields() {
        for (_, fieldView) in self.formViewModelDataSource.fieldViews {
            if let fieldViewResponder = fieldView as? UIResponder {
                fieldViewResponder.resignFirstResponder()
            }
        }
    }
    
    public func anyFieldIsResponding() -> Bool {
        var result = false
        for (_, fieldView) in self.formViewModelDataSource.fieldViews {
            if let fieldViewResponder = fieldView as? SinglelineFormFieldView {
                result = result || fieldViewResponder.textField!.isFirstResponder()
            }
        }
        
        return result
    }
    
    // MARK: Private
    
    func originalModelForIndexPath(indexPath: NSIndexPath) -> M {
        return anyModelForIndexPath(indexPath) as! M
    }
    
    func configurableModelForIndexPath(indexPath: NSIndexPath, forceCreate: Bool) -> M? {
        if case .None = modelCopies[indexPath] {            
            if forceCreate {
                let modelCopy = M()
                let configuration = formViewModelDataSource.fieldsConfigurations[indexPath]!
                if let extractedValue = configuration.extractValue(originalModelForIndexPath(indexPath)) {
                    configuration.setupValue(extractedValue, model: modelCopy)
                }
                modelCopies[indexPath] = modelCopy
            }
        }
        
        return modelCopies[indexPath]  
    }
    
    func mergeModelProperties(fromModel: M, _ toModel: M, configuration: FieldConfiguration<M, AnyObject>) {
        if let extractedValue = configuration.extractValue(fromModel) {
            configuration.setupValue(extractedValue, model: toModel)
        }
    }
    
    // Setters
    
    func setSignalProducerSpawner(spawner: Spawner) {
        // Setup signal spawnwer for each index path
        for (indexPath, _) in formViewModelDataSource.fieldsConfigurations {
            signalProducerSpawner[indexPath] = spawner
        }
    }
    
    // Decoration
    
    override public func decoratorForIndexPath(indexPath: NSIndexPath) -> Decorator {        
        switch (self.formViewModelDataSource.fieldHeaders[indexPath], self.formViewModelDataSource.fieldViews[indexPath]) {
            case (.Some(_), .None):
                return BasicDecorator(decoratedViewBackgroundColor: Colors.formBackground, contentViewBackgroundColor: Colors.clear)
            case (.None, .Some(_)):
                return BasicDecorator(decoratedViewBackgroundColor: Colors.white, contentViewBackgroundColor: Colors.clear)
            default: 
                return super.decoratorForIndexPath(indexPath)
        }
    }
    
    // Table view
    
    override public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {        
        switch (self.formViewModelDataSource.fieldsConfigurations[indexPath]?.type) {
            case .Some(.Selection(_, _)):
                cell.selectionStyle = .Default
            default:
                super.tableView(tableView, willDisplayCell: cell, forRowAtIndexPath: indexPath)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (self.formViewModelDataSource.fieldsConfigurations[indexPath]?.type) {
            case .Some(.Selection(_, let name)):
                selection(name)
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            default: break
        }                
    }
        
    // Selection
    
    func selection(name: String) {
        // Nothing here
    }
    
    // Keyboard notifications
    
    public func keyboardWillShow(notification: NSNotification) {
        originalTableInset = tableView?.contentInset
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        }
    }
    
    public func keyboardWillHide(notification: NSNotification) {
        if let originalInset = originalTableInset {
            tableView?.contentInset = originalInset
        }        
    }
    
    // MARK: TableView
    
    override public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if case let viewDataSource = modelViewDataSourceForIndexPath(indexPath) as? ReusableModelViewDataSource,
            let _ = viewDataSource?.heightChange(indexPath) {
            if case .None = cellHeightCache[indexPath] {
                cellHeightCache[indexPath] = super.tableView(tableView, heightForRowAtIndexPath: indexPath)
            }
        }
        
        return cellHeightCache[indexPath] ?? super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
}