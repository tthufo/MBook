//
//  Feed_Back_ViewController.swift
//  HearThis
//
//  Created by Thanh Hai Tran on 5/1/21.
//  Copyright © 2021 Thanh Hai Tran. All rights reserved.
//

import UIKit

class Feed_Back_ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var optionCell: UITableViewCell!

    @IBOutlet var sideGapLeft: NSLayoutConstraint!
    
    @IBOutlet var sideGapRight: NSLayoutConstraint!
    
    @IBOutlet var nextButton: UIButton!
    
    @IBOutlet var name: UITextField!

    @IBOutlet var email: UITextField!

    @IBOutlet var feedBack: UITextView!

    var kb: KeyBoard!

    override func viewDidLoad() {
        super.viewDidLoad()

        kb = KeyBoard.shareInstance()

        if IS_IPAD {
            sideGapLeft.constant = 100
            
            sideGapRight.constant = -100
        }

        tableView.estimatedRowHeight = 150
        
        tableView.rowHeight = UITableView.automaticDimension
        
        feedBack.inputAccessoryView = self.toolBar()
        
        self.view.action(forTouch: [:]) { (objc) in
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
            self.tableView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: isOn ? (height - 0) : 0, right: 0)
        }
    }
    
    @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didPressNext() {
        self.view.endEditing(true)
        if name.hasText && email.hasText && (email.text?.isValidEmail())! && feedBack.hasText {
            self.didRequestFeedback()
            name.text = ""
            email.text = ""
            feedBack.text = ""
        } else {
            if !name.hasText || !email.hasText || !feedBack.hasText {
                self.showToast("Bạn chưa nhập đầy đủ thông tin", andPos: 0)
            } else if !(email.text?.isValidEmail())! {
                self.showToast("Email không đúng định dạng", andPos: 0)
            }
        }
    }
    
    func didRequestFeedback() {
        let request = NSMutableDictionary.init(dictionary: [
                                                            "content": feedBack.text ?? "",
                                                            "email": email.text ?? "",
                                                            "user_name": name.text ?? "",
                                                            "header":["session":Information.token == nil ? "" : Information.token!],
                                                            "session":Information.token ?? "",
                                                            "overrideAlert":"1",
                                                            ])
        request["CMD_CODE"] = "sendFeedback"
        LTRequest.sharedInstance()?.didRequestInfo((request as! [AnyHashable : Any]), withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
            
            if result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
                self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
                return
            }
            
            self.didPressBack()
            
            self.showToast("Gửi phản hồi thành công", andPos: 0)
        })
    }
    
    @IBAction func didPressCancel() {
        EM_MenuView.init(cancel: ["line1": "Quý khách muốn huỷ phản hồi ?"]).disableCompletion { (index, obj, menu) in
            if index == 3 {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       if textField == name {
           email.becomeFirstResponder()
       } else if textField == email {
           feedBack.becomeFirstResponder()
       }
       return true
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

extension Feed_Back_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 675
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return optionCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
