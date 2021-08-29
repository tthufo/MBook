//
//  PC_FeedBack_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 8/9/19.
//  Copyright © 2019 Thanh Hai Tran. All rights reserved.
//

import UIKit
import MarqueeLabel

class PC_FeedBack_ViewController: UIViewController {
    
    var dataList: NSMutableArray!
    
    @objc var config: NSDictionary!
    
    @IBOutlet var bg: UIImageView!
    
    @IBOutlet var titleLabel: MarqueeLabel!
    
    @IBOutlet var sendBtn: UIButton!

    @IBOutlet var content: UITextField!
    
    @IBOutlet var bottomGap: NSLayoutConstraint!
    
    @objc var callBack: ((_ info: Any)->())?

    let refreshControl = UIRefreshControl()

    var pageIndex: Int = 1
    
    var totalPage: Int = 1
    
    var isLoadMore: Bool = false
    
    @IBOutlet weak var tableView: ChatTable! {
        didSet {
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 60.0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataList = NSMutableArray.init()
    
        tableView.withCell("PC_FeedBack_Cell")
        
        tableView.transform = CGAffineTransform(rotationAngle: (-.pi))
        
        
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        tableView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(didReloadFeedBack(_:)), for: .valueChanged)
        
        sendBtn.setImage(UIImage(named: "ic_send")?.withTintColor(AVHexColor.color(withHexString: "#1E928C")), for: .normal)
                
        sendBtn.action(forTouch: [:]) { (obj) in
            let comment = NSMutableDictionary.init(dictionary: [
                "avatar":Information.userInfo?.getValueFromKey("avatar") ?? "",
                "user_name":Information.userInfo?.getValueFromKey("name") ?? "",
                "comment":self.content.text as Any,
                "create_date": NSDate().string(withFormat: "dd/MM/yyyy") as Any
                ])
            self.dataList.insert(comment, at: 0)
            self.tableView.reloadData()
            self.didRequestSendFeedBack(content: self.content.text!)
            self.content.text = ""
            self.tableView.scrollToBottom(animated: true, scrollPostion: .top)
            self.sendBtn.isEnabled = false
            self.view.endEditing(true)
        }
        
        tableView.inputAccessory.alpha = 0
        
        tableView.action(forTouch: [:]) { (objc) in
            self.view.endEditing(true)
        }
        
        if Information.bg != nil && Information.bg != "" {
            bg.imageUrlNoCache(url: Information.bg ?? "")
        }
        
        self.didRequestFeedBack(isShow: true)
        
        content.addTarget(self, action: #selector(textIsChanging), for: .editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:  #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            bottomGap.constant = keyboardHeight
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            bottomGap.constant = 9
        }
    }
    
    @objc func textIsChanging(_ textField:UITextField) {
        sendBtn.isEnabled = textField.text!.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "") == "" ? false : true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.5) {
            self.tableView.inputAccessory.alpha = 1
        }
    }
    
    @objc func didReloadFeedBack(_ sender: Any) {
        isLoadMore = false
        pageIndex = 1
        totalPage = 1
        didRequestFeedBack(isShow: true)
    }
    
    func didRequestFeedBack(isShow: Bool) {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"getListComment",
                                                    "header":["session":Information.token == nil ? "" : Information.token!],
                                                    "session":Information.userInfo?.getValueFromKey("user_id") ?? "",
                                                    "item_id":self.config.getValueFromKey("id") ?? "",
                                                    "page_index":pageIndex,
                                                    "page_size":12,
                                                    "overrideAlert":"1",
                                                    "overrideLoading": isShow ? 1 : 0,
                                                    "host":self
            ], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            if error != nil {
                self.tableView.reloadData()
            }
            
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
                                    
            self.tableView.reloadData()
            
            if isShow {
//                self.tableView.scrollToBottom(animated: false, scrollPostion: .top)
            }
        })
    }
    
    func didRequestSendFeedBack(content: String) {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"pushCommentItem",
                                                    "header":["session":Information.token == nil ? "" : Information.token!],
                                                    "session":Information.userInfo?.getValueFromKey("user_id") ?? "",
                                                    "item_id":self.config.getValueFromKey("id") ?? "",
                                                    "comment":content,
                                                    "overrideAlert":"1"], withCache: { (cacheString) in
                                                    }, andCompletion: { [self] (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
            (self.dataList.firstObject as! NSMutableDictionary)["failed"] = result.getValueFromKey("error_code") != "0" ? "1" : "0"
            self.tableView.reloadData()
            if result.getValueFromKey("error_code") == "0" {
                self.callBack?((result["result"] as! NSDictionary))
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func didPressBack() {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
//        self.navigationController?.popViewController(animated: true)
    }
}

extension PC_FeedBack_ViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

extension PC_FeedBack_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataList.count == 0 ? 0 :  UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "PC_FeedBack_Cell", for: indexPath)
        
        cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        let data = dataList[indexPath.row] as! NSDictionary
        
        let ava = self.withView(cell, tag: 1) as! UIImageView

        ava.imageUrlHolder(url: data.getValueFromKey("avatar"), holder: "bg_publisher_default_img")

        
        let name = self.withView(cell, tag: 2) as! UILabel

        name.text = data.getValueFromKey("user_name")
        
        let dayLeft = self.withView(cell, tag: 3) as! UILabel
        
        dayLeft.text = data.getValueFromKey("create_date")
        
        
        let contentLeft = self.withView(cell, tag: 4) as! UILabel
        
        contentLeft.text = data.getValueFromKey("comment")

        dayLeft.isHidden = false
        
        contentLeft.isHidden = false

        let resend = self.withView(cell, tag: 9999) as! UIButton

        resend.isHidden = data.getValueFromKey("failed") != "1"
        resend.action(forTouch: [:]) { (objc) in
            self.dataList.moveObject(at: UInt(indexPath.row), to: UInt(0))
            (self.dataList.firstObject as! NSMutableDictionary)["failed"] = "0"
            (self.dataList.firstObject as! NSMutableDictionary)["create_date"] = NSDate().string(withFormat: "dd/MM/yyyy") as Any
            self.tableView.reloadData(withAnimation: true)
            let content = self.dataList.firstObject as! NSMutableDictionary
            self.didRequestSendFeedBack(content: content.getValueFromKey("comment"))
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if self.pageIndex == 1 {
            return
        }
        
        if indexPath.row == dataList.count - 1 {
            if self.pageIndex <= self.totalPage {
                self.isLoadMore = true
                self.didRequestFeedBack(isShow: false)
            }
        }
    }
}

extension Date {
    
    func toString(withFormat format: String = "HH:mm dd/MM/yyyy") -> String {
        
        let dateFormatter = DateFormatter()
//        dateFormatter.locale = Locale(identifier: "fa-IR")
//        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tehran")
//        dateFormatter.calendar = Calendar(identifier: .persian)
        dateFormatter.dateFormat = format
        let str = dateFormatter.string(from: self)
        
        return str
    }
}

extension String {
    
    func toDate(withFormat format: String = "yyyy-MM-dd HH:mm:ss")-> Date?{
        
        let dateFormatter = DateFormatter()
//        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tehran")
//        dateFormatter.locale = Locale(identifier: "fa-IR")
//        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self)
        
        return date
        
    }
}

class UIMarginLabel: UILabel {
    
    var topInset:       CGFloat = 5
    var rightInset:     CGFloat = 5
    var bottomInset:    CGFloat = 5
    var leftInset:      CGFloat = 5
    
    public override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
    public override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }
    
    public override func sizeToFit() {
        super.sizeThatFits(intrinsicContentSize)
    }
}
