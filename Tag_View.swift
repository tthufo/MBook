//
//  Tag_View.swift
//  HearThis
//
//  Created by Thanh Hai Tran on 5/4/21.
//  Copyright © 2021 Thanh Hai Tran. All rights reserved.
//

import UIKit

class Tag_View: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet var collectionView: UICollectionView!

    @IBOutlet var contentView: UIView!

    var dataList: Array<[String: Any]> = [["title": "Tất cả", "check": "1"], ["title": "Văn Học", "check": "0"], ["title": "Xã Hội", "check": "0"], ["title": "Kiến thức phổ thông", "check": "0"]]
    
    var callBack: ((_ info: Any)->())?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    func setUp() {
        Bundle.main.loadNibNamed("Tag_View", owner: self, options: nil)
        self.addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.collectionView.withCell("Tag")
        self.collectionView.withCell("Tag_Button")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item != 0 {
            let label = UILabel(frame: CGRect.zero)
            label.text = (dataList[indexPath.item - 1]["title"] as! String)
            label.sizeToFit()
            return CGSize(width: label.frame.width + 20, height: self.bounds.size.height)
        }
        return CGSize(width: 110, height: self.bounds.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataList.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: indexPath.item == 0 ? "Tag_Button" : "Tag", for: indexPath as IndexPath)
        
        if indexPath.item != 0 {
            let data = dataList[indexPath.item - 1]
            
            let title = self.withView(cell, tag: 9) as! UILabel
            
            title.text = (data["title"] as! String)
            
            let check = (data["check"] as! String) == "1"
            
            title.withBorder(["Bhex": check ? "#C2DEDC" : "#7DBAB6",
                              "Bground": check ? "#C2DEDC" : "#FFFFFF",
                              "Bcorner": 16, "Bwidth": "1"])
            
            title.textColor = AVHexColor.color(withHexString: check ? "#1D5266" : "#7DBAB6")
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.item != 0 {
            for i in 0 ..< dataList.count {
                dataList[i]["check"] = "0"
            }
            
            dataList[indexPath.item - 1]["check"] = "1"
                    
            collectionView.reloadData()
        }

//        callBack?(data)
    }
}
