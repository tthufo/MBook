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
    
    @objc var config: NSDictionary!
    
    var headerView: UIView!

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
        headerView = (Bundle.main.loadNibNamed("Book_Detail_Header", owner: self, options: nil)![IS_IPAD ? 1 : 0] as! UIView)
        
        headerView.blurView.setup(style: UIBlurEffect.Style.dark, alpha: 1).enable()
        
        let back = self.withView(headerView, tag: 1) as! UIButton
        
        back.action(forTouch: [:]) { (obj) in
            self.navigationController?.popViewController(animated: true)
        }
        
        let read = self.withView(headerView, tag: 33) as! UIButton
        
        read.action(forTouch: [:]) { (obj) in
            self.didRequestPackage(book: self.config)
        }
        
        let title = self.withView(headerView, tag: 2) as! UILabel

        title.text = self.config.getValueFromKey("name")

        let avatar = self.withView(headerView, tag: 3) as! UIImageView
        
        avatar.imageUrl(url: self.config.getValueFromKey("avatar"))
        
        let name = self.withView(headerView, tag: 4) as! UILabel

        name.text = self.config.getValueFromKey("name")
        
        let description = self.withView(headerView, tag: 5) as! UILabel
        
        description.text = (self.config["author"] as! NSArray).count > 1 ? "Nhiều tác giả" : (((self.config["author"] as! NSArray)[0]) as! NSDictionary).getValueFromKey("name")

        let backgroundImage = self.withView(headerView, tag: 6) as! UIImageView
               
        backgroundImage.blurView.setup(style: UIBlurEffect.Style.dark, alpha: 0.9).enable()

        backgroundImage.imageUrl(url: self.config.getValueFromKey("avatar"))

        collectionView.parallaxHeader.view = headerView
        collectionView.parallaxHeader.height = CGFloat(headerHeight)
        collectionView.parallaxHeader.minimumHeight = 64
        collectionView.parallaxHeader.mode = .centerFill
        collectionView.parallaxHeader.parallaxHeaderDidScrollHandler = { parallaxHeader in
            back.alpha = 1 - parallaxHeader.progress
            title.alpha = 1 - parallaxHeader.progress
            avatar.alpha = parallaxHeader.progress
            name.alpha = parallaxHeader.progress
//            read.alpha = parallaxHeader.progress
            description.alpha = parallaxHeader.progress
        }
        
        self.didRequestChapter()

        self.didRequestDetail()
    }
    
    func setupInfo() {
       let title = self.withView(headerView, tag: 2) as! UILabel

       title.text = self.config.getValueFromKey("name")

       let avatar = self.withView(headerView, tag: 3) as! UIImageView
       
       avatar.imageUrl(url: self.config.getValueFromKey("avatar"))
       
       let name = self.withView(headerView, tag: 4) as! UILabel

       name.text = self.config.getValueFromKey("name")
       
       let description = self.withView(headerView, tag: 5) as! UILabel
       
       description.text = (self.config["author"] as! NSArray).count > 1 ? "Nhiều tác giả" : (((self.config["author"] as! NSArray)[0]) as! NSDictionary).getValueFromKey("name")

       let backgroundImage = self.withView(headerView, tag: 6) as! UIImageView
              
       backgroundImage.blurView.setup(style: UIBlurEffect.Style.dark, alpha: 0.9).enable()

       backgroundImage.imageUrl(url: self.config.getValueFromKey("avatar"))
   }
    
    @objc func didReload(_ sender: Any) {
        isLoadMore = false
        pageIndex = 1
        totalPage = 1
        didRequestData(isShow: true)
    }
    
    func adjustInset() {
        let embeded = (self.isEmbed() ? 65 : 0)
        
        let contentSizeHeight = self.collectionView.collectionViewLayout.collectionViewContentSize.height
             
        let collectionViewHeight = self.collectionView.frame.size.height
         
        let collectionViewInsets: UIEdgeInsets = UIEdgeInsets(top: CGFloat(self.headerHeight), left: 0.0, bottom: contentSizeHeight < CGFloat(collectionViewHeight - 64) ? CGFloat(collectionViewHeight - contentSizeHeight - 64) + CGFloat(embeded) : CGFloat(0 + embeded), right: 0.0)
         
        self.collectionView.contentInset = collectionViewInsets
        
        let read = self.withView(headerView, tag: 33) as! UIButton

        read.isHidden = chapList.count > 1
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
            
            self.collectionView.reloadSections(IndexSet(integer: 2))
            
            self.adjustInset()
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
             
             if result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
                 self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
                 return
             }
                     
             self.chapList.removeAllObjects()

             let data = (result["result"] as! NSArray)

             self.chapList.addObjects(from: data as! [Any])
             
             self.collectionView.reloadSections(IndexSet(integer: 1))
            
             self.adjustInset()
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
            
            if result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
                self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
                return
            }
            
            self.detailList.removeAllObjects()
            
            self.detailList.addObjects(from: self.filter(info: result["result"] as! NSDictionary) as! [Any])

            self.collectionView.reloadSections(IndexSet(integer: 0))
            
            self.adjustInset()
        })
    }
    
    func didRequestUrlBook(book: NSDictionary) {
        let request = NSMutableDictionary.init(dictionary: [
                                                            "session":Information.token ?? "",
                                                            "overrideAlert":"1",
                                                            ])
           request["id"] = book.getValueFromKey("id")
           request["CMD_CODE"] = "getBookContent"
        LTRequest.sharedInstance()?.didRequestInfo((request as! [AnyHashable : Any]), withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
            
            if result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
                self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
                return
            }
            
            let reader = Reader_ViewController.init()
            
            let bookInfo = NSMutableDictionary.init(dictionary: book)
            
            bookInfo["file_url"] = (result["result"] as! NSDictionary).getValueFromKey("file_url")
            
            reader.config = bookInfo
            
            self.navigationController?.pushViewController(reader, animated: true)
            
           self.adjustInset()
        })
    }
    
    func didRequestPackage(book: NSDictionary) {
           let request = NSMutableDictionary.init(dictionary: [
                                                               "session":Information.token ?? "",
                                                               "overrideAlert":"1",
                                                               ])
           request["CMD_CODE"] = "getPackageInfo"
           LTRequest.sharedInstance()?.didRequestInfo((request as! [AnyHashable : Any]), withCache: { (cacheString) in
           }, andCompletion: { (response, errorCode, error, isValid, object) in
               let result = response?.dictionize() ?? [:]
               
               if result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
                   self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
                   return
               }
               if !self.checkRegister(package: response?.dictionize()["result"] as! NSArray, type: "EBOOK") {
                self.showToast("Xin chào " + (Information.userInfo?.getValueFromKey("phone"))! + ", Quý khách chưa đăng ký gói EBOOK hãy đăng ký để trải nghiệm dịch vụ.", andPos: 0)
                   self.center()?.pushViewController(Package_ViewController.init(), animated: true)
               } else {
                   self.didRequestUrlBook(book: book)
               }
           })
       }
    
    func filter(info: NSDictionary) -> NSArray {
        let keys = [["key": "category", "title": "Thể loại"],
                   ["key": "author", "title": "Tác giả"],
                   ["key": "publisher", "title": "Nhà xuất bản"],
                   ["key": "events", "title": "Tuyển tập"],
                   ["key": "publish_time", "title": "Ngày xuất bản", "arrow": "1"]]
                 
        let tempArray = NSMutableArray()
        for key in keys {
            let keying = (key as NSDictionary)["key"] as! String
            if info.object(forKey: keying) != nil {
                let dict = NSMutableDictionary()
                if (info[keying] as? NSArray) != nil {
                    if keying == "author" {
                        dict["name"] = (info[keying] as! NSArray).count != 0 ? (info[keying] as! NSArray).count == 1 ? (((info[keying] as! NSArray).firstObject) as! NSDictionary)["name"] : "Nhiều tác giả" : ""
                    } else {
                        dict["name"] = (info[keying] as! NSArray).count != 0 ? (((info[keying] as! NSArray).firstObject) as! NSDictionary)["name"] : ""
                    }
                } else {
                    dict["name"] = info.getValueFromKey(keying)
                }
                dict["key"] = keying
                dict["config"] = info[keying]
                dict["title"] = (key as NSDictionary)["title"] as! String
                dict["arrow"] = (key as NSDictionary).getValueFromKey("arrow") == "" ? "0" : "1"
                if dict.getValueFromKey("name") != "" {
                    tempArray.add(dict)
                }
            }
        }
        
        return tempArray
    }
    
    func didGoToType(object: NSDictionary) {
        let type = object.getValueFromKey("key")
        if let data = object["config"] as? NSArray {
           let config = data.firstObject as! NSDictionary
           if type == "category" {
               let list = List_Book_ViewController.init()
               list.config = ["url": ["CMD_CODE":"getListBook",
                             "category_id": config.getValueFromKey("id") as Any,
                             "book_type": 0,
                             "price": 0,
                             "sorting": 1,
                 ], "title": object.getValueFromKey("name") as Any]
               self.navigationController!.pushViewController(list, animated: true)
           }
           if type == "author" {
               let authorDetail = Author_Detail_ViewController.init()
               authorDetail.chapList = []
               authorDetail.config = config
               self.navigationController?.pushViewController(authorDetail, animated: true)
           }
           if type == "publisher" {
               let list = List_Book_ViewController.init()
               list.config = ["url": ["CMD_CODE":"getListBook",
                             "publishing_house_id": config.getValueFromKey("id") as Any,
                             "book_type": 0,
                             "price": 0,
                             "sorting": 1,
                 ], "title": object.getValueFromKey("name") as Any]
               self.navigationController!.pushViewController(list, animated: true)
           }
           if type == "events" {
               
           }
        }
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
        return section == 2 ? dataList.count : section == 1 ? chapList.count > 1 ? chapList.count : 0 : detailList.count
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

           description.text = detail.getValueFromKey("name")
            
           let arrow = self.withView(cell, tag: 3) as! UIImageView
            
            arrow.alpha = detail.getValueFromKey("arrow") != "1" ? 1 : 0
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
            
            let player = self.withView(cell, tag: 999) as! UIImageView
                       
            player.isHidden = data.getValueFromKey("book_type") != "3"
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            let bookInfo:NSMutableDictionary = NSMutableDictionary.init(dictionary: (dataList[indexPath.item] as! NSDictionary))
            bookInfo["url"] = self.config["url"]
            if bookInfo.getValueFromKey("book_type") == "3" {
               self.didRequestUrl(info: bookInfo)
               return
            }
            self.config = bookInfo
            self.setupInfo()
            collectionView.setContentOffset(CGPoint.init(x: 0, y: -headerHeight), animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.didReload(self.refreshControl)
                self.didRequestChapter()
                self.didRequestDetail()
            })
        }
        if indexPath.section == 1 { //chapter
            let chap = chapList[indexPath.item] as! NSDictionary
            self.didRequestPackage(book: chap)
        }
        if indexPath.section == 0 { //detail
            print(detailList[indexPath.item])
            let data = detailList[indexPath.item] as! NSDictionary
            self.didGoToType(object: data)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Book_Detail_Title", for: indexPath as IndexPath)
        (self.withView(view, tag: 1) as! UILabel).text = sectionTitle[indexPath.section]
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: section == 1 ? chapList.count <= 1 ? 0 : 44 : 44)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.section == 2 {
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
}
