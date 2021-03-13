//
//  PC_Confirm_ViewController.swift
//  HearThis
//
//  Created by Thanh Hai Tran on 3/14/21.
//  Copyright © 2021 Thanh Hai Tran. All rights reserved.
//

import UIKit

class PC_Confirm_ViewController: UIViewController {

    var isForgot: Bool = false
    
    @IBOutlet var topLine: UILabel!
    
    @IBOutlet var bottomLine: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        topLine.text = !isForgot ? "Tài khoản mới đã tạo" : "Mật khẩu mới đã tạo"
        
        bottomLine.text = !isForgot ? "Thông tin đăng nhập đã được gửi tới hòm thư/tin nhắn" : "Vui lòng kiểm tra hộp thư/tin nhắn để lấy mật khẩu mới"
    }
    
    @IBAction func didPressBack() {
        self.navigationController?.popToRootViewController(animated: true)
    }

}
