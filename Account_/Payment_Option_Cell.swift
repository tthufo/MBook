//
//  Payment_Optiopn_Cell.swift
//  HearThis
//
//  Created by Thanh Hai Tran on 8/9/21.
//  Copyright © 2021 Thanh Hai Tran. All rights reserved.
//

import UIKit

class Payment_Option_Cell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var tableView: UITableView!

    @objc var callBack: ((_ info: Any)->())?

    @objc var chooseBank: ((_ info: Any)->())?

    var dataList: NSMutableArray!

    var bankList: NSMutableArray!
        
    var bankInfo: NSDictionary!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dataList = NSMutableArray.init()
        bankList = NSMutableArray.init()

        self.collectionView.withCell("Payment_Cell")
        self.tableView.withCell("Bank_Cell")
        self.didRequestPaymentChannel()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func didRequestPaymentChannel() {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"getPaymentChannel",
                                                    "header":["session":Information.token == nil ? "" : Information.token!],
                                                    "page_index": NSNull(),
                                                    "page_size": NSNull(),
                                                    "session": NSNull(),
                                                    "overrideAlert":"1",
                                                    "overrideLoading":"1",
                                                    "host":self], withCache: { (cacheString) in
       }, andCompletion: { (response, errorCode, error, isValid, object) in
           let result = response?.dictionize() ?? [:]
        
           if result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
               self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
               return
           }
                        
            self.dataList.removeAllObjects()
        
            self.bankList.removeAllObjects()

            let data = (result["result"] as! NSArray).withMutable()! as NSArray
        
            for n in 0...data.count - 1 {
                (data[n] as! NSMutableDictionary)["check"] = n == 0 ? "1" : "0"
//                for detail in (data[n] as! NSDictionary)["details"] as! NSArray {
//                    (detail as! NSMutableDictionary)["check"] = "0"
//                }
            }
                
            self.dataList.addObjects(from: data as! [Any])
                  
            self.callBack?(self.dataList[0])
        
            self.collectionView.reloadData()
                
            self.bankList.addObjects(from: (data[0] as! NSDictionary)["details"] as! [Any] )

            self.tableView.reloadData()
       })
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataList == nil ? 0 : dataList.count + 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Payment_Cell", for: indexPath as IndexPath)
        
        let data = dataList[indexPath.item] as! NSDictionary

        let image = self.withView(cell, tag: 1) as! UIImageView
         
        image.imageUrlHolder(url: data.getValueFromKey("avatar_url"), holder: "icon_payment")
        
        let image_temp = image.image

        if data.getValueFromKey("check") == "0" {
            image.image = image_temp?.noir
        } else {
            image.image = image_temp
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        for i in 0 ..< dataList.count {
            (dataList[i] as! NSMutableDictionary)["check"] = "0"
        }

        (dataList[indexPath.item] as! NSMutableDictionary)["check"] = "1"

        self.bankList.removeAllObjects()
        
        self.bankList.addObjects(from: (dataList[indexPath.item] as! NSMutableDictionary)["details"] as! [Any])
        
        tableView.reloadData()
        
        collectionView.reloadData()
        
        callBack?(dataList[indexPath.item])
    }

}

extension Payment_Option_Cell: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Bank_Cell", for: indexPath)

        if bankInfo != nil {
            let label = self.withView(cell, tag: 2) as! UILabel
            label.text = bankInfo.getValueFromKey("name")
            
            let check = self.withView(cell, tag: 1) as! UIImageView
            check.imageUrlHolder(url: bankInfo.getValueFromKey("avatar_url"), holder: "icon_payment_square")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.chooseBank!(bankList as Any)

    }
}

