//
//  PC_Info_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 8/4/19.
//  Copyright © 2019 Thanh Hai Tran. All rights reserved.
//

import UIKit

import MarqueeLabel

class PC_Info_ViewController: UIViewController {
                
    @IBOutlet var tableView: UITableView!
    
    var dataList: NSMutableArray!
    
    var packageList: NSMutableArray!
    
    let sections = ["Gói cước", "Thông tin chi tiết"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataList = NSMutableArray.init(array: Information.check == "1" ? [
                                                ["title":"Thông tin tài khoản", "image":"user_info"],
                                                   ["title":"Đổi mật khẩu", "image":"change_pass"],
//                                                   ["title":"Cho phép nhận thông báo", "image":"notification", "content":"sw"],
                                                   ["title":"Đăng xuất", "image":"logout"]
            ] :
            [
                                               ["title":"Cho phép nhận thông báo", "image":"notification", "content":"sw"],
            ]
        )
        
        packageList = NSMutableArray.init(array: [
           ["title":"Danh sách gói", "image":"notification"],
        ])
        
        tableView.withCell("PC_Info_Cell")
        
//        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    @IBAction func didPressMenu() {
        self.root()?.toggleLeftPanel(nil)
    }
    
    @IBAction func didPressSearch() {
        let search = Search_ViewController.init()
        search.config = [:]
        self.center()?.pushViewController(search, animated: true)
    }
    
    func didPressLogout() {
//        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"logout",
//                                                    "user_id":Information.userInfo?.getValueFromKey("user_id") ?? "",
//                                                    "device_id":FirePush.shareInstance()?.deviceToken() ?? "",
//                                                    "overrideAlert":"1",
//                                                    "host":self], withCache: { (cacheString) in
//        }, andCompletion: { (response, errorCode, error, isValid, object) in
//            let result = response?.dictionize() ?? [:]
//            if result.getValueFromKey("ERR_CODE") != "0" {
//                self.showToast(response?.dictionize().getValueFromKey("ERR_MSG"), andPos: 0)
//                return
//            }
//
//        [[DropAlert shareInstance] alertWithInfor:@{@"cancel":@"Cancel",@"buttons":@[@"Restore", @"Purchase"],@"title":@"Remove Ads",@"message":@"Do you want to restore or purchase Remove Ads ?"} andCompletion:^(int indexButton, id object) {
//            switch (indexButton)
//            {
//                case 0:
//                {
//                    [self restoreProduct];
//                }
//                    break;
//                case 1:
//                {
//                    [self buyProduct];
//                }
//                    break;
//                default:
//                    break;
//            }
//        }];
        
        DropAlert.shareInstance()?.alert(withInfor: ["cancel":"Thoát", "buttons":["Đăng xuất"], "title":"Thông báo", "message": "Bạn có muốn đăng xuất khỏi tài khoản ?"], andCompletion: { (index, objc) in
            if index == 0 {
                if self.isEmbed() {
                    self.unEmbed()
                }
                Information.removeInfo()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    (UIApplication.shared.delegate as! AppDelegate).changeRoot(true)
                })
            }
        })
//        })
    }
    
    func postNotification(ids: NSArray) {
        LTRequest.sharedInstance()?.didRequestInfo(["absoluteLink":"".urlGet(postFix: "notification/subcribe"),
                                                                          "header":["Authorization":Information.token == nil ? "" : Information.token!],
                                                                          "ids": ids,
                                                                          "overrideAlert":"1",
                                                                          "overrideLoading":"1",
                                                                          "host":self], withCache: { (cacheString) in
                              }, andCompletion: { (response, errorCode, error, isValid, object) in
                                  let result = response?.dictionize() ?? [:]
                               
                                  if result.getValueFromKey("status") != "0" {
                                      self.showToast(response?.dictionize().getValueFromKey("data") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("data"), andPos: 0)
                                      return
                                  }
                                                                  
                                  self.showToast("Cập nhật thông báo thành công", andPos: 0)
                                              
                              })
    }
    
    func didRequestNotification() {
        LTRequest.sharedInstance()?.didRequestInfo(["absoluteLink":"".urlGet(postFix: "subcribe"),
                                                   "header":["Authorization":Information.token == nil ? "" : Information.token!],
                                                   "is_subcribe": self.getValue("push") == "1" ? false : true ,
                                                   "overrideAlert":"1",
                                                   "overrideLoading":"1",
                                                   "host":self], withCache: { (cacheString) in
       }, andCompletion: { (response, errorCode, error, isValid, object) in
           let result = response?.dictionize() ?? [:]
           
           if result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
               self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
               return
           }
        
           self.showToast("Cài đặt thành công", andPos: 0)
       })
    }
}

extension PC_Info_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? packageList.count : dataList.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = Bundle.main.loadNibNamed("List_Header_Cell", owner: self, options: nil)![0] as! UIView
        
        (self.withView(view, tag: 1) as! UILabel).text = sections[section]
        
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier:"PC_Info_Cell", for: indexPath)
        
        let data = indexPath.section == 0 ? packageList![indexPath.row] as! NSDictionary :  dataList![indexPath.row] as! NSDictionary

        
        let image = self.withView(cell, tag: 11) as! UIImageView

        image.image = UIImage(named: data.getValueFromKey("image"))
        
        let title = self.withView(cell, tag: 1) as! UILabel
        
        title.text = data["title"] as? String
        
        
        let sw = self.withView(cell, tag: 3) as! UISwitch
        
//        sw.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
//
//        sw.isOn = self.getValue("push") == "1"
//
//        sw.action(forTouch: [:]) { (obj) in
//            self.didRequestNotification()
//            self.addValue(self.getValue("push") == "1" ? "0" : "1", andKey: "push")
//            sw.isOn = self.getValue("push") == "1"
//        }
        
        sw.alpha = data["content"] as? String == "sw" ? 1 : 0
        
        let arrow = self.withView(cell, tag: 15) as! UIImageView

        arrow.isHidden = false
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                self.center()?.pushViewController(PC_Inner_Info_ViewController.init(), animated: true)
            }
        
            if indexPath.row == 1 {
                self.center()?.pushViewController(PC_ChangePass_ViewController.init(), animated: true)
            }
            
            if indexPath.row == 2 {
                self.didPressLogout()
            }
        } else {
            self.center()?.pushViewController(Package_ViewController.init(), animated: true)
        }
    }
}
