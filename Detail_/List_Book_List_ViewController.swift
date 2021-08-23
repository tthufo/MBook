//
//  List_Book_List_ViewController.swift
//  HearThis
//
//  Created by Thanh Hai Tran on 8/23/21.
//  Copyright © 2021 Thanh Hai Tran. All rights reserved.
//

import UIKit

class List_Book_List_ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    let refreshControl = UIRefreshControl()

    var dataList: NSMutableArray!
    
    var pageIndex: Int = 1
     
    var totalPage: Int = 1
     
    var isLoadMore: Bool = false
    
    @IBOutlet var tagView: Tag_View_Vip!
    
    @objc var callBack: ((_ info: Any)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.refreshControl = refreshControl
           
        refreshControl.tintColor = UIColor.black
        
        refreshControl.addTarget(self, action: #selector(didRequestStory), for: .valueChanged)

        tableView.estimatedRowHeight = UITableView.automaticDimension
        
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.withCell("Book_List_Cell")
        
        dataList = NSMutableArray.init()
        
        didRequestStory()
        
        tagView.callBack = { info in
            let listBook = List_Book_ViewController.init()
            let bookInfo = NSMutableDictionary.init(dictionary: [
                "url": [
                        "CMD_CODE":"getListBook",
                        "book_type":0,
                        "price":0,
                        "sorting":1,
                        "tag_id": (info as! NSDictionary).getValueFromKey("id")
                ],
                "title": (info as! NSDictionary).getValueFromKey("name")
            ])
            listBook.config = bookInfo;
            self.navigationController!.pushViewController(listBook, animated: true)
        }
    }
    
    @objc func didRequestStory() {
        isLoadMore = false
        pageIndex = 1
        totalPage = 1
        didRequestAll(isShow: true)
    }
    
    func didRequestAll(isShow: Bool) {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"getListStory",
                                                    "header":["session":Information.token == nil ? "" : Information.token!],
                                                    "page_index": 1,
                                                    "page_size": 12,
                                                    "sorting": 1,
                                                    "price": 0,
                                                    "overrideAlert":"1",
                                                    "overrideLoading":"1",
                                                    "host":isShow ? self : NSNull()], withCache: { (cacheString) in
       }, andCompletion: { (response, errorCode, error, isValid, object) in
           let result = response?.dictionize() ?? [:]
           self.refreshControl.endRefreshing()
        
           if result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
               self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
               return
           }
        
            self.totalPage = (result["result"] as! NSDictionary)["total_page"] as! Int

            self.pageIndex += 1
            
            if !self.isLoadMore {
                self.dataList.removeAllObjects()
            }
        
           let story = (result["result"] as! NSDictionary)["data"] as! NSArray

           self.dataList.addObjects(from: story.withMutable())
            
           self.tableView.reloadData()
       })
    }
    
    @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension List_Book_List_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = dataList![indexPath.row] as! NSDictionary

        let cell = tableView.dequeueReusableCell(withIdentifier:"Book_List_Cell", for: indexPath)
                
        (self.withView(cell, tag: 1) as! UIImageView).imageUrl(url: data.getValueFromKey("avatar"))
        
        (self.withView(cell, tag: 2) as! UILabel).text = data.getValueFromKey("name")
        
        (self.withView(cell, tag: 3) as! UILabel).text = (data["author"] as! NSArray).count > 1 ?"Nhiều tác giả" : ((data["author"] as! NSArray)[0] as! NSDictionary).getValueFromKey("name")

        (self.withView(cell, tag: 4) as! UILabel).text = (data["category"] as! NSArray).count > 1 ?"Đang cập nhật" : ((data["category"] as! NSArray)[0] as! NSDictionary).getValueFromKey("name")
        
        (self.withView(cell, tag: 5) as! UILabel).text = "%@ chương".format(parameters: data.getValueFromKey("total_chapter"))
        
        (self.withView(cell, tag: 14) as! UILabel).text = (data["newest_chapter"] is NSNull) ? "Đang cập nhật" : (data["newest_chapter"] as! NSDictionary).getValueFromKey("name")

        (self.withView(cell, tag: 14) as! UILabel).alpha = 1
        
        (self.withView(cell, tag: 11) as! UILabel).text = "%li".format(parameters: indexPath.row + 1)

        (self.withView(cell, tag: 15) as! UIImageView).alpha = 1
        
        let progress = self.withView(cell, tag: 12) as! Progress
        
        progress.alpha = 0

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let data = dataList![indexPath.row] as! NSDictionary

        let configuration = NSMutableDictionary.init(dictionary: data)
        
        configuration["url"] = ["CMD_CODE":"getListBook"]

        let bookDetail = Book_Detail_ViewController.init()
                
        bookDetail.config = configuration;
        
        self.center()?.pushViewController(bookDetail, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.pageIndex == 1 {
           return
        }

        if indexPath.row == dataList.count - 1 {
           if self.pageIndex <= self.totalPage {
               self.isLoadMore = true
               self.didRequestAll(isShow: false)
           }
        }
    }
    
}
