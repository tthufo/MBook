//
//  Check_Out_ViewController.swift
//  HearThis
//
//  Created by Thanh Hai Tran on 4/30/21.
//  Copyright © 2021 Thanh Hai Tran. All rights reserved.
//

import UIKit

class Check_Out_ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var optionCell: UITableViewCell!
    
    @IBOutlet var buttonCell: UITableViewCell!

    @IBOutlet var bankCell: UITableViewCell!

    @IBOutlet var login_bg_height: NSLayoutConstraint!

    @IBOutlet var sideGapLeft: NSLayoutConstraint!
    
    @IBOutlet var sideGapRight: NSLayoutConstraint!
    
    @IBOutlet var nextButton: UIButton!
    
    var expand: Bool = false

    var dataList: NSMutableArray!
    
    @objc var info: NSDictionary!
    
    var paymentInfoBank = NSMutableDictionary()
    
    var paymentInfoGate = NSMutableDictionary()

    var names = [["check": "0", "name": "ic_momo"], ["check": "0", "name": "ic_airpay"], ["check": "0", "name": "ic_vnpay"], ["check": "0", "name": "ic_nganluong"], ["check": "0", "name": "ic_sms"]]

    override func viewDidLoad() {
        super.viewDidLoad()

        if IS_IPAD {
            login_bg_height.constant = 550
            
            sideGapLeft.constant = 100
            
            sideGapRight.constant = 100
        }

        tableView.estimatedRowHeight = 150
        
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.withCell("Vip_Cell")
        
        tableView.withCell("Check_Out_Cell")
        
        tableView.withCell("Check_Out_Book_Cell")
        
        tableView.withCell("Payment_Option_Cell")

        dataList = NSMutableArray.init()
    }
    
    func didRequestPayment() {
        
        if expand && paymentInfoBank.allKeys.count == 0 {
            self.showToast("Bạn chưa chọn ngân hàng để thanh toán", andPos: 0)
            return
        }
        
        let payment = expand ? self.paymentInfoBank : self.paymentInfoGate

        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"purchaseOrder",
                                                    "header":["session":Information.token == nil ? "" : Information.token!],
                                                    "items": [[
                                                        "amount": self.info.getValueFromKey("price") ?? "",
                                                        "item_id": self.info.getValueFromKey("id") ?? "",
                                                        "item_type": "package",
                                                        "quantity": 1
                                                    ]],
                                                    "payment_detail_id": expand ? payment.getValueFromKey("payment_detail_id") as Any : "0",
                                                    "payment_id": payment.getValueFromKey("payment_id") ?? "",
                                                    "overrideAlert":"1",
                                                    "overrideLoading":"1",
                                                    "host":self], withCache: { (cacheString) in
       }, andCompletion: { (response, errorCode, error, isValid, object) in
           let result = response?.dictionize() ?? [:]
        
           if result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
               self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
               return
           }
        
            let payment = Payment_ViewController.init()
                        
            let allInfo = NSMutableDictionary.init(dictionary: self.info)
        
            allInfo["title"] = "Thanh toán"
        
            allInfo["payment"] = "1"
        
            payment.info = allInfo
        
            payment.requestUrl = (result["result"] as! NSDictionary).getValueFromKey("redirect")
            
            self.navigationController?.pushViewController(payment, animated: true)
        })
    }

    @IBAction func didPressBack() {
        if self.isPackage {
            self.navigationController?.popViewController(animated: true)
            return
        }
        if self.isModal {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func didPressNext() {
        self.didRequestPayment()
    }
    
    @IBAction func didPressCancel() {
        EM_MenuView.init(cancel: ["line1": "Quý khách muốn huỷ đăng ký ?"]).show { (index, obj, menu) in
            if index == 3 {
                if self.isModal {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    var isPackage: Bool {
        return self.info.getValueFromKey("is_package") == "1"
    }
}

extension Check_Out_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? (self.isPackage ? UITableView.automaticDimension : 260) : indexPath.row == (self.isPackage ? 2 : 1) ? expand ? 280 : 130 : indexPath.row == (self.isPackage ? 3 : 2) ? 120 : UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isPackage ? 4 : 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == (self.isPackage ? 3 : 2) {
            return buttonCell!
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.isPackage ? (indexPath.row == 0 ? "Vip_Cell" : indexPath.row == 1 ? "Check_Out_Cell" : "Payment_Option_Cell") : indexPath.row == 0 ? "Check_Out_Book_Cell" : "Payment_Option_Cell", for: indexPath)
        
        if self.isPackage {
            
            if indexPath.row == 0 {
                let vip = self.withView(cell, tag: 1) as! UILabel

                vip.text = self.info.getValueFromKey("package_code")

                let price = self.withView(cell, tag: 2) as! UILabel

                price.text = self.info.getValueFromKey("price") + " đ"

                let des = self.withView(cell, tag: 3) as! UILabel

                des.text = self.info.getValueFromKey("info")
            }
            
            if indexPath.row == 1 {
                let vip = self.withView(cell, tag: 1) as! UILabel

                vip.text = self.info.getValueFromKey("name")

                let price = self.withView(cell, tag: 2) as! UILabel

                price.text = self.info.getValueFromKey("price") + " đ"
            }
            
            if indexPath.row == 2 {
                (cell as! Payment_Option_Cell).callBack = { value in
                    let details = (value as! NSDictionary)["details"] as! NSArray
                    self.expand = details.count == 0 ? false : true
                    if details.count == 0 {
                        self.paymentInfoGate.removeAllObjects()
                        self.paymentInfoGate.addEntries(from: value as! [AnyHashable : Any])
                    }
                    tableView.reloadData()
                }
                
                (cell as! Payment_Option_Cell).chooseBank = { bank in
                    print(bank)
                    self.paymentInfoBank.removeAllObjects()
                    self.paymentInfoBank.addEntries(from: bank as! [AnyHashable : Any])
                }
            }
            
        } else {
            
            if indexPath.row == 0 {
                let title = self.withView(cell, tag: 1) as! UILabel
                title.text = self.info.getValueFromKey("name")
                        
                let authorName = ((self.info["author"] as! NSArray).firstObject as! NSDictionary).getValueFromKey("name")
                let author = self.withView(cell, tag: 2) as! UILabel
                author.text = authorName
                
                let price = self.withView(cell, tag: 3) as! UILabel
                price.text = self.info.getValueFromKey("price") + " đ"
                
                let backgroundImage = self.withView(cell, tag:11) as! UIImageView
                backgroundImage.imageUrl(url: self.info.getValueFromKey("avatar"))
            }
            
            if indexPath.row == 1 {
                (cell as! Payment_Option_Cell).callBack = { value in
                    let details = (value as! NSDictionary)["details"] as! NSArray
                    self.expand = details.count == 0 ? false : true
                    if details.count == 0 {
                        self.paymentInfoGate.removeAllObjects()
                        self.paymentInfoGate.addEntries(from: value as! [AnyHashable : Any])
                    }
                    tableView.reloadData()
                }

                (cell as! Payment_Option_Cell).chooseBank = { bank in
                    self.paymentInfoBank.removeAllObjects()
                    self.paymentInfoBank.addEntries(from: bank as! [AnyHashable : Any])
                    print(bank)
                }
            }
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
