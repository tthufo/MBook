//
//  Reader_ViewController.swift
//  HearThis
//
//  Created by Thanh Hai Tran on 4/15/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

import UIKit
import PDFKit
import MarqueeLabel

class Reader_ViewController: UIViewController {

    var config: NSDictionary!
    
    @IBOutlet var titleLabel: MarqueeLabel!
    
    @IBOutlet var topView: UIView!

    @IBOutlet var cover: UIImageView!
    
    @IBOutlet var failLabel: UILabel!
    
    @IBOutlet var restart: UIButton!
    
    @IBOutlet var showFull: UIButton!

    @IBOutlet var pdfView: PDFView!
    
    @IBOutlet var downLoad: DownLoad!
    
    @IBOutlet var topHeight: NSLayoutConstraint!
    
    var show: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cover.imageUrl(url: config.getValueFromKey("avatar"))
        
        titleLabel.text = config.getValueFromKey("name")
        
        downLoad.transform = downLoad.transform.scaledBy(x: 1.2, y: 1.9)
        
        if !self.existingFile(fileName: self.config.getValueFromKey("id")) {
            didDownload()
            showHide(show: true)
        } else {
            viewPDF()
        }
    }
    
    func viewPDF() {
        showHide(show: false)
        let path = self.pdfFile(fileName: self.config.getValueFromKey("id"))
        if let pdfDocument = PDFDocument(url: URL(fileURLWithPath: path)) {
//            pdfView.autoresizesSubviews = true
            pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin, .flexibleLeftMargin]
            pdfView.displayDirection = .horizontal
            pdfView.displayMode = IS_IPAD ? .twoUpContinuous : .singlePageContinuous
            pdfView.displaysPageBreaks = true
            pdfView.minScaleFactor = 1.0
//            pdfView.scaleFactor = 1.0
            pdfView.maxScaleFactor = 4.0
            pdfView.autoScales = true
            pdfView.document = pdfDocument
        } else {
            self.failLabel.alpha = 1
            self.failLabel.text = "Không mở được file PDF, mời bạn tải lại."
            self.restart.alpha = 1
            self.cover.alpha = 1
        }
    }
    
    func didDownload() {
        downLoad.didProgress(["url": self.config.getValueFromKey("file_url") as Any,
                                               "name": self.config.getValueFromKey("id") as Any,
                                               "infor": self.config as Any
            ], andCompletion: { (index, download, object) in
            if index == -1 {
                self.failLabel.alpha = 1
                self.failLabel.text = "Lỗi xảy ra, mời bạn tải lại."
                self.restart.alpha = 1
                self.downLoad.alpha = 0
            }
                
            if index == 0 {
                self.viewPDF()
            }
        })
    }
    
    func showHide(show: Bool) {
        cover.alpha = show ? 1 : 0
        downLoad.alpha = show ? 1 : 0
        pdfView.isHidden = show
    }
    
    @IBAction func didPressRestart() {
        self.restart.alpha = 0
        self.failLabel.alpha = 0
        self.downLoad.alpha = 1
        if !self.existingFile(fileName: self.config.getValueFromKey("id")) {
           self.deleteFile(fileName: self.pdfFile(fileName: self.config.getValueFromKey("id")))
        }
        showHide(show: true)
        self.didDownload()
    }
    
    @IBAction func didPressBack() {
       self.navigationController?.popViewController(animated: true)
        if self.player()?.playState == Pause {
          self.embed()
       }
        if downLoad.percentComplete > 0 && downLoad.percentComplete < 100 {
            downLoad.forceStop()
            if !self.existingFile(fileName: self.config.getValueFromKey("id")) {
                self.deleteFile(fileName: self.pdfFile(fileName: self.config.getValueFromKey("id")))
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    @IBAction func didPressFull() {
        UIView.animate(withDuration: 0.3) {
            self.topHeight.constant = !self.show ? 0 : 64
            self.showFull.alpha = !self.show ? 1 : 0
            self.topView.layoutIfNeeded()
        }
        show = !show
    }
}
