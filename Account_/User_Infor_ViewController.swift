//
//  User_Infor_ViewController.swift
//  HearThis
//
//  Created by Thanh Hai Tran on 5/3/21.
//  Copyright © 2021 Thanh Hai Tran. All rights reserved.
//

import UIKit

class User_Infor_ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var headerCell: UITableViewCell!
    
    @IBOutlet var inforCell: UITableViewCell!
    
    @IBOutlet var optionCell: UITableViewCell!

    @IBOutlet var sideGapLeft: NSLayoutConstraint!
    
    @IBOutlet var sideGapRight: NSLayoutConstraint!
    
    @IBOutlet var login_bg_height: NSLayoutConstraint!
    
    let refreshControl = UIRefreshControl()
    
    @IBOutlet var avatar: UIImageView!

    var avatarTemp: UIImage!
    
    @IBOutlet var name: UILabel!
    
    @IBOutlet var phone: UILabel!

    @IBOutlet var email: UILabel!

    @IBOutlet var changePass: UILabel!

    @IBOutlet var transaction: UILabel!

    @IBOutlet var logout: UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()

        if IS_IPAD {
            sideGapLeft.constant = 100
            
            sideGapRight.constant = 100
            
            login_bg_height.constant = 390
        }
        self.viewInfor()
        
        tableView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(didReload(_:)), for: .valueChanged)
        
        changePass.action(forTouch: [:]) { (objc) in
            self.center()?.pushViewController(PC_ChangePass_ViewController.init(), animated: true)
        }
        
        transaction.action(forTouch: [:]) { (objc) in
            self.center()?.pushViewController(Transaction_ViewController.init(), animated: true)
        }
        
        logout.action(forTouch: [:]) { (objc) in
            DropAlert.shareInstance()?.alert(withInfor: ["cancel":"Thoát", "buttons":["Đăng xuất"], "title":"Thông báo", "message": "Bạn có muốn đăng xuất khỏi tài khoản ?"], andCompletion: { (index, objc) in
                if index == 0 {
                    if self.isEmbed() {
                        self.unEmbed()
                    }
                    Information.removeInfo()
                    self.requestLogout()
                    FB_Plugin.shareInstance().signoutFacebook()
                    GG_PlugIn.shareInstance().signOutGoogle()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        (UIApplication.shared.delegate as! AppDelegate).changeRoot(true)
                    })
                }
            })
        }
    }
    
    func requestLogout() {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"logout",
                                                    "user_id":Information.userInfo?.getValueFromKey("user_id") ?? "",
                                                    "header":["session":Information.token == nil ? "" : Information.token!],
                                                    "device_id":FirePush.shareInstance()?.deviceToken() ?? "",
                                                    "overrideAlert":"1",
                                                    "host":self], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
            if result.getValueFromKey("ERR_CODE") != "0" {
                self.showToast(response?.dictionize().getValueFromKey("ERR_MSG"), andPos: 0)
                return
            }
        
        })
    }
    
    @objc func didReload(_ sender: Any) {
        self.didGetInfo()
    }
    
    @IBAction func didPressEdit() {
        self.center()?.pushViewController(PC_Inner_Info_ViewController.init(), animated: true)
    }
    
    @IBAction func didPressBuy() {
        let vip = VIP_ViewController.init()
        vip.callBack = { info in
            print(info)
        }
        let nav = UINavigationController.init(rootViewController: vip)
        nav.isNavigationBarHidden = true
        nav.modalPresentationStyle = .fullScreen
        self.center().present(nav, animated: true, completion: nil)
    }
    
    func viewInfor() {
        name.text = Information.userInfo?.getValueFromKey("name")
        phone.text = Information.userInfo?.getValueFromKey("phone")
        email.text = Information.userInfo?.getValueFromKey("email")
        if Information.avatar != nil {
            avatarTemp = Information.avatar
            avatar.image = avatarTemp
        } else {
            avatar.imageUrlHolder(url: (Information.userInfo?.getValueFromKey("avatar"))!, holder: "ic_avatar")
        }
    }
    
    func didGetInfo() {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"getUserInfo",
                                                    "header":["session":Information.token == nil ? "" : Information.token!],
                                                     "session": Information.token ?? "",
                                                    "overrideAlert":"1",
                                                    "overrideLoading":"1",
                                                    "host":self], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
            self.refreshControl.endRefreshing()
            
            if result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
                self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
                return
            }
                   
            let preInfo: NSMutableDictionary = (response?.dictionize()["result"] as! NSDictionary).reFormat()
                        
            self.add(preInfo as? [AnyHashable : Any], andKey: "info")

            Information.saveInfo()
            
            self.viewInfor()
        })
    }
    
    @IBAction func didPressImage() {
        EM_MenuView.init(settingMenu: [:]).show(completion: { (indexing, obj, menu) in
            switch indexing {
            case 1:
//                self.didPressPreview(image: self.avatarTemp != nil ? self.avatarTemp as Any: Information.userInfo?.getValueFromKey("avatar") as Any)
                break
            case 2:
                Permission.shareInstance()?.askCamera { (camType) in
                    switch (camType) {
                    case .authorized:
                        DispatchQueue.main.async(execute: {
                            Media.shareInstance().startPickImage(withOption: true, andBase: nil, andRoot: self, andCompletion: { (image) in
                                if image != nil {
                                    self.didPressSubmit(image: image as! UIImage)
                                }
                            })
                        })
                        break
                    case .denied:
                        self.showToast("Bạn chưa cho phép sử dụng Camera", andPos: 0)
                        break
                    case .per_denied:
                        self.showToast("Bạn chưa cho phép sử dụng Camera", andPos: 0)
                        break
                    case .per_granted:
                        DispatchQueue.main.async(execute: {
                            Media.shareInstance().startPickImage(withOption: true, andBase: nil, andRoot: self, andCompletion: { (image) in
                                if image != nil {
                                    self.didPressSubmit(image: image as! UIImage)
                                }
                            })
                        })
                        break
                    case .restricted:
                        self.showToast("Bạn chưa cho phép sử dụng Camera", andPos: 0)
                        break
                    default:
                        break
                    }
                }
                break
            case 3:
                Permission.shareInstance()?.askGallery { (camType) in
                   switch (camType) {
                   case .authorized:
                        DispatchQueue.main.async(execute: {
                           Media.shareInstance().startPickImage(withOption: false, andBase: nil, andRoot: self, andCompletion: { (image) in
                               if image != nil {
                                self.didPressSubmit(image: image as! UIImage)
                               }
                           })
                       })
                       break
                   case .denied:
                       self.showToast("Bạn chưa cho phép sử dụng Bộ sưu tập", andPos: 0)
                       break
                   case .per_denied:
                       self.showToast("Bạn chưa cho phép sử dụng Bộ sưu tập", andPos: 0)
                       break
                   case .per_granted:
                        DispatchQueue.main.async(execute: {
                           Media.shareInstance().startPickImage(withOption: false, andBase: nil, andRoot: self, andCompletion: { (image) in
                               if image != nil {
                                self.didPressSubmit(image: image as! UIImage)
                               }
                           })
                        })
                       break
                   case .restricted:
                       self.showToast("Bạn chưa cho phép sử dụng Bộ sưu tập", andPos: 0)
                       break
                   default:
                       break
                   }
               }
                break
            default:
                break
            }
        })
    }
    
    @IBAction func didPressSubmit(image: UIImage) {
        let data: NSMutableDictionary =
            self.avatarTemp != nil ? ["CMD_CODE":"updateUserInfo",
                                         "session": Information.token ?? "",
                                         "header":["session":Information.token == nil ? "" : Information.token!],
                                         "avatar": self.avatarTemp != nil ? self.avatarTemp.imageString() : "",
//                                         "sex": sex ?? "",
                                         "email":email.text as Any,
                                         "name":name.text as Any,
                                         "phone":phone.text as Any,
//                                         "birthday": birthday.text as Any,
//                                         "address":address.text as Any,
                                        "overrideAlert":"1",
                                        "overrideLoading":"1",
                                        "host":self]
                                        :
                                        ["CMD_CODE":"updateUserInfo",
                                         "header":["session":Information.token == nil ? "" : Information.token!],
                                         "session": Information.token ?? "",
//                                         "sex": sex ?? "",
                                         "email":email.text as Any,
                                         "name":name.text as Any,
                                         "phone":phone.text as Any,
//                                         "birthday": birthday.text as Any,
//                                         "address":address.text as Any,
                                        "overrideAlert":"1",
                                        "overrideLoading":"1",
                                        "host":self]
        
        LTRequest.sharedInstance()?.didRequestInfo((data as! [AnyHashable : Any]), withCache: { (cacheString) in
       }, andCompletion: { (response, errorCode, error, isValid, object) in
           let result = response?.dictionize() ?? [:]
                                               
           if result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
//               self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
                EM_MenuView.init(confirm: ["image": "fail", "line1": "Cập nhật không thành công", "line2": "Xin lỗi quý khách vì sự cố này \nVui lòng thử lại sau", "line3": "Về trang Cá nhân"]).show { (index, obj, menu) in
                    if index == 4 {
        
                    } else {
        
                    }
                }
               return
           }
//           self.showToast("Cập nhật thông tin thành công", andPos: 0)
            EM_MenuView.init(confirm: ["image": "success", "line1": "Đổi avatar thành công", "line2": "Thông tin của quý khách đã được cập nhật", "line3": "Về trang Cá nhân"]).show { (index, obj, menu) in
                if index == 4 {

                } else {

                }
            }
        
            self.avatarTemp = image
            self.avatar.image = image
            Information.avatar = image
           
            self.didGetInfo()
       })
   }
}

extension User_Infor_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 620 : indexPath.row == 1 ? 255 : 200
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return indexPath.row == 0 ? headerCell! : indexPath.row == 1 ? inforCell! : optionCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
