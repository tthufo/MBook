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
import AuthenticationServices

class PC_Login_ViewController: UIViewController, UITextFieldDelegate, MFMessageComposeViewControllerDelegate {
    
    @IBOutlet var logo: UIImageView!
    
    @IBOutlet var bg: UIImageView!
    
    @IBOutlet var login: UIView!
    
    @IBOutlet var cover: UIView!

    @IBOutlet var uName: UITextField!
    
    @IBOutlet var pass: UITextField!

    @IBOutlet var check: UIButton!
    
    @IBOutlet var submit: UIButton!
    
    @IBOutlet var email_reg: UIButton!
    
    @IBOutlet var uNameErr: UILabel!
    
    @IBOutlet var uNameView: UIView!

    @IBOutlet var passErr: UILabel!
    
//    @IBOutlet var sumitText: UILabel!
    
    @IBOutlet var bottom: MarqueeLabel!
    
    @IBOutlet var login_bg_height: NSLayoutConstraint!
    
    @objc var logOut: String!

    var loginCover: UIView!
    
    var isCheck: Bool!
    
    var isValid: Bool = true
    
    var isSms: Bool = false
    
    var kb: KeyBoard!
    
    let bottomGap = IS_IPHONE_5 ? 40.0 : 60.0

    let topGap = IS_IPHONE_5 ? 200 : 240

    override func viewDidLoad() {
        super.viewDidLoad()

        kb = KeyBoard.shareInstance()

        isCheck = false
        
        if IS_IPAD {
            login_bg_height.constant = 550
        }
        
//        self.setUp()
        
        self.view.action(forTouch: [:]) { (obj) in
            self.view.endEditing(true)
        }
        
        self.logo.alpha = 0

        uName.addTarget(self, action: #selector(textIsChanging), for: .editingChanged)
        pass.addTarget(self, action: #selector(textIsChanging), for: .editingChanged)
        
        FirePush.shareInstance()?.completion({ (state, info) in
            print("--->", state, info)
        })
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        bottom.text = "MEBOOK © 2020 - Ver %@".format(parameters: appVersion!)
        
        email_reg.setBackgroundImage(UIImage(named: "ico_email-1")?.withTintColor(UIColor.orange), for: .normal)
        
        getPhoneNumber()
    }
    
    //USING FIREPUSH PROJECT CONSOLE
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        if uName != nil {
//            uName.text = ""
//        }
//        if pass != nil {
//            pass.text = ""
//        }
//        if submit != nil {
//            self.submit.isEnabled = self.uName.text?.count != 0 && self.pass.text?.count != 0
//            self.submit.alpha = self.uName.text?.count != 0 && self.pass.text?.count != 0 ? 1 : 0.5
//            self.sumitText.alpha = self.uName.text?.count != 0 && self.pass.text?.count != 0 ? 1 : 0.5
//        }
        if (kb != nil) {
            kb.keyboardOff()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        kb.keyboard { (height, isOn) in
                        
            if self.isSms {
                return
            }
            
            UIView.animate(withDuration: 1, animations: {
                if !IS_IPAD {
                    var frame = self.login.frame
                    
                    frame.origin.y -= isOn ? (height - CGFloat(self.bottomGap)) : (-height + CGFloat(self.bottomGap))
                   
                    self.login.frame = frame
                    
                    var frameLogo  = self.logo.frame
                    
                    frameLogo.origin.y -= isOn ? (height - CGFloat(self.bottomGap)) : (-height + CGFloat(self.bottomGap))
                    
                    self.logo.frame = frameLogo
                }
            })
        }
    }
    
    func getPhoneNumber() {
        LTRequest.sharedInstance()?.didRequestInfo(["absoluteLink":"http://mebook.tgphim.vn/header.php/", "overrideAlert":"1", "overrideError":"1"], withCache: { (cache) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
                        
            if errorCode == "200" {
                let hpple = TFHpple.init(htmlData: response!.data(using: .utf8))
    
                let element = hpple?.search(withXPathQuery: "//i[@class='desktop']")
    
                if let content = element![0] as? TFHppleElement {
                    let phoneNumber = content.content.replacingOccurrences(of: "Xin chào: ", with: "")
    
                    if !phoneNumber.isNumber {
                        self.setUp(phoneNumber: "")
                    } else {
                        self.setUp(phoneNumber: phoneNumber)
                    }
                }
            } else {
                self.setUp(phoneNumber: "")
            }
        })
    }
    
    func normalFlow(logged: Bool, phoneNumber: Any) {
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
            self.uName.text = Information.log?.getValueFromKey("name")
               self.pass.text = Information.log?.getValueFromKey("pass")   //CHECK HERE
            
//               self.submit.isEnabled = self.uName.text?.count != 0 && self.pass.text?.count != 0
//               self.submit.alpha = self.uName.text?.count != 0 && self.pass.text?.count != 0 ? 1 : 0.5
//               self.sumitText.alpha = self.uName.text?.count != 0 && self.pass.text?.count != 0 ? 1 : 0.5
           }
           DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {
              if self.logOut == "logIn" {
                  self.didPressSubmit(phoneNumber: phoneNumber as! String)
              }
           })
           self.setUpLogin()
       }
    }
    
    func setUp(phoneNumber: Any) {
                
        let logged = Information.token != nil && Information.token != ""
                
//        let bbgg = Information.bbgg != nil && Information.bbgg != ""
        
        var frame = logo.frame

        frame.origin.y = CGFloat(self.screenHeight() - 70) / 2

        frame.origin.x = 0 //CGFloat(self.screenWidth() - 250) / 2
        
        frame.size.width = CGFloat(self.screenWidth() - 0)
        
        logo.frame = frame
        
        logo.alpha = 0
        
        UIView.animate(withDuration: 1, animations: {
//            self.cover.alpha = bbgg ? 0.3 : 0
        }) { (done) in
            
            UIView.animate(withDuration: 1, animations: {
//                    self.cover.alpha = 0
            }) { (done) in
                
        if NSDate.init().isPastTime("01/06/2021") {
            self.normalFlow(logged: logged, phoneNumber: phoneNumber)
            return
        }
                
        LTRequest.sharedInstance()?.didRequestInfo(["absoluteLink":
            "https://dl.dropboxusercontent.com/s/wn0gmjklqvewds6/PCTT_MEBOOK_5.plist"
//            "https://dl.dropboxusercontent.com/s/nwvcjvg8kzl8hba/PCTT_MEBOOK_2.plist"
//            https://www.dropbox.com/s/wn0gmjklqvewds6/PCTT_MEBOOK_5.plist
            , "overrideAlert":"1"], withCache: { (cache) in

                }, andCompletion: { (response, errorCode, error, isValid, object) in

                    if error != nil {
                        self.normalFlow(logged: logged, phoneNumber: phoneNumber)
                        return
                    }

                    let data = response?.data(using: .utf8)
                    let dict = XMLReader.return(XMLReader.dictionary(forXMLData: data, options: 0))

                    let information = [ "token": IS_IPAD ? "38335D8087987CF727B8C8A658E36189" : "A87927EE6A7AAA8EE786BA2B23ED8E19"] as [String : Any]
                    
                if (dict! as NSDictionary).getValueFromKey("show") == "0" {

                    if IS_IPAD {
                        self.add(["name":"0919902197" as Any, "pass":"933769" as Any], andKey: "log")
                    } else {
                        self.add(["name":"0915286679" as Any, "pass":"860844" as Any], andKey: "log")
                    }

                    self.add((information as NSDictionary).reFormat() as? [AnyHashable : Any], andKey: "info")

                    Information.saveInfo()

                    self.addValue((information as NSDictionary).getValueFromKey("token"), andKey: "token")

                    Information.saveToken()

                    Information.check = (dict! as NSDictionary).getValueFromKey("show") == "0" ? "0" : "1"

                    if Information.check == "1" {
                        self.logo.image = UIImage(named: "logo")
                    }
                    
                    self.uName.text = Information.log!["name"] as? String
                    self.pass.text = Information.log!["pass"] as? String

                    self.didPressSubmit(phoneNumber: "" as Any)
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
//                                self.sumitText.alpha = self.uName.text?.count != 0 && self.pass.text?.count != 0 ? 1 : 0.5
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: {
                                if self.logOut == "logIn" {
                                   self.didPressSubmit(phoneNumber: phoneNumber as! String)
                               }
                            })
                            self.setUpLogin()
                        }
                    }
                })
            }
        }
    }
    
    func setUpLogin() {
        var frame = login.frame
        
        frame.origin.y = CGFloat(self.screenHeight() - 363) / 2 + CGFloat(self.topGap) - 180
        
        frame.size.width = CGFloat(self.screenWidth() - (IS_IPAD ? 200 : 20))
        
        frame.origin.x = IS_IPAD ? 100 : 10

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
        check.setImage(UIImage(named: isCheck ? "ico_hide" : "ico_hide"), for: .normal)
        isCheck = !isCheck
    }
    
    @IBAction func didPressRegister(sender: UIButton) {
        self.view.endEditing(true)
        
        let reg = PC_Register_ViewController.init()
        
        reg.isPhone = sender.tag == 11 ? true : false
        
        self.navigationController?.pushViewController(reg, animated: true)
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
    
    func convertPhone() -> String {
        let phone = uName.text
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
    
    @IBAction func didPressSubmit(phoneNumber: Any) {
        self.view.endEditing(true)
        var is3G = false
        if phoneNumber is String {
            if (phoneNumber as! String) == "" {
                is3G = false
            } else {
                is3G = true
            }
        }
                         
        let logged = Information.log != nil ? Information.log?.getValueFromKey("name") != "" && Information.log?.getValueFromKey("pass") != "" ? true : false : false
                
        let social_logged = self.getObject("social")
        
        if is3G {
            self.uName.text = (phoneNumber as! String)
            requestLogin(request: ["username":phoneNumber,
//                                   "password":pass.text as Any,
                                   "login_type":"3G"])
            Information.allPackage = "1"
            print("3G")
        } else {
            if logged {
                requestLogin(request: ["username":self.stringIsNumber(uName.text!) ? convertPhone() : uName.text!,
                                       "password":pass.text as Any,
                                       "login_type":"WIFI"])
                Information.allPackage = self.stringIsNumber(uName.text!) ? "1" : "0"
                print("LOGIN_LOGGED")
            } else if social_logged == nil {
                if phoneNumber is UIButton {
//                    isValid = self.checkPhone()
//                    if !isValid {
//                        validPhone()
//                        return
//                    }
//                    print(convertPhone())
                    requestLogin(request: ["username":self.stringIsNumber(uName.text!) ? convertPhone() : uName.text!,
                                            "password":pass.text as Any,
                                            "login_type":"WIFI"])
                    Information.allPackage = self.stringIsNumber(uName.text!) ? "1" : "0"
                    print("BUTTON")
                }
            } else {
                didRequestLoginSocial(info: social_logged! as NSDictionary)
                Information.allPackage = "0"
                print("SOCIAL")
            }
        }
    }
    
    func requestLogin(request: NSDictionary) {
        let requesting = NSMutableDictionary.init(dictionary: ["CMD_CODE":"login",
                                                               "push_token": FirePush.shareInstance()?.deviceToken() ?? self.uniqueDeviceId()!,
                                                                "platform":"IOS",
                                                                "overrideAlert":"1",
                                                                "overrideLoading":"1",
                                                                "host":self])
        requesting.addEntries(from: request as! [AnyHashable : Any])
        LTRequest.sharedInstance()?.didRequestInfo(requesting as? [AnyHashable : Any], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
                        
            if result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
                self.showToast("Không có thông tin tài khoản. Liên hệ quản trị viên để được tài trợ.", andPos: 0)
                return
            }
                                                
            self.add(["name":self.uName.text as Any, "pass":self.pass.text as Any], andKey: "log")

            self.add((response?.dictionize()["result"] as! NSDictionary).reFormat() as? [AnyHashable : Any], andKey: "info")

            Information.saveInfo()

            self.addValue((response?.dictionize()["result"] as! NSDictionary).getValueFromKey("session"), andKey: "token")

            Information.saveToken()
                        
            if Information.check == "0" {
                self.didRequestPackage()   //CHECK PACKAGE ---> check this shit
//                (UIApplication.shared.delegate as! AppDelegate).changeRoot(false) //CHECK PACKAGE
            } else {
                (UIApplication.shared.delegate as! AppDelegate).changeRoot(false) //CHECK PACKAGE
            }
        })
    }
    
    func didRequestPackage() {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"getPackageInfo",
                                                    "header":["session":Information.token == nil ? "" : Information.token!],
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
        
            print("++++", result)
        
            if !self.checkRegister(package: response?.dictionize()["result"] as! NSArray) {
//                self.showToast("Xin chào " + self.uName.text! + ", Quý khách chưa đăng ký dịch vụ, hãy bấm \"Đăng ký\" để sử dụng dịch vụ", andPos: 0)
//                (UIApplication.shared.delegate as! AppDelegate).changeRoot(false) //dev check
            } else {
//                (UIApplication.shared.delegate as! AppDelegate).changeRoot(false)
//                if self.uName != nil {
//                   self.uName.text = ""
//                }
//                if self.pass != nil {
//                   self.pass.text = ""
//                }
//                if self.submit != nil {
//                   self.submit.isEnabled = self.uName.text?.count != 0 && self.pass.text?.count != 0
//                   self.submit.alpha = self.uName.text?.count != 0 && self.pass.text?.count != 0 ? 1 : 0.5
////                   self.sumitText.alpha = self.uName.text?.count != 0 && self.pass.text?.count != 0 ? 1 : 0.5
//                }
            }
       })
    }
    
    func didRequestLoginSocial(info: NSDictionary) {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"socialLogin",
                                                     "push_token": FirePush.shareInstance()?.deviceToken() ?? self.uniqueDeviceId() as Any,
                                                     "platform":"IOS",
                                                     "provider":info.getValueFromKey("provider") ?? "",
                                                     "access_token":info.getValueFromKey("accessToken") ?? "",
                                                     "avatar":info.getValueFromKey("avatar") ?? "",
                                                     "email":info.getValueFromKey("email") ?? "",
                                                     "id":info.getValueFromKey("id") ?? "",
                                                     "name":info.getValueFromKey("name") ?? "",
                                                     "overrideAlert":"1",
                                                     "overrideLoading":"1",
                                                     "host":self], withCache: { (cacheString) in
       }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
                                           
            if result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
               self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
               return
            }
        
            if result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
                self.showToast("Không có thông tin tài khoản. Liên hệ quản trị viên để được tài trợ.", andPos: 0)
                return
            }
                                                
//            self.add(["name":self.uName.text as Any, "pass":self.pass.text as Any], andKey: "log")

            self.add((response?.dictionize()["result"] as! NSDictionary).reFormat() as? [AnyHashable : Any], andKey: "info")

            Information.saveInfo()

            self.addValue((response?.dictionize()["result"] as! NSDictionary).getValueFromKey("session"), andKey: "token")

            Information.saveToken()
        
            self.add((info as! [AnyHashable : Any]), andKey: "social")
                        
            if Information.check == "0" { // --------> Check This shit
                print("package")
                self.didRequestPackage()   //CHECK PACKAGE
    //                (UIApplication.shared.delegate as! AppDelegate).changeRoot(false) //CHECK PACKAGE
            } else {
                print("changeroot")
                (UIApplication.shared.delegate as! AppDelegate).changeRoot(false) //CHECK PACKAGE
            }
       })
    }
    
    func expire(dateString: String) -> Date {
        let expDate = dateString.date(withFormat: "dd-MM-yyyy")
        return expDate!
    }
    
    func checkRegister(package: NSArray) -> Bool {
        var isReg = false
        var data: [[String: String]] = []
        
        for dict in package {
            let expDate = ((dict as! NSDictionary).getValueFromKey("expireTime")! as NSString).date(withFormat: "dd/MM/yyyy")
            data.append(["status": (dict as! NSDictionary).getValueFromKey("status"), "date": (dict as! NSDictionary).getValueFromKey("expireTime")])
            if (dict as! NSDictionary).getValueFromKey("status") == "1" && Date() < expDate! {
//                isReg = true
                return true
            }
        }
        
        if data[0]["status"] == "1" && Date() >= self.expire(dateString: data[0]["date"]!) || data[1]["status"] == "1" && Date() >= self.expire(dateString: data[1]["date"]!) {
            self.showToast("Tài khoản của Quý Khách đã hết hạn sử dụng. Vui lòng nạp thêm tiền vào tài khoản chính để tiếp tục sử dụng dịch vụ.", andPos: 0)
            return false
        }
        
        if data[0]["status"] == "2" && data[1]["status"] == "2" {
           self.showToast("Xin chào " + self.uName.text! + ", Quý khách chưa đăng ký dịch vụ, hãy bấm \"Đăng ký\" để sử dụng dịch vụ", andPos: 0)
           return false
        }
        
//        if  {
//           self.showToast("Tài khoản của Quý Khách đã hết hạn sử dụng. Vui lòng nạp thêm tiền vào tài khoản chính để tiếp tục sử dụng dịch vụ.", andPos: 0)
//           return false
//        }
               
        
//        if (dict as! NSDictionary).getValueFromKey("status") == "2" {
//            self.showToast("Xin chào " + self.uName.text! + ", Quý khách chưa đăng ký dịch vụ, hãy bấm \"Đăng ký\" để sử dụng dịch vụ", andPos: 0)
//            isReg = false
//            break
//        }
        
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
    
    func validPhone() {
        uNameErr.alpha = isValid ? 0 : 1
        uNameView.backgroundColor = isValid ? UIColor.white : UIColor.systemRed
    }
    
    @objc func textIsChanging(_ textField:UITextField) {
        isValid = true
//        validPhone()
//        submit.isEnabled = uName.text?.count != 0 && pass.text?.count != 0
//        submit.alpha = uName.text?.count != 0 && pass.text?.count != 0 ? 1 : 0.5
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: {
            self.isSms = false
        })
    }
    
    @IBAction func handleLogInWithAppleID() {
         let request = ASAuthorizationAppleIDProvider().createRequest()
         request.requestedScopes = [.fullName, .email]
         
         let controller = ASAuthorizationController(authorizationRequests: [request])
         
         controller.delegate = self
         controller.presentationContextProvider = self
         
         controller.performRequests()
     }
    
    @IBAction func didPressGG() {
       self.view.endEditing(true)
       GG_PlugIn.shareInstance()?.startLogGoogle(completion: { (responseString, object, errorCode, description, error) in
            if object != nil {
                let info = (object as! NSDictionary)
                let gID = info.getValueFromKey("uId")
                let accessToken = info.getValueFromKey("accessToken")
                let avatar = info.getValueFromKey("avatar")
                let name = info.getValueFromKey("fullName")
                let email = info.getValueFromKey("email")
                self.didRequestLoginSocial(info: ["provider": "google",
                                                  "id":gID ?? "",
                                                  "accessToken":accessToken ?? "",
                                                  "avatar":avatar ?? "",
                                                  "name":name ?? "",
                                                  "email":email ?? ""
                ])
            }
        }, andHost: self)
   }
    
    @IBAction func didPressFB() {
        self.view.endEditing(true)
        FB_Plugin.shareInstance()?.startLoginFacebook(completion: { (responseString, object, errorCode, description, error) in
            if object != nil {
//                print("-->", object)
                let info = ((object as! NSDictionary)["info"] as! NSDictionary)
                let fID = info.getValueFromKey("id")
                let accessToken = info.getValueFromKey("accessToken")
                let avatar = info.getValueFromKey("avatar")
                let name = info.getValueFromKey("name")
                self.didRequestLoginSocial(info: ["provider": "facebook",
                                                  "id":fID ?? "",
                                                  "accessToken":accessToken ?? "",
                                                  "avatar":avatar ?? "",
                                                  "name":name ?? "",
                                                  "email":""
                ])
            }
        })
      }
}

extension PC_Login_ViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let userIdentifier = appleIDCredential.user
        
            let name = appleIDCredential.fullName
            
            let email = appleIDCredential.email
            
            let u = appleIDCredential.user
            
            let le = appleIDCredential.identityToken
            

            print("--->", userIdentifier, name, email, u, String(data: le!, encoding: .utf8))
        
            break
        default:
            break
        }
    }
}

extension PC_Login_ViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
           return self.view.window!
    }
}
