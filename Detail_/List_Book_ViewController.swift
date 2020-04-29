//
//  PC_Map_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 11/4/19.
//  Copyright © 2019 Thanh Hai Tran. All rights reserved.
//

import UIKit

import MarqueeLabel

class List_Book_ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    let refreshControl = UIRefreshControl()
    
    @objc var config: NSDictionary!

    var pageIndex: Int = 1
     
    var totalPage: Int = 1
     
    var isLoadMore: Bool = false
    
    @IBOutlet var counterHeight: NSLayoutConstraint!
    
    @IBOutlet var titleLabel: MarqueeLabel!

    @IBOutlet var counter: UILabel!

    @IBOutlet var collectionView: UICollectionView!
        
    var dataList: NSMutableArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        titleLabel.text = config.getValueFromKey("title")
        
        dataList = NSMutableArray.init()
        
        collectionView.withCell("TG_Map_Cell")
                
        collectionView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(didReload(_:)), for: .valueChanged)
                
        didRequestData(isShow: true)
        
        counterHeight.constant = config.response(forKey: "counter") ? 29 : 0
    }
    
    @objc func didReload(_ sender: Any) {
        isLoadMore = false
        pageIndex = 1
        totalPage = 1
        didRequestData(isShow: true)
    }
    
    func didRequestData(isShow: Bool) {
        let request = NSMutableDictionary.init(dictionary: [
                                                            "session":Information.token ?? "",
                                                            "page_index": self.pageIndex,
                                                            "page_size": 10,
                                                            "overrideAlert":"1",
                                                            "overrideLoading":isShow ? 1 : 0,
                                                            "host":self])
        
        request.addEntries(from: self.config["url"] as! [AnyHashable : Any])
        
        LTRequest.sharedInstance()?.didRequestInfo((request as! [AnyHashable : Any]), withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            self.refreshControl.endRefreshing()
            let result = response?.dictionize() ?? [:]
            
            if result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
                self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
                return
            }
                        
            self.totalPage = (result["result"] as! NSDictionary)["total_page"] as! Int

            self.pageIndex += 1

            if !self.isLoadMore {
                self.dataList.removeAllObjects()
            }

            let data = ((result["result"] as! NSDictionary)["data"] as! NSArray)

            let filter = self.filterArray(data: data)

            self.dataList.addObjects(from: Information.check == "0" ? filter.withMutable() : data.withMutable())
            
            self.counter.text = self.dataList.count == 0 ? "" : (String(self.dataList.count) + " TÁC PHẨM")
            
            self.collectionView.reloadData()
        })
    }
    
    @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didPressSearch() {
        let search = Search_ViewController.init()
        search.config = [:]
        self.center()?.pushViewController(search, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Int((self.screenWidth() / (IS_IPAD ? 5 : 3)) - 15), height: Int(((self.screenWidth() / (IS_IPAD ? 5 : 3)) - 15) * 1.72))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
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
                   
        player.isHidden = data.getValueFromKey("book_type") != "3"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         let data =  dataList[indexPath.item] as! NSDictionary
         let bookInfo = NSMutableDictionary.init(dictionary: data)
         bookInfo["url"] = ["CMD_CODE":"getListBook"]
         if data.getValueFromKey("book_type") == "3" {
            self.didRequestUrl(info: bookInfo)
            return
         }
         let bookDetail = Book_Detail_ViewController.init()
         bookDetail.config = bookInfo
         self.navigationController?.pushViewController(bookDetail, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if self.pageIndex == 1 {
           return
        }
       
        if indexPath.item == dataList.count - 1 {
           if self.pageIndex <= self.totalPage {
               self.isLoadMore = true
               self.didRequestData(isShow: false)
           }
        }
    }
}
