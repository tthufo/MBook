//
//  PC_ChangePass_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 8/4/19.
//  Copyright © 2019 Thanh Hai Tran. All rights reserved.
//

import UIKit

import MarqueeLabel

class PC_ChangePass_ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var bg: UIImageView!
    
    @IBOutlet var cover: UIView!
    
    @IBOutlet var reNewBg: UIView!
    
    @IBOutlet var titleLabel: MarqueeLabel!

    var kb: KeyBoard!
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var cell1: UITableViewCell!
    
    @IBOutlet var cell2: UITableViewCell!

    @IBOutlet var cell3: UITableViewCell!
    
    @IBOutlet var cell4: UITableViewCell!

    @IBOutlet var oldPass: UITextField!
    
    @IBOutlet var newPass: UITextField!
    
    @IBOutlet var reNewPass: UITextField!
    
    @IBOutlet var oldPass_btn: UIButton!
    
    @IBOutlet var newPass_btn: UIButton!
    
    @IBOutlet var reNewPass_btn: UIButton!
    
    @IBOutlet var submit: UIButton!
    
    @IBOutlet var oldPassErr: UILabel!
    
    @IBOutlet var newPassErr: UILabel!
    
    @IBOutlet var reNewPassErr: UILabel!
    
    @IBOutlet var bottomHeight: NSLayoutConstraint!
    
    @IBOutlet var sideGapLeft: NSLayoutConstraint!
      
    @IBOutlet var sideGapRight: NSLayoutConstraint!
    
    @IBOutlet var sideGapBottomLeft: NSLayoutConstraint!
       
    @IBOutlet var sideGapBottomRight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if IS_IPAD {
          sideGapLeft.constant = 100
          sideGapRight.constant = -100
//          sideGapBottomLeft.constant = 100
//          sideGapBottomRight.constant = 100
        }
        
        kb = KeyBoard.shareInstance()
        
        self.view.action(forTouch: [:]) { (obj) in
            self.view.endEditing(true)
        }
        
//        self.tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        
        if Information.bg != nil && Information.bg != "" {
            bg.imageUrlNoCache(url: Information.bg ?? "")
        }
        
        oldPass.addTarget(self, action: #selector(textOldIsChanging), for: .editingChanged)
        newPass.addTarget(self, action: #selector(textOldIsChanging), for: .editingChanged)
        reNewPass.addTarget(self, action: #selector(textIsChanging), for: .editingChanged)
        
        let fields = [oldPass_btn, newPass_btn, reNewPass_btn]

        for field in fields {
            (field!).setImage(UIImage(named: "ico_hide")?.withTintColor(AVHexColor.color(withHexString: "#1E928C")), for: .normal)
            (field!).accessibilityLabel = "0"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        kb.keyboardOff()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.isEmbed() {
           bottomHeight.constant = 100
        }
        
        self.tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        
        kb.keyboard { (height, isOn) in
            self.tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: isOn ? (height - 100) : 0, right: 0)
        }
    }
    
    @IBAction func didPressBack() {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didPressCancel() {
        self.view.endEditing(true)
        EM_MenuView.init(cancel: ["line1": "Quý khách muốn huỷ thay đổi ?"]).disableCompletion { (index, obj, menu) in
            if index == 3 {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func didPressCheck(sender: UIButton) {
        let tag = sender.tag

        let fields = [oldPass, newPass, reNewPass]
                
        let check = sender.accessibilityLabel == "0" // sender.currentImage == UIImage(named: "ico_hide")?.withTintColor(AVHexColor.color(withHexString: "#1E928C"))
                        
        (fields[tag - 1])!.isSecureTextEntry = !check
        
        sender.setImage(UIImage(named: !check ? "ico_hide" : "ico_un_hide")?.withTintColor(AVHexColor.color(withHexString: "#1E928C")), for: .normal)

        sender.accessibilityLabel = sender.accessibilityLabel == "0" ? "1" : "0"
    }
    
    @IBAction func didPressSubmit() {
        self.view.endEditing(true)
        
        if newPass.text!.count < 6 || reNewPass.text!.count < 6  {
            self.showToast("Mật khẩu mới phải lớn hơn 6 chữ số", andPos: 0)
            
            return
        }
        
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"changePassword",
                                                    "header":["session":Information.token == nil ? "" : Information.token!],
                                                    "old_password":oldPass.text as Any,
                                                    "new_password":newPass.text as Any,
                                                    "session":Information.token ?? "",
                                                    
                                                    "overrideLoading":"1",
                                                    "overrideAlert":"1",
                                                    "host":self], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]

            if result.getValueFromKey("error_code") != "0" {
                self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
                return
            }
                        
            self.showToast("Đổi mật khẩu thành công", andPos: 0)

            let uInfo: NSDictionary = Information.log!

            self.add(["name":uInfo["name"] as Any, "pass":self.newPass.text as Any], andKey: "log")
            
            Information.saveInfo()
            
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == oldPass {
            newPass.becomeFirstResponder()
        } else if textField == newPass {
            reNewPass.becomeFirstResponder()
        } else {
            self.view.endEditing(true)
        }
        
        return true
    }
    
    @objc func textOldIsChanging(_ textField:UITextField) {
        submit.isEnabled = oldPass.text?.count != 0 && newPass.text?.count != 0 && reNewPass.text?.count != 0 && newPass.text == reNewPass.text
        submit.alpha = oldPass.text?.count != 0 && newPass.text?.count != 0 && reNewPass.text?.count != 0 && newPass.text == reNewPass.text ? 1 : 0.5
    }
    
    @objc func textIsChanging(_ textField:UITextField) {
        let isMatch: Bool = newPass.text?.count != 0 && reNewPass.text?.count != 0 && newPass.text == reNewPass.text
        reNewBg.backgroundColor = isMatch ? AVHexColor.color(withHexString: "#FFFFFF") : .red
        reNewPassErr.alpha = isMatch ? 0 : 1
        
        submit.isEnabled = oldPass.text?.count != 0 && newPass.text?.count != 0 && reNewPass.text?.count != 0 && newPass.text == reNewPass.text
        submit.alpha = oldPass.text?.count != 0 && newPass.text?.count != 0 && reNewPass.text?.count != 0 && newPass.text == reNewPass.text ? 1 : 0.5
    }
}

extension PC_ChangePass_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 3 ? 155 : 94
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return indexPath.row == 0 ? cell1 : indexPath.row == 1 ? cell2 : indexPath.row == 2 ? cell3 : cell4
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}
