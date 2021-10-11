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
        
//        print("-->", info)
                 
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
                
                var messaging = ""
                
                if info.getValueFromKey("is_package") == "1" {
                    messaging = "Bạn đã thanh toán " + info.getValueFromKey("name")
                } else {
                    let mess = info.getValueFromKey("book_type") == "3" ? "sách nói" : "sách đọc"
                    messaging = "Bạn đã thanh toán " + mess + " \"" + info.getValueFromKey("name") + "\""
                    self.player().isRestricted = false
                }
                                
                EM_MenuView.init(confirm: ["image": "success", "line1": "Giao dịch thành công", "line2": messaging, "line3": "Xác nhận"]).show { (index, obj, menu) in
                    if index == 4 {
                        let social_logged = self.getObject("social")
                        self.checkVipStatusLogin(isSocial: social_logged == nil, menu: menu!)
                    } else {

                    }
                }
            } else {
                EM_MenuView.init(confirm: ["image": "fail", "line1": "Thanh toán không thành công", "line2": "", "line3": "Về trang Cá nhân"]).show { (index, obj, menu) in
                    (menu!).close()
                    if index == 4 {
                        self.didPressBack()
                    } else {

                    }
                }
            }
        }
        
        decisionHandler(.allow)
    }
    
    func checkVipStatusLogin(isSocial: Bool, menu: EM_MenuView) {
        let paymentList = NSMutableArray()
        let packageList = NSMutableArray()
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"getPaymentPackage",
                                                    "header":["session":Information.token == nil ? "" : Information.token!],
                                                    "session":NSNull(),
                                                    "overrideAlert":"1",
                                                    "overrideLoading":"1",
                                                    "host":self], withCache: { (cacheString) in
       }, andCompletion: { (response, errorCode, error, isValid, object) in
           let result = response?.dictionize() ?? [:]
        
           if result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
               self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
               return
           }
        
           let payment = (result["result"] as! NSArray)

           paymentList.addObjects(from: payment.withMutable())
           if Information.allPackage == "1" {
                LTRequest.sharedInstance()?.didRequestInfo(["cmd_code":"getPackageInfo",
                                                            "header":["session":Information.token == nil ? "" : Information.token!],
                                                            "overrideAlert":"1",
                                                            "overrideLoading":"1",
                                                            "host":self], withCache: { (cacheString) in
               }, andCompletion: { (response, errorCode, error, isValid, object) in
                   let result = response?.dictionize() ?? [:]
                
                   if result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
                       self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
                       return
                   }
                            

                   let package = (result["result"] as! NSArray).withMutable()
                                     
                   packageList.addObjects(from: package!)
                
                   print( "is_VIP", self.isVipLogin(paymentList: paymentList, packageList: packageList))
                   
                   Information.isVip = self.isVipLogin(paymentList: paymentList, packageList: packageList)
                
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
                        menu.close()
                        self.dismiss(animated: true, completion: nil)
                        self.didRequestMP3Link(info: self.info)
                    })
                
               })
            } else {
                Information.isVip = self.isVipLogin(paymentList: paymentList, packageList: packageList)
                             
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
                    menu.close()
                    self.dismiss(animated: true, completion: nil)
                    self.didRequestMP3Link(info: self.info)
                })
            }
       })
    }
    
    func isVipLogin(paymentList: NSMutableArray, packageList: NSMutableArray) -> Bool {
        var isVip = false
        let groupPackage = NSMutableArray()
        for pay in paymentList {
            let payment = (pay as! NSDictionary)
            let dateKey = payment.getValueFromKey("expireTime") == "" ? payment.getValueFromKey("expire_time") : payment.getValueFromKey("expireTime")
            let expDate = (dateKey! as NSString).date(withFormat: "dd/MM/yyyy")
                        
            if payment.getValueFromKey("status") == "1" && Date() < expDate! {
                Information.packageInfo = "Gói " + payment.getValueFromKey("package_code") + " - HSD " + dateKey!
                isVip = true
                return isVip
            }
        }
        
        for pack in packageList {
            let package = (pack as! NSDictionary)
            let dateKey = package.getValueFromKey("expireTime") == "" ? package.getValueFromKey("expire_time") : package.getValueFromKey("expireTime")
            let expDate = (dateKey! as NSString).date(withFormat: "dd/MM/yyyy")
                        
            if (package.getValueFromKey("reg_keyword") == "EB" || package.getValueFromKey("reg_keyword") == "AU") && package.getValueFromKey("status") == "1" && Date() < expDate! {
                groupPackage.add("valid")
            }
        }
        
        isVip = groupPackage.count == 2 ? true : false
        
        if isVip {
            Information.packageInfo = "Gói AU + EB"
        }
        
        return isVip
    }
    
    func didGetInfo(menu: EM_MenuView) {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"getUserInfo",
                                                    "header":["session":Information.token == nil ? "" : Information.token!],
                                                     "session": Information.token ?? "",
                                                    "overrideAlert":"1",
                                                    "overrideLoading":"1",
                                                    "host":self], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
            if result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
                self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
                return
            }
                   
            let preInfo: NSMutableDictionary = (response?.dictionize()["result"] as! NSDictionary).reFormat()
                        
            self.add(preInfo as? [AnyHashable : Any], andKey: "info")

            Information.isVip = true
            
            Information.saveInfo()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
                menu.close()
                self.dismiss(animated: true, completion: nil)
            })
        })
    }
    

    @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
    }

}
