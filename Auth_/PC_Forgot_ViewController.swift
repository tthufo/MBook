//
//  PC_Forgot_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 8/4/19.
//  Copyright © 2019 Thanh Hai Tran. All rights reserved.
//

import UIKit

import MarqueeLabel

class PC_Forgot_ViewController: UIViewController , UITextFieldDelegate {
    
    @IBOutlet var logo: UIImageView!
    
    @IBOutlet var bg: UIImageView!
    
    @IBOutlet var login: UIView!
    
    @IBOutlet var cover: UIView!
    
    @IBOutlet var uNameBg: UIView!
    
    @IBOutlet var uName: UITextField!
    
    @IBOutlet var submit: UIButton!
    
    @IBOutlet var uNameErr: UILabel!
    
    @IBOutlet var count: UILabel!
    
    @IBOutlet var reminder: UILabel!
    
    @IBOutlet var bottom: MarqueeLabel!
    
    var typing: NSString!
    
    var kb: KeyBoard!
    
    let bottomGap = IS_IPHONE_5 ? 20.0 : 40.0
    
    let topGap = IS_IPHONE_5 ? 80 : 120
    
    var isValid: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        kb = KeyBoard.shareInstance()
        
        self.setUp()
                
        self.view.action(forTouch: [:]) { (obj) in
            self.view.endEditing(true)
        }
        uName.addTarget(self, action: #selector(textIsChanging), for: .editingChanged)
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

        bottom.text = "MEBOOK © 2020 - Ver %@".format(parameters: appVersion!)

        bottom.action(forTouch: [:]) { (obj) in
//            self.callNumber(phoneNumber: Information.phone)
        }
        
        if Information.check == "1" {
            self.logo.image = UIImage(named: "logo")
        }
        
        submit.setTitle(typing == "register" ? "Đăng ký" : "Lấy mật khẩu", for: .normal)
        
        reminder.boldSubstring("Mebook")
        reminder.colorSubstring("Mebook", color: AVHexColor.color(withHexString: "#1e928c"))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        kb.keyboardOff()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        kb.keyboard { (height, isOn) in
            UIView.animate(withDuration: 1, animations: {
//                var frame = self.login.frame
//                
//                frame.origin.y -= isOn ? (height - CGFloat(self.bottomGap)) : (-height + CGFloat(self.bottomGap))
//                
//                self.login.frame = frame
//                
//                var frameLogo  = self.logo.frame
//                
//                frameLogo.origin.y -= isOn ? (height - CGFloat(self.bottomGap)) : (-height + CGFloat(self.bottomGap))
//                
//                self.logo.frame = frameLogo
            })
        }
    }
    
    func setUp() {
        let bbgg = Information.bbgg != nil && Information.bbgg != ""

        var frame = logo.frame
        
        frame.origin.y = CGFloat(self.screenHeight() - 70) / 2
        
        frame.origin.x = 0 //CGFloat(self.screenWidth() - 250) / 2
              
        frame.size.width = CGFloat(self.screenWidth() - 0)
        
        logo.frame = frame
        
        logo.alpha = 1
        
        UIView.animate(withDuration: 0, animations: {
            var frame = self.logo.frame
            
            frame.origin.y -= CGFloat((self.screenHeight()/2 - (237 * 0.7)) / 2) + (CGFloat(self.topGap) - 100) + (IS_IPHONE_5 ? 140 : 60)
            
            self.logo.frame = frame
            
            self.logo.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            
        }) { (done) in
//            self.setUpLogin()
        }
    }
    
    func setUpLogin() {
        var frame = login.frame
        
        frame.origin.y = CGFloat(self.screenHeight() - 280) / 2 + CGFloat(self.topGap)
        
        frame.size.width = CGFloat(self.screenWidth() - (IS_IPAD ? 200 : 40))
               
        frame.origin.x = IS_IPAD ? 100 : 20
        
        login.frame = frame
        
        self.view.addSubview(login)
        
        UIView.animate(withDuration: 1, animations: {
            
            self.login.alpha = 1
            
        }) { (done) in
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == uName {
            self.view.endEditing(true)
        }
        
        return true
    }

    
    @IBAction func didPressBack() {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    func convertPhone() -> String {
       let phone = uName.text
        if phone!.count < 2 {
            return phone!
        }
       if phone?.substring(to: 2) == "84" {
           return phone!
       } else if phone?.substring(to: 1) == "0"  {
           return "84" + (phone?.dropFirst())!
       }
       return phone!
    }
    
    func stringIsNumber(_ string:String) -> Bool {
        var allNumber: Bool = true
        for character in string{
            if !character.isNumber{
                allNumber = false
                return allNumber
            }
        }
        return allNumber
    }
    
    @IBAction func didPressSubmit() {
        self.view.endEditing(true)
        
        if !uName.hasText {
            self.showToast("Bạn chưa nhập thông tin", andPos: 0)
            return
        }

        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"forgetPassword",
                                                    "username":self.stringIsNumber(uName.text!) ? convertPhone() : uName.text!,
                                                    "overrideAlert":"1",
                                                    "overrideLoading":"1",
                                                    "host":self], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
                                    
            if result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
//               self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
                EM_MenuView.init(confirm: ["image": "fail", "line1": "Lấy lại mật khẩu không thành công", "line2": "Xin lỗi bạn về sự cố này, vui lòng thử lại sau", "line3": "Thoát"]).show { (index, obj, menu) in
                    if index == 4 {
                    }
                }
                return
            }
            
//            self.showToast("Lấy lại mật khẩu thành công. Mật khẩu mới sẽ đưởi gửi về số điện thoại %@".format(parameters: self.uName.text!), andPos: 0)
//
            EM_MenuView.init(confirm: ["image": "success", "line1": "Mật khẩu mới đã tạo", "line2": "Vui lòng kiểm tra hòm thư/tin nhắn\n để lấy mật khẩu mới", "line3": "Về trang Đăng nhập"]).show { (index, obj, menu) in
                if index == 4 {
                    self.didPressBack()
                }
            }
        })
    }
    
    func checkPhone() -> Bool {
        let phone = uName.text
        if phone!.count > 10 {
            if phone?.substring(to: 2) == "84" {
                if phone?.count == 11 {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        } else {
            if phone!.count == 10 {
                if phone?.substring(to: 1) != "0" {
                    return false
                } else {
                    return true
                }
            } else {
                return false
            }
        }
    }
    
    func validPhone() {
          uNameErr.alpha = isValid ? 0 : 1
          uNameBg.backgroundColor = isValid ? UIColor.white : UIColor.red
      }
    
    @objc func textIsChanging(_ textField:UITextField) {
        isValid = true
//        validPhone()
    }
    
    func toolBar() -> UIToolbar {
        
        let toolBar = UIToolbar.init(frame: CGRect.init(x: 0, y: 0, width: Int(self.screenWidth()), height: 50))
        
        toolBar.barStyle = .default
        
        toolBar.items = [UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                         UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                         UIBarButtonItem.init(title: "Thoát", style: .done, target: self, action: #selector(disMiss))]
        return toolBar
    }
    
    @objc func disMiss() {
        self.view.endEditing(true)
    }
}
