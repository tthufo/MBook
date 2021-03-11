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
    
    @IBOutlet var logo: UIImageView!
    
    @IBOutlet var logoCell: UITableViewCell!
    
    @IBOutlet var nameCell: UITableViewCell!

    @IBOutlet var emailCell: UITableViewCell!
    
    @IBOutlet var phoneCell: UITableViewCell!

    @IBOutlet var passCell: UITableViewCell!

    @IBOutlet var rePassCell: UITableViewCell!

    @IBOutlet var submitCell: UITableViewCell!

    @IBOutlet var uName: UITextField!
    
    @IBOutlet var email: UITextField!
    
    @IBOutlet var phone: UITextField!

    @IBOutlet var pass: UITextField!
    
    @IBOutlet var rePass: UITextField!
    
    @IBOutlet var submit: UIButton!
    
    
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

    override func viewDidLoad() {
        super.viewDidLoad()

        kb = KeyBoard.shareInstance()

        dataList = NSMutableArray.init(array: [logoCell, nameCell, emailCell, phoneCell, submitCell])
        
        self.tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        bottom.text = "MEBOOK © 2020 - Ver %@".format(parameters: appVersion!)

        self.view.action(forTouch: [:]) { (objc) in
            self.view.endEditing(true)
        }
        
        uName.addTarget(self, action: #selector(textIsChanging), for: .editingChanged)
        pass.addTarget(self, action: #selector(textIsChanging), for: .editingChanged)
        
        rePass.addTarget(self, action: #selector(textRePassIsChanging), for: .editingChanged)
        email.addTarget(self, action: #selector(textEmailIsChanging), for: .editingChanged)
        phone.addTarget(self, action: #selector(textPhoneIsChanging), for: .editingChanged)

        if Information.check == "1" {
//            self.logo.image = UIImage(named: "logo")
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
            if !isValid {
                validPhone()
                return
            }
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
                    self.showToast(response?.dictionize().getValueFromKey("data") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("data"), andPos: 0)
                    return
                }
                
                self.showToast("Đăng ký thành công", andPos: 0)
                
                self.navigationController?.popViewController(animated: true)

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
       
    
    @objc func textEmailIsChanging(_ textField:UITextField) {
       let isEmail: Bool = email.text?.count != 0 && (email.text?.isValidEmail())!
        let isMatch: Bool = pass.text?.count != 0 && rePass.text?.count != 0 && pass.text == rePass.text
          emailBG.backgroundColor = isEmail ? AVHexColor.color(withHexString: "#F2F2F2") : .red
          emailError.alpha = isEmail ? 0 : 1
        submit.isEnabled = uName.text?.count != 0 && pass.text?.count != 0 && email.text?.count != 0 && rePass.text?.count != 0 && isEmail && isMatch
        submit.alpha = uName.text?.count != 0 && pass.text?.count != 0 && email.text?.count != 0 && rePass.text?.count != 0 && isEmail && isMatch ? 1 : 0.5
    }
    
    @objc func textRePassIsChanging(_ textField:UITextField) {
        let isEmail: Bool = email.text?.count != 0 && (email.text?.isValidEmail())!

      let isMatch: Bool = pass.text?.count != 0 && rePass.text?.count != 0 && pass.text == rePass.text
            rePassBG.backgroundColor = isMatch ? AVHexColor.color(withHexString: "#F2F2F2") : .red
            rePassError.alpha = isMatch ? 0 : 1
        submit.isEnabled = uName.text?.count != 0 && pass.text?.count != 0 && email.text?.count != 0 && rePass.text?.count != 0 && isEmail && isMatch
               submit.alpha = uName.text?.count != 0 && pass.text?.count != 0 && email.text?.count != 0 && rePass.text?.count != 0 && isEmail && isMatch ? 1 : 0.5
    }
    
   @objc func textIsChanging(_ textField:UITextField) {
    let isEmail: Bool = email.text?.count != 0 && (email.text?.isValidEmail())!
       
    let isMatch: Bool = true// pass.text?.count != 0 && rePass.text?.count != 0 && pass.text == rePass.text
    
    submit.isEnabled = uName.text?.count != 0 && pass.text?.count != 0 && email.text?.count != 0 && rePass.text?.count != 0 && isEmail && isMatch
       submit.alpha = uName.text?.count != 0 && pass.text?.count != 0 && email.text?.count != 0 && rePass.text?.count != 0 && isEmail && isMatch ? 1 : 0.5
   }
    
    func convertPhone() -> String {
       let phone = uName.text
       if phone?.substring(to: 2) == "84" {
           return phone!
       } else if phone?.substring(to: 1) == "0"  {
           return "84" + (phone?.dropFirst())!
       }
       return phone!
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
          phoneError.alpha = isValid ? 0 : 1
          phoneBG.backgroundColor = isValid ? UIColor.white : UIColor.red
      }
    
    @objc func textPhoneIsChanging(_ textField:UITextField) {
        isValid = true
        validPhone()
    }
}

extension PC_Register_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 158 : indexPath.row == 5 ? 100 : 93
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        return dataList?[indexPath.row] as! UITableViewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}



