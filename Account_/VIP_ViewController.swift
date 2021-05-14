//
//  VIP_ViewController.swift
//  HearThis
//
//  Created by Thanh Hai Tran on 4/28/21.
//  Copyright © 2021 Thanh Hai Tran. All rights reserved.
//

import UIKit

class VIP_ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var login_bg_height: NSLayoutConstraint!

    @IBOutlet var top_bg_height: NSLayoutConstraint!

    @IBOutlet var sideGapLeft: NSLayoutConstraint!
    
    @IBOutlet var sideGapRight: NSLayoutConstraint!

    @IBOutlet var sideGapTop: NSLayoutConstraint!

    var dataList: NSMutableArray!
    
    @objc var callBack: ((_ info: Any)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if IS_IPAD {
            login_bg_height.constant = 550
            top_bg_height.constant = 550
            
            sideGapLeft.constant = 100
            sideGapRight.constant = 100
            
            sideGapTop.constant = 250
        } else {
            sideGapTop.constant = 150
        }

        tableView.estimatedRowHeight = 150
        
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.withCell("Vip_Cell")
        
        dataList = [["price": "365.000 đ", "vip": "VIP12", "des": "Đọc trọn bộ kho sách VIP 365 ngày *"], ["price": "90.000 đ", "vip": "VIP3", "des": "Đọc trọn bộ kho sách VIP 90 ngày *"], ["price": "30.000 đ", "vip": "VIP1", "des": "Đọc trọn bộ kho sách VIP 30 ngày *"], ["price": "3.000 đ", "vip": "VIPD", "des": "Đọc trọn bộ kho sách VIP 1 ngày *"]]
    }
    
    @objc func didReload(_ sender: Any) {
//       didRequestPackage()
    }
    
//    func didRequestPackage() {
//        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"getPackageInfo",
//                                                    "session":Information.token ?? "",
//                                                    "overrideAlert":"1",
//                                                    "overrideLoading":"1",
//                                                    "host":self], withCache: { (cacheString) in
//       }, andCompletion: { (response, errorCode, error, isValid, object) in
//           let result = response?.dictionize() ?? [:]
//           self.refreshControl.endRefreshing()
//        
//           if result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
//               self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
//               return
//           }
//        
//        print(result)
//        
//           self.dataList.removeAllObjects()
//
//           let data = (result["result"] as! NSArray)
//
//           self.dataList.addObjects(from: data.withMutable())
//                  
//           self.tableView.reloadData()
//       })
//    }
    
    @IBAction func didPressBack() {
        if self.isModal {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        callBack?(["bla": "blo"])
    }
}

extension VIP_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = dataList![indexPath.row] as! NSDictionary

        let cell = tableView.dequeueReusableCell(withIdentifier:"Vip_Cell", for: indexPath)
                
        let vip = self.withView(cell, tag: 1) as! UILabel
                    
        vip.text = data.getValueFromKey("vip")
        
        let price = self.withView(cell, tag: 2) as! UILabel
        
        price.text = data.getValueFromKey("price")

        let des = self.withView(cell, tag: 3) as! UILabel

        des.text = data.getValueFromKey("des")

//        if isRegistered {
//            button.setTitle("Đang sử dụng Gói " + data.getValueFromKey("package_code"), for: .normal)
//
//            button.setBackgroundImage(UIImage.init(named: "trans"), for: .normal)
//
//            button.backgroundColor = AVHexColor.color(withHexString: "#009BB4")
//
//            title.text = (data["info"] as? String)! + ". Hết hạn sử dụng ngày " + data.getValueFromKey("expireTime")
//
//        } else {
//            button.setTitle("%@ %@".format(parameters: ((data["name"] as? String)!), ((data["price"] as? String)!)), for: .normal)
//
//            title.text = (data["info"] as? String)!
//        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        let data = dataList![indexPath.row] as! NSDictionary
//        let expDate = (data.getValueFromKey("expireTime")! as NSString).date(withFormat: "dd/MM/yyyy")
//        let isRegistered = data.getValueFromKey("status") == "1" && expDate! > Date()

        let checkOut = Check_Out_ViewController.init()
        
        checkOut.isPackage = indexPath.row == 0
        
        self.navigationController?.pushViewController(checkOut, animated: true)
    }

}
