//
//  PC_Map_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 11/4/19.
//  Copyright © 2019 Thanh Hai Tran. All rights reserved.
//

import UIKit

class List_Book_ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    let refreshControl = UIRefreshControl()
    
    var categoryId: String!
    
    var topLabel: String!

    var pageIndex: Int = 1
     
    var totalPage: Int = 1
     
    var isLoadMore: Bool = false
    
    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var collectionView: UICollectionView!
        
    var dataList: NSMutableArray!
    
//        = Information.check == "1" ?  [["title": "D.sách trạm", "img": "ic_list_station", "category": "1"],
//                                    ["title": "Bản đồ", "img": "ic_bandonen-1", "category": "2"],
//                                    ["title": "Cung cấp thông tin", "img": "ic_feedback_home", "category": "3"],
//                                    ["title": "Cảnh báo", "img": "ic_notification_home", "category": "4"],
//                                    ["title": "T.tin t.khoản", "img": "ic_user_info_home", "category": "5"],
//                                    ["title": "Thiết lập", "img": "ic_setting_home", "category": "6"],
//    ] : [["title": "D.sách trạm", "img": "ic_list_station", "category": "1"],
//                                    ["title": "Bản đồ", "img": "ic_bandonen-1", "category": "2"],
//                                    ["title": "Cung cấp thông tin", "img": "ic_feedback_home", "category": "3"],
//                                    ["title": "Cảnh báo", "img": "ic_notification_home", "category": "4"],
//                                    ["title": "Thiết lập", "img": "ic_setting_home", "category": "6"],
//    ]
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = topLabel
        
        dataList = NSMutableArray.init()
        
        collectionView.withCell("TG_Map_Cell")
        
//        collectionView.addSubview(refreshControl)
        
        collectionView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(didReloadNotification(_:)), for: .valueChanged)
                
        self.didRequestNotification(isShow: true)
    }
    
    @objc func didReloadNotification(_ sender: Any) {
        isLoadMore = false
        pageIndex = 1
        totalPage = 1
        didRequestNotification(isShow: true)
    }
    
    func didRequestNotification(isShow: Bool) {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"getListBook",
                                                    "session":Information.token ?? "",
                                                    "category_id": Int(categoryId) ?? 0,
                                                    "page_index": pageIndex,
                                                    "page_size": 10,
                                                    "book_type": 0,
                                                    "price": 0,
                                                    "sorting": 1,
                                                    "overrideAlert":"1",
                                                    "overrideLoading":isShow ? 1 : 0,
                                                    "host":self], withCache: { (cacheString) in
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
            
            self.collectionView.reloadData()
        })
    }
    
    //{
    //    "book_type": 0,
    //    "category_id": 62,
    //    "cmd_code": "getListBook",
    //    "page_index": 1,
    //    "page_size": 12,
    //    "price": 0,
    //    "session": "F9E3FB3421758EB0C5E8E5CE10A7A4CA",
    //    "sorting": 1
    //}
    
    @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Int((self.screenWidth() / 3) - 15), height: 190)
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
        
        let title = self.withView(cell, tag: 12) as! UILabel

        title.text = data.getValueFromKey("name")
        
        let image = self.withView(cell, tag: 11) as! UIImageView
        
        image.imageUrl(url: data.getValueFromKey("avatar"))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if self.pageIndex == 1 {
           return
        }
       
        if indexPath.row == dataList.count - 1 {
           if self.pageIndex <= self.totalPage {
               self.isLoadMore = true
               self.didRequestNotification(isShow: true)
           }
        }
    }
}
