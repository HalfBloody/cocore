//
//  StringUtils.swift
//  PocketFlip
//
//  Created by Dmitry Shashlov on 23/04/16.
//  Copyright © 2016 Dmitry Shashlov. All rights reserved.
//

import Foundation
import TTTAttributedLabel

extension String : CustomStringConvertible {
    public var description: String { return self } 
}

extension String {
    
    // MARK: HTML Description
    
    func htmlString(style style: String) -> String {
        guard let stylePath = NSBundle.mainBundle().pathForResource(style, ofType: "css") else {
            return self
        }

        do {
            let styleValue = try String(contentsOfFile: stylePath, encoding: NSUTF8StringEncoding)
            return "<html><head><meta charset=\"UTF-8\">\(styleValue)</head><body>\(self)</body></html>"
        } catch (_) {
            return self
        }
        
    }
    
    func htmlAttributedString(style style: String, ignoreStyle: Bool = false) -> NSAttributedString? {
        return htmlString(style: ignoreStyle ? "default" : style).htmlAttributedString()
    }
    
    func htmlAttributedString() -> NSAttributedString? {
        do {
            guard let attributedStringData = self.dataUsingEncoding(NSUTF8StringEncoding) else {
                return nil
            }
            
            let result = try NSAttributedString(data: attributedStringData,
                                                options: [ NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType ],
                                                documentAttributes: nil)
            
            return result
        } catch (_) {
            return nil
        }
    }
}

extension TTTAttributedLabel {
    
    func setupHtml(string: String, style: String) {
        let htmlString = string.htmlString(style: style)
        if let htmlAttributedString = htmlString.htmlAttributedString() {
            
            // Setup attributed string
            self.attributedText = htmlAttributedString
            
            // Link attributes
            self.linkAttributes
                = [ NSForegroundColorAttributeName: UIColor(rgb: 0x0087d7, alphaVal: 1.0),
                    NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleNone.rawValue ]
            
            // Highlight links
            self.highlightLinks(htmlString)
        }
    }
    
    private func highlightLinks(htmlString: String) {
        if let attributedText = attributedText {
            let plainText = NSString(string: attributedText.string)
            let regexp = try! NSRegularExpression(pattern: "[^>]*<a[^>]+href=\"(.*?)\"[^>]*>(.*?)</a>[^<]*", options: .CaseInsensitive)
            regexp.enumerateMatchesInString(htmlString,
                                            options: .WithoutAnchoringBounds,
                                            range: NSMakeRange(0, htmlString.characters.count),
                                            usingBlock: { (result, _, _) in

                                                let htmlStringCasted = NSString(string: htmlString)
                                                
                                                // Link text and URL
                                                let linkText = htmlStringCasted.substringWithRange(result!.rangeAtIndex(2))
                                                let linkURLString = htmlStringCasted.substringWithRange(result!.rangeAtIndex(1))
                                                
                                                // Find out real link's range
                                                let pattern = htmlStringCasted.substringWithRange(result!.rangeAtIndex(0))
                                                let plainPattern = pattern.htmlAttributedString(style: "", ignoreStyle: true)!.string
                                                let plainPatternRange = plainText.rangeOfString(plainPattern)
                                                let linkRange: NSRange = plainText.rangeOfString(linkText, options: [], range: plainPatternRange)

                                                // Highlight link
                                                self.addLinkToURL(NSURL(string: linkURLString)!, withRange: linkRange)
            })
        }
    }
    
}

extension String {
    func trimmedNewlinesAndTabsString() -> String {
        let characterSet = NSMutableCharacterSet.newlineCharacterSet()
        characterSet.addCharactersInString("\t")
        return self.componentsSeparatedByCharactersInSet(characterSet).joinWithSeparator("")
    }
}

extension String {
    static func intFromHexString(hexStr: String) -> UInt32 {
        var hexInt: UInt32 = 0
        let scanner: NSScanner = NSScanner(string: hexStr)
        scanner.charactersToBeSkipped = NSCharacterSet(charactersInString: "#")
        scanner.scanHexInt(&hexInt)
        return hexInt
    }
}