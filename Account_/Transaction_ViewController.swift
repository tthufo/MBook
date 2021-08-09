//
//  Transaction_ViewController.swift
//  HearThis
//
//  Created by Thanh Hai Tran on 5/2/21.
//  Copyright © 2021 Thanh Hai Tran. All rights reserved.
//

import UIKit

class Transaction_ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var sideGapLeft: NSLayoutConstraint!
    
    @IBOutlet var sideGapRight: NSLayoutConstraint!
    
    let refreshControl = UIRefreshControl()
    
    var pageIndex: Int = 1
     
    var totalPage: Int = 1
     
    var isLoadMore: Bool = false
    
    var dataList: NSMutableArray!

    override func viewDidLoad() {
        super.viewDidLoad()

        if IS_IPAD {
            sideGapLeft.constant = 100
            
            sideGapRight.constant = 100
        }
        
        dataList = NSMutableArray.init()

        tableView.estimatedRowHeight = 150
        
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.withCell("Transaction_Cell")
        
        tableView.withCell("Transaction_Fail")
        
        tableView.refreshControl = refreshControl
           
        refreshControl.tintColor = UIColor.black
        
        refreshControl.addTarget(self, action: #selector(didRequestPurchase), for: .valueChanged)

        didRequestPurchase()
    }
    
    @objc func didRequestPurchase() {
        isLoadMore = false
        pageIndex = 1
        totalPage = 1
        didRequestData(isShow: true)
    }
    
    func didRequestData(isShow: Bool) {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"getPurchaseHistory",
                                                    "header":["session":Information.token == nil ? "" : Information.token!],
                                                    "page_index": 1,
                                                    "page_size": 12,
                                                    "overrideAlert":"1",
                                                    "overrideLoading":"1",
                                                    "host": isShow ? self : NSNull()], withCache: { (cacheString) in
       }, andCompletion: { (response, errorCode, error, isValid, object) in
           let result = response?.dictionize() ?? [:]
           self.refreshControl.endRefreshing()
        
           if result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
               self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
               return
           }
                
            self.totalPage = (result["result"] as! NSDictionary)["total_page"] as! Int

            self.pageIndex += 1
            
            if !self.isLoadMore {
                self.dataList.removeAllObjects()
            }
        
           let data = (result["result"] as! NSDictionary)["data"] as! NSArray

           self.dataList.addObjects(from: data.withMutable())
                  
           self.tableView.reloadData()
       })
    }
    
    @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension Transaction_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = dataList[indexPath.row] as! NSDictionary
        
        let cell = tableView.dequeueReusableCell(withIdentifier: data.getValueFromKey("status") == "1" ? "Transaction_Cell" : "Transaction_Fail", for: indexPath)
        
        let createTime = data.getValueFromKey("create_date")
        
        let packageName = ((data["items"] as! NSArray)[0] as! NSDictionary).getValueFromKey("item_name")
        
        let price = ((data["items"] as! NSArray)[0] as! NSDictionary).getValueFromKey("amount")
        
        let date = ((data["items"] as! NSArray)[0] as! NSDictionary).getValueFromKey("expired_date") as! NSString
        
        let dateTime = date.date(fromTimeStamp: "dd/MM/yyyy")
        
        if data.getValueFromKey("status") == "1" {
            let title = self.withView(cell, tag: 1) as! UILabel
            title.text = createTime + " - " + "Đã thanh toán " + packageName + " - " + price + " VND"
            let des = self.withView(cell, tag: 2) as! UILabel
            des.text = "Hạn sử dụng gói " + packageName + " tới hết ngày " + dateTime
        } else {
            let title = self.withView(cell, tag: 1) as! UILabel
            title.text = createTime + " - " + "Thanh toán " + packageName + " không thành công"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.pageIndex == 1 {
           return
        }

        if indexPath.row == dataList.count - 1 {
           if self.pageIndex <= self.totalPage {
               self.isLoadMore = true
               self.didRequestData(isShow: false)
           }
        }
    }

}
