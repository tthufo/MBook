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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.withCell("TG_Room_Cell")

        tableView.withCell("TG_Room_Cell_0")
        
        tableView.withCell("TG_Room_Cell_1")

        tableView.withCell("TG_Room_Cell_2")

        tableView.withCell("TG_Room_Cell_3")

        tableView.withCell("TG_Room_Cell_4")

        tableView.withCell("TG_Room_Cell_5")

        dataList = NSMutableArray.init()
        
        config = NSArray.init(array: [["url": "", "height": 0], ["url": "", "height": 0, "direction": "vertical"], ["url": "", "height": 0, "direction": "horizontal"], ["url": "", "height": 0, "direction": "vertical"], ["url": "", "height": 0, "direction": "horizontal"], ]).withMutable() as NSArray?
    }
    
    @IBAction func didPressMenu() {
        self.root()?.toggleLeftPanel(nil)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: indexPath.row == 0 ? "TG_Room_Cell" :    "TG_Room_Cell_%i".format(parameters: indexPath.row) , for: indexPath)
        
        if(indexPath.row == 0) {
            (cell as! TG_Room_Cell).returnValue = { value in
                (self.config[indexPath.row] as! NSMutableDictionary)["height"] = value
                tableView.reloadData()
            }
            (cell as! TG_Room_Cell).callBack = { info in
                print("--->", info)
               }
        } else {
            (cell as! TG_Room_Cell_N).config = config[indexPath.row] as! NSDictionary
            (cell as! TG_Room_Cell_N).returnValue = { value in
                (self.config[indexPath.row] as! NSMutableDictionary)["height"] = value
                tableView.reloadData()
            }
            (cell as! TG_Room_Cell_N).callBack = { info in
                print("--->", info)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}

