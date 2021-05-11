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
    
    var dataList = [["image": "https://homepages.cae.wisc.edu/~ece533/images/airplane.png", "title": "sàdsabas ádf ấdưewer ưer f. ádfasf. ádfdfewrewr r ewfadsaf ẻtrt êt ẻt ểtwer ưerew wer rter êtrtr "], ["image": "https://homepages.cae.wisc.edu/~ece533/images/airplane.png", "title": "sàdsaba ưewrwe. ưerew. ửew ưer ưes ádfs sdf à ádf à à"], ["image": "https://homepages.cae.wisc.edu/~ece533/images/airplane.png", "title": "sàdsabas à shttps://homepages.cae.wisc.edu/~ece533/images/airplane.png"], ["image": "https://homepages.cae.wisc.edu/~ece533/images/airplane.png", "title": "sàds abas rtwrwe e rưe rưerwe ấ ádf ádfsad f"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if IS_IPAD {
            sideGapLeft.constant = 100
            
            sideGapRight.constant = 100
        }

        tableView.estimatedRowHeight = 150
        
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.withCell("News_Cell")
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
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "News_Cell", for: indexPath) as! News_Cell
        
        let dict = dataList[indexPath.row]
                
        cell.avatarImage.imageUrl(url: dict["image"]!)
        
        cell.titleLabel.text = dict["title"]!
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
