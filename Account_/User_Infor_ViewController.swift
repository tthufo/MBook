//
//  User_Infor_ViewController.swift
//  HearThis
//
//  Created by Thanh Hai Tran on 5/3/21.
//  Copyright © 2021 Thanh Hai Tran. All rights reserved.
//

import UIKit

class User_Infor_ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var headerCell: UITableViewCell!
    
    @IBOutlet var inforCell: UITableViewCell!
    
    @IBOutlet var optionCell: UITableViewCell!
    
    @IBOutlet var optionCell_S: UITableViewCell!

    @IBOutlet var optionCell_S_S: UITableViewCell!

    @IBOutlet var sideGapLeft: NSLayoutConstraint!
    
    @IBOutlet var sideGapRight: NSLayoutConstraint!
    
    @IBOutlet var login_bg_height: NSLayoutConstraint!
    
    let refreshControl = UIRefreshControl()
    
    @IBOutlet var avatar: UIImageView!

    var avatarTemp: UIImage!
    
    @IBOutlet var totalBook: UILabel!

    @IBOutlet var totalTime: UILabel!
    
    @IBOutlet var account: UILabel!

    @IBOutlet var name: UILabel!
    
    @IBOutlet var userName: UILabel!
    
    @IBOutlet var phone: UILabel!

    @IBOutlet var email: UILabel!

    @IBOutlet var changePass: UILabel!

    @IBOutlet var transaction: UILabel!
    
    @IBOutlet var transaction_S: UILabel!

    @IBOutlet var logout: UILabel!
    
    @IBOutlet var logout_S: UILabel!
    
    @IBOutlet var logout_S_S: UILabel!
    
    @IBOutlet var des: UILabel!

    @IBOutlet var searchBtn: UIImageView!

    @IBOutlet var vipIcon: UIImageView!

    @IBOutlet var vipIcon_B: UIImageView!

    @IBOutlet var des_B: UILabel!
    
    @IBOutlet var buyBtn_B: UIButton!

    @IBOutlet var searchView: UITextField!

    @IBOutlet var buyBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        if IS_IPAD {
//            sideGapLeft.constant = 100
//            
//            sideGapRight.constant = 100
            
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
        
        transaction_S.action(forTouch: [:]) { (objc) in
            self.center()?.pushViewController(Transaction_ViewController.init(), animated: true)
        }
        
        logout.action(forTouch: [:]) { (objc) in
            self.didPressLogOut()
        }
        
        logout_S.action(forTouch: [:]) { (objc) in
            self.didPressLogOut()
        }
        
        logout_S_S.action(forTouch: [:]) { (objc) in
            self.didPressLogOut()
        }
        
        searchBtn.imageColor(color: .lightGray)
        
        searchBtn.action(forTouch: [:]) { (objc) in
            self.didPressSearch()
        }
        searchView.addTarget(self, action: #selector(textIsChanging), for: .editingChanged)
    }
    
    func didPressSearch() {
        let search = Search_ViewController.init()
        search.config = ["search": searchView.text ?? ""]
        self.center()?.pushViewController(search, animated: true)
    }
    
    @objc func textIsChanging(_ textField:UITextField) {
        Information.searchValue = textField.text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       searchView.resignFirstResponder()
       return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vipIcon.isHidden = Information.check == "0" ? true : !Information.isVip
        vipIcon_B.isHidden = Information.isVip
        buyBtn.isHidden = Information.isVip
        buyBtn_B.isHidden = Information.isVip
        searchView.text = Information.searchValue ?? ""
        des.text = Information.packageInfo
        des.isHidden = Information.check == "0"
        des_B.isHidden = Information.isVip
        totalBook.text = (Information.userInfo?.getValueFromKey("total_book") == "" ? "0" : (Information.userInfo?.getValueFromKey("total_book"))!) + " cuốn"
        totalTime.text = (Information.userInfo?.getValueFromKey("total_time") == "" ? "0" : (Information.userInfo?.getValueFromKey("total_time"))!) + " giờ"
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.view.endEditing(true)
    }
    
    func didPressLogOut() {
        DropAlert.shareInstance()?.alert(withInfor: ["cancel":"Thoát", "buttons":["Đăng xuất"], "title":"Thông báo", "message": "Bạn có muốn đăng xuất khỏi tài khoản ?"], andCompletion: { (index, objc) in
            if index == 0 {
                if self.isEmbed() {
                    self.unEmbed()
                }
                self.requestLogout()
                Information.removeInfo()
                FB_Plugin.shareInstance().signoutFacebook()
                GG_PlugIn.shareInstance().signOutGoogle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    (UIApplication.shared.delegate as! AppDelegate).changeRoot(true)
                })
            }
        })
    }
    
    @IBAction func didPressMenu() {
        self.view.endEditing(true)
        self.root()?.toggleLeftPanel(nil)
    }
    
    func requestLogout() {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"logout",
//                                                    "user_id":Information.userInfo?.getValueFromKey("user_id") ?? "",
                                                    "header":["session":Information.token == nil ? "" : Information.token!],
                                                    "push_token":FirePush.shareInstance()?.deviceToken() ?? "",
                                                    "overrideAlert":"1",
                                                    "host":self], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
            if result.getValueFromKey("ERR_CODE") != "0" {
//                self.showToast(response?.dictionize().getValueFromKey("ERR_MSG"), andPos: 0)
                return
            }
        
        })
    }
    
    @objc func didReload(_ sender: Any) {
        self.didGetInfo()
    }
    
    @IBAction func didPressEdit() {
        let editInfo = PC_Inner_Info_ViewController.init()
        editInfo.callBack = { value in
            self.didReload(self.refreshControl)
        }
        self.center()?.pushViewController(editInfo, animated: true)
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
        account.text = "userID" + (Information.userInfo?.getValueFromKey("user_id"))!
        name.text = Information.userInfo?.getValueFromKey("name")
        userName.text = Information.userInfo?.getValueFromKey("name") == "" ? "(Chưa cài đặt)" : Information.userInfo?.getValueFromKey("name")
        if Information.userInfo?.getValueFromKey("name") == "" {
            userName.textColor = .black
        }
        phone.text = Information.userInfo?.getValueFromKey("phone") == "" ? "(Chưa cài đặt)" : Information.userInfo?.getValueFromKey("phone")
        if Information.userInfo?.getValueFromKey("phone") == "" {
            phone.textColor = .black
        }
        email.text = Information.userInfo?.getValueFromKey("email") == "" ? "(Chưa cài đặt)" : Information.userInfo?.getValueFromKey("email")
        if Information.userInfo?.getValueFromKey("email") == "" {
            email.textColor = .black
        }
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
    
    func didPressSubmit(image: UIImage) {
        let data: NSMutableDictionary = ["CMD_CODE":"updateUserInfo",
                                         "session": Information.token ?? "",
                                         "header":["session":Information.token == nil ? "" : Information.token!],
                                         "avatar": image.imageString(),
                                         "overrideAlert":"1",
                                         "overrideLoading":"1",
                                         "host":self]
        
        LTRequest.sharedInstance()?.didRequestInfo((data as! [AnyHashable : Any]), withCache: { (cacheString) in
       }, andCompletion: { (response, errorCode, error, isValid, object) in
           let result = response?.dictionize() ?? [:]
                                               
           if result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
                EM_MenuView.init(confirm: ["image": "fail", "line1": "Cập nhật không thành công", "line2": "Xin lỗi quý khách vì sự cố này \nVui lòng thử lại sau", "line3": "Về trang Cá nhân"]).show { (index, obj, menu) in
                    (menu!).close()
                    if index == 4 {
        
                    } else {
        
                    }
                }
               return
           }
//           self.showToast("Cập nhật thông tin thành công", andPos: 0)
//            EM_MenuView.init(confirm: ["image": "success", "line1": "Đổi ảnh đại diện thành công", "line2": "Thông tin của quý khách đã được cập nhật", "line3": "Về trang Cá nhân"]).show { (index, obj, menu) in
//                if index == 4 {
//
//                } else {
//
//                }
//            }
        
            self.avatarTemp = image
            self.avatar.image = image
            Information.avatar = image
            self.didGetInfo()
       })
   }
}

extension User_Infor_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let social_logged = self.getObject("social")
        return indexPath.row == 0 ? Information.isVip ? 460 : 600 : indexPath.row == 1 ? 185 : Information.check == "0" ? 90 : social_logged != nil ? 120 : 155 
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let social_logged = self.getObject("social")
        
        return indexPath.row == 0 ? headerCell! : indexPath.row == 1 ? inforCell! : Information.check == "0" ? optionCell_S_S : social_logged != nil ? optionCell_S : optionCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
