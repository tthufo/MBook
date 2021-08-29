//
//  Rating_ViewController.swift
//  HearThis
//
//  Created by Thanh Hai Tran on 8/28/21.
//  Copyright © 2021 Thanh Hai Tran. All rights reserved.
//

import UIKit

class Rating_ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    let refreshControl = UIRefreshControl()
    
    @IBOutlet var collectionView: UICollectionView!

    @objc var config: NSDictionary!
    
    @objc @IBOutlet var bottomGap: NSLayoutConstraint!
    
    var pageIndex: Int = 1
     
    var totalPage: Int = 1
     
    var isLoadMore: Bool = false

    var ratingList: NSMutableArray!
    
    @objc var ratingMode: String = ""
    
    @objc var callBack: ((_ info: Any)->())?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ratingList = NSMutableArray.init()

        collectionView.withCell("Book_Rating_Cell")

        collectionView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(didReload(_:)), for: .valueChanged)
        
        self.didRequestRating(isShow: true)
        
        if self.isEmbed() {
//            bottomGap.constant = 75
        }
    }
    
    @objc func forceReload(config: NSDictionary) {
        if config.getValueFromKey("id") != self.config.getValueFromKey("id") {
            self.config = config
            self.didReload(refreshControl)
        }
    }
    
    @objc func didReload(_ sender: Any) {
        isLoadMore = false
        pageIndex = 1
        totalPage = 1
        didRequestRating(isShow: true)
    }

    func didRequestRating(isShow: Bool) {
         let request = NSMutableDictionary.init(dictionary: [
                                                             "header":["session":Information.token == nil ? "" : Information.token!],
                                                             "session":Information.token ?? "",
                                                             "overrideAlert":"1",
                                                             "overrideLoading":"1",
                                                             "host":self,
                                                             "page_index": pageIndex,
                                                             "page_size": 10
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
                     
            self.totalPage = (result["result"] as! NSDictionary)["total_page"] as! Int

            self.pageIndex += 1

            if !self.isLoadMore {
                self.ratingList.removeAllObjects()
            }

            let data = ((result["result"] as! NSDictionary)["data"] as! NSArray)

            self.ratingList.addObjects(from: data as! [Any])
             
            self.collectionView.reloadData()
         })
    }
 
    func didRequestComment(comment: NSDictionary, menu: EM_MenuView) {
        if comment.getValueFromKey("rating") == "0.0" {
            self.showToast("Bạn chưa chọn đánh giá", andPos: 0)
            return
        }
        if comment.getValueFromKey("comment") == "" {
            self.showToast("Bạn chưa viết đánh giá", andPos: 0)
            return
        }
        let request = NSMutableDictionary.init(dictionary: [
                                                            "header":["session":Information.token == nil ? "" : Information.token!],
                                                            "session":Information.token ?? "",
                                                            "item_id": self.config.getValueFromKey("id") as Any,
                                                            "rating": comment.getValueFromKey("rating") as Any,
                                                            "rating_content": comment.getValueFromKey("comment") as Any,
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
            
            self.callBack?([:])
            
            self.didReload(self.refreshControl)
        })
    }
    
    @IBAction func didPressBack() {
        self.dismiss(animated: true, completion: nil)
//        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didPressRate() {
        EM_MenuView.init(rate: [:])?.disableCompletion({ (indexing, obj, menu) in
            if indexing == 3 {
                self.didRequestComment(comment: obj as! NSDictionary, menu: menu!)
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ratingList.count > 0 ? ratingList.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sizeForRating(for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Book_Rating_Cell", for: indexPath as IndexPath)
        
            let rating = ratingList[indexPath.item] as! NSDictionary

            let image = self.withView(cell, tag: 1) as! UIImageView

            image.imageUrl(url: rating.getValueFromKey("avatar"))
            
            let title = self.withView(cell, tag: 2) as! UILabel

            title.text = rating.getValueFromKey("user_name")
            
            let rate = self.withView(cell, tag: 3) as! CosmosView
            rate.rating = Double(rating.getValueFromKey("rating")) ?? 0

            let description = self.withView(cell, tag: 4) as! UILabel

            description.text = rating.getValueFromKey("rating_content")
       
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
   
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if self.pageIndex == 1 {
          return
        }
      
        if indexPath.item == ratingList.count - 1 {
          if self.pageIndex <= self.totalPage {
              self.isLoadMore = true
              self.didRequestRating(isShow: false)
          }
       }
    }
}
