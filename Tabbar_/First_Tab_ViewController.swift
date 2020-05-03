//
//  First_Tab_ViewController.swift
//  HearThis
//
//  Created by Thanh Hai Tran on 4/8/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

import UIKit

class First_Tab_ViewController: UIViewController {

    @IBOutlet var tableView: OwnTableView!
    
    var config: NSArray!
    
    var dataList: NSMutableArray!
    
    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.withCell("TG_Room_Cell_Banner_0")

        tableView.withCell("TG_Room_Cell_Banner_1")

        tableView.withCell("TG_Room_Cell_0")

        tableView.withCell("TG_Room_Cell_1")

        tableView.withCell("TG_Room_Cell_2")

        tableView.withCell("TG_Room_Cell_3")

        tableView.withCell("TG_Room_Cell_4")

        tableView.withCell("TG_Room_Cell_5")
                
        tableView.withCell("TG_Room_Cell_6")

        tableView.withCell("TG_Room_Cell_7")

        tableView.withCell("TG_Room_Cell_8")
                
        tableView.withCell("TG_Room_Cell_9")

        tableView.withCell("TG_Room_Cell_10")
        
        dataList = NSMutableArray.init()
        
        tableView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(didReload), for: .valueChanged)
        
        config = NSArray.init(array: [["url": ["CMD_CODE":"getHomeEvent",
                                               "page_index": 1,
                                               "page_size": 24,
                                               "position": 1,
                                        ], "height": 0, "loaded": false, "ident": "TG_Room_Cell_Banner_0"],
                                      ["title":"Mới nhất",
                                       "url": ["CMD_CODE":"getListBook",
                                          "page_index": 1,
                                          "page_size": 24,
                                          "book_type": 2,
                                          "price": 0,
                                          "sorting": 1,
                                        ], "height": 0, "direction": "horizontal", "loaded": false],
                                      ["title":"Miễn phí HOT",
                                       "url": ["CMD_CODE":"getListBook",
                                           "page_index": 1,
                                           "page_size": 24,
                                           "book_type": 0,
                                           "price": 2,
                                           "sorting": 1,
                                       ], "height": 0, "direction": "horizontal", "loaded": false],
                                      ["title":"Đọc nhiều nhất",
                                       "url": ["CMD_CODE":"getListBook",
                                          "page_index": 1,
                                          "page_size": 24,
                                          "book_type": 0,
                                          "price": 0,
                                          "sorting": 1,
                                      ], "height": 0, "direction": "vertical", "loaded": false],
                                      ["title":"Sách nói",
                                       "url": ["CMD_CODE":"getListBook",
                                          "page_index": 1,
                                          "page_size": 24,
                                          "book_type": 3,
                                          "price": 0,
                                          "sorting": 1,
                                      ], "height": 0, "direction": "horizontal", "loaded": false],
                                      ["title":"Khuyên nên đọc",
                                       "url": ["CMD_CODE":"getListBook",
                                          "page_index": 1,
                                          "page_size": 24,
                                          "book_type": 0,
                                          "price": 0,
                                          "sorting": 3,
                                      ], "height": 0, "direction": "vertical", "loaded": false],
                                      ["url": ["CMD_CODE":"getHomeEvent",
                                               "page_index": 1,
                                               "page_size": 24,
                                               "position": 2,
                                      ], "height": 0, "loaded": false, "ident": "TG_Room_Cell_Banner_1"],
                                      ["title":"Promotion",
                                        "url": ["CMD_CODE":"getListPromotionBook",
                                           "page_index": 1,
                                           "page_size": 24,
                                         ], "height": 0, "direction": "horizontal", "loaded": false],
        ]).withMutable() as NSArray?
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.didReload()
        })
    }
    
    @objc func didReload() {
        for dict in self.config {
            (dict as! NSMutableDictionary)["loaded"] = false
        }
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.refreshControl.endRefreshing()
        })
    }
    
    @IBAction func didPressMenu() {
        self.root()?.toggleLeftPanel(nil)
    }
    
    @IBAction func didPressSearch() {
        let search = Search_ViewController.init()
        search.config = [:]
        self.center()?.pushViewController(search, animated: true)
    }
}

extension First_Tab_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (config![indexPath.row] as! NSDictionary)["height"] as! CGFloat
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return config.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let conf = config[indexPath.row] as! NSMutableDictionary
        let cell = tableView.dequeueReusableCell(withIdentifier: conf.getValueFromKey("ident") != "" ? conf.getValueFromKey("ident") : "TG_Room_Cell_%i".format(parameters: indexPath.row) , for: indexPath)
        
        if(conf.getValueFromKey("ident") != "") {
            (cell as! TG_Room_Cell).config = (config[indexPath.row] as! NSDictionary)
            (cell as! TG_Room_Cell).returnValue = { value in
                (self.config[indexPath.row] as! NSMutableDictionary)["height"] = value
                (self.config[indexPath.row] as! NSMutableDictionary)["loaded"] = true
                tableView.reloadData()
            }
            (cell as! TG_Room_Cell).callBack = { info in
                let eventDetail = Event_Detail_ViewController.init()
                eventDetail.config = ((info as! NSDictionary)["selection"] as! NSDictionary)
                eventDetail.chapList = (info as! NSDictionary)["data"] as! NSMutableArray
                self.center()?.pushViewController(eventDetail, animated: true)
            }
        } else {
            (cell as! TG_Room_Cell_N).config = (config[indexPath.row] as! NSDictionary)
            (cell as! TG_Room_Cell_N).returnValue = { value in
                (self.config[indexPath.row] as! NSMutableDictionary)["height"] = value
                (self.config[indexPath.row] as! NSMutableDictionary)["loaded"] = true
                tableView.reloadData()
            }
            (cell as! TG_Room_Cell_N).callBack = { info in
                if (info as! NSDictionary).getValueFromKey("book_type") == "3" {
                    self.didRequestUrl(info: (info as! NSDictionary))
                    return
                }
                let bookDetail = Book_Detail_ViewController.init()
                let bookInfo = NSMutableDictionary.init(dictionary: self.removeKey(info: conf))
                bookInfo.addEntries(from: info as! [AnyHashable : Any])
                bookDetail.config = bookInfo
                self.center()?.pushViewController(bookDetail, animated: true)
            }
            
            let more = self.withView((cell as! TG_Room_Cell_N), tag: 12) as! UIButton
            
            more.action(forTouch:[:]) { (obj) in
                let list = List_Book_ViewController.init()
                
                list.config = self.removeKey(info: conf)
                       
                self.center()?.pushViewController(list, animated: true)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}
