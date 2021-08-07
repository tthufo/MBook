//
//  PC_Register_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 11/4/19.
//  Copyright © 2019 Thanh Hai Tran. All rights reserved.
//

import UIKit

import MarqueeLabel

//import AVHexColor

class PC_Register_ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 100.0
        }
    }
    
    @IBOutlet var topLine: UILabel!
    
    @IBOutlet var logo: UIImageView!
    
    @IBOutlet var logoCell: UITableViewCell!
    
    @IBOutlet var nameCell: UITableViewCell!

    @IBOutlet var emailCell: UITableViewCell!
    
    @IBOutlet var phoneCell: UITableViewCell!

    @IBOutlet var passCell: UITableViewCell!

    @IBOutlet var rePassCell: UITableViewCell!

    @IBOutlet var submitCell: UITableViewCell!

    @IBOutlet var confirmCell: UITableViewCell!

    @IBOutlet var uName: UITextField!
    
    @IBOutlet var email: UITextField!
    
    @IBOutlet var phone: UITextField!

    @IBOutlet var pass: UITextField!
    
    @IBOutlet var rePass: UITextField!
    
    @IBOutlet var submit: UIButton!
    
    @IBOutlet var policyBtn: UIButton!

    
    @IBOutlet var emailBG: UIView!

    @IBOutlet var phoneBG: UIView!

    @IBOutlet var rePassBG: UIView!

    @IBOutlet var emailError: UILabel!

    @IBOutlet var phoneError: UILabel!

    @IBOutlet var rePassError: UILabel!

    var dataList: NSMutableArray!
    
    @IBOutlet var bottom: MarqueeLabel!
    
    var kb: KeyBoard!

    var isValid: Bool = true

    var agreed: Bool = false
    
    var confirm: Bool = false
    
    @IBOutlet var submitConfirmBtn: UIButton!

    @IBOutlet var confirmEmailBtn: UIButton!

    @IBOutlet var confirmPhoneBtn: UIButton!

    var confirmEmail: Bool = false

    var confirmPhone: Bool = false
    
    var isPhone: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        topLine.boldSubstring("Meebook")
        topLine.colorSubstring("Meebook", color: AVHexColor.color(withHexString: "#1e928c"))
        
        kb = KeyBoard.shareInstance()

//        dataList = NSMutableArray.init(array: [logoCell, nameCell, emailCell, phoneCell, submitCell])
        
        dataList = NSMutableArray.init(array: isPhone ? [logoCell, phoneCell, submitCell] : [logoCell, emailCell, submitCell])
        
        self.tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        bottom.text = "MEBOOK © 2020 - Ver %@".format(parameters: appVersion!)
        
//        uName.addTarget(self, action: #selector(textIsChanging), for: .editingChanged)
//        pass.addTarget(self, action: #selector(textIsChanging), for: .editingChanged)
//
//        rePass.addTarget(self, action: #selector(textRePassIsChanging), for: .editingChanged)
        
        email.addTarget(self, action: #selector(textEmailIsChanging), for: .editingChanged)
        phone.addTarget(self, action: #selector(textPhoneIsChanging), for: .editingChanged)

        if Information.check == "1" {
//            self.logo.image = UIImage(named: "logo")
        }
        
        self.view.action(forTouch: [:]) { (obj) in
            self.view.endEditing(true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        kb.keyboardOff()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        kb.keyboard { (height, isOn) in
            self.tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: isOn ? (height - 0) : 0, right: 0)
        }
    }
    
    @IBAction func didPressBack() {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didPressAgreed() {
        self.view.endEditing(true)
//        let isEmailValid: Bool = email.text?.count != 0 && (email.text?.isValidEmail())!
//        let isPhoneValid: Bool = checkPhone()
        
        self.policyBtn.setImage(UIImage(named: self.agreed ? "ico_select" : "ico_select_active"), for: .normal)
        self.agreed = !self.agreed
        
//        submit.isEnabled = agreed && uName.text?.count != 0 && email.text?.count != 0 && isEmail
//        submit.alpha = agreed && uName.text?.count != 0 && email.text?.count != 0 && isEmail ? 1 : 0.5
//        submit.isEnabled = agreed && (self.isPhone ? isPhoneValid : (email.text?.count != 0 && isEmailValid))
//        submit.alpha = agreed && (self.isPhone ? isPhoneValid : email.text?.count != 0 && isEmailValid) ? 1 : 0.5
    }
    
    @IBAction func didPressConfirm(sender: UIButton) {
        self.confirmEmailBtn.setImage(UIImage(named: sender.tag == 2 ? "ico_select" : "ico_select_active"), for: .normal)
        self.confirmPhoneBtn.setImage(UIImage(named: sender.tag == 1 ? "ico_select" : "ico_select_active"), for: .normal)
        self.confirmEmail = sender.tag == 2 ? true : false
        self.confirmPhone = sender.tag == 1 ? true : false
        submitConfirmBtn.isEnabled = true
        submitConfirmBtn.alpha = 1
    }
    
    
//    "CMD_CODE": "auth/",
//    "Department": "",
//    "Email": "tthufo@gmail.com",
//    "FullName": "",
//    "Password": "123456",
//    "PhoneNumber": "",
//    "ReRegisterPassword": "123456",
//    "UserName": "tthufo"
    
    @IBAction func didPressSubmit() {
        self.view.endEditing(true)
        isValid = self.checkPhone()
        if isPhone {
            if !isValid {
                validPhone()
                return
            }
        } else {
            let isEmail: Bool = email.text?.count != 0 && (email.text?.isValidEmail())!
            if isEmail {
                
            } else {
                emailError.alpha = 1
                return
            }
        }
        
        if !agreed {
            self.showToast("Hãy đồng ý với các điều khoản sử dụng", andPos: 0)
        }
        
        self.didPressSignup()
        
//        self.confirm = true
//
//        self.topLine.text = "Vui lòng chọn phương thức nhận mật khẩu"
//
//        self.tableView.reloadData()
    }
    
    @IBAction func didPressSignup() {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"signin",
                                                    "username": isPhone ? self.convertPhone() : email.text as Any,
                                                    "overrideAlert":"1",
                                                    "overrideLoading":"1",
                                                    "postFix":"auth",
                                                    "host":self], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
                                    
//            {
//                "result": null,
//                "cmd_code": "signin",
//                "error_code": 1,
//                "error_msg": "Số điện thoại đã được đăng ký"
//            }
            
            if result.getValueFromKey("error_code") != "0" {
//                self.showToast(response?.dictionize().getValueFromKey("data") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("data"), andPos: 0)
                EM_MenuView.init(confirm: ["image": "fail", "line1": "Đăng ký không thành công", "line2": result.getValueFromKey("error_msg") as Any, "line3": "Thoát"]).show { (index, obj, menu) in
                    if index == 4 {
                    }
                }
                return
            }
            
//            self.showToast("Đăng ký thành công", andPos: 0)
            
            EM_MenuView.init(confirm: ["image": "success", "line1": "Tài khoản mới đã tạo", "line2": "Thông tin đăng nhận đã được gửi tới\n" + (self.isPhone ? "tin nhắn" : "hòm thư"), "line3": "Về trang Đăng nhập"]).show { (index, obj, menu) in
                if index == 4 {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        })
    }
    
    @IBAction func didPressRequest() {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"auth",
                                                    "Department":"",
                                                    "Email":email.text as Any,
                                                    "FullName":"",
                                                    "UserName":uName.text as Any,
                                                    "Password":pass.text as Any,
                                                    "ReRegisterPassword":rePass.text as Any,
                                                    "PhoneNumber":"",
                                                    "overrideAlert":"1",
                                                    "overrideLoading":"1",
                                                    "postFix":"auth",
                                                    "host":self], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
                                    
            if result.getValueFromKey("status") != "OK" {
//                self.showToast(response?.dictionize().getValueFromKey("data") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("data"), andPos: 0)
                EM_MenuView.init(confirm: ["image": "fail", "line1": "Đăng ký không thành công", "line2": "Xin lỗi bạn về sự cố này, vui lòng thử lại sau", "line3": "Thoát"]).show { (index, obj, menu) in
                    if index == 4 {
                    }
                }
                return
            }
            
//            self.showToast("Đăng ký thành công", andPos: 0)
            
            EM_MenuView.init(confirm: ["image": "success", "line1": "Tài khoản mới đã tạo", "line2": "Thông tin đăng nhận đã được gửi tới\n hòm thư/tin nhắn", "line3": "Về trang Đăng nhập"]).show { (index, obj, menu) in
                if index == 4 {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           if textField == uName {
               email.becomeFirstResponder()
           } else if textField == email {
               phone.becomeFirstResponder()
           } else if textField == phone {
               self.view.endEditing(true)
           }
           return true
       }
    
    @objc func textRePassIsChanging(_ textField:UITextField) {
        let isEmail: Bool = email.text?.count != 0 && (email.text?.isValidEmail())!
        let isMatch: Bool = pass.text?.count != 0 && rePass.text?.count != 0 && pass.text == rePass.text
        rePassBG.backgroundColor = isMatch ? AVHexColor.color(withHexString: "#F2F2F2") : .red
        rePassError.alpha = isMatch ? 0 : 1
        submit.isEnabled = agreed && uName.text?.count != 0 && pass.text?.count != 0 && email.text?.count != 0 && rePass.text?.count != 0 && isEmail && isMatch
        submit.alpha = agreed && uName.text?.count != 0 && pass.text?.count != 0 && email.text?.count != 0 && rePass.text?.count != 0 && isEmail && isMatch ? 1 : 0.5
    }
    
    @objc func textEmailIsChanging(_ textField:UITextField) {
//        let isEmail: Bool = email.text?.count != 0 && (email.text?.isValidEmail())!
//        let isMatch: Bool = true//pass.text?.count != 0 && rePass.text?.count != 0 && pass.text == rePass.text
//        emailBG.backgroundColor = isEmail ? .white : .white
//        emailError.alpha = isEmail ? 0 : 1
//        submit.isEnabled = agreed && uName.text?.count != 0 && email.text?.count != 0 && isEmail && isMatch
//        submit.alpha = agreed && uName.text?.count != 0 && email.text?.count != 0 && isEmail && isMatch ? 1 : 0.5
        emailBG.backgroundColor = .white
        emailError.alpha = 0
    }
    
   @objc func textIsChanging(_ textField:UITextField) {
        let isEmail: Bool = email.text?.count != 0 && (email.text?.isValidEmail())!
        let isMatch: Bool = true// pass.text?.count != 0 && rePass.text?.count != 0 && pass.text == rePass.text
        submit.isEnabled = agreed && uName.text?.count != 0 && email.text?.count != 0 && isEmail && isMatch
        submit.alpha = agreed && uName.text?.count != 0 && email.text?.count != 0 && isEmail && isMatch ? 1 : 0.5
   }
    
    func convertPhone() -> String {
        let phone = self.phone.text
       if phone?.substring(to: 2) == "84" {
           return phone!
       } else if phone?.substring(to: 1) == "0"  {
           return "84" + (phone?.dropFirst())!
       }
       return phone!
    }
    
    func checkPhone() -> Bool {
        let phone = self.phone.text
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
        phoneError.alpha = isValid ? 0 : 1
        phoneBG.backgroundColor = isValid ? .white : .white
      }
    
    @objc func textPhoneIsChanging(_ textField:UITextField) {
        isValid = true
        validPhone()
    }
}

extension PC_Register_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return indexPath.row == 0 ? 158 : confirm ? 240 : indexPath.row == 4 ? 150 : 93
        return indexPath.row == 0 ? 158 : confirm ? 240 : indexPath.row == 2 ? 150 : 93
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return confirm ? 2 : dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        return confirm ? [ logoCell, confirmCell][indexPath.row] : dataList?[indexPath.row] as! UITableViewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}



