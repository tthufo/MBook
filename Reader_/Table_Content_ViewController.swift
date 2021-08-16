//
//  Table_Content_ViewController.swift
//  HearThis
//
//  Created by Thanh Hai Tran on 8/16/21.
//  Copyright © 2021 Thanh Hai Tran. All rights reserved.
//

import UIKit

class Table_Content_ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var dataList = NSArray()
    
    @objc var callBack: ((_ info: Any)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.withCell("Table_Content_Cell")
        
        print("-->", dataList.count)
        tableView.reloadData()
    }
    
    @IBAction func didPressDismiss() {
        self.dismiss(animated: true, completion: nil)
    }

}

extension Table_Content_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Table_Content_Cell", for: indexPath)

        let data = dataList[indexPath.row] as! NSDictionary
        
        let label = self.withView(cell, tag: 1) as! UILabel
        
        label.text = data.getValueFromKey("Title")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let data = dataList[indexPath.row] as! NSDictionary
        self.didPressDismiss()
        callBack?(data)
    }
}

