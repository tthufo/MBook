//
//  Book_Detail_ViewController.swift
//  HearThis
//
//  Created by Thanh Hai Tran on 4/10/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

import UIKit
import ParallaxHeader

class Book_Detail_ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    let refreshControl = UIRefreshControl()
    
    var config: NSDictionary!

    var pageIndex: Int = 1
     
    var totalPage: Int = 1
     
    var isLoadMore: Bool = false
    
    @IBOutlet var collectionView: UICollectionView!
        
    var dataList: NSMutableArray!
    
    var chapList: NSMutableArray!
    
    var detailList: NSMutableArray!
    
    let headerHeight = IS_IPAD ? 340 : 220
    
    let sectionTitle = ["Thông tin chi tiết", "Danh sách chương", "Có thể bạn thích"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
                        
        dataList = NSMutableArray.init()
        
        chapList = NSMutableArray.init()
        
        detailList = NSMutableArray.init()

        collectionView.withCell("TG_Map_Cell")
                        
        collectionView.withCell("TG_Book_Detail_Cell")

        collectionView.withCell("TG_Book_Chap_Cell")

        collectionView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(didReload(_:)), for: .valueChanged)
                
        collectionView.withHeaderOrFooter("Book_Detail_Title", andKind: UICollectionView.elementKindSectionHeader)

        didRequestData(isShow: true)
    
        setupParallaxHeader()
    }
        
    private func setupParallaxHeader() {
        let view = Bundle.main.loadNibNamed("Book_Detail_Header", owner: self, options: nil)![IS_IPAD ? 1 : 0] as! UIView
        
        view.blurView.setup(style: UIBlurEffect.Style.dark, alpha: 1).enable()
        
        let back = self.withView(view, tag: 1) as! UIButton
        
        back.action(forTouch: [:]) { (obj) in
            self.navigationController?.popViewController(animated: true)
        }
        
        let title = self.withView(view, tag: 2) as! UILabel

        title.text = self.config.getValueFromKey("name")

        let avatar = self.withView(view, tag: 3) as! UIImageView
        
        avatar.imageUrl(url: self.config.getValueFromKey("avatar"))
        
        let name = self.withView(view, tag: 4) as! UILabel

        name.text = self.config.getValueFromKey("name")
        
        let description = self.withView(view, tag: 5) as! UILabel
        
        description.text = (self.config["author"] as! NSArray).count > 1 ? "Nhiều tác giả" : (((self.config["author"] as! NSArray)[0]) as! NSDictionary).getValueFromKey("name")

        let backgroundImage = self.withView(view, tag: 6) as! UIImageView
               
        backgroundImage.blurView.setup(style: UIBlurEffect.Style.dark, alpha: 0.9).enable()

        backgroundImage.imageUrl(url: self.config.getValueFromKey("avatar"))

        collectionView.parallaxHeader.view = view
        collectionView.parallaxHeader.height = CGFloat(headerHeight)
        collectionView.parallaxHeader.minimumHeight = 64
        collectionView.parallaxHeader.mode = .centerFill
        collectionView.parallaxHeader.parallaxHeaderDidScrollHandler = { parallaxHeader in
            back.alpha = 1 - parallaxHeader.progress
            title.alpha = 1 - parallaxHeader.progress
            avatar.alpha = parallaxHeader.progress
            name.alpha = parallaxHeader.progress
            description.alpha = parallaxHeader.progress
        }
        
        self.didRequestChapter()

        self.didRequestDetail()
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
            
            if result.getValueFromKey("error_code") != "0" {
                self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
                return
            }
                        
            self.totalPage = (result["result"] as! NSDictionary)["total_page"] as! Int

            self.pageIndex += 1

            if !self.isLoadMore {
                self.dataList.removeAllObjects()
            }

            let data = ((result["result"] as! NSDictionary)["data"] as! NSArray)

            self.dataList.addObjects(from: data.withMutable())
            
            self.collectionView.reloadSections(IndexSet(integer: 2))
            
            let height = self.collectionView.contentSize.height
            
            let collectionViewInsets: UIEdgeInsets  = UIEdgeInsets(top: CGFloat(self.headerHeight), left: 0.0, bottom: height < CGFloat(self.screenHeight()) ? CGFloat(self.headerHeight) : 0, right: 0.0)
            self.collectionView.contentInset = collectionViewInsets
        })
    }
    
    func didRequestChapter() {
         let request = NSMutableDictionary.init(dictionary: [
                                                             "session":Information.token ?? "",
                                                             "overrideAlert":"1",
                                                             ])
        request.addEntries(from: self.config["url"] as! [AnyHashable : Any])
        request["id"] = self.config.getValueFromKey("id")
        request["CMD_CODE"] = "getListChapOfStory"
         LTRequest.sharedInstance()?.didRequestInfo((request as! [AnyHashable : Any]), withCache: { (cacheString) in
         }, andCompletion: { (response, errorCode, error, isValid, object) in
             self.refreshControl.endRefreshing()
             let result = response?.dictionize() ?? [:]
             
             if result.getValueFromKey("error_code") != "0" {
                 self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
                 return
             }
                     
             self.chapList.removeAllObjects()

             let data = (result["result"] as! NSArray)

             self.chapList.addObjects(from: data as! [Any])
             
             self.collectionView.reloadSections(IndexSet(integer: 1))
            
             let height = self.collectionView.contentSize.height
            
            let collectionViewInsets: UIEdgeInsets  = UIEdgeInsets(top: CGFloat(self.headerHeight), left: 0.0, bottom: height < CGFloat(self.screenHeight()) ? CGFloat(self.headerHeight) : 0, right: 0.0)
             self.collectionView.contentInset = collectionViewInsets
         })
    }
    
    func didRequestDetail() {
        let request = NSMutableDictionary.init(dictionary: [
                                                            "session":Information.token ?? "",
                                                            "overrideAlert":"1",
                                                            ])
       request["id"] = self.config.getValueFromKey("id")
       request["CMD_CODE"] = "getBookDetail"
        LTRequest.sharedInstance()?.didRequestInfo((request as! [AnyHashable : Any]), withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            self.refreshControl.endRefreshing()
            let result = response?.dictionize() ?? [:]
            
            if result.getValueFromKey("error_code") != "0" {
                self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
                return
            }
            
            self.detailList.removeAllObjects()
            

            self.detailList.addObjects(from: self.filter(info: result["result"] as! NSDictionary) as! [Any])

            self.collectionView.reloadSections(IndexSet(integer: 0))
            
            let height = self.collectionView.contentSize.height
            
            let collectionViewInsets: UIEdgeInsets  = UIEdgeInsets(top: CGFloat(self.headerHeight), left: 0.0, bottom: height < CGFloat(self.screenHeight()) ? CGFloat(self.headerHeight) : 0, right: 0.0)
            self.collectionView.contentInset = collectionViewInsets
        })
    }
    
    func filter(info: NSDictionary) -> NSArray {
        let keys = [["key": "category", "title": "Thể loại"],
                   ["key": "author", "title": "Tác giả"],
                   ["key": "publisher", "title": "Nhà xuất bản"],
                   ["key": "events", "title": "Tuyển tập"],
                   ["key": "publish_time", "title": "Ngày xuất bản"]]
                 
        let tempArray = NSMutableArray()
        for key in keys {
            let keying = (key as NSDictionary)["key"] as! String
            if info.object(forKey: keying) != nil {
                let dict = NSMutableDictionary()
                if (info[keying] as? NSArray) != nil {
                    if keying == "author" {
                        dict["value"] = (info[keying] as! NSArray).count != 0 ? (info[keying] as! NSArray).count > 1 ? (((info[keying] as! NSArray).firstObject) as! NSDictionary)["name"] : "Nhiều tác giả" : ""
                    } else {
                        dict["value"] = (info[keying] as! NSArray).count != 0 ? (((info[keying] as! NSArray).firstObject) as! NSDictionary)["name"] : ""
                    }
                } else {
                    dict["value"] = info.getValueFromKey(keying)
                }
                dict["title"] = (key as NSDictionary)["title"] as! String
                if dict.getValueFromKey("value") != "" {
                    tempArray.add(dict)
                }
            }
        }
        
        return tempArray
    }
    
    @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 2 ? dataList.count : section == 1 ? chapList.count : detailList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return indexPath.section == 2 ? CGSize(width: Int((self.screenWidth() / (IS_IPAD ? 5 : 3)) - 15), height: Int(((self.screenWidth() / (IS_IPAD ? 5 : 3)) - 15) * 1.72)) : CGSize(width: collectionView.frame.width, height: indexPath.section == 1 ? 50 : 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: indexPath.section == 2 ? "TG_Map_Cell" : indexPath.section == 1 ? "TG_Book_Chap_Cell" : "TG_Book_Detail_Cell", for: indexPath as IndexPath)
        
        if indexPath.section == 0 {
           let detail = detailList[indexPath.item] as! NSDictionary
           
           let title = self.withView(cell, tag: 1) as! UILabel

           title.text = detail.getValueFromKey("title")

           let description = self.withView(cell, tag: 2) as! UILabel

           description.text = detail.getValueFromKey("value")
        }
        
        if indexPath.section == 1 {
            let chap = chapList[indexPath.item] as! NSDictionary
            
            let title = self.withView(cell, tag: 1) as! UILabel

            title.text = chap.getValueFromKey("name")
            
            let description = self.withView(cell, tag: 2) as! UILabel

            description.text = chap.getValueFromKey("total_character") + " chữ Cập nhật: " + chap.getValueFromKey("publish_time")
        }
        
        if indexPath.section == 2 {
            let data = dataList[indexPath.item] as! NSDictionary
            
            let title = self.withView(cell, tag: 112) as! UILabel

            title.text = data.getValueFromKey("name")
            
            let description = self.withView(cell, tag: 13) as! UILabel

            description.text = (data["author"] as! NSArray).count > 1 ? "Nhiều tác giả" : (((data["author"] as! NSArray)[0]) as! NSDictionary).getValueFromKey("name")
            
            let image = self.withView(cell, tag: 11) as! UIImageView
            
            image.imageUrl(url: data.getValueFromKey("avatar"))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Book_Detail_Title", for: indexPath as IndexPath)
        (self.withView(view, tag: 1) as! UILabel).text = sectionTitle[indexPath.section]
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 44)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.section == 2 {
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
}
