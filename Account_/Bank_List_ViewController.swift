//
//  Bank_List_ViewController.swift
//  HearThis
//
//  Created by Thanh Hai Tran on 8/15/21.
//  Copyright © 2021 Thanh Hai Tran. All rights reserved.
//

import UIKit

class Bank_List_ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var closeButton: UIButton!

    @IBOutlet var searchView: UITextField!

    var bankList = NSMutableArray()
    
    var tempList: NSMutableArray!
    
    @objc var selectBank: ((_ info: Any)->())?

    override func viewDidLoad() {
        super.viewDidLoad()
                
        tempList = NSMutableArray.init(array: bankList)
                        
        closeButton.setImage(UIImage(named: "ic_close")?.withTintColor(AVHexColor.color(withHexString: "#009BB4")), for: .normal)
        
        self.tableView.withCell("Bank_Cell")
        
        self.tableView.reloadData()
        
        searchView.addTarget(self, action: #selector(textIsChanging), for: .editingChanged)
    }
    
    @objc func textIsChanging(_ textField:UITextField) {
        if searchView.text == "" {
            bankList.removeAllObjects()
            bankList.addObjects(from: tempList as! [Any])
            tableView.reloadData()
            return
        }
        
        let filtered = NSMutableArray.init()
        
        for dict in tempList {
            if (strip((dict as! NSDictionary)["name"] as! String).replacingOccurrences(of: "Đ", with: "D").replacingOccurrences(of: "đ", with: "d")).containsIgnoringCase(find: strip(textField.text!)) {
                filtered.add(dict)
            }
        }
        
        bankList.removeAllObjects()
        bankList.addObjects(from: filtered as! [Any])
        tableView.reloadData()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    let strip: (String) -> String = {
        var mStringRef = NSMutableString(string: $0) as CFMutableString
        CFStringTransform(mStringRef, nil, kCFStringTransformStripCombiningMarks, Bool(truncating: 0))
        return String(mStringRef)
    }
    
    @IBAction func didPressDismiss() {
        bankList.removeAllObjects()
        bankList.addObjects(from: tempList as! [Any])
        tableView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
}

extension Bank_List_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bankList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Bank_Cell", for: indexPath)

        let data = bankList[indexPath.row] as! NSDictionary
        let label = self.withView(cell, tag: 2) as! UILabel
        label.text = data.getValueFromKey("name")
        
        let check = self.withView(cell, tag: 1) as! UIImageView
        check.imageUrlHolder(url: data.getValueFromKey("avatar_url"), holder: "icon_payment_square")

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        self.selectBank!(bankList[indexPath.row])
        
        self.didPressDismiss()
    }
}

