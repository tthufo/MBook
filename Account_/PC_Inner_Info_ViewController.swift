//
//  PC_Inner_Info_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 11/15/19.
//  Copyright © 2019 Thanh Hai Tran. All rights reserved.
//

import UIKit

//import DKImagePickerController

class PC_Inner_Info_ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var cell: UITableViewCell!
    
    @IBOutlet var phone: UITextField!
    
    @IBOutlet var name: UITextField!
    
    @IBOutlet var email: UITextField!

//    @IBOutlet var birthday: UITextField!
    
//    @IBOutlet var address: UITextField!
//
//    @IBOutlet var avatar: UIImageView!
//
//    @IBOutlet var male: UIImageView!
//
//    @IBOutlet var female: UIImageView!
    
//    @IBOutlet var dateTime: UIView!

//    var avatarTemp: UIImage!
    
    @IBOutlet var emailBG: UIView!

    @IBOutlet var rePassBG: UIView!

    @IBOutlet var emailError: UILabel!

    @IBOutlet var rePassError: UILabel!
    
    @IBOutlet var submit: UIButton!

//    @IBOutlet var bottomHeight: NSLayoutConstraint!
    
//    var sex: String!
    
    var kb: KeyBoard!
    
    @IBOutlet var sideGapLeft: NSLayoutConstraint!
    
    @IBOutlet var sideGapRight: NSLayoutConstraint!
    
//    @IBOutlet var sideGapBottomLeft: NSLayoutConstraint!
//
//    @IBOutlet var sideGapBottomRight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if IS_IPAD {
           sideGapLeft.constant = 100
           sideGapRight.constant = -100
//           sideGapBottomLeft.constant = 100
//           sideGapBottomRight.constant = 100
        }
        
        kb = KeyBoard.shareInstance()
        
        self.view.action(forTouch: [:]) { (obj) in
            self.view.endEditing(true)
        }
                           
        phone.text = Information.userInfo?.getValueFromKey("phone")

        name.text = Information.userInfo?.getValueFromKey("name")
        
        email.text = Information.userInfo?.getValueFromKey("email")
        
//        let birtText = Information.userInfo?.getValueFromKey("birthday")?.components(separatedBy: " ").first
//
//        birthday.text = birtText

//        address.text = Information.userInfo?.getValueFromKey("address")
        
//        sex = Information.userInfo?.getValueFromKey("sex")
        
//        if Information.avatar != nil {
//            avatarTemp = Information.avatar
//            avatar.image = avatarTemp
//        } else {
//        avatar.imageUrlHolder(url: (Information.userInfo?.getValueFromKey("avatar"))!, holder: "ic_avatar")
                
//        }
                
        phone.addTarget(self, action: #selector(textRePassIsChanging), for: .editingChanged)
        email.addTarget(self, action: #selector(textEmailIsChanging), for: .editingChanged)
        
//        let isEmail: Bool = email.text?.count != 0 && (email.text?.isValidEmail())!
//        let isMatch: Bool = phone.text?.count != 0 && phone.text?.count == 10
          
//        submit.isEnabled = phone.text?.count != 0 && email.text?.count != 0 && isEmail && isMatch
//        submit.alpha = phone.text?.count != 0 && email.text?.count != 0 && isEmail && isMatch ? 1 : 0.5
        
//        avatar.action(forTouch: [:]) { (objc) in
//            self.didPressPreview(image: self.avatarTemp != nil ? self.avatarTemp as Any: Information.userInfo?.getValueFromKey("avatar") as Any)
//        }
        
//        self.male.image = UIImage.init(named: sex == "1" ? "radio_ac" : "radio_in")
//        self.female.image = UIImage.init(named: sex == "1" ? "radio_in" : "radio_ac")
//
//        male.action(forTouch: [:]) { (objc) in
//            self.female.image = UIImage.init(named: "radio_in")
//            self.male.image = UIImage.init(named: "radio_ac")
//            self.sex = "1"
//        }
//
//        female.action(forTouch: [:]) { (objc) in
//            self.female.image = UIImage.init(named: "radio_ac")
//            self.male.image = UIImage.init(named: "radio_in")
//            self.sex = "0"
//        }
        
//        dateTime.action(forTouch: [:]) { (objc) in
//            EM_MenuView.init(date: ["date": self.birthday.text as Any]).show { (index, obj, menu) in
//                self.birthday.text = (obj as! NSDictionary).getValueFromKey("date")
//            }
//        }

        didGetInfo()
    }
    
    func convertDate(date: String) -> String {
                
        let date: NSString = date.components(separatedBy: " ").first! as NSString
        
        let dateString = date.date(withFormat: "MM/dd/yyyy")
                
        return (dateString! as NSDate).string(withFormat: "dd/MM/yyyy")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       super.viewWillDisappear(animated)
       kb.keyboardOff()
    }
   
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
       
        if self.isEmbed() {
//            bottomHeight.constant = 80
        }
       kb.keyboard { (height, isOn) in
           self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: isOn ? (height - 100) : 0, right: 0)
       }
    }
    
    func didPressPreview(image: Any) {
        EM_MenuView.init(previewMenu: ["image": image]).show { (indexing, obj, menu) in
            menu?.close()
        }
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
//                                    self.avatarTemp = (image as! UIImage)
//                                    self.avatar.image = (image as! UIImage)
                                    Information.avatar = (image as! UIImage)
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
//                                    self.avatarTemp = (image as! UIImage)
//                                    self.avatar.image = (image as! UIImage)
                                    Information.avatar = (image as! UIImage)
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
//                                self.avatarTemp = (image as! UIImage)
//                                self.avatar.image = (image as! UIImage)
                                Information.avatar = (image as! UIImage)
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
//                                self.avatarTemp = (image as! UIImage)
//                                self.avatar.image = (image as! UIImage)
                                Information.avatar = (image as! UIImage)
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
    
    func didGetInfo() {
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
            
//            preInfo["birthday"] = self.convertDate(date: preInfo.getValueFromKey("birthday"))
            
            self.add(preInfo as? [AnyHashable : Any], andKey: "info")

            Information.saveInfo()
        })
    }
    
    @IBAction func didPressSubmit() {
       self.view.endEditing(true)
        let data: NSMutableDictionary =
//            self.avatarTemp != nil ? ["CMD_CODE":"updateUserInfo",
//                                         "session": Information.token ?? "",
//                                         "avatar": self.avatarTemp != nil ? self.avatarTemp.imageString() : "",
//                                         "sex": sex ?? "",
//                                         "email":email.text as Any,
//                                         "name":name.text as Any,
//                                         "phone":phone.text as Any,
//                                         "birthday": birthday.text as Any,
//                                         "address":address.text as Any,
//                                        "overrideAlert":"1",
//                                        "overrideLoading":"1",
//                                        "host":self]
//                                        :
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
               self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
               return
           }
        
           self.showToast("Cập nhật thông tin thành công", andPos: 0)
           
           self.didGetInfo()
       })
   }
    
    @IBAction func didPressBack() {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didPressCancel() {
        EM_MenuView.init(cancel: ["line1": "Quý khách muốn huỷ thay đổi ?"]).show { (index, obj, menu) in
            if index == 3 {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//       if textField == phone {
//           email.becomeFirstResponder()
//       } else {
//           self.view.endEditing(true)
//       }
       
       return true
   }
    
    @objc func textEmailIsChanging(_ textField:UITextField) {
        let isEmail: Bool = email.text?.count != 0 && (email.text?.isValidEmail())!
        let isMatch: Bool = phone.text?.count != 0 && phone.text?.count == 10
        emailBG.backgroundColor = isEmail ? AVHexColor.color(withHexString: "#FFFFFF") : .red
        emailError.alpha = isEmail ? 0 : 1
        
//        submit.isEnabled = phone.text?.count != 0 && email.text?.count != 0 && isEmail && isMatch
//        submit.alpha = phone.text?.count != 0 && email.text?.count != 0 && isEmail && isMatch ? 1 : 0.5
    }
    
    @objc func textRePassIsChanging(_ textField:UITextField) {
        let isEmail: Bool = email.text?.count != 0 && (email.text?.isValidEmail())!
        let isMatch: Bool = phone.text?.count != 0 && phone.text?.count == 10
        rePassBG.backgroundColor = isMatch ? AVHexColor.color(withHexString: "#FFFFFF") : .red
        rePassError.alpha = isMatch ? 0 : 1
        
//        submit.isEnabled = phone.text?.count != 0 && email.text?.count != 0 && isEmail && isMatch
//        submit.alpha = phone.text?.count != 0 && email.text?.count != 0 && isEmail && isMatch ? 1 : 0.5
    }
}

extension PC_Inner_Info_ViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 490
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return cell
    }
}
