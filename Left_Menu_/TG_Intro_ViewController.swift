//
//  TG_Intro_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 11/4/19.
//  Copyright © 2019 Thanh Hai Tran. All rights reserved.
//

import UIKit

import MarqueeLabel

class TG_Intro_ViewController: UIViewController {
            
    @IBOutlet var tableView: UITableView!
        
    @IBOutlet var userName: UILabel!

    @IBOutlet var phoneNo: UILabel!

    @IBOutlet var avatar: UIImageView!
    
    @IBOutlet var vipIcon: UIImageView!

    @IBOutlet var buyBtn: UIButton!

    @IBOutlet var widthBuyBtn: NSLayoutConstraint!

    @IBOutlet var widthConstant: NSLayoutConstraint!

    var dataList: NSMutableArray!
    
    let refreshControl = UIRefreshControl()
        
      override func viewDidLoad() {
        super.viewDidLoad()
          
        widthConstant.constant = CGFloat(self.screenWidth() * (IS_IPAD ? 0.4 : 0.8));
        
        tableView.refreshControl = refreshControl
           
        refreshControl.tintColor = UIColor.black
        
        refreshControl.addTarget(self, action: #selector(didRequestNotification), for: .valueChanged)
                   
        dataList = NSMutableArray.init()
                
        tableView.withCell("PC_Sub_Cell")
        
        tableView.withHeaderOrFooter("PC_Header_Tab")
        
        didRequestNotification()
        
//        if Information.check == "1" {
//            avatar.imageUrlHolder(url: (Information.userInfo?.getValueFromKey("avatar"))!, holder: "ic_avatar")
//            avatar.action(forTouch: [:]) { (objc) in
//                    self.center()?.pushViewController(PC_Inner_Info_ViewController.init(), animated: true)
//                    self.root()?.showCenterPanel(animated: true)
//            }
//        } else {
//            avatar.image = UIImage.init(named: "logos-1")
//        }
//
//        userName.alpha = Information.check == "1" ? 1 : 0
//
//        phoneNo.alpha = Information.check == "1" ? 1 : 0
        
        reloadData()
    }
    
    @objc func reloadData() {
        if avatar == nil {
            return
        }
        
        if Information.check == "1" {
            if Information.userInfo != nil {
                avatar.imageUrlHolder(url: (Information.userInfo?.getValueFromKey("avatar"))!, holder: "ic_avatar")
                avatar.action(forTouch: [:]) { (objc) in
                    (self.tabbar()!).selectedIndex = 3
                    self.root()?.showCenterPanel(animated: true)
                }
            }
        } else {
            avatar.image = UIImage.init(named: "logos-1")
        }
        
        userName.alpha = Information.check == "1" ? 1 : 0
        
        phoneNo.alpha = Information.check == "1" ? 1 : 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        widthBuyBtn.constant = Information.isVip ? 0 : 56
        
        vipIcon.isHidden = !Information.isVip
                        
        userName.text = Information.userInfo?.getValueFromKey("name") == "" ? "Vô danh" : Information.userInfo?.getValueFromKey("name")
        
        phoneNo.text = (Information.packageInfo)
    }
    
    @objc func didRequestNotification() {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"getBookCategory",
                                                    "header":["session":Information.token == nil ? "" : Information.token!],
                                                    "session":Information.token ?? "",
                                                    "overrideAlert":"1",
                                                    ], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
                                                         
            self.refreshControl.endRefreshing()
                        
            if (error != nil) || result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
                self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
                return
            }
                        
            self.dataList.removeAllObjects()

            let noti = (result["result"] as! NSArray).withMutable()

            for not in noti! {
                (not as! NSMutableDictionary)["open"] = "0"
                if ((not as! NSMutableDictionary)["sub_category"] as! NSArray).count != 0 {
                    ((not as! NSMutableDictionary)["sub_category"] as! NSMutableArray).insert(["name": "Tất cả", "id": (not as! NSMutableDictionary)["id"], "title": (not as! NSMutableDictionary)["name"]], at: 0)
                }
            }
            
            self.dataList.addObjects(from: noti!)
            
            self.dataList.add(NSMutableDictionary.init(dictionary:["avatar": "id", "name": "Tác giả", "sub_category": [], "open": "0", "id": "9999"]))

            self.dataList.add(NSMutableDictionary.init(dictionary:["avatar": "id", "name": "Tuyển tập chọn lọc", "sub_category": [], "open": "0", "id": "99100"]))

            self.dataList.add(NSMutableDictionary.init(dictionary:["avatar": "id", "name": "Nhà xuất bản", "sub_category": [], "open": "0", "id": "99101"]))
            
            let menu = [
                NSMutableDictionary.init(dictionary:["avatar": "id", "name": "", "sub_category": [], "open": "0", "id": "100001"]),
                NSMutableDictionary.init(dictionary:["avatar": "id", "name": "Giới thiệu Mebook", "sub_category": [], "open": "0", "id": "10000"]),
                NSMutableDictionary.init(dictionary:["avatar": "id", "name": "Điều khoản sử dụng", "sub_category": [], "open": "0", "id": "10001"]),
                NSMutableDictionary.init(dictionary:["avatar": "id", "name": "Tổng đài hỗ trợ", "sub_category": [], "open": "0", "id": "10002"]),
                NSMutableDictionary.init(dictionary:["avatar": "id", "name": "Phản hồi dịch vụ", "sub_category": [], "open": "0", "id": "10003"])
            ]
            
            self.dataList.addObjects(from: menu)

            self.tableView.reloadData()
        })
    }
    
    @IBAction func didPressBack() {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didPressFAQ() {

    }
    
    @IBAction func didPressPurchase() {
        let vip = VIP_ViewController.init()
        vip.callBack = { info in
            print(info)
        }
        let nav = UINavigationController.init(rootViewController: vip)
        nav.isNavigationBarHidden = true
        nav.modalPresentationStyle = .fullScreen
        self.root()?.showCenterPanel(animated: true)
        self.center().present(nav, animated: true, completion: nil)
    }
}

extension TG_Intro_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sec = (dataList[section] as! NSMutableDictionary);
        let id = sec.getValueFromKey("id")
        return id == "100001" ? 0.5 : 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let head = Bundle.main.loadNibNamed("PC_Header_Tab", owner: nil, options: nil)![0] as! UIView
                
        let sec = (dataList[section] as! NSMutableDictionary);
                
        let subMenu = (sec["sub_category"] as! NSArray).count == 0
        
        (self.withView(head, tag: 11) as! UILabel).text = sec.getValueFromKey("name")

        (self.withView(head, tag: 12) as! UIButton).isHidden = subMenu
        
        (self.withView(head, tag: 12) as! UIButton).action(forTouch: [:]) { (obj) in
            sec["open"] = sec.getValueFromKey("open") == "0" ? "1" : "0"
            tableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
        }
        
        head.action(forTouch: [:]) { (obj) in
            sec["open"] = sec.getValueFromKey("open") == "0" ? "1" : "0"
            tableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
        }
                
        let angle = sec.getValueFromKey("open") == "0" ? 0 : CGFloat.pi
        
        (self.withView(head, tag: 12) as! UIButton).transform = CGAffineTransform(rotationAngle: angle)
        
        (self.withView(head, tag: 10) as! UIImageView).imageUrl(url: sec.getValueFromKey("avatar"))
        
        let id = sec.getValueFromKey("id")
        
        head.backgroundColor = id == "100001" ? .lightGray : sec.getValueFromKey("open") != "0" ? AVHexColor.color(withHexString: "#DEEBEA") : .clear

        if subMenu {
            head.action(forTouch: [:]) { (obj) in
                if id == "9999" {
                    self.center()?.pushViewController(Author_ViewController.init(), animated: true)
                } else
                if id == "99100" {
                    let event = Event_ViewController.init()
                    event.config = ["url": ["CMD_CODE": "getHomeEvent", "position": 0], "title": sec.getValueFromKey("name") as Any]
                    self.center()?.pushViewController(event, animated: true)
                } else
                if id == "99101" {
                    let publisher = Publisher_ViewController.init()
                    publisher.config = ["url": ["CMD_CODE": "getListPublishingHouse"]]
                    self.center()?.pushViewController(publisher, animated: true)
                } else
                if id == "100001"{
                    
                } else
                if id == "10001" || id == "10000" {
                    let payment = Payment_ViewController.init()
                    let allInfo = NSMutableDictionary.init(dictionary: ["title": sec.getValueFromKey("name") ?? "", "url": id == "10000" ? "getServiceInfo" : "getPolicy"])
                    payment.info = allInfo
                    self.center()?.pushViewController(payment, animated: true)
                } else
                if id == "10002"{
                    self.callNumber(phoneNumber: "19001595")
                } else
                if id == "10003"{
                    let feedBack = Feed_Back_ViewController.init()
                    self.center()?.pushViewController(feedBack, animated: true)
                } else {
                    let list = List_Book_ViewController.init()
                    list.config = ["url": ["CMD_CODE":"getListBook",
                                  "category_id": id,
                                  "book_type": 0,
                                  "price": 0,
                                  "sorting": 1,
                      ], "title": sec.getValueFromKey("name") as Any]
                          
                    self.center()?.pushViewController(list, animated: true)
                }
                self.root()?.showCenterPanel(animated: true)
            }
        }
        return head
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = (dataList[indexPath.section] as! NSDictionary);

        return section.getValueFromKey("open") == "0" ? 0 : UITableView.automaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let section = (dataList[section] as! NSDictionary);
        
        return section.getValueFromKey("open") == "0" ? 0 : (section["sub_category"] as! NSArray).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let data = ((dataList![indexPath.section] as! NSDictionary)["sub_category"] as! NSArray)[indexPath.row] as! NSDictionary
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PC_Sub_Cell", for: indexPath)
                 
        (self.withView(cell, tag: 11) as! UILabel).text = data.getValueFromKey("name")
        
        cell.backgroundColor = AVHexColor.color(withHexString: "#DEEBEA")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
       
        let data = ((dataList![indexPath.section] as! NSDictionary)["sub_category"] as! NSArray)[indexPath.row] as! NSDictionary

        let list = List_Book_ViewController.init()
        
        list.config = ["url": ["CMD_CODE":"getListBook",
                        "category_id": Int(data.getValueFromKey("id")) as Any,
                        "book_type": 0,
                        "price": 0,
                        "sorting": 1,
            ], "title": data.getValueFromKey(data.getValueFromKey("title") != "" ? "title" : "name") as Any]
                
        self.center()?.pushViewController(list, animated: true)
        
        self.root()?.showCenterPanel(animated: true)
    }
}

extension String {
    private var convertHtmlToNSAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else {
            return nil
        }
        do {
            return try NSAttributedString(data: data,options: [.documentType: NSAttributedString.DocumentType.html,.characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        }
        catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    public func convertHtmlToAttributedStringWithCSS(font: UIFont? , csscolor: String , lineheight: Int, csstextalign: String) -> NSAttributedString? {
        guard let font = font else {
            return convertHtmlToNSAttributedString
        }
        let modifiedString = "<style>body{font-family: '\(font.fontName)'; font-size:\(font.pointSize)px; color: \(csscolor); line-height: \(lineheight)px; text-align: \(csstextalign); }</style>\(self)";
        guard let data = modifiedString.data(using: .utf8) else {
            return nil
        }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        }
        catch {
            print(error)
            return nil
        }
    }
}
