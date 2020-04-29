//
//  PC_Map_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 11/4/19.
//  Copyright © 2019 Thanh Hai Tran. All rights reserved.
//

import UIKit

class Search_ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, UITextFieldDelegate {
    
    let refreshControl = UIRefreshControl()
    
    @objc var config: NSDictionary!

    var pageIndex: Int = 1
     
    var totalPage: Int = 1
     
    var isLoadMore: Bool = false
        
    @IBOutlet var topView: UIView!
    
    @IBOutlet var deleteWidth: NSLayoutConstraint!

    @IBOutlet var deleteButton: UIButton!
    
    @IBOutlet var searchField: UITextField!

    @IBOutlet var collectionView: UICollectionView!
        
    @IBOutlet var collectionBook: UICollectionView!

    @IBOutlet var flowLayout: TagFlowLayout!

    var dataList: NSMutableArray!
    
    var bookList: NSMutableArray!
    
    var historyList: NSMutableArray!

    var sizingCell: Tag_Cell?
    
    let sectionTitle = ["Danh sách đánh dấu", "Lịch sử tìm kiếm"]

    var kb: KeyBoard!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                        
        kb = KeyBoard.shareInstance()

        dataList = NSMutableArray.init()
        
        bookList = NSMutableArray.init()
        
        historyList = NSMutableArray.init()

        collectionBook.withCell("TG_Map_Cell")
                        
        collectionBook.refreshControl = refreshControl
                
        refreshControl.addTarget(self, action: #selector(didReload(_:)), for: .valueChanged)
                
        let cellNib = UINib(nibName: "Tag_Cell", bundle: nil)

        sizingCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! Tag_Cell?

        self.flowLayout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        collectionView.register(cellNib, forCellWithReuseIdentifier: "Tag_Cell")

        collectionView.withHeaderOrFooter("Book_Detail_Title", andKind: UICollectionView.elementKindSectionHeader)

        searchField.addTarget(self, action: #selector(searchTextChange), for: .editingChanged)
            
        reloadHistory()
        
        didRequestTag()
    }
    
    func reloadHistory() {
        historyList.removeAllObjects()
        historyList.addObjects(from: self.getHistory())
        collectionView.reloadData()
    }
    
    @objc func searchTextChange(_ textField:UITextField) {
        let hasText = textField.text?.replacingOccurrences(of: " ", with: "") == ""
        UIView.animate(withDuration: 0.3) {
            self.deleteWidth.constant = hasText ? 0 : 44
            self.topView.layoutIfNeeded()
        }
        deleteButton.alpha = hasText ? 0 : 1
        collectionBook.alpha = hasText ? 0 : 1
        if !hasText {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reloading), object: nil)
            self.perform(#selector(self.reloading), with: nil, afterDelay: 0.5)
        }
    }
    
    @objc func reloading() {
        self.didReload(refreshControl)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       searchField.resignFirstResponder()
       return true
    }

    @IBAction func didPressClose() {
        UIView.animate(withDuration: 0.3) {
            self.deleteWidth.constant = 0
            self.topView.layoutIfNeeded()
        }
        deleteButton.alpha = 0
        collectionBook.alpha = 0
        searchField.text = ""
        bookList.removeAllObjects()
        collectionBook.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        kb.keyboardOff()
     }
    
     override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        kb.keyboard { (height, isOn) in
            self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: isOn ? (height - 0) : 0, right: 0)
            self.collectionBook.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: isOn ? (height - 0) : 0, right: 0)
        }
     }
    
    @objc func didReload(_ sender: Any) {
        isLoadMore = false
        pageIndex = 1
        totalPage = 1
        didRequestData(isShow: true)
    }
    
    func didRequestTag() {
        let request = NSMutableDictionary.init(dictionary: ["CMD_CODE":"getListTag",
                                                           "session":Information.token ?? "",
                                                           "overrideAlert":"1",
                                                           "overrideLoading":"1",
                                                           "host":self])
       LTRequest.sharedInstance()?.didRequestInfo((request as! [AnyHashable : Any]), withCache: { (cacheString) in
       }, andCompletion: { (response, errorCode, error, isValid, object) in
           self.refreshControl.endRefreshing()
           let result = response?.dictionize() ?? [:]
           
           if result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
               self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
               return
           }
        
           self.dataList.removeAllObjects()

           let data = (result["result"] as! NSArray)

           self.dataList.addObjects(from: data.withMutable())
           
           self.collectionView.reloadData()
       })
    }
    
    func didRequestData(isShow: Bool) {
        let request = NSMutableDictionary.init(dictionary: ["CMD_CODE":"getListBook",
                                                            "session":Information.token ?? "",
                                                            "page_index": self.pageIndex,
                                                            "page_size": 10,
                                                            "search_key":searchField.text ?? "",
                                                            "book_type":0,
                                                            "price":0,
                                                            "sorting":1,
                                                            "overrideAlert":"1",
                                                            "overrideLoading":isShow ? 1 : 0,
                                                            "host":self])
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
                self.bookList.removeAllObjects()
            }

            let data = ((result["result"] as! NSDictionary)["data"] as! NSArray)

            let filter = self.filterArray(data: data)

            self.bookList.addObjects(from: Information.check == "0" ? filter.withMutable() : data.withMutable())
            
            self.collectionBook.reloadData()
        })
    }
    
    @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configureCell(cell: Tag_Cell, forIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            let tag = dataList[indexPath.item] as! NSDictionary
            cell.tagName.text = (tag["name"] as! String)
        } else {
            cell.tagName.text = (historyList[indexPath.item] as! String)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return collectionView != self.collectionView ? 1 : 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == self.collectionView ? section == 0 ? dataList.count : historyList.count : bookList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView != self.collectionView {
            return CGSize(width: Int((self.screenWidth() / (IS_IPAD ? 5 : 3)) - 15), height: Int(((self.screenWidth() / (IS_IPAD ? 5 : 3)) - 15) * 1.72))
        }
        self.configureCell(cell: self.sizingCell!, forIndexPath: indexPath as NSIndexPath)
        return self.sizingCell!.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionView != self.collectionView ? "TG_Map_Cell" : "Tag_Cell", for: indexPath as IndexPath)
        
        if collectionView == self.collectionView {
            self.configureCell(cell: cell as! Tag_Cell, forIndexPath: indexPath as NSIndexPath)
        } else {
            let data = bookList[indexPath.item] as! NSDictionary

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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Book_Detail_Title", for: indexPath as IndexPath)
        (self.withView(view, tag: 1) as! UILabel).text = sectionTitle[indexPath.section]
        (self.withView(view, tag: 3) as! UIButton).alpha = indexPath.section == 1 ? 1 : 0
        (self.withView(view, tag: 3) as! UIButton).action(forTouch: [:]) { (obj) in
            self.removeHistory()
            self.reloadHistory()
        }
       return view
    }
       
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView != self.collectionView ? 0 : 44)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView != self.collectionView {
            let data = bookList[indexPath.item] as! NSDictionary
            self.addHistory(data.getValueFromKey("name"))
            self.reloadHistory()
            if data.getValueFromKey("book_type") == "3" {
                self.didRequestUrl(info: (data ))
                return
            }
            let bookDetail = Book_Detail_ViewController.init()
            let bookInfo = NSMutableDictionary.init(dictionary: ["url": ["CMD_CODE":"getListBook", "book_type": 0, "price": 0, "sorting": 1]])
             bookInfo.addEntries(from: data as! [AnyHashable : Any])
             bookDetail.config = bookInfo
             self.navigationController?.pushViewController(bookDetail, animated: true)
        } else {
            if indexPath.section == 0 {
                let data = dataList[indexPath.item] as! NSDictionary
                let listBook = List_Book_ViewController.init()
                let bookInfo = NSMutableDictionary.init(dictionary: ["url": ["CMD_CODE":"getListBook", "book_type": 0, "price": 0, "sorting": 1, "tag_id": data.getValueFromKey("id") as Any], "title": data.getValueFromKey("name") as Any])
                listBook.config = bookInfo
                self.navigationController?.pushViewController(listBook, animated: true)
            } else {
                searchField.text = (historyList[indexPath.item] as! String)
                didReload(refreshControl)
                collectionBook.alpha = 1
                deleteButton.alpha = 1
                UIView.animate(withDuration: 0.3) {
                    self.deleteWidth.constant = 44
                    self.topView.layoutIfNeeded()
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == self.collectionView {
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
