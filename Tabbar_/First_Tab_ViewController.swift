//
//  First_Tab_ViewController.swift
//  HearThis
//
//  Created by Thanh Hai Tran on 4/8/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

import UIKit

class First_Tab_ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var tableView: OwnTableView!
    
    var config: NSArray!
    
    var dataList: NSMutableArray!
    
    let refreshControl = UIRefreshControl()

    @IBOutlet var login_bg_height: NSLayoutConstraint!

    @IBOutlet var banner_bg_height: NSLayoutConstraint!
    
    @IBOutlet var bg_banner: UIImageView!
    
    @IBOutlet var bg_top: UIImageView!

    @IBOutlet var searchBtn: UIImageView!

    @IBOutlet var searchView: UITextField!

    @IBOutlet var buyBtn: UIButton!
    
    @IBOutlet var notiBtn: UIButton!
    
    var bg_view: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        bg_banner.imageColor(color: AVHexColor.color(withHexString: "#1E928C"))
        
        bg_top.imageColor(color: AVHexColor.color(withHexString: "#1E928C"))
        
        banner_bg_height.constant = CGFloat(screenWidth() * 9 / 16) - 70
        
        tableView.withCell("TG_Room_Cell_Banner_0")

        tableView.withCell("TG_Release_Cell")
        
        tableView.withCell("TG_Room_Cell_Cube")

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
        
        let imaging = UIImage(named: "bg_banner")
        
        bg_view = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: Int(self.screenWidth()), height: Int(screenWidth() * 9 / 16) - 70))
        
        bg_view.image = imaging
        
        tableView.insertSubview(bg_view, at: 0)
        
        dataList = NSMutableArray.init()
        
        tableView.refreshControl = refreshControl
                
        refreshControl.addTarget(self, action: #selector(didReload), for: .valueChanged)
        
        config = NSArray.init(array: [["url": ["CMD_CODE":"getHomeEvent", //getHomeEvent
                                               "position": 1,
                                        ], "height": 0, "loaded": false, "ident": "TG_Room_Cell_Banner_0"],
        
        
                                      ["title":"MỚI NHẤT",
                                       "url": ["CMD_CODE":"getListBook",
                                               "group_type":1,
                                          "page_index": 1,
                                          "page_size": 25,
                                          "book_type": 0,
                                          "price": 0,
                                          "sorting": 1,
                                        ], "height": 0, "direction": "horizontal", "loaded": false],
        
        
                                      ["title":"SÁCH NÓI",
                                       "url": ["CMD_CODE":"getListBook",
                                               "group_type":1,
                                           "page_index": 1,
                                           "page_size": 25,
                                           "book_type": 3,
                                           "price": 0,
                                           "sorting": 1,
                                       ], "height": 0, "direction": "horizontal", "loaded": false],
        
        
        
                                      ["title":"MIỄN PHÍ HOT",
                                       "url": ["CMD_CODE":"getListBook",
                                               "group_type":1,
                                          "page_index": 1,
                                          "page_size": IS_IPAD ? 10 : 6,
                                          "book_type": 0,
                                          "price": 1,
                                          "sorting": 1,
                                      ], "height": 0, "direction": "vertical", "loaded": false],
        
    
        
                                      ["title":"TRUYỆN TRANH",
                                        "url": ["CMD_CODE":"getListBook",
                                                "group_type":1,
                                           "book_type": 0,
                                           "category_id": 181,
                                           "page_index": 1,
                                           "page_size": 25,
                                           "price": 0,
                                           "sorting": 1
                                         ], "height": 0, "direction": "horizontal", "loaded": false],
        
        
                                      ["title":"SẮP PHÁT HÀNH",
                                                             "url": ["CMD_CODE":"getUpcomingBookReleases",
                                                                "page_index": 1,
                                                                "page_size": 30,
                                                            ], "height": 0, "direction": "horizontal", "loaded": false, "ident": "TG_Release_Cell"],
        
        
                                      ["title":"TUYỂN TẬP",
                                        "url": ["CMD_CODE":"getHomeEvent",
                                               "position": 2,
                                      ], "height": 0, "direction": "vertical", "loaded": false, "ident": "TG_Room_Cell_Cube"],
        
//                                      ["title":"Sách hay khuyên đọc",
//                                                             "url": ["CMD_CODE":"getListBook",
//                                                                "page_index": 1,
//                                                                "page_size": 24,
//                                                                "book_type": 0,
//                                                                "price": 2,
//                                                                "sorting": 1,
//                                                            ], "height": 0, "direction": "vertical", "loaded": false],
        
        
        ]).withMutable() as NSArray?
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.didReload()
        })
        
        searchBtn.imageColor(color: .lightGray)
        
        searchBtn.action(forTouch: [:]) { (objc) in
            self.didPressSearch()
        }
        
        searchView.addTarget(self, action: #selector(textIsChanging), for: .editingChanged)
    }
    
    @objc func textIsChanging(_ textField:UITextField) {
        Information.searchValue = textField.text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchView.resignFirstResponder()
       return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        buyBtn.isHidden = Information.isVip
        buyBtn.widthConstaint?.constant = Information.isVip ? 0 : 44
        searchView.text = Information.searchValue ?? ""
        notiBtn.shouldHideBadgeAtZero = true
        if Information.userInfo?.getValueFromKey("total_unread") != "0" {
            notiBtn.badgeValue = Information.userInfo?.getValueFromKey("total_unread")
        }
        notiBtn.badgeOriginX = 20
        notiBtn.badgeOriginY = 5
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.view.endEditing(true)
    }
    
    func didRequestNotification() {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"getListNotification",
                                                    "header":["session":Information.token == nil ? "" : Information.token!],
                                                    "user_id":Information.userInfo?.getValueFromKey("user_id") ?? "",
                                                    "page_index": 1,
                                                    "page_size": 10,
                                                    "overrideAlert":"1",
                                                    "overrideLoading":"0",
                                                    "host":nil
            ], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
            
            if result.getValueFromKey("error_code") != "0" {
                self.showToast(response?.dictionize().getValueFromKey("ERR_MSG"), andPos: 0)
                return
            }
            
            Information.changeInfo(notification: ((result["result"] as! NSDictionary)["total_unread"] as! Int))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(0), execute: {
                self.notiBtn.badgeValue = Information.userInfo?.getValueFromKey("total_unread")
            })
        })
    }
    
    @objc func didReload() {
        for dict in self.config {
            (dict as! NSMutableDictionary)["loaded"] = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
        })
        self.didRequestNotification()
    }
    
    @IBAction func didPressMenu() {
        self.view.endEditing(true)
        self.root()?.toggleLeftPanel(nil)
    }
    
    @IBAction func didPressNoti() {
        self.view.endEditing(true)
        self.center()?.pushViewController(PC_Notification_ViewController.init(), animated: true)
    }
    
    @IBAction func didPressBuy() {
        let vip = VIP_ViewController.init()
        vip.callBack = { info in
            print(info)
        }
        let nav = UINavigationController.init(rootViewController: vip)
        nav.isNavigationBarHidden = true
        nav.modalPresentationStyle = .fullScreen
        self.center().present(nav, animated: true, completion: nil)
    }
    
    func didPressSearch() {
        let search = Search_ViewController.init()
        search.config = ["search": searchView.text ?? ""]
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
            if conf.getValueFromKey("ident") == "TG_Room_Cell_Banner_0" {
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
            } else if conf.getValueFromKey("ident") == "TG_Room_Cell_Cube" {
                (cell as! TG_Room_Cell_Cube).config = (config[indexPath.row] as! NSDictionary)
                (cell as! TG_Room_Cell_Cube).returnValue = { value in
                    (self.config[indexPath.row] as! NSMutableDictionary)["height"] = value
                    (self.config[indexPath.row] as! NSMutableDictionary)["loaded"] = true
                    tableView.reloadData()
                }
                (cell as! TG_Room_Cell_Cube).callBack = { info in
                    let eventDetail = Event_Detail_ViewController.init()
                    eventDetail.config = ((info as! NSDictionary)["selection"] as! NSDictionary)
                    eventDetail.chapList = (info as! NSDictionary)["data"] as! NSMutableArray
                    self.center()?.pushViewController(eventDetail, animated: true)
                }
                let more = self.withView((cell as! TG_Room_Cell_Cube), tag: 122) as! UIButton
                
                more.action(forTouch:[:]) { (obj) in
                    let event = Event_ViewController.init()
                    event.config = ["url": ["CMD_CODE": "getHomeEvent", "position": 0], "title": "Tuyển tập chọn lọc"]
                    self.center()?.pushViewController(event, animated: true)
                }
            } else {
                (cell as! TG_Release_Cell).config = (config[indexPath.row] as! NSDictionary)
                (cell as! TG_Release_Cell).returnValue = { value in
                    (self.config[indexPath.row] as! NSMutableDictionary)["height"] = value
                    (self.config[indexPath.row] as! NSMutableDictionary)["loaded"] = true
                    tableView.reloadData()
                }
                (cell as! TG_Release_Cell).callBack = { info in
                    if (info as! NSDictionary).getValueFromKey("book_type") == "3" {
                        self.didRequestMP3Link(info: (info as! NSDictionary))
                        return
                    }
                    let bookDetail = Book_Detail_ViewController.init()
                    let bookInfo = NSMutableDictionary.init(dictionary: self.removeKey(info: conf))
                    bookInfo.addEntries(from: info as! [AnyHashable : Any])
                    bookDetail.config = bookInfo
                    self.center()?.pushViewController(bookDetail, animated: true)
                }
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
                    self.didRequestMP3Link(info: (info as! NSDictionary))
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.sendSubviewToBack(bg_view)
    }
}
