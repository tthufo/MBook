//
//  User_Infor_ViewController.swift
//  HearThis
//
//  Created by Thanh Hai Tran on 5/3/21.
//  Copyright © 2021 Thanh Hai Tran. All rights reserved.
//

import UIKit

class User_Infor_ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var headerCell: UITableViewCell!
    
    @IBOutlet var inforCell: UITableViewCell!

    @IBOutlet var sideGapLeft: NSLayoutConstraint!
    
    @IBOutlet var sideGapRight: NSLayoutConstraint!
    
    @IBOutlet var login_bg_height: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        if IS_IPAD {
            sideGapLeft.constant = 100
            
            sideGapRight.constant = 100
            
            login_bg_height.constant = 390
        }
    }
    
    @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension User_Infor_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 620 : 255
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return indexPath.row == 0 ? headerCell! : inforCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
