//
//  Tag_View.swift
//  HearThis
//
//  Created by Thanh Hai Tran on 5/4/21.
//  Copyright © 2021 Thanh Hai Tran. All rights reserved.
//

import UIKit

@objc class Tag_View: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet var collectionView: UICollectionView!

    @IBOutlet var contentView: UIView!

    var dataList: NSMutableArray!
    
    @objc var callBack: ((_ info: Any)->())?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
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

           let data = (result["result"] as! NSArray)

           self.dataList.addObjects(from: data.withMutable())

           self.collectionView.reloadData()
        
       })
    }
    
    func setUp() {
        Bundle.main.loadNibNamed("Tag_View", owner: self, options: nil)
        self.addSubview(contentView)
        dataList = NSMutableArray.init()
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.collectionView.withCell("Tag")
        self.collectionView.withCell("Tag_Button")
        self.didRequestTag()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if indexPath.item != 0 {
            let label = UILabel(frame: CGRect.zero)
            label.text = (dataList[indexPath.item - 0] as! NSDictionary).getValueFromKey("name")
            label.sizeToFit()
            return CGSize(width: label.frame.width + 20, height: self.bounds.size.height)
//        }
//        return CGSize(width: 105, height: self.bounds.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataList == nil ? 0 : dataList.count + 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: indexPath.item == 0 ? "Tag" : "Tag", for: indexPath as IndexPath)
        
//        if indexPath.item != 0 {
            let data = dataList[indexPath.item - 0] as! NSDictionary

            let title = self.withView(cell, tag: 9) as! UILabel

            title.text = data.getValueFromKey("name")

            let check = false // (data["check"] as! String) == "1"

//            title.withBorder(["Bhex": check ? "#C2DEDC" : "#7DBAB6",
//                              "Bground": check ? "#C2DEDC" : "#FFFFFF",
//                              "Bcorner": 16, "Bwidth": "1"])
//
//            title.textColor = AVHexColor.color(withHexString: check ? "#1D5266" : "#7DBAB6")
//        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        if indexPath.item != 0 {
//            for i in 0 ..< dataList.count {
//                dataList[i]["check"] = "0"
//            }
//
//            dataList[indexPath.item - 1]["check"] = "1"
//
            callBack?(dataList[indexPath.item - 0])
//
//            collectionView.reloadData()
//        } else {
//            callBack?(["data": "Mua VIP"])
//        }
    }
}
