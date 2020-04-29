//
//  TG_Room_Cell_N.swift
//  TourGuide
//
//  Created by Mac on 7/13/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class TG_Room_Cell_N: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {

    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var extraButton: UIButton!

    var dataList: NSMutableArray!
    
    var config: NSDictionary!
        
    var returnValue: ((_ value: Float)->())?
    
    var callBack: ((_ info: Any)->())?

    let itemHeight = Int(((screenWidth() / (IS_IPAD ? 5 : 3)) - 15) * 1.72)
        
    override func prepareForReuse() {
        super.prepareForReuse()
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = config.getValueFromKey("direction") == "vertical" ? .vertical : .horizontal
            collectionView.isScrollEnabled = config.getValueFromKey("direction") != "vertical"
         }
        
        titleLabel.font = UIFont.systemFont(ofSize: 17)
                
        if !(self.config["loaded"] as! Bool) {
            didRequestInfo()
        } else {
            titleLabel.text = config.getValueFromKey("title") != "" ? config.getValueFromKey("title") : ""
            extraButton.alpha = 1
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.withCell("TG_Map_Cell")
                
        dataList = NSMutableArray.init()
    }
    
    func didRequestInfo() {
        let request = NSMutableDictionary.init(dictionary: ["session":Information.token ?? "", "overrideAlert":"1"])
        request.addEntries(from: self.config["url"] as! [AnyHashable : Any])
        LTRequest.sharedInstance()?.didRequestInfo((request as! [AnyHashable : Any])
            ,withCache: { (cacheString) in
       }, andCompletion: { (response, errorCode, error, isValid, object) in
           let result = response?.dictionize() ?? [:]
           
           if result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
               self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
               return
           }
        
           let data = ((result["result"] as! NSDictionary)["data"] as! NSArray)
        
           let filter = self.parentViewController()?.filterArray(data: data)
        
           self.dataList.removeAllObjects()
        
           self.dataList.addObjects(from: Information.check == "0" ? filter!.withMutable() : data.withMutable())

           self.collectionView.reloadData()
           
            if self.config.getValueFromKey("direction") == "vertical" {
                self.returnValue?(self.dataList.count == 0 ? 0 : Float(self.itemHeight * (self.dataList.count % (IS_IPAD ? 5 : 3) == 0 ? self.dataList.count / (IS_IPAD ? 5 : 3) : (self.dataList.count / (IS_IPAD ? 5 : 3)) + 1)) + 60)
            } else {
                self.returnValue?(self.dataList.count == 0 ? 0 : Float(self.itemHeight) + 60)
            }
        
       })
   }
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Int((self.screenWidth() / (IS_IPAD ? 5 : 3)) - 15), height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return config.getValueFromKey("direction") != "vertical" ? 10.0 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TG_Map_Cell", for: indexPath as IndexPath)
        
        let data = dataList[indexPath.item] as! NSDictionary

        let title = self.withView(cell, tag: 112) as! UILabel

        title.text = data.getValueFromKey("name")

        let description = self.withView(cell, tag: 13) as! UILabel

        description.text = (data["author"] as! NSArray).count > 1 ? "Nhiều tác giả" : (((data["author"] as! NSArray)[0]) as! NSDictionary).getValueFromKey("name")

        let image = self.withView(cell, tag: 11) as! UIImageView

        image.imageUrl(url: data.getValueFromKey("avatar"))
        
        let player = self.withView(cell, tag: 999) as! UIImageView
        
        player.isHidden = data.getValueFromKey("book_type") != "3" ? true : false
                
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let data = dataList[indexPath.item] as! NSDictionary

        callBack?(data)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
