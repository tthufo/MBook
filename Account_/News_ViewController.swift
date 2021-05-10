//
//  News_ViewController.swift
//  HearThis
//
//  Created by Thanh Hai Tran on 5/10/21.
//  Copyright © 2021 Thanh Hai Tran. All rights reserved.
//

import UIKit

class News_ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var sideGapLeft: NSLayoutConstraint!
    
    @IBOutlet var sideGapRight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if IS_IPAD {
            sideGapLeft.constant = 100
            
            sideGapRight.constant = 100
        }

        tableView.estimatedRowHeight = 150
        
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.withCell("Transaction_Cell")
        
        tableView.withCell("Transaction_Fail")
    }
    
    @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension News_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: indexPath.row == 1 ? "Transaction_Cell" : "Transaction_Fail", for: indexPath)
                
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
