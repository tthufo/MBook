//
//  PC_Info_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 8/4/19.
//  Copyright © 2019 Thanh Hai Tran. All rights reserved.
//

import UIKit

import MarqueeLabel

import MessageUI


class Package_ViewController: UIViewController, MFMessageComposeViewControllerDelegate {
                
    let refreshControl = UIRefreshControl()

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var sideGapLeft: NSLayoutConstraint!
    
    @IBOutlet var sideGapRight: NSLayoutConstraint!

    var dataList: NSMutableArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if IS_IPAD {
            sideGapLeft.constant = -100
            sideGapRight.constant = 100
        }
        
        tableView.withCell("Package_Cell")
        
        dataList = NSMutableArray.init()
        
        tableView.refreshControl = refreshControl
            
        refreshControl.addTarget(self, action: #selector(didReload(_:)), for: .valueChanged)
        
        didReload(refreshControl)
    }
    
    @objc func didReload(_ sender: Any) {
       didRequestPackage()
    }
    
    func didRequestPackage() {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"getPackageInfo",
                                                    "session":Information.token ?? "",
                                                    "overrideAlert":"1",
                                                    "overrideLoading":"1",
                                                    "host":self], withCache: { (cacheString) in
       }, andCompletion: { (response, errorCode, error, isValid, object) in
           let result = response?.dictionize() ?? [:]
           self.refreshControl.endRefreshing()
        
           if result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
               self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
               return
           }
        
        print(result)
        
           self.dataList.removeAllObjects()

           let data = (result["result"] as! NSArray)

           self.dataList.addObjects(from: data.withMutable())
                  
           self.tableView.reloadData()
       })
    }
    
    @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension Package_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier:"Package_Cell", for: indexPath)
        
        let data = dataList![indexPath.row] as! NSDictionary

        let title = self.withView(cell, tag: 1) as! UILabel
        
        let background = self.withView(cell, tag: 2) as! UIImageView
        
        if data.getValueFromKey("status") == "1" {
            background.image = UIImage.init(named: "trans")
            
            title.text = data["info"] as? String
        } else {
            title.text = "%@ %@".format(parameters: ((data["name"] as? String)!), ((data["price"] as? String)!))
                   
            title.font = UIFont.boldSystemFont(ofSize: 15)
           
            title.textColor = UIColor.white
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let data = dataList![indexPath.row] as! NSDictionary
        print(data)
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = data.getValueFromKey("reg_keyword")
            controller.recipients = [data.getValueFromKey("reg_shortcode")]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
}
