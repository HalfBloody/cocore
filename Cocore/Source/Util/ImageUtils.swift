//
//  ImageUtils.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 1/15/17.
//  Copyright © 2017 Dmitry Shashlov. All rights reserved.
//

import Foundation

extension UIImage {

    public func scaleImage(scale: Double) -> UIImage {
        let scale = CGFloat(scale)

        let newWidth = CGFloat(ceilf(Float(size.width * scale)))
        let newHeight = CGFloat(ceilf(Float(size.height * scale)))
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return scaledImage
    }

    public func resizeFill(resize: CGSize) -> UIImage {
        if size.width > size.height {
            return resizeByHeight(resize.height)
        } else {
            return resizeByWidth(resize.width)
        }
    }

    public func resizeByWidth(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / size.width
        let newHeight = size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }

    public func resizeByHeight(newHeight: CGFloat) -> UIImage {
        let scale = newHeight / size.height
        let newWidth = size.width * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}