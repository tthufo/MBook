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
    
    @IBOutlet var bottom: MarqueeLabel!
    
    var typing: NSString!
    
    var kb: KeyBoard!
    
    let bottomGap = IS_IPHONE_5 ? 20.0 : 40.0
    
    let topGap = IS_IPHONE_5 ? 80 : 120
    
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        kb.keyboardOff()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        kb.keyboard { (height, isOn) in
            UIView.animate(withDuration: 1, animations: {
                var frame = self.login.frame
                
                frame.origin.y -= isOn ? (height - CGFloat(self.bottomGap)) : (-height + CGFloat(self.bottomGap))
                
                self.login.frame = frame
                
                var frameLogo  = self.logo.frame
                
                frameLogo.origin.y -= isOn ? (height - CGFloat(self.bottomGap)) : (-height + CGFloat(self.bottomGap))
                
                self.logo.frame = frameLogo
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
        
        UIView.animate(withDuration: 1.5, animations: {
            self.cover.alpha = bbgg ? 0.3 : 0
        }) { (done) in
            UIView.transition(with: self.bg, duration: 1.5, options: .transitionCrossDissolve, animations: {
                self.bg.image = bbgg ? Information.bbgg!.stringImage() : UIImage(named: "bg_login")
            }, completion: { (done) in
                UIView.animate(withDuration: 1.5, animations: {
                    self.cover.alpha = 0
                }) { (done) in
                   
                }
            })
        }
        
        UIView.animate(withDuration: 0, animations: {
            var frame = self.logo.frame
            
            frame.origin.y -= CGFloat((self.screenHeight()/2 - (237 * 0.7)) / 2) + (CGFloat(self.topGap) - 100) + (IS_IPHONE_5 ? 140 : 60)
            
            self.logo.frame = frame
            
            self.logo.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            
        }) { (done) in
            self.setUpLogin()
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
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
//        count.text = "%i/10".format(parameters: updatedString!.count > 10 ? 10 : updatedString!.count)
//        return updatedString!.count >= 11 ? false : true
//    }
    
    @IBAction func didPressBack() {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didPressSubmit() {
        self.view.endEditing(true)
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"reset",
                                                    "phone":uName.text as Any,
                                                    "overrideAlert":"1",
                                                    "overrideLoading":"1",
                                                    "postFix":"auth/password/reset",
                                                    "host":self], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
                                    
            if result.getValueFromKey("status") != "OK" {
                self.showToast(response?.dictionize().getValueFromKey("data") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("data"), andPos: 0)
                return
            }
            
            self.showToast("Lấy lại mật khẩu thành công".format(parameters: self.uName.text!), andPos: 0)

            self.didPressBack()
        })
    }
    
    @objc func textIsChanging(_ textField:UITextField) {
//        let isEmail: Bool = uName.text?.count != 0 && (uName.text?.isValidEmail())!
//
//        uNameBg.backgroundColor = isEmail ? AVHexColor.color(withHexString: "#F2F2F2") : .red
//        uNameErr.alpha = isEmail ? 0 : 1
//        submit.isEnabled = isEmail
//        submit.alpha = isEmail ? 1 : 0.5
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
