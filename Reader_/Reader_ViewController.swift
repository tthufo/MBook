//
//  Reader_ViewController.swift
//  HearThis
//
//  Created by Thanh Hai Tran on 4/15/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

import UIKit
import PDFKit

class Reader_ViewController: UIViewController {

    var config: NSDictionary!
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var cover: UIImageView!
    
    @IBOutlet var pdfView: PDFView!
    
    @IBOutlet var downLoad: DownLoad!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cover.imageUrl(url: config.getValueFromKey("avatar"))
        
        titleLabel.text = config.getValueFromKey("name")
        
        if !self.existingFile(fileName: self.config.getValueFromKey("id")) {
            didDownload()
        } else {
            didDownload()

//            let path = self.pdfFile(fileName: self.config.getValueFromKey("id"))
//            if let pdfDocument = PDFDocument(url: URL(fileURLWithPath: path)) {
//                pdfView.displayMode = .singlePageContinuous
//                pdfView.autoScales = true
//                pdfView.displayDirection = .horizontal
//                pdfView.document = pdfDocument
//            }
        }
    }
    
    func didDownload() {
        downLoad = DownLoad.shareInstance()
        downLoad.didProgress(["url": self.config.getValueFromKey("file_url") as Any,
                                               "name": self.config.getValueFromKey("id") as Any,
                                               "infor": self.config as Any
            ], andCompletion: { (index, download, object) in
            print(index)
            print(object)
        })
    }
    
    @IBAction func didPressBack() {
           self.navigationController?.popViewController(animated: true)
       }
}
