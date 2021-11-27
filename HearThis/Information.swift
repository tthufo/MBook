//
//  Information.swift
//  TourGuide
//
//  Created by Mac on 8/18/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class Information: NSObject {
    @objc static var phone: String = "0917271595"

    @objc static var check: String?
    
    @objc static var token: String?
    
    @objc static var bg: String?
    
    @objc static var bbgg: String?
    
    @objc static var avatar: UIImage?
    
    @objc static var userInfo: NSDictionary?
    
    static var offLine: NSArray?
    
    static var log: NSDictionary?
    
    static var allPackage: String?
    
    @objc static var loginType: NSDictionary!
    
    @objc static var isVip: Bool = false
    
    @objc static var packageInfo: String = "Tài khoản giới hạn"
    
    @objc static var searchValue: String?
    
    @objc static func saveToken() {
        if self.getValue("token") != nil {
            token = "%@".format(parameters: self.getValue("token"))
        } else {
            token = nil
        }
    }
    
    static func saveBG() {
        if self.getValue("bg") != nil {
            bg = self.getValue("bg")
        } else {
            bg = nil
        }
        if self.getValue("bbgg") != nil {
            bbgg = self.getValue("bbgg")
        } else {
            bbgg = nil
        }
    }
    
    static func changeInfo(notification: Int) {
        if self.getObject("info") != nil {
            userInfo = self.getObject("info")! as NSDictionary
            let temp = userInfo?.reFormat()
            temp!["total_unread"] = notification >= 0 ? notification : Int((temp?.getValueFromKey("total_unread"))!)! - 1
            self.add((temp as! [AnyHashable : Any]), andKey: "info")
            userInfo = self.getObject("info")! as NSDictionary
        }
    }
    
    @objc static func saveInfo() {
        if self.getObject("info") != nil {
            userInfo = self.getObject("info")! as NSDictionary
        } else {
            userInfo = nil
        }
        
        if self.getObject("log") != nil {
            log = self.getObject("log")! as NSDictionary
        } else {
            log = nil
        }
    }
    
    static func saveOffline() {
        if self.getObject("offline") != nil {
            offLine = (self.getObject("offline")! as NSDictionary)["data"] as! NSArray
        } else {
            offLine = []
        }
    }
    
    static func addOffline(request: NSDictionary) {
        
        offLine = (self.getObject("offline")! as NSDictionary)["data"] as! NSArray

        let mutableOffline = NSMutableArray.init(array: offLine!)
                        
        mutableOffline.insert(request, at: 0)
        
        self.add(["data": mutableOffline as Any], andKey: "offline")
        
        self.saveOffline()
    }
    
    static func removeOffline(order: String) {
        
        offLine = (self.getObject("offline")! as NSDictionary)["data"] as! NSArray

        let mutableOffline = NSMutableArray.init(array: offLine!)

        for dict in mutableOffline {
            if order == (dict as! NSDictionary).getValueFromKey("id") {
                mutableOffline.remove(dict)
            }
        }
        
        self.add(["data": mutableOffline as Any], andKey: "offline")

        self.saveOffline()
    }
    
    static func getOffline() -> NSArray {
        return offLine!
    }
    
    @objc static func removeInfo() {
        
        self.avatar = nil
        
        self.allPackage = "0"
        
        self.loginType = nil
        
        self.searchValue = ""
        
        self.packageInfo = "Tài khoản giới hạn"
        
        self.remove("social")
        
        self.removeValue("token")

        token = nil
        
        self.remove("info")

        userInfo = nil
        
        self.remove("log")
        
        log = nil
        
        self.remove("bg")
        
        bg = nil
    }
}

