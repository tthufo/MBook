//
//  Tag_View_Vip.swift
//  HearThis
//
//  Created by Thanh Hai Tran on 8/17/21.
//  Copyright © 2021 Thanh Hai Tran. All rights reserved.
//

import UIKit

@IBDesignable @objc class Tag_View_Vip: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet var collectionView: UICollectionView!

    @IBOutlet var contentView: UIView!
    
//    @objc var typing: String!
        
    var dataList: NSMutableArray!
    
//    var defaultList = NSMutableArray.init(array: [ NSMutableDictionary.init(dictionary: ["check":"1", "name":"Tất cả",
//                                                                                         "book_type": 0,
//                                                                                         "cmd_code": "getListBookPurchaseByUser",
//                                                                                         "price": 1]),
//                                                   NSMutableDictionary.init(dictionary: ["check":"0", "name":"EBook",
//                                                                                         "book_type": 1,
//                                                                                         "cmd_code": "getListBookPurchaseByUser",
//                                                                                         "price": 1]),
//                                                   NSMutableDictionary.init(dictionary: ["check":"0", "name":"Truyện",
//                                                                                         "book_type": 2,
//                                                                                         "cmd_code": "getListBookPurchaseByUser",
//                                                                                         "price": 1]),
//                                                   NSMutableDictionary.init(dictionary: ["check":"0", "name":"Sách nói",
//                                                                                         "book_type": 3,
//                                                                                         "cmd_code": "getListBookPurchaseByUser",
//                                                                                         "price": 1]),
//                                                   NSMutableDictionary.init(dictionary: ["check":"0", "name":"Sách miễn phí",
//                                                                                         "book_type": 0,
//                                                                                         "cmd_code": "getListReadOfUser",
//                                                                                         "price": 1])])
    
    @objc var callBack: ((_ info: Any)->())?
    
    @objc var loadDone: ((_ info: Any)->())?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func didRequestTag() {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"getListTag",
                                                    "header":["session":Information.token == nil ? "" : Information.token!],
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

           let data = (result["result"] as! NSArray).withMutable()
        
           self.dataList.addObjects(from: data!)

           self.collectionView.reloadData()
        
           self.loadDone?("")
        
       })
    }
    
//    func reloading(tag: String) {
//        for dat in dataList {
//             if tag == (dat as! NSMutableDictionary).getValueFromKey("name") {
//                 (dat as! NSMutableDictionary)["check"] = "1"
//             }
//        }
//        self.collectionView.reloadData()
//    }
    
    func setUp() {
        Bundle.main.loadNibNamed("Tag_View", owner: self, options: nil)
        self.addSubview(contentView)
        dataList = NSMutableArray.init()
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.collectionView.withCell("Tag")
//        self.collectionView.withCell("Tag_Button")
//        self.collectionView.withCell("Tag_Add")
        self.didRequestTag()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let label = UILabel(frame: CGRect.zero)
        label.text = (dataList[indexPath.item - 0] as! NSDictionary).getValueFromKey("name")
        label.sizeToFit()
        return CGSize(width: label.frame.width + 20, height: self.bounds.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataList == nil ? 0 : dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Tag", for: indexPath as IndexPath)
        
        let data = dataList[indexPath.item] as! NSDictionary

        let title = self.withView(cell, tag: 9) as! UILabel

        title.text = data.getValueFromKey("name")
        
//        let check = (data["check"] as! String) == "1"
//
//        title.withBorder(["Bhex": check ? "#C2DEDC" : "#7DBAB6",
//                          "Bground": check ? "#C2DEDC" : "#FFFFFF",
//                          "Bcorner": 16, "Bwidth": "1"])
//
//        title.textColor = AVHexColor.color(withHexString: check ? "#1D5266" : "#7DBAB6")
            
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        if self.typing != "normal" {
//            if indexPath.item == 0 {
//                callBack?(["action": "custom"])
//            } else {
//                if self.typing == "add" {
//                    for i in 0 ..< defaultList.count {
//                        (defaultList[i] as! NSMutableDictionary)["check"] = "0"
//                    }
//
//                    (defaultList[indexPath.item - 1] as! NSMutableDictionary)["check"] = "1"
//
//                    collectionView.reloadData()
//
//                    callBack?(defaultList[indexPath.item - 1])
//                } else {
//                    callBack?(dataList[indexPath.item - 1])
//                }
//            }
//        } else {
//            for i in 0 ..< dataList.count {
//                (dataList[i] as! NSMutableDictionary)["check"] = "0"
//            }
//
//            (dataList[indexPath.item - 0] as! NSMutableDictionary)["check"] = "1"
//
//            collectionView.reloadData()
            
            callBack?(dataList[indexPath.item - 0])
//        }
    }
}

//extension Tag_View_Vip {
//    @IBInspectable var secret: String? {
//        set (newValue) {
//            self.typing = newValue
//        }
//        get {
//            return self.typing
//        }
//    }
//}
