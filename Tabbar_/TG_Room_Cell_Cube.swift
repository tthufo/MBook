//
//  TG_Room_Cell_N.swift
//  TourGuide
//
//  Created by Mac on 7/13/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class TG_Room_Cell_Cube: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {

    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var extraButton: UIButton!

    var dataList: NSMutableArray!
    
    @objc var config: NSDictionary!
        
    @objc var returnValue: ((_ value: Float)->())?
    
    @objc var callBack: ((_ info: Any)->())?

    let itemHeight = Int(((screenWidth() / (IS_IPAD ? 3 : 2)) - 15) * 0.6) //Int(((screenWidth() / (IS_IPAD ? 4 : 2)) - 15) * 1.80)
        
    override func prepareForReuse() {
        super.prepareForReuse()
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = config.getValueFromKey("direction") == "vertical" ? .vertical : .horizontal
            collectionView.isScrollEnabled = config.getValueFromKey("direction") != "vertical"
         }
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
                
        if !(self.config["loaded"] as! Bool) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                self.didRequestInfo()
            })
        } else {
            titleLabel.text = config.getValueFromKey("title") != "" ? config.getValueFromKey("title").uppercased() : ""
            extraButton.alpha = 1
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.withCell("Event_Cell")
        
        self.backgroundColor = .clear
        
        self.contentView.backgroundColor = .clear
                
        dataList = NSMutableArray.init()
    }
    
    func didRequestInfo() {
        let request = NSMutableDictionary.init(dictionary: [
                                                "header":["session":Information.token == nil ? "" : Information.token!],
                                                "session":Information.token ?? "",
                                                "overrideAlert":"1"]
        )
        request.addEntries(from: self.config["url"] as! [AnyHashable : Any])
        LTRequest.sharedInstance()?.didRequestInfo((request as! [AnyHashable : Any])
            ,withCache: { (cacheString) in
       }, andCompletion: { (response, errorCode, error, isValid, object) in
           let result = response?.dictionize() ?? [:]
           
           if result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
               return
           }
        
           let data = result["result"] as! NSArray
                
           self.dataList.removeAllObjects()
        
           self.dataList.addObjects(from: data.withMutable())

           self.collectionView.reloadData()
           
            if self.config.getValueFromKey("direction") == "vertical" {
                self.returnValue?(self.dataList.count == 0 ? 0 : Float(self.itemHeight * (self.dataList.count % (IS_IPAD ? 3 : 2) == 0 ? self.dataList.count / (IS_IPAD ? 3 : 2) : (self.dataList.count / (IS_IPAD ? 3 : 2)) + 1)) + 60)
            } else {
                self.returnValue?(self.dataList.count == 0 ? 0 : Float(self.itemHeight) + 60)
            }
        
       })
   }
    
    func eventSize() -> CGSize {
        return CGSize(width: Int((self.screenWidth() / (IS_IPAD ? 3 : 2)) - 15), height: Int(((self.screenWidth() / (IS_IPAD ? 3 : 2)) - 15) * 0.6))
    }
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return eventSize()// CGSize(width: Int((self.screenWidth() / (IS_IPAD ? 4 : 2)) - 15), height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return config.getValueFromKey("direction") != "vertical" ? 10.0 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Event_Cell", for: indexPath as IndexPath)
        
        let data = dataList[indexPath.item] as! NSDictionary
        
        let book = self.withView(cell, tag: 12) as! UILabel

        book.text = data.getValueFromKey("book_count")

        let image = self.withView(cell, tag: 11) as! UIImageView
        
        image.imageUrl(url: data.getValueFromKey("avatar"))
                
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let data = dataList[indexPath.item] as! NSDictionary

        callBack?(["selection": data, "data": dataList])
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
