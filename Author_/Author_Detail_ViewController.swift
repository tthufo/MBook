//
//  Book_Detail_ViewController.swift
//  HearThis
//
//  Created by Thanh Hai Tran on 4/10/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

import UIKit
import ParallaxHeader
import ExpandableLabel

class Author_Detail_ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, ExpandableLabelDelegate {
    
    @IBOutlet var collectionView: UICollectionView!

    var headerView: UIView!

    let refreshControl = UIRefreshControl()
    
    var config: NSDictionary!

    var pageIndex: Int = 1
     
    var totalPage: Int = 1
     
    var isLoadMore: Bool = false
    
    var isCollapse: Bool = true
            
    var dataList: NSMutableArray!
    
    var chapList = NSMutableArray()
        
    let headerHeight = IS_IPAD ? 306 : 171
    
    var bioHeight: CGFloat = 0
    
    let sectionTitle = ["", "Tác phẩm", "Tác giả khác"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
                        
        dataList = NSMutableArray.init()
                
        collectionView.withCell("TG_Map_Cell")
                        
        collectionView.withCell("Author_Bio_Cell")

        collectionView.withCell("TG_Book_Detail_Cell")

        collectionView.withCell("TG_Book_Chap_Cell")

        collectionView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(didReload(_:)), for: .valueChanged)
                
        collectionView.withHeaderOrFooter("Book_Detail_Title", andKind: UICollectionView.elementKindSectionHeader)

        didRequestData(isShow: true)
    
        setupParallaxHeader()
        
        let height = self.collectionView.contentSize.height

        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
           let collectionViewInsets: UIEdgeInsets  = UIEdgeInsets(top: CGFloat(self.headerHeight), left: 0.0, bottom: height < CGFloat(self.screenHeight()) ? CGFloat(self.headerHeight) : 0, right: 0.0)
           self.collectionView.contentInset = collectionViewInsets
        })
    }
        
    private func setupParallaxHeader() {
        headerView = (Bundle.main.loadNibNamed("Author_Detail_Header", owner: self, options: nil)![IS_IPAD ? 0 : 1] as! UIView)
                
        let back = self.withView(headerView, tag: 1) as! UIButton
        
        back.action(forTouch: [:]) { (obj) in
            self.navigationController?.popViewController(animated: true)
        }
        
        let title = self.withView(headerView, tag: 2) as! UILabel

        title.text = self.config.getValueFromKey("name")

        let avatar = self.withView(headerView, tag: 3) as! UIImageView

        avatar.imageUrl(url: self.config.getValueFromKey("avatar"))

        let name = self.withView(headerView, tag: 4) as! UILabel

        name.text = self.config.getValueFromKey("name")

        let description = self.withView(headerView, tag: 5) as! UILabel

        description.text = self.config.getValueFromKey("book_count") + " Tác phẩm"
        
        let backgroundImage = self.withView(headerView, tag: 6) as! UIImageView
               
        collectionView.parallaxHeader.view = headerView
        collectionView.parallaxHeader.height = CGFloat(headerHeight)
        collectionView.parallaxHeader.minimumHeight = 64
        collectionView.parallaxHeader.mode = .centerFill
        collectionView.parallaxHeader.parallaxHeaderDidScrollHandler = { parallaxHeader in
            backgroundImage.alpha = 1 - parallaxHeader.progress
            back.alpha = 1 - parallaxHeader.progress
            title.alpha = 1 - parallaxHeader.progress
            avatar.alpha = parallaxHeader.progress
            name.alpha = parallaxHeader.progress
            description.alpha = parallaxHeader.progress
        }
                          
        self.collectionView.reloadSections(IndexSet(integer: 0))
    }
    
    func setupInfo() {
        let title = self.withView(headerView, tag: 2) as! UILabel

        title.text = self.config.getValueFromKey("name")

        let avatar = self.withView(headerView, tag: 3) as! UIImageView
        
        avatar.imageUrl(url: self.config.getValueFromKey("avatar"))
        
        let name = self.withView(headerView, tag: 4) as! UILabel

        name.text = self.config.getValueFromKey("name")
        
        let description = self.withView(headerView, tag: 5) as! UILabel
        
        description.text = self.config.getValueFromKey("book_count") + " Tác phẩm"
    }
    
    @objc func didReload(_ sender: Any) {
        isLoadMore = false
        pageIndex = 1
        totalPage = 1
        didRequestData(isShow: true)
    }
    
    func didRequestData(isShow: Bool) {
        let request = NSMutableDictionary.init(dictionary: ["CMD_CODE":"getListBook",
                                                            "session":Information.token ?? "",
                                                            "page_index": self.pageIndex,
                                                            "page_size": 10,
                                                            "book_type": 0,
                                                            "price":0,
                                                            "sorting":1,
                                                            "overrideAlert":"1",
                                                            "overrideLoading":isShow ? 1 : 0,
                                                            "host":self])
        
        request["author_id"] = Int(self.config.getValueFromKey("id"))
        
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

            self.dataList.addObjects(from: data.withMutable())
            
            self.collectionView.reloadSections(IndexSet(integer: 1))

            self.collectionView.reloadData()

            let height = self.collectionView.contentSize.height
            
            let collectionViewInsets: UIEdgeInsets  = UIEdgeInsets(top: CGFloat(self.headerHeight), left: 0.0, bottom: height < CGFloat(self.screenHeight()) ? CGFloat(self.headerHeight) : 0, right: 0.0)
            self.collectionView.contentInset = collectionViewInsets
        })
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
        return section == 1 ? dataList.count : section == 2 ? chapList.count : bioHeight == 0 ? 1 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return indexPath.section != 0 ? CGSize(width: Int((self.screenWidth() / (IS_IPAD ? 5 : 3)) - 15), height: Int(((self.screenWidth() / (IS_IPAD ? 5 : 3)) - 15) * 1.72)) : CGSize(width: collectionView.frame.width, height: bioHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func willExpandLabel(_ label: ExpandableLabel) {
    }
       
    func didExpandLabel(_ label: ExpandableLabel) {
           isCollapse = false
        bioHeight = label.frame.size.width
        self.collectionView.reloadSections(IndexSet(integer: 0))
    }
   
    func willCollapseLabel(_ label: ExpandableLabel) {
//       tableView.beginUpdates()
    }
   
    func didCollapseLabel(_ label: ExpandableLabel) {
          isCollapse = true
        bioHeight = label.frame.size.width
        self.collectionView.reloadSections(IndexSet(integer: 0))
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: indexPath.section != 0 ? "TG_Map_Cell" : "Author_Bio_Cell", for: indexPath as IndexPath)
        
        if indexPath.section == 0 {

           let title = self.withView(cell, tag: 1) as! UILabel
            
//            title.text = self.config.getValueFromKey("info")
//
            let data = self.config.getValueFromKey("info").data(using: String.Encoding.unicode)

            let attributedText = try! NSAttributedString(data: data!, options: [.documentType:NSAttributedString.DocumentType.html], documentAttributes: nil)
//
            title.attributedText = attributedText
//
            bioHeight = title.sizeOfMultiLineLabel().height + 80
//
            print("--->", bioHeight)
        
//            self.collectionView.reloadSections(IndexSet(integer: 0))
            
//            title.delegate = self

//            title.setLessLinkWith(lessLink: "Close", attributes: [.foregroundColor:UIColor.red], position: .left)

//            cell.layoutIfNeeded()

//            title.shouldCollapse = true
//            title.textReplacementType = .word
//            title.numberOfLines = 3
//            title.collapsed = isCollapse
//            title.text = self.config.getValueFromKey("info")
//            title.attributedText = attributedText

        }
        
        if indexPath.section == 2 {
            let data = chapList[indexPath.item] as! NSDictionary

            let title = self.withView(cell, tag: 112) as! UILabel

            title.text = data.getValueFromKey("name")

            let description = self.withView(cell, tag: 13) as! UILabel

            description.text = data.getValueFromKey("book_count") + " Tác phẩm"

            let image = self.withView(cell, tag: 11) as! UIImageView

            image.imageUrl(url: data.getValueFromKey("avatar"))
        }
        
        if indexPath.section == 1 {
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
        if indexPath.section == 1 {
            let data = dataList[indexPath.item] as! NSDictionary
            let bookInfo = NSMutableDictionary.init(dictionary: data)
            bookInfo["url"] = ["CMD_CODE":"getListBook"];
            if data.getValueFromKey("book_type") == "3" {
               self.didRequestUrl(info: bookInfo)
               return
            }
            let bookDetail = Book_Detail_ViewController.init()
            bookDetail.config = bookInfo
            self.center()?.pushViewController(bookDetail, animated: true)
        }
        
        if indexPath.section == 2 {
            self.config = (chapList[indexPath.item] as! NSDictionary)
            self.setupInfo()
            collectionView.setContentOffset(CGPoint.init(x: 0, y: -headerHeight), animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.didReload(self.refreshControl)
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Book_Detail_Title", for: indexPath as IndexPath)
        (self.withView(view, tag: 1) as! UILabel).text = indexPath.section == 0 ? "" : sectionTitle[indexPath.section]
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: section == 0 ? 0 : 44)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
//        if indexPath.section == 2 {
//            if self.pageIndex == 1 {
//              return
//            }
//
//            if indexPath.row == dataList.count - 1 {
//              if self.pageIndex <= self.totalPage {
//                  self.isLoadMore = true
//                  self.didRequestData(isShow: false)
//              }
//           }
//        }
    }
}
