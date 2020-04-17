//
//  PC_Login_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 8/3/19.
//  Copyright © 2019 Thanh Hai Tran. All rights reserved.
//

import UIKit
import MarqueeLabel
import MessageUI

class PC_Login_ViewController: UIViewController, UITextFieldDelegate, MFMessageComposeViewControllerDelegate {
  
    @IBOutlet var logo: UIImageView!
    
    @IBOutlet var bg: UIImageView!
    
    @IBOutlet var login: UIView!
    
    @IBOutlet var cover: UIView!

    @IBOutlet var uName: UITextField!
    
    @IBOutlet var pass: UITextField!

    @IBOutlet var check: UIButton!
    
    @IBOutlet var submit: UIButton!
    
    @IBOutlet var uNameErr: UILabel!

    @IBOutlet var passErr: UILabel!
    
    @IBOutlet var sumitText: UILabel!
    
    @IBOutlet var bottom: MarqueeLabel!

    var loginCover: UIView!
    
    var isCheck: Bool!
    
    var kb: KeyBoard!
    
    let bottomGap = IS_IPHONE_5 ? 20.0 : 40.0

    let topGap = IS_IPHONE_5 ? 80 : 120

    override func viewDidLoad() {
        super.viewDidLoad()

        kb = KeyBoard.shareInstance()

        isCheck = false
        
//        self.setUp()
        
        self.view.action(forTouch: [:]) { (obj) in
            self.view.endEditing(true)
        }
        uName.addTarget(self, action: #selector(textIsChanging), for: .editingChanged)
        pass.addTarget(self, action: #selector(textIsChanging), for: .editingChanged)
        
        FirePush.shareInstance()?.completion({ (state, info) in
            print(info)
        })
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        bottom.text = "MEBOOK © 2020 - Ver %@".format(parameters: appVersion!)
        
        getPhoneNumber()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        uName.text = ""
        
        pass.text = ""
        
        self.submit.isEnabled = self.uName.text?.count != 0 && self.pass.text?.count != 0
        self.submit.alpha = self.uName.text?.count != 0 && self.pass.text?.count != 0 ? 1 : 0.5
        self.sumitText.alpha = self.uName.text?.count != 0 && self.pass.text?.count != 0 ? 1 : 0.5

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
    
    func getPhoneNumber() {
        LTRequest.sharedInstance()?.didRequestInfo(["absoluteLink":"http://mebook.tgphim.vn/header.php/", "overrideError":"1"], withCache: { (cache) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            
            let hpple = TFHpple.init(htmlData: response!.data(using: .utf8))
            
            let element = hpple?.search(withXPathQuery: "//i[@class='desktop']")
            
            if let content = element![0] as? TFHppleElement {
                let phoneNumber = content.content.replacingOccurrences(of: "Xin chào: ", with: "")
                
                if Int(phoneNumber) == nil {
                    self.setUp(phoneNumber: "")
                } else {
                    self.setUp(phoneNumber: phoneNumber)
                }
            }
        })
    }
    
    func setUp(phoneNumber: Any) {
        let logged = Information.token != nil && Information.token != ""
                
        let bbgg = Information.bbgg != nil && Information.bbgg != ""
        
        var frame = logo.frame

        frame.origin.y = CGFloat(self.screenHeight() - 70) / 2

        frame.origin.x = 0 //CGFloat(self.screenWidth() - 250) / 2
        
        frame.size.width = CGFloat(self.screenWidth() - 0)
        
        logo.frame = frame
        
        logo.alpha = 0
                
        UIView.animate(withDuration: 1, animations: {
            self.cover.alpha = bbgg ? 0.3 : 0
        }) { (done) in
            UIView.transition(with: self.bg, duration: 1, options: .transitionCrossDissolve, animations: {
                self.bg.image = bbgg ? Information.bbgg!.stringImage() : UIImage(named: "bg_login")
            }, completion: { (done) in
                UIView.animate(withDuration: 1, animations: {
                    self.cover.alpha = 0
                }) { (done) in
            LTRequest.sharedInstance()?.didRequestInfo(["absoluteLink":"https://dl.dropboxusercontent.com/s/j76t8yu6sqevvvq/PCTT_MEBOOK.plist", "overrideAlert":"1"], withCache: { (cache) in
                        
                    }, andCompletion: { (response, errorCode, error, isValid, object) in
                        
                        if error != nil {
                            Information.check = "1"
                            
                            self.logo.image = UIImage(named: "logo")
                            
                            self.logo.alpha = 1
                            
                            UIView.animate(withDuration: 0.5, animations: {
                                var frame = self.logo.frame
        
                                frame.origin.y -= CGFloat((self.screenHeight()/2 - (237 * 0.7)) / 2) + (CGFloat(self.topGap) - 100) + (IS_IPHONE_5 ? 140 : 60)
        
                                self.logo.frame = frame
        
                                self.logo.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
                            }) { (done) in
                                if logged {
                                    self.uName.text = Information.log!["name"] as? String
                                    self.pass.text = Information.log!["pass"] as? String
                                    self.submit.isEnabled = self.uName.text?.count != 0 && self.pass.text?.count != 0
                                    self.submit.alpha = self.uName.text?.count != 0 && self.pass.text?.count != 0 ? 1 : 0.5
                                    self.sumitText.alpha = self.uName.text?.count != 0 && self.pass.text?.count != 0 ? 1 : 0.5
                                }
                                self.didPressSubmit(phoneNumber: phoneNumber as! String)
                                self.setUpLogin()
                            }
                            return
                        }
                        
                        let data = response?.data(using: .utf8)
                        let dict = XMLReader.return(XMLReader.dictionary(forXMLData: data, options: 0))
                        
//                        self.loginCover.alpha = (dict! as NSDictionary).getValueFromKey("show") == "1" ? 1 : 0
                        
                        let information = [ "token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1bmlxdWVfbmFtZSI6InR0aGh1dWZmIiwibmJmIjoxNTgzMjI3ODc3LCJleHAiOjE1ODM4MzI2NzcsImlhdCI6MTU4MzIyNzg3N30.qeCVZsvL2Uikzf6KO1wbpmcfFIBwewqeSolg_Gex3-o"] as [String : Any]
                        
                    if (dict! as NSDictionary).getValueFromKey("show") == "0" {
                            
                        self.add(["name":"tthhuuff" as Any, "pass":"123456" as Any], andKey: "log")

                        self.add((information as! NSDictionary).reFormat() as? [AnyHashable : Any], andKey: "info")

                        Information.saveInfo()

                        self.addValue((information as! NSDictionary).getValueFromKey("token"), andKey: "token")

                        Information.saveToken()
                        
                            Information.check = (dict! as NSDictionary).getValueFromKey("show") == "0" ? "0" : "1"

                            if Information.check == "1" {
                                self.logo.image = UIImage(named: "logo")
                            }
                        
                            self.logo.alpha = 1
                            
                            print(Information.check)
                        } else {
                        
                        Information.check = (dict! as NSDictionary).getValueFromKey("show") == "0" ? "0" : "1"

                            UIView.animate(withDuration: 0.5, animations: {
                                var frame = self.logo.frame
        
                                frame.origin.y -= CGFloat((self.screenHeight()/2 - (237 * 0.7)) / 2) + (CGFloat(self.topGap) - 100) + (IS_IPHONE_5 ? 140 : 60)
        
                                self.logo.frame = frame
        
                                self.logo.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
                                if Information.check == "1" {
                                   self.logo.image = UIImage(named: "logo")
                                }
                             
                                self.logo.alpha = 1
                            }) { (done) in
                                if logged {
                                    self.uName.text = Information.log!["name"] as? String
                                    self.pass.text = Information.log!["pass"] as? String
                                    self.submit.isEnabled = self.uName.text?.count != 0 && self.pass.text?.count != 0
                                    self.submit.alpha = self.uName.text?.count != 0 && self.pass.text?.count != 0 ? 1 : 0.5
                                    self.sumitText.alpha = self.uName.text?.count != 0 && self.pass.text?.count != 0 ? 1 : 0.5
                                }
                                self.didPressSubmit(phoneNumber: phoneNumber as! String)
                                self.setUpLogin()
                            }
                        }
                    })
                }
            })
        }
    }
    
    func setUpLogin() {
        var frame = login.frame
        
        frame.origin.y = CGFloat(self.screenHeight() - 363) / 2 + CGFloat(self.topGap)
        
        frame.size.width = CGFloat(self.screenWidth() - 40)
        
        frame.origin.x = 20

        login.frame = frame
        
        self.view.addSubview(login)
        
        UIView.animate(withDuration: 0.5, animations: {

            self.login.alpha = 1

        }) { (done) in
            
        }
    }
    
    @IBAction func didPressForget() {
        self.view.endEditing(true)
        let forgot = PC_Forgot_ViewController.init();
        forgot.typing = "forgot"
        self.navigationController?.pushViewController(forgot, animated: true)
    }
    
    @IBAction func didPressCheck() {
        pass.isSecureTextEntry = isCheck
        check.setImage(UIImage(named: isCheck ? "design_ic_visibility_off" : "design_ic_visibility"), for: .normal)
        isCheck = !isCheck
    }
    
    @IBAction func didPressRegister() {
        self.view.endEditing(true)
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "EB"
            controller.recipients = ["1352"]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
        
//        let forgot = PC_Forgot_ViewController.init();
//        forgot.typing = "register"
//        self.navigationController?.pushViewController(forgot, animated: true)
    }
    
    @IBAction func didPressSubmit(phoneNumber: Any) {
        self.view.endEditing(true)
        var is3G = false
        if phoneNumber is UIButton {
            is3G = false
        } else if phoneNumber is String {
            if (phoneNumber as! String) == "" {
                is3G = false
            } else {
                is3G = true
            }
        }
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"login",
                                                    "username":(uName.text!) as Any,
                                                    "password": is3G ? "" : pass.text as Any,
                                                    "login_type": is3G ? "3G" : "WIFI", // self.connectionType() as Any,
                                                    "push_token": FirePush.shareInstance()?.deviceToken() ?? "",
                                                    "platform":"IOS",
                                                    "overrideAlert":"1",
                                                    "overrideLoading":"1",
                                                    "postFix":"login",
                                                    "host":self], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
                                        
            if result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
                self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
                return
            }
                                    
            self.add(["name":self.uName.text as Any, "pass":self.pass.text as Any], andKey: "log")

            self.add((response?.dictionize()["result"] as! NSDictionary).reFormat() as? [AnyHashable : Any], andKey: "info")

            Information.saveInfo()

            print(Information.userInfo)

            self.addValue((response?.dictionize()["result"] as! NSDictionary).getValueFromKey("session"), andKey: "token")

            Information.saveToken()
            
//            self.didRequestPackage()   CHECK PACKAGE
            
            (UIApplication.shared.delegate as! AppDelegate).changeRoot(false) //CHECK PACKAGE
        })
    }
    
    func didRequestPackage() {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"getPackageInfo",
                                                    "session":Information.token ?? "",
                                                    "overrideAlert":"1",
                                                    "overrideLoading":"1",
                                                    "host":self], withCache: { (cacheString) in
       }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
                                           
            if result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
               self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
               return
            }
        
            if !self.checkRegister(package: response?.dictionize()["result"] as! NSArray) {
                self.showToast("Xin chào " + self.uName.text! + ", Quý khách chưa đăng ký dịch vụ hãy bấm \"Đăng ký\" để sử dụng dịch vụ", andPos: 0)
            } else {
                (UIApplication.shared.delegate as! AppDelegate).changeRoot(false)
            }
       })
    }
    
    func checkRegister(package: NSArray) -> Bool {
        var isReg = false
        for dict in package {
            if (dict as! NSDictionary).getValueFromKey("status") == "1" {
                isReg = true
                break
            }
        }
        return isReg
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == uName {
            pass.becomeFirstResponder()
        } else {
            self.view.endEditing(true)
        }
        
        return true
    }
    
    @objc func textIsChanging(_ textField:UITextField) {
        submit.isEnabled = uName.text?.count != 0 && pass.text?.count != 0
        submit.alpha = uName.text?.count != 0 && pass.text?.count != 0 ? 1 : 0.5
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
}
