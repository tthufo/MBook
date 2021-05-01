//
//  Check_Out_ViewController.swift
//  HearThis
//
//  Created by Thanh Hai Tran on 4/30/21.
//  Copyright © 2021 Thanh Hai Tran. All rights reserved.
//

import UIKit

class Check_Out_ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var optionCell: UITableViewCell!

    @IBOutlet var login_bg_height: NSLayoutConstraint!

    @IBOutlet var sideGapLeft: NSLayoutConstraint!
    
    @IBOutlet var sideGapRight: NSLayoutConstraint!
    
    @IBOutlet var nextButton: UIButton!

    var isPackage: Bool = true
    
    var names = [["check": "0", "name": "ic_momo"], ["check": "0", "name": "ic_airpay"], ["check": "0", "name": "ic_vnpay"], ["check": "0", "name": "ic_nganluong"], ["check": "0", "name": "ic_sms"]]

    override func viewDidLoad() {
        super.viewDidLoad()

        if IS_IPAD {
            login_bg_height.constant = 550
            
            sideGapLeft.constant = 100
            
            sideGapRight.constant = 100
        }

        tableView.estimatedRowHeight = 150
        
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.withCell("Vip_Cell")
        
        tableView.withCell("Check_Out_Cell")
        
        tableView.withCell("Check_Out_Book_Cell")
    }

    @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didPressNext() {
        
    }
    
    @IBAction func didPressCancel() {
        
    }
}

extension Check_Out_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == (self.isPackage ? 2 : 1) ? 330 : self.isPackage ? UITableView.automaticDimension : 260
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isPackage ? 3 : 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == (self.isPackage ? 2 : 1) {
            
            let stack = self.withView(optionCell, tag: 1) as! UIStackView
                        
            for i in 0 ..< stack.subviews.count {
                let button = stack.subviews[i]
                let checked = self.names[i]["check"] == "1"
                (button as! UIButton).setImage(checked ? UIImage(named: self.names[i]["name"]!) : UIImage(named: self.names[i]["name"]!)?.noir, for: .normal)
                (button as! UIButton).action(forTouch: ["index": i, "button": button]) { (obc) in
                    let indexing = obc!["index"]
                    let bacton = obc!["button"]
                    let checking = self.names[indexing as! Int]["check"] == "0"
                    if checking {
                        for k in 0 ..< stack.subviews.count {
                            let btn = stack.subviews[k]
                            self.names[k]["check"] = "0"
                            (btn as! UIButton).setImage(UIImage(named: self.names[k]["name"]!)?.noir, for: .normal)
                        }
                        self.names[indexing as! Int]["check"] = "1"
                        self.nextButton.isEnabled = true
                        self.nextButton.alpha = 1
                    } else {
                        self.names[indexing as! Int]["check"] = "0"
                        self.nextButton.isEnabled = false
                        self.nextButton.alpha = 0.5
                    }
                    (bacton as! UIButton).setImage(self.names[indexing as! Int]["check"] == "1" ? UIImage(named: self.names[indexing as! Int]["name"]!) : UIImage(named: self.names[indexing as! Int]["name"]!)?.noir, for: .normal)
                }
            }
                
            
            return optionCell!
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.isPackage ? (indexPath.row == 0 ? "Vip_Cell" : "Check_Out_Cell") : "Check_Out_Book_Cell", for: indexPath)
                
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
