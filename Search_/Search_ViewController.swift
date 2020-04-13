//
//  PC_Map_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 11/4/19.
//  Copyright © 2019 Thanh Hai Tran. All rights reserved.
//

import UIKit

class Search_ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    let refreshControl = UIRefreshControl()
    
    @objc var config: NSDictionary!

    var pageIndex: Int = 1
     
    var totalPage: Int = 1
     
    var isLoadMore: Bool = false
    
    @IBOutlet var counterHeight: NSLayoutConstraint!
    
    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var counter: UILabel!

    @IBOutlet var collectionView: UICollectionView!
        
    @IBOutlet var flowLayout: TagFlowLayout!

    var dataList: NSMutableArray!
    
    var sizingCell: Tag_Cell?
    
    let TAGS = ["Tech", "Design", "Humor", "Travel", "Music", "Writing", "Social Media", "Life", "Education", "Edtech", "Education Reform", "Photography", "Startup", "Poetry", "Women In Tech", "Female Founders", "Business", "Fiction", "Love", "Food", "Sports"]

    override func viewDidLoad() {
        super.viewDidLoad()
                
        titleLabel.text = config.getValueFromKey("title")
        
        dataList = NSMutableArray.init()
        
        collectionView.withCell("TG_Map_Cell")
        
//        collectionView.withCell("Tag_Cell")
                
        collectionView.refreshControl = refreshControl
                
        self.flowLayout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        refreshControl.addTarget(self, action: #selector(didReload(_:)), for: .valueChanged)
                
        let cellNib = UINib(nibName: "Tag_Cell", bundle: nil)

        self.collectionView.register(cellNib, forCellWithReuseIdentifier: "Tag_Cell")

        self.sizingCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! Tag_Cell?

//        didRequestData(isShow: true)
        
//        counterHeight.constant = config.response(forKey: "counter") ? 29 : 0
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
            
            self.counter.text = self.dataList.count == 0 ? "" : (String(self.dataList.count) + " TÁC PHẨM")
            
            self.collectionView.reloadData()
        })
    }
    
    @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configureCell(cell: Tag_Cell, forIndexPath indexPath: NSIndexPath) {
        let tag = TAGS[indexPath.row]
        cell.tagName.text = tag
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TAGS.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        self.configureCell(cell: self.sizingCell!, forIndexPath: indexPath as NSIndexPath)
        return self.sizingCell!.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
//        return CGSize(width: Int((self.screenWidth() / (IS_IPAD ? 5 : 3)) - 15), height: Int(((self.screenWidth() / (IS_IPAD ? 5 : 3)) - 15) * 1.72))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Tag_Cell", for: indexPath as IndexPath)
        
        self.configureCell(cell: cell as! Tag_Cell, forIndexPath: indexPath as NSIndexPath)

//        let data = dataList[indexPath.item] as! NSDictionary
//
//        let title = self.withView(cell, tag: 1) as! UILabel
////
//        title.text = TAGS[indexPath.item]
//        title.text = data.getValueFromKey("name")
//
//        let description = self.withView(cell, tag: 13) as! UILabel
//
//        description.text = (data["author"] as! NSArray).count > 1 ? "Nhiều tác giả" : (((data["author"] as! NSArray)[0]) as! NSDictionary).getValueFromKey("name")
//
//        let image = self.withView(cell, tag: 11) as! UIImageView
//
//        image.imageUrl(url: data.getValueFromKey("avatar"))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//         let bookDetail = Book_Detail_ViewController.init()
//         let bookInfo = NSMutableDictionary.init(dictionary: ["url": ["CMD_CODE":"getListBook"]])
//         bookInfo.addEntries(from: dataList[indexPath.item] as! [AnyHashable : Any])
//         bookDetail.config = bookInfo
//         self.navigationController?.pushViewController(bookDetail, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
//        if self.pageIndex == 1 {
//           return
//        }
//
//        if indexPath.row == dataList.count - 1 {
//           if self.pageIndex <= self.totalPage {
//               self.isLoadMore = true
//               self.didRequestData(isShow: false)
//           }
//        }
    }
}
