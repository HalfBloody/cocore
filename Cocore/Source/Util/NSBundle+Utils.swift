//
//  NSBundle+Utils.swift
//  Cocore
//
//  Created by Dmitry Shashlov on 1/20/17.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation

extension NSBundle {

    // MARK: Public

    public class func loadNibView<T: UIView>(nibName: String) -> T {
        return NSBundle.mainBundle()
            .loadNibNamed(nibName, owner: nil, options: [:]).first! as! T
    }

    public class func loadCoreNibView<T: UIView>(nibName: String) -> T {
        return coreBundle()
            .loadNibNamed(nibName, owner: nil, options: [:]).first! as! T
    }

    public class func coreBundle() -> NSBundle {
        return _bundleForClass(AppDelegate.self)._coreBundle()
    }

    // MARK: Bundle for resource

    public class func bundleForNib(nibName: String) -> NSBundle {

        guard let nibPath = NSBundle.mainBundle().pathForResource(nibName, ofType: "nib") else {
            return NSBundle.coreBundle()
        }

        return NSBundle.mainBundle()
    }

    // MARK: Private

    private class func _bundleForClass<T: AnyObject>(objectClass: T.Type) -> NSBundle {
        return NSBundle(forClass: objectClass)
    }

    private func _coreBundle() -> NSBundle {
        let coreBundlePath = pathForResource("Cocore", ofType: "bundle")!
        return NSBundle(path: coreBundlePath)!
    }
}

extension UINib {

    // MARK: Load nib

    public class func loadNib(nibName: String) -> UINib {
        return UINib(nibName: nibName, bundle: NSBundle.bundleForNib(nibName))
    }

    // MARK: Load view

    func loadView<T: UIView>() -> T {
        return instantiateWithOwner(nil, options: nil).first! as! T
    }

}

extension UIViewController {

    // MARK: View controller

    public convenience init(nibName nibName: String) {
        self.init(nibName: nibName, bundle: NSBundle.bundleForNib(nibName))
    }
}