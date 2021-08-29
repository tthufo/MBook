//
//  TG_Release_Cell.swift
//  TourGuide
//
//  Created by Mac on 8/22/2021.
//  Copyright © 2021 Mac. All rights reserved.
//

import UIKit

class TG_Release_Cell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {

    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var extraButton: UIButton!

    var dataList: NSMutableArray!
    
    @objc var config: NSDictionary!
        
    @objc var returnValue: ((_ value: Float)->())?
    
    @objc var callBack: ((_ info: Any)->())?

    let itemHeight = 60// Int(((screenWidth() / (IS_IPAD ? 5 : 3)) - 15) * 1.80)
        
    override func prepareForReuse() {
        super.prepareForReuse()
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = config.getValueFromKey("direction") == "vertical" ? .vertical : .horizontal
            collectionView.isScrollEnabled = config.getValueFromKey("direction") != "vertical"
         }
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
                
        if !(self.config["loaded"] as! Bool) {
            didRequestInfo()
        } else {
            titleLabel.text = config.getValueFromKey("title") != "" ? config.getValueFromKey("title").uppercased() : ""
            extraButton.alpha = 1
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.withCell("TG_Release")
        
//        self.backgroundColor = .clear
//
//        self.contentView.backgroundColor = .clear
                
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
        return CGSize(width: 200, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return config.getValueFromKey("direction") != "vertical" ? 10.0 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TG_Release", for: indexPath as IndexPath)
        
        let data = dataList[indexPath.item] as! NSDictionary

        let title = self.withView(cell, tag: 1) as! UILabel

        title.text = self.getDay(date: data.getValueFromKey("publish_time") as! NSString)

        let description = self.withView(cell, tag: 2) as! UILabel

        description.text = data.getValueFromKey("name")

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let data = dataList[indexPath.item] as! NSDictionary

        callBack?(data)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    let weekDays = ["1": "CN", "2": "Thứ 2", "3": "Thứ 3", "4": "Thứ 4", "5": "Thứ 5", "6": "Thứ 6", "7": "Thứ 7"]
    
    func getDay(date: NSString) -> String {
        if date == "" {
            return ""
        }
        let dat = date.date(withFormat: "dd/MM/yyyy")
        let dayNumber = dat!.dayNumberOfWeek()
        let dateEl = date.components(separatedBy: "/")
        
        return weekDays["%i".format(parameters: dayNumber!)]! + "\n" + dateEl[0] + "/" + dateEl[1]
    }
}

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}
