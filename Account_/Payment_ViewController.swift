//
//  Payment_ViewController.swift
//  HearThis
//
//  Created by Thanh Hai Tran on 8/9/21.
//  Copyright © 2021 Thanh Hai Tran. All rights reserved.
//

import UIKit
import WebKit

class Payment_ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    @IBOutlet var webView: WKWebView!

    @IBOutlet var titleLabel: UILabel!

    var requestUrl: String!
    
    var info: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel.text = self.info.getValueFromKey("title")
        
        webView.navigationDelegate = self

        webView.uiDelegate = self
                 
        if self.info.getValueFromKey("payment") == "1" {
            self.reloading()
        } else {
            self.didRequestContent()
        }
    }
    
    func didRequestContent() {
        
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":self.info.getValueFromKey("url") ?? "",
                                                    "header":["session":Information.token == nil ? "" : Information.token!],
                                                    "overrideAlert":"1",
                                                    "overrideLoading":"1",
                                                    "host":self], withCache: { (cacheString) in
                                                    }, andCompletion: { [self] (response, errorCode, error, isValid, object) in
           let result = response?.dictionize() ?? [:]
        
           if result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
               self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
               return
           }
        
            let headerString = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header>"

            webView.loadHTMLString(headerString + result.getValueFromKey("result"), baseURL: nil)
                   
        })
    }
    
    func reloading() {
        let link = URL(string: ((requestUrl as NSString) as String))!
     
        let request = URLRequest(url: link)
     
        webView.load(request)
     }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
                
        if self.info.getValueFromKey("payment") != "1" {
            decisionHandler(.allow)
            return
        }
        
        let link = navigationAction.request.url?.absoluteString
                    
        if link!.contains("http://mebook_wp//purchaseorder") {
            if link!.contains("status=1") {
                EM_MenuView.init(confirm: ["image": "success", "line1": "Đăng ký thành công gói " + info.getValueFromKey("package_code"), "line2": "", "line3": "Về trang Cá nhân"]).show { (index, obj, menu) in
                    if index == 4 {
                        self.dismiss(animated: true, completion: nil)
                    } else {

                    }
                }
            } else {
                EM_MenuView.init(confirm: ["image": "fail", "line1": "Đăng ký không thành công", "line2": "", "line3": "Về trang Cá nhân"]).show { (index, obj, menu) in
                    if index == 4 {
                        self.didPressBack()
                    } else {

                    }
                }
            }
        }
        
        decisionHandler(.allow)
    }

    @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
    }

}
