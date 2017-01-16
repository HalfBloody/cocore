//
//  ContactInfoController.swift
//  PrizeArena
//
//  Created by Dmitry Shashlov on 24/02/16.
//  Copyright © 2016 Half Bloody. All rights reserved.
//

import Foundation
import UIKit

class WebController : UIViewController {
    
    var url: NSURL
    
    var backItem: UIBarButtonItem?
    var forwardItem: UIBarButtonItem?
    
    @IBOutlet var webView: UIWebView?
    
    // MARK: Handlers
    
    var backHandler: ActionHandler?
    
    // MARK: ----
    
    init (title: String, url: NSURL) {
        
        // URL
        self.url = url

        super.init(nibName: "Web",
                   bundle: nil)
        
        // Hide tab bar
        self.hidesBottomBarWhenPushed = true
        
        // Title
        self.title = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        
    }
    
    // MARK: Actions
    
    func back() {
        backHandler?()
    }
    
    // MARK: View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Addign self as web view delegate
        webView?.delegate = self
        
        // Load web view
        webView?.loadRequest(NSURLRequest(URL: url))
        
        // Right navigation items
        backItem = UIBarButtonItem(image: UIImage(named: "icn_back"), style: .Plain, target: self, action: #selector(WebController.backAction))
        backItem?.enabled = false
        
        forwardItem = UIBarButtonItem(image: UIImage(named: "icn_forward"), style: .Plain, target: self, action: #selector(WebController.forwardAction))
        forwardItem?.enabled = false
        
        self.navigationItem.rightBarButtonItems = [ forwardItem!, backItem! ]
        
        // Setup back button item
        navigationItem.leftBarButtonItem
            = UIBarButtonItem(image: UIImage(named: "icn_back")!.imageWithRenderingMode(.AlwaysOriginal),
                              style: .Plain,
                              target: self,
                              action: #selector(back))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Disable left bar button item untile fully appeared
        self.navigationItem.leftBarButtonItem?.enabled = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Enable left bar button item when appeared
        self.navigationItem.leftBarButtonItem?.enabled = true
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        // Clear UIWebView's delegate reference
        webView?.delegate = nil
    }

    // MARK: Actions
    
    @IBAction func backAction() {
        webView?.goBack()
    }
    
    @IBAction func forwardAction() {
        webView?.goForward()
    }
}

extension WebController : UIWebViewDelegate {
    func webViewDidFinishLoad(webView: UIWebView) {
        backItem?.enabled = webView.canGoBack
        forwardItem?.enabled = webView.canGoForward
    }
}