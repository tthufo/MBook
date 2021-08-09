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

    var requestUrl: String!
    
    var info: NSDictionary!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self

        webView.uiDelegate = self
                 
        self.reloading()
    }
    
    func reloading() {
        let link = URL(string: ((requestUrl as NSString) as String))!
     
        let request = URLRequest(url: link)
     
        webView.load(request)
     }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        let backButton = UIButton.init(type: .custom)
//        backButton.setImage(UIImage.init(named: "icon_back"), for: .normal)
//        backButton.frame = CGRect.init(x: 10, y: 10, width: 44, height: 44)
//        if directUrl == "" {
////            webView.addSubview(backButton)
//        }
//        backButton.action(forTouch: [:]) { (objc) in
//            self.navigationController?.popViewController(animated: true)
//        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
                
        let link = navigationAction.request.url?.absoluteString
                    
        if link!.contains("http://mebook_wp//purchaseorder") {
            if link!.contains("status=1") {
                EM_MenuView.init(confirm: ["image": "success", "line1": "Đăng ký thành công gói " + info.getValueFromKey("package_code"), "line2": "", "line3": "Về trang Cá nhân"]).show { (index, obj, menu) in
                    if index == 4 {
                        self.didPressBack()
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
