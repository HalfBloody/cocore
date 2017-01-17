//
//  TaskService.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 26/04/16.
//  Copyright © 2016 Dmitry Shashlov. All rights reserved.
//

import Foundation
import ReactiveCocoa

// Image size
public enum ImageSize: Int {
    case Small = 1
    case Medium
    case Big
    
    func reverseAdjustmentSizes() -> [ImageSize] {
        var sizes = [ImageSize]()
        for adjustedImageSizeValue in (1...self.rawValue).reverse() {
            sizes.append(ImageSize(rawValue: adjustedImageSizeValue)!)
        }
        
        return sizes
    }
}

// Task service
public class ImageService {

    var imageFetchingProgress = [String: Bool]()
    var imageObservers = [String: [Observer<UIImage, NSError>]]()

    let imageFetchQueue: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)

    // MARK: ----

    public init() {
        // Nothing here
    }

    // MARK: ----

    public func imageSignal<M: ImageFetchCompatible>(model: M, imageSize: ImageSize, placeholderImage: UIImage? = nil) -> SignalProducer<UIImage, NSError> {
        if case .None = imageFetchingProgress[model.imageFetchIdentifier] {

            // Placeholder image for models which doesn't have image link
            if case .Some(let pImage) = placeholderImage {
                guard let _ = model.imageURLStringBySize(size: imageSize) else {
                    return SignalProducer {
                        (observer, disposable) in

                        observer.sendNext(pImage)
                        observer.sendCompleted()
                    }
                }
            }

            return modelImageSignal(model,
                imageSize: imageSize,
                imagePathConversion: imagePathForModel,
                urlFromSize: model.imageURLStringBySize)
                .on(started: {
                    self.imageFetchingProgress[model.imageFetchIdentifier] = true
                    }, next: { image in
                        if let observers = self.imageObservers[model.imageFetchIdentifier] {
                            for observer in observers {
                                observer.sendNext(image)
                                observer.sendCompleted()
                            }
                        }
                    }, completed: {
                        self.imageFetchingProgress[model.imageFetchIdentifier] = nil
                        self.imageObservers[model.imageFetchIdentifier] = nil
                })

        } else {
            return SignalProducer {
                (observer, disposable) in

                var observers = self.imageObservers[model.imageFetchIdentifier]
                if case .None = observers {
                    observers = [Observer<UIImage, NSError>]()
                }
                observers!.append(observer)

                self.imageObservers[model.imageFetchIdentifier] = observers
            }
        }
    }

    // MARK: ----
    
    private func imageSizePostfix(imageSize: ImageSize) -> String {
        switch imageSize {
        case .Small: return "small";
        case .Medium: return "medium";
        case .Big: return "big";
        }
    }
    
    private func modelImageSignal<M>(model: M, imageSize: ImageSize, imagePathConversion: (M, ImageSize) -> String, urlFromSize: (ImageSize) -> String?) -> SignalProducer<UIImage, NSError> {
        
        let imageUrlString = urlFromSize(imageSize)
        let imagePath = imagePathConversion(model, imageSize)
        
        return SignalProducer<(UIImage, Bool), NSError> {
            (observer, disposable) in            
            
                // sendNext() already loaded image orp revious loaded size smaller than imageSize
                for adjustedImageSize in imageSize.reverseAdjustmentSizes() {
                    if let image = UIImage(contentsOfFile: imagePath) {
                        observer.sendNext((image, false))
                        if (imageSize == adjustedImageSize) {
                            observer.sendCompleted()
                        }
                        break
                    }
                }
                
                if let imageUrlString = imageUrlString, 
                    imageUrl = NSURL(string: imageUrlString),
                    imageData = NSData(contentsOfURL: imageUrl),
                    image = UIImage(data: imageData) {                    
                        observer.sendNext((image, true))
                        observer.sendCompleted()
                } else {
                    observer.sendFailed(NSError(domain: "ImageService", code: 0, userInfo: nil)) // FIXME: update error details
                }            
            }
            .on(next: {
                (prizeImage, fromWeb) in
                if fromWeb {
                    printd("Writing image: \(imagePath)")
                    UIImagePNGRepresentation(prizeImage)?.writeToFile(imagePath, atomically: true)
                }
            })
            .map { return $0.0 }
            .startOn(QueueScheduler(queue: self.imageFetchQueue))
            .observeOn(UIScheduler())
    }

    private func imagePathForModel<M: ImageFetchCompatible>(model: M, imageSize: ImageSize) -> String {
        return "\(NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0])/\(model.imageFetchIdentifier)_\(imageSizePostfix(imageSize)).png"
    }
}

// MARK: ImageFetchCompatible protocol

public protocol ImageFetchCompatible : Hashable {
    var imageFetchIdentifier: String { get }
    func imageURLStringBySize(size size: ImageSize) -> String?
}