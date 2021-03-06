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
    
    @IBOutlet var collectionView: UICollectionView!

    @objc var config: NSDictionary!
    
    var headerView: UIView!

    var pageIndex: Int = 1
     
    var totalPage: Int = 1
     
    var isLoadMore: Bool = false
    
    var bioHeight: CGFloat = 0
        
    var bioString: String!
    
    var showMore: Bool = false
            
    var retract: Bool = true

    var dataList: NSMutableArray!
    
    var chapList: NSMutableArray!
    
    var detailList: NSMutableArray!
    
    let headerHeight = IS_IPAD ? 340 : 220
    
    var tempBio: String = ""
    
    var tempInfo: NSMutableDictionary!
    
    let sectionTitle = ["Thông tin chi tiết", "Danh sách chương", "Có thể bạn thích"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
                        
        dataList = NSMutableArray.init()
        
        chapList = NSMutableArray.init()
        
        detailList = NSMutableArray.init()
        
        tempInfo = NSMutableDictionary.init()

        collectionView.withCell("TG_Map_Cell")
        
        collectionView.withCell("Book_Detail_Infor")
        
        collectionView.withCell("Book_Detail_Option_Cell")

        collectionView.withCell("Author_Bio_Cell")
                        
        collectionView.withCell("TG_Book_Detail_Cell")

        collectionView.withCell("TG_Book_Chap_Cell")

        collectionView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(didReload(_:)), for: .valueChanged)
                
        collectionView.withHeaderOrFooter("Book_Detail_Chap_Header", andKind: UICollectionView.elementKindSectionHeader)

        didRequestData(isShow: true)
    
        setupParallaxHeader()
    }
    
    func initBio(show: Bool) -> String {
        let modifiedFont = String(format:"<span style=\"font-family: '-apple-system', 'HelveticaNeue'; font-size:16 \">%@</span>", self.tempBio
         )
        
        let tempString = modifiedFont.html2String.count > (IS_IPAD ? 120 : 120) ? modifiedFont.html2String.substring(to: 120) + "..." : modifiedFont.html2String
        
        return !show ? tempString : modifiedFont.html2String
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
               
//        backgroundImage.blurView.setup(style: UIBlurEffect.Style.dark, alpha: 0.9).enable()

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
            
//            self.collectionView.reloadSections(IndexSet(integer: 2))
            
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
             
            self.collectionView.performBatchUpdates {
                
                self.collectionView.reloadSections(IndexSet(integer: 3))

//                self.collectionView.reloadData()
                
            } completion: { (done) in
                
            }
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
            
            self.tempInfo.removeAllObjects()
            
            self.tempInfo.addEntries(from: result["result"] as! [AnyHashable : Any])
            
            let tem = "Câu chuyện mở ra với bữa tiệc mừng của một thế giới phù thủy mà nhiều năm nay đã bị khủng hoảng bởi Chúa tể Hắc ám Voldemort. Đêm trước đó, Voldemort đã tìm thấy nơi sinh sống của gia đình Potter tại thung lũng Godric và giết chết Lily cũng như James Potter vì một lời tiên tri dự đoán sẽ ảnh hưởng đến Voldemort rằng hắn sẽ bị đánh bại bởi \"đứa trẻ sinh ra khi tháng bảy tàn đi\" mà Voldemort tin đứa trẻ là Harry Potter. Tuy vậy, khi hắn định giết Harry, Lời nguyền Chết chóc Avada Kedavra đã bật lại, Voldemort bị tiêu diệt, chỉ còn là một linh hồn, không sống mà cũng chẳng chết. Trong lúc đó, Harry bị lưu lại một vết sẹo hình tia chớp đặc biệt trên trán mình, dấu hiệu bên ngoài."
            
            self.tempBio = tem//(((result["result"] as! NSDictionary)["publisher"] as! NSArray).firstObject as! NSDictionary)["description"] as! String
            
            self.bioString = self.initBio(show: self.showMore)
            
            self.collectionView.performBatchUpdates {
                
                self.collectionView.reloadSections(IndexSet(integer: 0))

                self.collectionView.reloadSections(IndexSet(integer: 1))
    
                self.collectionView.reloadSections(IndexSet(integer: 2))
    
                self.collectionView.reloadData()
                
            } completion: { (done) in
                
            }
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
//                self.showToast("Xin chào " + (Information.userInfo?.getValueFromKey("phone"))! + ", Quý khách chưa đăng ký gói EBOOK hãy đăng ký để trải nghiệm dịch vụ.", andPos: 0)
                   self.center()?.pushViewController(Package_ViewController.init(), animated: true)
               } else {
                   self.didRequestUrlBook(book: book)
               }
           })
       }
    
    func filter(info: NSDictionary) -> NSArray {
        let keys = [["key": "header_cell", "tag": 1, "height": 44],
                   ["key": "category", "title": "Thể loại", "tag": 2, "height": 35 ],
                   ["key": "author", "title": "Tác giả", "tag": 2, "height": 35],
                   ["key": "publisher", "title": "Nhà xuất bản", "tag": 2, "height": 35],
                   ["key": "events", "title": "Tuyển tập", "tag": 2, "height": 35],
                   ["key": "publish_time", "title": "Ngày upload", "arrow": "1", "tag": 2, "height": 35],
                   ["key": "price", "title": "Giá mua lẻ", "tag": 2, "height": 35, "unit": " VND"],
                   ["key": "button_cell", "tag": 4, "height": 35],
                   ["key": "read_cell", "tag": 6, "height": 90],
        ]
                 
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
                dict["tag"] = (key as NSDictionary)["tag"]
                dict["height"] = (key as NSDictionary)["height"]
                dict["unit"] = (key as NSDictionary).getValueFromKey("unit")
                if dict.getValueFromKey("name") != "" {
                    tempArray.add(dict)
                }
            } else {
                let dict = NSMutableDictionary()
                dict["key"] = keying
                dict["tag"] = (key as NSDictionary)["tag"]
                dict["height"] = (key as NSDictionary)["height"]
                tempArray.add(dict)
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
    
    private func size(for indexPath: IndexPath) -> CGSize {
       let cell = Bundle.main.loadNibNamed("Book_Detail_Infor", owner: self, options: nil)?.first as! UICollectionViewCell
        
       let title = self.withView(cell, tag: 1) as! UILabel
       title.text = self.config.getValueFromKey("name")
                
        let authorName = ((self.config["author"] as! NSArray).firstObject as! NSDictionary).getValueFromKey("name")
        let author = self.withView(cell, tag: 2) as! UILabel
        author.text = authorName
        
       cell.setNeedsLayout()
       cell.layoutIfNeeded()

       let width = collectionView.frame.width
       let height: CGFloat = 0

       let targetSize = CGSize(width: width, height: height)

       let size = cell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .defaultHigh, verticalFittingPriority: .fittingSizeLevel)

       return size
   }
    
    private func sizeBio(for indexPath: IndexPath) -> CGSize {
       let cell = Bundle.main.loadNibNamed("Author_Bio_Cell", owner: self, options: nil)?.first as! UICollectionViewCell
        
       let title = self.withView(cell, tag: 1) as! UILabel
       title.text = self.bioString
        
       cell.setNeedsLayout()
       cell.layoutIfNeeded()

       let width = collectionView.frame.width
       let height: CGFloat = 0

       let targetSize = CGSize(width: width, height: height)

       let size = cell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .defaultHigh, verticalFittingPriority: .fittingSizeLevel)
        
       return size
   }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 || section == 1 ? 1 : section == 2 ? detailList.count : section == 3 ? self.retract ? 0 : chapList.count > 1 ? chapList.count : 0 : 0 //section == 2 ? dataList.count : section == 1 ? chapList.count > 1 ? chapList.count : 0 : detailList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return indexPath.section == 0 ? size(for: indexPath) : indexPath.section == 1 ? sizeBio(for: indexPath) : indexPath.section == 2 ? CGSize(width: collectionView.frame.width, height: detailList.count == 0 ? 0 : (detailList[indexPath.item] as! NSDictionary)["height"] as! CGFloat) : CGSize(width: collectionView.frame.width, height: 65)
//        return indexPath.section == 2 ? CGSize(width: Int((self.screenWidth() / (IS_IPAD ? 5 : 3)) - 15), height: Int(((self.screenWidth() / (IS_IPAD ? 5 : 3)) - 15) * 1.72)) : CGSize(width: collectionView.frame.width, height: indexPath.section == 1 ? 50 : 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: indexPath.section == 2 ? "TG_Map_Cell" : indexPath.section == 1 ? "TG_Book_Chap_Cell" : "TG_Book_Detail_Cell", for: indexPath as IndexPath)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: indexPath.section == 0 ? "Book_Detail_Infor" : indexPath.section == 1 ? "Author_Bio_Cell" : indexPath.section == 2 ? "Book_Detail_Option_Cell" : "TG_Book_Chap_Cell", for: indexPath as IndexPath)
        
        if indexPath.section == 0 {
            
            let title = self.withView(cell, tag: 1) as! UILabel
            title.text = self.config.getValueFromKey("name")
                    
            let authorName = ((self.config["author"] as! NSArray).firstObject as! NSDictionary).getValueFromKey("name")
            let author = self.withView(cell, tag: 2) as! UILabel
            author.text = authorName
            
            let rate = self.withView(cell, tag: 3) as! CosmosView
            rate.rating = Double(self.tempInfo.getValueFromKey("rating")) ?? 0
                                    
            let viewCount = self.withView(cell, tag: 4) as! UIButton
            viewCount.setTitle(self.tempInfo.getValueFromKey("read_count"), for: .normal)
            
            let likeCount = self.withView(cell, tag: 5) as! UIButton
            likeCount.setTitle(self.tempInfo.getValueFromKey("like_count"), for: .normal)
            
            let voteCount = self.withView(cell, tag: 6) as! UIButton
            voteCount.setTitle(self.tempInfo.getValueFromKey("comment_count"), for: .normal)
            
        }
        
        if indexPath.section == 1 {
            
            let title = self.withView(cell, tag: 1) as! UILabel

            title.text = bioString
            
            bioHeight = title.sizeOfMultiLineLabel().height
        }
        
        if indexPath.section == 2 {
           let detail = detailList[indexPath.item] as! NSDictionary

           if detail.getValueFromKey("tag") == "1" {
                for v in cell.contentView.subviews {
                    v.isHidden = v.tag != 1
                }
           }
            
            if detail.getValueFromKey("tag") == "2" {
               let title = self.withView(cell, tag: 2) as! UILabel
               title.text = detail.getValueFromKey("title")
    
               let description = self.withView(cell, tag: 3) as! UILabel
                description.text = "%@%@".format(parameters: detail.getValueFromKey("name"), detail.getValueFromKey("unit"))
                
                for v in cell.contentView.subviews {
                    v.isHidden = v.tag != 2 && v.tag != 3
                }
            }
            
            if detail.getValueFromKey("tag") == "4" {
                let readOrListen = self.withView(cell, tag: 4) as! UIButton
                
                let purchase = self.withView(cell, tag: 5) as! UIButton
                purchase.action(forTouch: [:]) { (obj) in
                    
                    let checkInfo = NSMutableDictionary.init(dictionary: self.tempInfo)
                    checkInfo["is_package"] = "0"
                    
                    let checkOut = Check_Out_ViewController.init()
                    checkOut.info = checkInfo
                    
                    let nav = UINavigationController.init(rootViewController: checkOut)
                    nav.isNavigationBarHidden = true
                    nav.modalPresentationStyle = .fullScreen
                    
                    self.present(nav, animated: true, completion: nil)
                }
                for v in cell.contentView.subviews {
                    v.isHidden = v.tag != 4 && v.tag != 5
                }
            }
            
            if detail.getValueFromKey("tag") == "6" {
                let read = self.withView(cell, tag: 6) as! UIButton
                if IS_IPAD {
                    read.leadingConstaint?.constant = 1200
                    read.trailingConstaint?.constant = 1200
                }
                read.action(forTouch: [:]) { (objc) in
                    self.didRequestPackage(book: self.config)
                }
                for v in cell.contentView.subviews {
                    v.isHidden = v.tag != 6
                }
            }
            
            
            
//            let data = dataList[indexPath.item] as! NSDictionary
//
//            let title = self.withView(cell, tag: 112) as! UILabel
//
//            title.text = data.getValueFromKey("name")
//
//            let description = self.withView(cell, tag: 13) as! UILabel
//
//            description.text = (data["author"] as! NSArray).count > 1 ? "Nhiều tác giả" : (((data["author"] as! NSArray)[0]) as! NSDictionary).getValueFromKey("name")
//
//            let image = self.withView(cell, tag: 11) as! UIImageView
//
//            image.imageUrl(url: data.getValueFromKey("avatar"))
//
//            let player = self.withView(cell, tag: 999) as! UIImageView
//
//            player.isHidden = data.getValueFromKey("book_type") != "3"
        }
        
        if indexPath.section == 3 {
            let chap = chapList[indexPath.item] as! NSDictionary

            let title = self.withView(cell, tag: 1) as! UILabel

            title.text = chap.getValueFromKey("name")

            let description = self.withView(cell, tag: 2) as! UILabel

//            description.text = chap.getValueFromKey("total_character") + " chữ Cập nhật: " + chap.getValueFromKey("publish_time")

            description.text = "Cập nhật: " + chap.getValueFromKey("publish_time")

            let arrow = self.withView(cell, tag: 5) as! UILabel

            arrow.text = "Đọc >"
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 3 {//chapter
            let chap = chapList[indexPath.item] as! NSDictionary
            self.didRequestPackage(book: chap)
        }
        
        if indexPath.section == 2 {
//            let bookInfo:NSMutableDictionary = NSMutableDictionary.init(dictionary: (dataList[indexPath.item] as! NSDictionary))
//            bookInfo["url"] = self.config["url"]
//            if bookInfo.getValueFromKey("book_type") == "3" {
//               self.didRequestUrl(info: bookInfo)
//               return
//            }
//            self.config = bookInfo
//            self.setupInfo()
//            collectionView.setContentOffset(CGPoint.init(x: 0, y: -headerHeight), animated: true)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
//                self.didReload(self.refreshControl)
//                self.didRequestChapter()
//                self.didRequestDetail()
//            })
        }
        if indexPath.section == 1 { //bio
            let cell = collectionView.cellForItem(at: indexPath)
            let title = self.withView(cell, tag: 1) as! UILabel
            showMore = !showMore
            bioString = initBio(show: showMore)
            title.text = bioString
            bioHeight = title.sizeOfMultiLineLabel().height
            self.collectionView.reloadSections(IndexSet(integer: 0))
            self.adjustInset()
        }
        if indexPath.section == 0 {
            
//            print(detailList[indexPath.item])
//            let data = detailList[indexPath.item] as! NSDictionary
//            self.didGoToType(object: data)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Book_Detail_Chap_Header", for: indexPath as IndexPath)
        (self.withView(view, tag: 1) as! UILabel).text = "Đọc EBOOK (%i CHƯƠNG)".format(parameters: self.chapList.count)
        let angle = self.retract ? 0 : CGFloat.pi
        
        (self.withView(view, tag: 3) as! UIButton).transform = CGAffineTransform(rotationAngle: angle)
        view.action(forTouch: [:]) { (objc) in
            self.retract = !self.retract
            self.collectionView.performBatchUpdates {
                self.collectionView.reloadSections(IndexSet(integer: 3))
            } completion: { (done) in
                self.adjustInset()
            }
        }
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        view.layer.zPosition = 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: section == 3 ? chapList.count <= 1 ? 0 : 55 : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
//        if indexPath.section == 2 {
//            if self.pageIndex == 1 {
//              return
//            }
//          
//            if indexPath.item == dataList.count - 1 {
//              if self.pageIndex <= self.totalPage {
//                  self.isLoadMore = true
//                  self.didRequestData(isShow: false)
//              }
//           }
//        }
    }
}
