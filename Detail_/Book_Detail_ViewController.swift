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

    @IBOutlet var likeBtn: UIButton!

    @objc var config: NSDictionary!
    
    var headerView: UIView!

    var pageIndex: Int = 1
     
    var totalPage: Int = 1
    
    var totalRateCount: Int = 0
     
    var isLoadMore: Bool = false
    
    var bioHeight: CGFloat = 0
        
    var bioString: String!
    
    var showMore: Bool = false
            
    var retract: Bool = true

    var dataList: NSMutableArray!
    
    var chapList: NSMutableArray!
    
    var detailList: NSMutableArray!
    
    var ratingList: NSMutableArray!

    
    let headerHeight = IS_IPAD ? 340 : 220
    
    var tempBio: String = ""
    
    var catId: String = ""
    
    var tempInfo: NSMutableDictionary!
        
    override func viewDidLoad() {
        super.viewDidLoad()
                        
        dataList = NSMutableArray.init()
        
        chapList = NSMutableArray.init()
        
        detailList = NSMutableArray.init()
                
        ratingList = NSMutableArray.init()

        tempInfo = NSMutableDictionary.init()

        collectionView.withCell("TG_Map_Cell")
        
        collectionView.withCell("Book_Detail_Infor")
        
        collectionView.withCell("Book_Detail_Option_Cell")

        collectionView.withCell("Author_Bio_Cell")
                        
        collectionView.withCell("TG_Book_Detail_Cell")

        collectionView.withCell("TG_Book_Chap_Cell")

        collectionView.withCell("Book_Rating_Cell")

        collectionView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(didReload(_:)), for: .valueChanged)
                
        collectionView.withHeaderOrFooter("Book_Detail_Chap_Header", andKind: UICollectionView.elementKindSectionHeader)

        collectionView.withHeaderOrFooter("Book_Detail_Gap", andKind: UICollectionView.elementKindSectionHeader)
            
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
            description.alpha = parallaxHeader.progress
        }
        
        self.didRequestDetail()

        self.didRequestChapter()
        
        self.didRequestRating()
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
        didRequestRating()
        didRequestChapter()
    }
    
    func adjustInset() {
        let embeded = (self.isEmbed() ? 65 : 0)
        
        let contentSizeHeight = self.collectionView.collectionViewLayout.collectionViewContentSize.height
             
        let collectionViewHeight = self.collectionView.frame.size.height
         
        let collectionViewInsets: UIEdgeInsets = UIEdgeInsets(top: CGFloat(self.headerHeight), left: 0.0, bottom: contentSizeHeight < CGFloat(collectionViewHeight - 64) ? CGFloat(collectionViewHeight - contentSizeHeight - 64) + CGFloat(embeded) : CGFloat(0 + embeded), right: 0.0)
         
        self.collectionView.contentInset = collectionViewInsets
    }
    
   @IBAction func didRequestLike() {
         let request = NSMutableDictionary.init(dictionary: [
                                                             "header":["session":Information.token == nil ? "" : Information.token!],
                                                             "session":Information.token ?? "",
                                                             "overrideAlert":"1",
                                                             ])
            request["item_id"] = self.config.getValueFromKey("id")
            request["CMD_CODE"] = "pushLikeItem"
         LTRequest.sharedInstance()?.didRequestInfo((request as! [AnyHashable : Any]), withCache: { (cacheString) in
         }, andCompletion: { (response, errorCode, error, isValid, object) in
             self.refreshControl.endRefreshing()
             let result = response?.dictionize() ?? [:]
             
             if result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
                 self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
                 return
             }
            
            let tempConfig = NSMutableDictionary.init(dictionary: self.tempInfo)
            
            tempConfig["like_count"] = (result["result"] as! NSDictionary).getValueFromKey("like_count")
            
            let likeStatus = (result["result"] as! NSDictionary).getValueFromKey("like_status")

            tempConfig["like_status"] = likeStatus
    
            self.tempInfo.removeAllObjects()
            
            self.tempInfo.addEntries(from: tempConfig as! [AnyHashable : Any])
//            self.tempInfo = tempConfig
            
            self.collectionView.reloadSections(IndexSet(integer: 0))
                        
            self.likeBtn.setImage(likeStatus == "1" ? UIImage(named:"ico_like_fill")?.withTintColor(.systemPink) : UIImage(named:"ico_like_white"), for: .normal)
         })
    }
    
    func didRequestData(isShow: Bool) {
        let request = NSMutableDictionary.init(dictionary: [
                                                            "header":["session":Information.token == nil ? "" : Information.token!],
                                                            "session":Information.token ?? "",
                                                            "page_index": self.pageIndex,
                                                            "page_size": 10,
                                                            "overrideAlert":"1",
                                                            "overrideLoading":isShow ? 1 : 0,
                                                            "host":self])
        let bookInfo = NSMutableDictionary.init(dictionary: self.config["url"] as! NSDictionary)
        
        bookInfo.removeObject(forKey: "group_type")
        
        bookInfo["category_id"] = self.catId
        
        bookInfo["sorting"] = Int.random(in: 1..<7)
        
        request.addEntries(from: bookInfo as! [AnyHashable : Any])
                        
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
            
            self.collectionView.reloadSections(IndexSet(integer: 4))
            
            self.adjustInset()
        })
    }
    
    func didRequestChapter() {
         let request = NSMutableDictionary.init(dictionary: [
                                                             "header":["session":Information.token == nil ? "" : Information.token!],
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
                
            } completion: { (done) in
                
            }
             self.adjustInset()
         })
    }
    
    func didRequestDetail() {
        let request = NSMutableDictionary.init(dictionary: [
                                                            "header":["session":Information.token == nil ? "" : Information.token!],
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
            
            let data = result["result"] as! NSDictionary
            
            self.catId = (data["category"] as! NSArray).count == 0 ? "0" : ((data["category"] as! NSArray).firstObject as! NSDictionary).getValueFromKey("id")
            
            self.didRequestData(isShow: true)
            
            self.detailList.removeAllObjects()
            
                        
            self.detailList.addObjects(from: self.filter(info: data, relate: !(data["related"] is NSNull) || data.getValueFromKey("price") != "0") as! [Any])
            
            self.tempInfo.removeAllObjects()
            
            self.tempInfo.addEntries(from: result["result"] as! [AnyHashable : Any])
            
            self.tempInfo["like_status"] = (result["result"] as! NSDictionary).getValueFromKey("like_status") // == "" ? "0" : "1"
            
            let likeStatus = (result["result"] as! NSDictionary).getValueFromKey("like_status")
            
            self.likeBtn.setImage(likeStatus == "1" ? UIImage(named:"ico_like_fill")?.withTintColor(.systemPink) : UIImage(named:"ico_like_white"), for: .normal)
            
            self.tempBio = (data["publisher"] as! NSArray).count == 0 ? "" : ((data["publisher"] as! NSArray).firstObject as! NSDictionary)["description"] as! String
            
            self.bioString = self.initBio(show: self.showMore)
            
            
            self.collectionView.performBatchUpdates {
                
                self.collectionView.reloadSections(IndexSet(integer: 0))

                self.collectionView.reloadSections(IndexSet(integer: 1))
    
                self.collectionView.reloadSections(IndexSet(integer: 2))
                
                self.collectionView.reloadSections(IndexSet(integer: 3))
    
                self.collectionView.reloadData()
                
            } completion: { (done) in
                
            }
            self.adjustInset()
        })
    }
    
    func didRequestRating() {
         let request = NSMutableDictionary.init(dictionary: [
                                                             "header":["session":Information.token == nil ? "" : Information.token!],
                                                             "session":Information.token ?? "",
                                                             "overrideAlert":"1",
                                                             "page_index": 1,
                                                             "page_size": 3
                                                             ])
            request["item_id"] = self.config.getValueFromKey("id")
            request["CMD_CODE"] = "getListRating"
         LTRequest.sharedInstance()?.didRequestInfo((request as! [AnyHashable : Any]), withCache: { (cacheString) in
         }, andCompletion: { (response, errorCode, error, isValid, object) in
             self.refreshControl.endRefreshing()
             let result = response?.dictionize() ?? [:]
             
             if result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
                 self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
                 return
             }
                     
            self.totalRateCount = (result["result"] as! NSDictionary)["total_count"] as! Int

             self.ratingList.removeAllObjects()

             let data = (result["result"] as! NSDictionary)["data"]

             self.ratingList.addObjects(from: data as! [Any])
             
             self.collectionView.performBatchUpdates {
                
                 self.collectionView.reloadSections(IndexSet(integer: 4))
                
            } completion: { (done) in
                
            }
             self.adjustInset()
         })
    }
    
    func didRequestUrlBook(book: NSDictionary) {
        let request = NSMutableDictionary.init(dictionary: [
                                                            "header":["session":Information.token == nil ? "" : Information.token!],
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
            
            self.showReader(book: book, urlPath: (result["result"] as! NSDictionary).getValueFromKey("file_url"), preview: false)
        })
    }
    
    func showReader(book: NSDictionary, urlPath: String, preview: Bool) {
        let reader = Reader_ViewController()
        
        reader.isRestricted = preview
        
        let bookInfo = NSMutableDictionary.init(dictionary: book)

        bookInfo["file_url"] = urlPath

        reader.config = bookInfo

        self.navigationController?.pushViewController(reader, animated: true)

        self.adjustInset()
    }
    
    func didRequestItemInfo(book: NSDictionary) {
       let request = NSMutableDictionary.init(dictionary: [
                                                           "header":["session":Information.token == nil ? "" : Information.token!],
                                                           "session":Information.token ?? "",
                                                           "item_id": book.getValueFromKey("id") ?? "",
                                                           "item_type": "item",
                                                           "overrideAlert":"1",
                                                           "overrideLoading":"1"
                                                           ])
       request["CMD_CODE"] = "checkItemPurchaseInfo"
       LTRequest.sharedInstance()?.didRequestInfo((request as! [AnyHashable : Any]), withCache: { (cacheString) in
       }, andCompletion: { (response, errorCode, error, isValid, object) in
           let result = response?.dictionize() ?? [:]
           
           if result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
               self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
               return
           }
        
        if (result["result"] as! NSDictionary).getValueFromKey("status") == "1" {
            self.showToast("Mua sách đọc \"%@\" thành công".format(parameters: self.config.getValueFromKey("name")) , andPos: 0)
//            self.didRequestUrlBook(book: self.tempInfo)
        } else {
            let checkInfo = NSMutableDictionary.init(dictionary: book)
            checkInfo["is_package"] = "0"
            
            let checkOut = Check_Out_ViewController.init()
            checkOut.info = checkInfo
    
            let nav = UINavigationController.init(rootViewController: checkOut)
            nav.isNavigationBarHidden = true
            nav.modalPresentationStyle = .fullScreen
            
            self.present(nav, animated: true, completion: nil)
         }
       })
    }

    func didRequestPackage(book: NSDictionary) {
        if self.tempInfo.getValueFromKey("book_released") == "0" {
            self.showToast("Truyện sắp phát hành. Hãy thử lại sau.", andPos: 0)
            return
        }
        if book.getValueFromKey("price") != "0" {
            self.didRequestUrl(info: book, callBack: { value in
                if (value as! NSDictionary).response(forKey: "fail") {
                    if self.tempInfo.getValueFromKey("has_preview") == "0" {
                        self.didPressBuy(isAudio: false)
                    } else {
                        self.showReader(book: book, urlPath: self.tempInfo.getValueFromKey("demo_path"), preview: true)
                    }
                } else {
                    self.didRequestUrlBook(book: book)
                }
            })
        } else {
            self.didRequestUrlBook(book: book)
        }
    }
    
    func didRequestChapDetail(chap: NSDictionary) {
        let request = NSMutableDictionary.init(dictionary: [
                                                            "header":["session":Information.token == nil ? "" : Information.token!],
                                                            "session":Information.token ?? "",
                                                            "overrideAlert":"1",
                                                            ])
           request["id"] = chap.getValueFromKey("id")
           request["CMD_CODE"] = "getBookDetail"
        LTRequest.sharedInstance()?.didRequestInfo((request as! [AnyHashable : Any]), withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            self.refreshControl.endRefreshing()
            let result = response?.dictionize() ?? [:]
            
            if result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
                self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
                return
            }
            
            let chapter = result["result"] as! NSDictionary
            self.didRequestPackage(book: chapter)
        })
    }
    
//    let keys = relate ? [["key": "header_cell", "tag": 1, "height": 44],
//               ["key": "category", "title": "Thể loại", "tag": 2, "height": 35 ],
////                   ["key": "author", "title": "Tác giả", "tag": 2, "height": 35],
////                   ["key": "publisher", "title": "Nhà xuất bản", "tag": 2, "height": 35],
////                   ["key": "events", "title": "Tuyển tập", "tag": 2, "height": 35],
//               ["key": "publish_time", "title": "Ngày upload", "arrow": "1", "tag": 2, "height": 35],
//               ["key": "price", "title": "Giá mua lẻ", "tag": 2, "height": 35, "unit": " VND"],
//               ["key": "button_cell", "tag": 4, "height": 35],
//               ["key": "read_cell", "tag": 6, "height": 90],
//    ] :
//    [["key": "header_cell", "tag": 1, "height": 44],
//               ["key": "category", "title": "Thể loại", "tag": 2, "height": 35 ],
////                   ["key": "author", "title": "Tác giả", "tag": 2, "height": 35],
////                   ["key": "publisher", "title": "Nhà xuất bản", "tag": 2, "height": 35],
////                   ["key": "events", "title": "Tuyển tập", "tag": 2, "height": 35],
//               ["key": "publish_time", "title": "Ngày upload", "arrow": "1", "tag": 2, "height": 35],
//               ["key": "price", "title": "Giá mua lẻ", "tag": 2, "height": 35, "unit": " VND"],
////                   ["key": "button_cell", "tag": 4, "height": 35],
//               ["key": "read_cell", "tag": 6, "height": 90],
//    ]
    
    func filter(info: NSDictionary, relate: Bool) -> NSArray {
        let keys = relate ? Information.check == "1" ? [["key": "header_cell", "tag": 1, "height": 44],
                   ["key": "category", "title": "Thể loại", "tag": 2, "height": 35 ],
                   ["key": "publish_time", "title": "Ngày upload", "arrow": "1", "tag": 2, "height": 35],
                   ["key": "price", "title": "Giá mua lẻ", "tag": 2, "height": 35, "unit": " VND"],
                   ["key": "button_cell", "tag": 4, "height": 35],
                   ["key": "read_cell", "tag": 6, "height": 90],
        ] : [["key": "header_cell", "tag": 1, "height": 44],
             ["key": "category", "title": "Thể loại", "tag": 2, "height": 35 ],
             ["key": "publish_time", "title": "Ngày upload", "arrow": "1", "tag": 2, "height": 35],
//             ["key": "price", "title": "Giá mua lẻ", "tag": 2, "height": 35, "unit": " VND"],
             ["key": "button_cell", "tag": 4, "height": 35],
             ["key": "read_cell", "tag": 6, "height": 90],
        ] : Information.check == "1" ?
        [["key": "header_cell", "tag": 1, "height": 44],
                   ["key": "category", "title": "Thể loại", "tag": 2, "height": 35 ],
                   ["key": "publish_time", "title": "Ngày upload", "arrow": "1", "tag": 2, "height": 35],
                   ["key": "price", "title": "Giá mua lẻ", "tag": 2, "height": 35, "unit": " VND"],
                   ["key": "read_cell", "tag": 6, "height": 90],
        ] : [["key": "header_cell", "tag": 1, "height": 44],
             ["key": "category", "title": "Thể loại", "tag": 2, "height": 35 ],
             ["key": "publish_time", "title": "Ngày upload", "arrow": "1", "tag": 2, "height": 35],
//             ["key": "price", "title": "Giá mua lẻ", "tag": 2, "height": 35, "unit": " VND"],
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
    
    func didRequestComment(comment: NSDictionary, menu: EM_MenuView) {
        if comment.getValueFromKey("rating") == "0.0" {
            self.showToast("Bạn chưa chọn đánh giá", andPos: 0)
            return
        }
        let request = NSMutableDictionary.init(dictionary: [
                                                            "header":["session":Information.token == nil ? "" : Information.token!],
                                                            "session":Information.token ?? "",
                                                            "item_id": self.config.getValueFromKey("id") as Any,
                                                            "rating": comment.getValueFromKey("rating") as Any,
                                                            "rating_content": comment.getValueFromKey("comment") == "" ? " " : comment.getValueFromKey("comment"),
                                                            "overrideAlert":"1",
                                                            ])
        
        request["CMD_CODE"] = "pushRateItem"
        LTRequest.sharedInstance()?.didRequestInfo((request as! [AnyHashable : Any]), withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            self.refreshControl.endRefreshing()
            let result = response?.dictionize() ?? [:]
            
            menu.close()

            if result.getValueFromKey("error_code") != "0" {
                self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
                return
            }
            
            self.tempInfo["rating"] = (result["result"] as! NSDictionary).getValueFromKey("rating")
            
            self.collectionView.reloadSections(IndexSet(integer: 0))
            
            self.showToast("Đánh giá thành công", andPos: 0)
                        
            self.didRequestRating()
        })
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
    
    private func sizeForRating(for indexPath: IndexPath) -> CGSize {
       let cell = Bundle.main.loadNibNamed("Book_Rating_Cell", owner: self, options: nil)?.first as! UICollectionViewCell
        
       let rating = self.withView(cell, tag: 4) as! UILabel
       rating.text = (self.ratingList[indexPath.item] as! NSDictionary).getValueFromKey("rating_content")
        
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
        return 6
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 || section == 1 ? 1 : section == 2 ? detailList.count : section == 3 ? self.retract ? 0 : chapList.count > 1 ? chapList.count : 0 : section == 4 ? ratingList.count > 0 ? ratingList.count : 0 : dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return indexPath.section == 0 ? size(for: indexPath) : indexPath.section == 1 ? sizeBio(for: indexPath) : indexPath.section == 2 ? CGSize(width: collectionView.frame.width, height: detailList.count == 0 ? 0 : (detailList[indexPath.item] as! NSDictionary)["height"] as! CGFloat) : indexPath.section == 3 ? CGSize(width: collectionView.frame.width, height: 65) : indexPath.section == 4 ? sizeForRating(for: indexPath) : CGSize(width: Int((self.screenWidth() / (IS_IPAD ? 5 : 3)) - 15), height: Int(((self.screenWidth() / (IS_IPAD ? 5 : 3)) - 15) * 1.72))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return section == 5 ? UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5) : UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: indexPath.section == 0 ? "Book_Detail_Infor" : indexPath.section == 1 ? "Author_Bio_Cell" : indexPath.section == 2 ? "Book_Detail_Option_Cell" : indexPath.section == 3 ? "TG_Book_Chap_Cell" : indexPath.section == 4 ? "Book_Rating_Cell" : "TG_Map_Cell", for: indexPath as IndexPath)
        
        
        if indexPath.section == 0 {
            
            let title = self.withView(cell, tag: 1) as! UILabel
            title.text = self.config.getValueFromKey("name")
                    
            let authorName = ((self.config["author"] as! NSArray).firstObject as! NSDictionary).getValueFromKey("name")
            let author = self.withView(cell, tag: 2) as! UILabel
            author.text = authorName
            
            let rate = self.withView(cell, tag: 3) as! CosmosView
            rate.rating = Double(self.tempInfo.getValueFromKey("rating")) ?? 0
            
            rate.action(forTouch: [:]) { (obj) in
                EM_MenuView.init(rate: [:])?.disableCompletion({ (indexing, obj, menu) in
                    if indexing == 3 {
                        self.didRequestComment(comment: obj as! NSDictionary, menu: menu!)
                    }
                })
            }
                                    
            let viewCount = self.withView(cell, tag: 4) as! UIButton
            viewCount.setTitle(self.tempInfo.getValueFromKey("read_count"), for: .normal)
            
            let likeCount = self.withView(cell, tag: 5) as! UIButton
            likeCount.setTitle(self.tempInfo.getValueFromKey("like_count"), for: .normal)
            likeCount.setImage(self.tempInfo.getValueFromKey("like_status") == "1" ? UIImage(named:"ico_like")?.withTintColor(.systemPink) : UIImage(named:"ico_like"), for: .normal)
            likeCount.action(forTouch: [:]) { (obj) in
                self.didRequestLike()
            }
            
            let voteCount = self.withView(cell, tag: 6) as! UIButton
            voteCount.setTitle(self.tempInfo.getValueFromKey("comment_count"), for: .normal)
            
            voteCount.action(forTouch: [:]) { (obj) in
                let feedBack = PC_FeedBack_ViewController.init()
                feedBack.config = self.tempInfo
                feedBack.callBack = { infor in
                    let tempConfig = NSMutableDictionary.init(dictionary: self.tempInfo)
                    
                    tempConfig["comment_count"] = (infor as! NSDictionary).getValueFromKey("comment_count")
                    
                    self.tempInfo = tempConfig
                    
                    self.collectionView.reloadSections(IndexSet(integer: 0))
                }
                let nav = UINavigationController.init(rootViewController: feedBack)
                nav.isNavigationBarHidden = true
                nav.modalPresentationStyle = .fullScreen
                self.center()?.present(nav, animated: true, completion: nil)
            }
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
                
                for v in cell.contentView.subviews {
                    v.isHidden = v.tag != 4 && v.tag != 5
                }
                
                let readOrListen = self.withView(cell, tag: 4) as! UIButton
                readOrListen.isHidden = (self.tempInfo["related"] is NSNull)
                readOrListen.setTitleColor(UIColor.orange, for: .normal)
                readOrListen.setTitle("Nghe Audio", for: .normal)
                readOrListen.setImage(UIImage(named: "ico_audio"), for: .normal)
                readOrListen.action(forTouch: [:]) { (objc) in
                    let bookInfo:NSMutableDictionary = NSMutableDictionary.init(dictionary: (self.tempInfo["related"] as! NSDictionary))
                    bookInfo["url"] = self.config["url"]
                    self.didRequestMP3Link(info: bookInfo)
                }
                
                let purchase = self.withView(cell, tag: 5) as! UIButton
                purchase.isHidden = self.tempInfo.getValueFromKey("price") == "0"
                purchase.isHidden = Information.check == "0"
                purchase.action(forTouch: [:]) { (obj) in
                    self.didRequestItemInfo(book: self.tempInfo)
                }
            }
            
            if detail.getValueFromKey("tag") == "6" {
                let read = self.withView(cell, tag: 6) as! UIButton
                if IS_IPAD {
                    read.leadingConstaint?.constant = 1200
                    read.trailingConstaint?.constant = 1200
                }
                read.action(forTouch: [:]) { (objc) in
                    self.didRequestPackage(book: self.tempInfo)
                }
                for v in cell.contentView.subviews {
                    v.isHidden = v.tag != 6
                }
            }
            
        }
        
        if indexPath.section == 3 {
            let chap = chapList[indexPath.item] as! NSDictionary

            let title = self.withView(cell, tag: 1) as! UILabel

            title.text = chap.getValueFromKey("name")

            let description = self.withView(cell, tag: 2) as! UILabel

            description.text = "Cập nhật: " + chap.getValueFromKey("publish_time")

            let arrow = self.withView(cell, tag: 5) as! UILabel

            arrow.text = "Đọc >"
        }
        
        if indexPath.section == 4 {
            let rating = ratingList[indexPath.item] as! NSDictionary

            let image = self.withView(cell, tag: 1) as! UIImageView

            image.imageUrlHolder(url: rating.getValueFromKey("avatar"), holder: "ic_avatar")
            
            let title = self.withView(cell, tag: 2) as! UILabel

            title.text = rating.getValueFromKey("user_name")
            
            let rate = self.withView(cell, tag: 3) as! CosmosView
            rate.rating = Double(rating.getValueFromKey("rating")) ?? 0

            let description = self.withView(cell, tag: 4) as! UILabel

            description.text = rating.getValueFromKey("rating_content")
        }
        
        if indexPath.section == 5 {
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
        
        if indexPath.section == 2 {//detail
            print(detailList[indexPath.item])
            let data = detailList[indexPath.item] as! NSDictionary
            self.didGoToType(object: data)
        }
        
        if indexPath.section == 3 {//chapter
            let chap = chapList[indexPath.item] as! NSDictionary
            self.didRequestChapDetail(chap: chap)
        }
        
        if indexPath.section == 5 {
            let bookInfo:NSMutableDictionary = NSMutableDictionary.init(dictionary: (dataList[indexPath.item] as! NSDictionary))
            bookInfo["url"] = self.config["url"]
            if bookInfo.getValueFromKey("book_type") == "3" {
                self.didRequestMP3Link(info: bookInfo)
                return
            }
            self.config = bookInfo
            self.setupInfo()
            collectionView.setContentOffset(CGPoint.init(x: 0, y: -headerHeight), animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.didReload(self.refreshControl)
                self.didRequestChapter()
                self.didRequestDetail()
                self.didRequestRating()
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if indexPath.section == 5 {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Book_Detail_Gap", for: indexPath as IndexPath)

            return view
        }
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Book_Detail_Chap_Header", for: indexPath as IndexPath)
        (self.withView(view, tag: 1) as! UILabel).text = indexPath.section == 3 ? "ĐỌC EBOOK (%i CHƯƠNG)".format(parameters: self.chapList.count) :
            "ĐÁNH GIÁ (%i)".format(parameters: totalRateCount)
        if indexPath.section == 3 {
            (self.withView(view, tag: 99) as! UILabel).isHidden = true
            (self.withView(view, tag: 3) as! UIButton).isHidden = false
            (self.withView(view, tag: 4) as! UIButton).isHidden = true
            (self.withView(view, tag: 3) as! UIButton).setBackgroundImage(UIImage(named: "ico_arrow_teal"), for: .normal)
            view.backgroundColor = AVHexColor.color(withHexString: "#F0F0EC")
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
        } else {
            (self.withView(view, tag: 99) as! UILabel).isHidden = false
            (self.withView(view, tag: 4) as! UIButton).isHidden = false
            (self.withView(view, tag: 3) as! UIButton).isHidden = true
            (self.withView(view, tag: 4) as! UIButton).setBackgroundImage(UIImage(named: "ico_arrow_teal_r"), for: .normal)
            view.backgroundColor = .white
            view.action(forTouch: [:]) { (objc) in
                let rating = Rating_ViewController.init()
                rating.config = self.tempInfo
                rating.ratingMode = "book"
                rating.callBack = { info in
                    self.tempInfo["rating"] = (info as! NSDictionary).getValueFromKey("rating")
                    self.collectionView.reloadSections(IndexSet(integer: 0))
                    self.didRequestRating()
                }
                let nav = UINavigationController.init(rootViewController: rating)
                nav.isNavigationBarHidden = true
                nav.modalPresentationStyle = .fullScreen
                
                self.present(nav, animated: true, completion: nil)
            }
        }
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        view.layer.zPosition = 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: section == 3 ? chapList.count <= 1 ? 0 : 55 : section == 4 ? 55 : section == 5 ? 40 : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.section == 5 {
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
