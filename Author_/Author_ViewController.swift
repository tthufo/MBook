//
//  PC_Map_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 11/4/19.
//  Copyright © 2019 Thanh Hai Tran. All rights reserved.
//

import UIKit

class Author_ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, UITextFieldDelegate {
    
    let refreshControl = UIRefreshControl()
    
    var config: NSDictionary!

    var pageIndex: Int = 1
     
    var totalPage: Int = 1
     
    var isLoadMore: Bool = false
    
    var isOn: Bool = true
    
    var isSearch: Bool = false

    var keyword: NSString!

    @IBOutlet var collectionView: UICollectionView!
        
    @IBOutlet var collectionFilter: UICollectionView!

    @IBOutlet var arrow: UIImageView!
    
    @IBOutlet var searchBg: UIView!
    
    @IBOutlet var searchView: UITextField!
    
    @IBOutlet var searchBtn: UIImageView!

    @IBOutlet var filterButton: UIButton!

    @IBOutlet var searchButton: UIButton!

    var dataList: NSMutableArray!
    
    var dataFilter: NSArray = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "TẤT CẢ"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
                        
        dataList = NSMutableArray.init()
        
        collectionView.withCell("Author_Cell")
        
        collectionFilter.withCell("Author_Filter_Cell")
                
        collectionView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(didReload(_:)), for: .valueChanged)
                
        didRequestData(isShow: true)
        
        keyword = "TẤT CẢ"
        
        searchBtn.imageColor(color: .lightGray)
        
        searchView.addTarget(self, action: #selector(textIsChanging), for: .editingChanged)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchView.resignFirstResponder()
       return true
    }
    
    @objc func textIsChanging(_ textField:UITextField) {
        let hasText = textField.text?.replacingOccurrences(of: " ", with: "") == ""
        if !hasText {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reloading), object: nil)
            self.perform(#selector(self.reloading), with: nil, afterDelay: 0.8)
        }
    }
    
    @objc func reloading() {
        self.didReload(refreshControl)
    }
    
    func searchVisible(show: Bool) {
        searchBg.isHidden = show
        searchView.isHidden = show
    }
    
    @IBAction func didPressSearch(sender: UIButton) {
        self.searchVisible(show: isSearch)
        searchButton.setImage(UIImage(named: !isSearch ? "icon_close" : "ic_search"), for: .normal)
        if isSearch {
            searchView.text = ""
            keyword = "TẤT CẢ"
            filterButton.setTitle("TẤT CẢ", for: .normal)
            filterButton.isEnabled = true
            arrow.isHidden = false
            self.didReload(refreshControl)
            searchView.resignFirstResponder()
        } else {
            if !isOn {
                filter()
            }
            filterButton.setTitle("KẾT QUẢ PHÙ HỢP NHẤT", for: .normal)
            filterButton.isEnabled = false
            arrow.isHidden = true
            keyword = "TẤT CẢ"
            self.didReload(refreshControl)
            searchView.becomeFirstResponder()
        }
        isSearch = !isSearch
    }
    
    func filter() {
        let angle = !isOn ? 0 : CGFloat.pi
        
        arrow.transform = CGAffineTransform(rotationAngle: angle)
        
        collectionView.alpha = !isOn ? 1 : 0
        
        collectionFilter.alpha = isOn ? 1 : 0

        filterButton.setTitle(keyword as String?, for: .normal)
        
        isOn = !isOn
    }
    
    @objc func didReload(_ sender: Any) {
        isLoadMore = false
        pageIndex = 1
        totalPage = 1
        didRequestData(isShow: true)
    }
    
    func didRequestData(isShow: Bool) {
        let request = NSMutableDictionary.init(dictionary: [
                                                            "CMD_CODE": "getListAuthor",
                                                            "keyword": isSearch ? searchView.text ?? "" : (keyword == "TẤT CẢ" ? NSNull.init() : keyword ?? ""),
                                                            "header":["session":Information.token == nil ? "" : Information.token!],
                                                            "session":Information.token ?? "",
                                                            "page_index": self.pageIndex,
                                                            "page_size": 12,
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
                self.dataList.removeAllObjects()
            }

            let data = ((result["result"] as! NSDictionary)["data"] as! NSArray)

            self.dataList.addObjects(from: data.withMutable())
            
            self.collectionView.reloadData()
        })
    }
    
    @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didPressFilter() {
        filter()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == self.collectionView ? dataList.count : dataFilter.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView == self.collectionView ? CGSize(width: Int((self.screenWidth() / (IS_IPAD ? 5 : 3)) - 15), height: Int(((self.screenWidth() / (IS_IPAD ? 5 : 3)) - 15) * 1.5)) : CGSize(width: Int((self.screenWidth() / (IS_IPAD ? 6 : 4)) - 15), height: Int(((self.screenWidth() / (IS_IPAD ? 6 : 4)) - 15) * 0.6))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionView == self.collectionView ? "Author_Cell" : "Author_Filter_Cell", for: indexPath as IndexPath)
        
        if collectionView == self.collectionView {
            let data = dataList[indexPath.item] as! NSDictionary
            
            let title = self.withView(cell, tag: 112) as! UILabel

            title.text = data.getValueFromKey("name")
            
            let description = self.withView(cell, tag: 13) as! UILabel

            description.text = data.getValueFromKey("book_count")
            
            let image = self.withView(cell, tag: 11) as! UIImageView
            
            image.imageUrl(url: data.getValueFromKey("avatar"))
            
//            let player = self.withView(cell, tag: 999) as! UIImageView
//                       
//            player.isHidden = data.getValueFromKey("book_type") != "3"
        } else {
            let title = self.withView(cell, tag: 1) as! UILabel
            
            title.text = (self.dataFilter[indexPath.item] as! String)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collectionView {
            let data = dataList[indexPath.item] as! NSDictionary

            let authorDetail = Author_Detail_ViewController.init()

            authorDetail.chapList = dataList
            
            authorDetail.config = data

            self.navigationController?.pushViewController(authorDetail, animated: true)
        } else {
            keyword = (dataFilter[indexPath.item] as! NSString)
            
            filter()
            
            didReload(refreshControl)
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
