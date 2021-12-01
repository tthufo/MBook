//
//  PC_Notification_Detail_ViewController.swift
//  HearThis
//
//  Created by Thanh Hai Tran on 27/11/2021.
//  Copyright © 2021 Thanh Hai Tran. All rights reserved.
//

import UIKit
import WebKit
import MarqueeLabel

class PC_Notification_Detail_ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    @IBOutlet var webView: WKWebView!

    @IBOutlet var titleLabel: MarqueeLabel!

//    var requestUrl: String!
    
    var info: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel.text = self.info.getValueFromKey("title")
        
        webView.navigationDelegate = self

        webView.uiDelegate = self
                         
        if self.info.getValueFromKey("payment") == "1" {
//            self.reloading()
        } else {
//            self.didRequestContent()
        }
        
        let modifiedFont = String(format:"<span style=\"font-family: '-apple-system', 'HelveticaNeue'; font-size:16 \">%@</span>", info.getValueFromKey("content")
        )
        
        let headerString = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header>"

        webView.loadHTMLString(headerString + modifiedFont, baseURL: nil)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
                
        decisionHandler(.allow)
    }

    @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
    }

}
