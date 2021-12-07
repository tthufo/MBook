
extension PDFView {
    func overrideCenterAlign() {
        guard let _centerAlign = class_getInstanceMethod(NSClassFromString("PDFPageViewController"), Selector(extendedGraphemeClusterLiteral: "_centerAlign")) else {
            return
        }
        guard let centerAlign = class_getInstanceMethod(UIViewController.self, #selector(UIViewController.centerAlign)) else {
            return
        }
        method_exchangeImplementations(_centerAlign, centerAlign)
    }
}

fileprivate extension UIViewController {

    @objc dynamic func centerAlign() {
        // We are in the PDFPageViewController's frame of reference now (which is just a UIViewController subclass)
        // Since this method implementation has been swapped, we're actually calling the original implementation of _centerAlign and *not* looping here.
        self.centerAlign()

        guard let pdfScrollView = view.firstSubview(ofType: UIScrollView.self),
            let pdfTextInputView = pdfScrollView.firstSubview(withClassName: "PDFTextInputView"),
            let pdfController = firstResponder(ofType: Reader_ViewController.self)
        else {
            return
        }

        pdfScrollView.alwaysBounceVertical = true
        pdfScrollView.pinchGestureRecognizer?.addTarget(pdfController, action: #selector(Reader_ViewController.handlePDFScrollViewPinch(gesture:)))

        /// The current scale applied to the pdf
        let scale = pdfTextInputView.transform.a
        /// The pdf's frame without any tranforms applied
        let originalFrame = pdfTextInputView.frame.applying(pdfTextInputView.transform.inverted())
        /// The min scale factor where the width of the pdf is the width of the view
        let widthRatio: CGFloat = view.frame.width / originalFrame.width
        /// The scale at which the height of the pdf is the height of the view
        let heightRatio = view.frame.height / originalFrame.height

        // If the pdf is taller than the view
        if originalFrame.height > view.frame.height {
            // If the user is dragging between pages
            // TODO: If the user has zoomed in and scrolled, then begins to page forward/backward but cancels,
            // the pdf will jump and be resized. It isn't occurring due to this logic, I believe that it's from
            // the original implementation when the view settles.
            if let queuingScrollView = pdfController.queueingScrollView, queuingScrollView.isDragging && !queuingScrollView.isDecelerating {
                pdfScrollView.setZoomScale(widthRatio, animated: false)
                pdfScrollView.setContentOffset(.zero, animated: false)
            }
        }
        // Otherwise, the pdf is the as tall or shorter than the view
        else {
            /// The distance between the top of the pdf and the top of the view when the pdf isn't scaled.
            let yOffset = (view.frame.height - (originalFrame.height * widthRatio)) / 2
            /// The distance the pdf should be offset in relation to the current scale
            let scaledTY: CGFloat = yOffset * (1 / scale)

            // Scale the view in the same way that the actual implementation would and apply the vertical translation
            pdfTextInputView.transform = CGAffineTransform
                .identity
                .scaledBy(x: scale, y: scale)
                .translatedBy(x: 0, y: -scaledTY)

            // If the height of the pdf taller than or as tall as the view we need to
            // adjust the transform and shift it down by the original y offset.
            if pdfTextInputView.frame.height >= view.frame.height {
                pdfTextInputView.transform.ty += yOffset
            }
            // Otherwise, the pdf is shorter than the view and we need to scaled the
            // transform adjustment proprotional to the progress of the scale
            else {
                /// The progress of the scale starting at the minScaleFactor moving
                /// towards the scale factor at which the pdf becomes as tall or taller
                /// than the view.
                let progress = (scale - widthRatio) / (heightRatio - widthRatio)
                let scaledAdjustment = yOffset * progress
                pdfTextInputView.transform.ty += scaledAdjustment
            }
        }
    }
}

// MARK: Helpers
extension UIView {
    var allSubviews: Set<UIView> {
        var all = subviews
        for subview in all {
            all.append(contentsOf: subview.allSubviews)
        }
        return Set(all)
    }

    func firstSubview<T>(ofType classType: T.Type) -> T? {
        return allSubviews.first { $0 is T } as? T
    }

    func firstSubview(withClassName className: String) -> UIView? {
        print("-->", allSubviews.first { type(of: $0).description() == className })
        return allSubviews.first { type(of: $0).description() == className }
    }
}

extension UIResponder {
    func firstResponder<T>(ofType classType: T.Type) -> T? {
        var outer = self.next
        while let next = outer {
            if let found = next as? T {
                return found
            }
            outer = next.next
        }
        return nil
    }
}

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
import WebKit

class Reader_ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {

    @objc var config: NSDictionary!
    
    @objc var timer: Timer!

    @IBOutlet var titleLabel: MarqueeLabel!

    @IBOutlet var topView: UIView!

    @IBOutlet var cover: UIImageView!

    @IBOutlet var pageNumber: UILabel!

    @IBOutlet var failLabel: UILabel!

    @IBOutlet var restart: UIButton!

    @IBOutlet var showFull: UIButton!
    
    @IBOutlet var chapter: UIButton!

    @IBOutlet var pdfView: PDFView!

    @IBOutlet var downLoad: DownLoad!

    @IBOutlet var topHeight: NSLayoutConstraint!
    
    @IBOutlet var collectionView: UICollectionView!

    var dataList: NSMutableArray!

    @IBOutlet var reader: UIButton!

    @IBOutlet var activity: UIActivityIndicatorView!

    var isReader: Bool = false
    
    var show: Bool = false
    
    var success: Bool = false
    
    var isRestricted: Bool = false

    var readTime: Int = 0
    
    var currentPage: Int = 0
    
    var pdfDocument: PDFDocument!

    enum PDFError: Error {
        case failedToLoadPDFDocument
    }
    
    @objc func startTimer() {
        if !success {
            return
        }
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func stopTimer() {
        if !success {
            return
        }
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }
    
    @objc func updateTime() {
        readTime += 1
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataList = NSMutableArray()
        
        cover.imageUrl(url: config.getValueFromKey("avatar"))

//        titleLabel.text = config.getValueFromKey("name")
        
        downLoad.transform = downLoad.transform.scaledBy(x: 1.2, y: 1.9)

        collectionView.withCell("Reader_Cell")
        
//        pdfView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            pdfView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
//            pdfView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
//            pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            pdfView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
//        ])

        pdfView.pageShadowsEnabled = false
        pdfView.autoScales = true
        pdfView.displaysPageBreaks = false
        pdfView.displayMode = .singlePage
        pdfView.displayDirection = .horizontal
        pdfView.usePageViewController(true, withViewOptions: [
            UIPageViewController.OptionsKey.interPageSpacing: 0
        ])
//        pdfView.overrideCenterAlign()
        queueingScrollView?.showsHorizontalScrollIndicator = false
        subscribeToNotifications()
        
        if !self.existingFile(fileName: isRestricted ? self.config.getValueFromKey("id") + "_preview" : self.config.getValueFromKey("id")) {
            didDownload()
            showHide(show: true)
        } else {
            viewPDF()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadPDF()
    }

    func loadPDF() {
        pdfView.document = pdfDocument
        pdfView.minScaleFactor = pdfView.scaleFactorForSizeToFit
    }

    func currentPageIndex() -> Int? {
        if pdfDocument != nil {
            return pdfView.currentPage.map(pdfDocument.index) ?? 0
        }
        return 0
    }

    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(pageChanged(notification:)), name: .PDFViewPageChanged, object: pdfView)
    }

    private func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self, name: .PDFViewPageChanged, object: pdfView)
    }

    @objc private func pageChanged(notification: Notification) {
        if currentPageIndex() != nil && self.pdfDocument != nil {
            self.pageNumber.text = "%i / %i".format(parameters: Int(currentPageIndex().map(String.init)!)! + 1 ?? 1, self.pdfDocument.documentRef?.numberOfPages as! CVarArg)
            
            if Int(currentPageIndex().map(String.init)!)! + 1 == self.pdfDocument.documentRef?.numberOfPages {
                if self.isRestricted {
                    self.showRestricted()
                }
            }
        }
        self.currentPage = Int(currentPageIndex().map(String.init)!)!
        print("Page changed: \(currentPageIndex().map(String.init) ?? "nil")")
    }
    
    func showRestricted() {
        EM_MenuView.init(restrict: ["line3": "MUA GÓI"]).disableCompletion { indexing, objc, menu in
            if indexing == 4 {
                self.didPressBuy()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.didPressBack()
                })
            }
        }
    }
    
    @IBAction func didPressBuy() {
        let vip = VIP_ViewController.init()
        vip.callBack = { info in
            print(info)
        }
        let nav = UINavigationController.init(rootViewController: vip)
        nav.isNavigationBarHidden = true
        nav.modalPresentationStyle = .fullScreen
        self.center().present(nav, animated: true, completion: nil)
    }

    fileprivate var queueingScrollView: UIScrollView? {
        return pdfView.firstSubview(withClassName: "_UIQueuingScrollView") as? UIScrollView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSet = scrollView.contentOffset.x
        let width = scrollView.frame.width
        let horizontalCenter = width / 2

        self.currentPage = Int(offSet + horizontalCenter) / Int(width)
        self.pageNumber.text = "%i / %i".format(parameters: self.currentPage + 1, self.pdfDocument.documentRef?.numberOfPages as! CVarArg)
    }

    @objc fileprivate func handlePDFScrollViewPinch(gesture: UIPinchGestureRecognizer) {
        guard gesture.state == .ended else {
            return
        }
        guard let pdfScrollView = gesture.view as? UIScrollView else {
            return
        }
        let snapScaleFactor = pdfView.minScaleFactor
        let threshold: CGFloat = 0.08
        let snapRange = (snapScaleFactor - threshold ... snapScaleFactor + threshold)
        if snapRange.contains(pdfScrollView.zoomScale) {
            pdfScrollView.setZoomScale(snapScaleFactor, animated: true)
        }
    }

    func pdfToText(fromPDF: String) -> String {
        let docContent = NSMutableAttributedString()
        if let pdf = PDFDocument(url: URL(fileURLWithPath: fromPDF)) {
            let pageCount = pdf.pageCount

            for i in 1 ..< pageCount {
                guard let page = pdf.page(at: i) else { continue }
                guard let pageContent = page.attributedString else { continue }
                docContent.append(pageContent)
            }
        }

        return docContent.string
    }
    
    func readerMode(document: PDFDocument) {
        let pageCount = document.pageCount
        for i in 0 ..< pageCount {
            guard let page = document.page(at: i) else { continue }
            guard let pageContent = page.string else { continue }
            self.dataList.add(pageContent)
        }
    }
    
    @IBAction func didPressReader() {
        self.collectionView.isHidden = isReader
        isReader = !isReader
        if isReader {
            self.collectionView.isPagingEnabled = false
            let indexPath = IndexPath(item: self.currentPage, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            self.collectionView.isPagingEnabled = true
        } else {
            let pagePdf = self.pdfDocument.page(at: self.currentPage)
            self.pdfView.go(to: pagePdf!)
        }
    }
    
    func viewPDF() {
        showHide(show: false)
        let path = self.pdfFile(fileName: isRestricted ? self.config.getValueFromKey("id") + "_preview" : self.config.getValueFromKey("id"))
        if let document = PDFDocument(url: URL(fileURLWithPath: path)) {
            self.pdfDocument = document
            self.pageNumber.text = "%i / %i".format(parameters: 1, document.documentRef?.numberOfPages as! CVarArg)
            self.chapter.isEnabled = true
            self.pageNumber.isHidden = false
            self.success = true
            self.startTimer()
            DispatchQueue.background(delay: 0.1, background: {
                self.readerMode(document: document)
            }, completion: {
                self.activity.stopAnimating()
                self.reader.isHidden = self.dataList.count == 0 ? true : false
                self.collectionView.reloadData()
            })
        } else {
            self.failLabel.alpha = 1
            self.failLabel.text = "Không mở được file PDF, mời bạn tải lại."
            self.restart.alpha = 1
            self.cover.alpha = 1
        }
    }

    func didDownload() {
        downLoad.didProgress(["url": self.config.getValueFromKey("file_url") as Any,
                              "name": isRestricted ? self.config.getValueFromKey("id") + "_preview" : self.config.getValueFromKey("id") as Any,
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
//                self.subscribeToNotifications()
                self.loadPDF()
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
        if !self.existingFile(fileName: isRestricted ? self.config.getValueFromKey("id") + "_preview" : self.config.getValueFromKey("id")) {
            self.deleteFile(fileName: self.pdfFile(fileName: isRestricted ? self.config.getValueFromKey("id") + "_preview" : self.config.getValueFromKey("id")))
        }
        showHide(show: true)
        self.didDownload()
    }
    
    @IBAction func didPressContent() {
        if let dict = pdfDocument.documentRef?.outline as? [String: AnyObject] {
            let content = Table_Content_ViewController.init()
            let nav = UINavigationController.init(rootViewController: content)
            nav.isNavigationBarHidden = true
            nav.modalPresentationStyle = .fullScreen
            content.dataList = dict["Children"] as! NSArray
            content.callBack = { data in
                let pageIndex = (data as! NSDictionary)["Destination"]
                let pagePdf = self.pdfDocument.page(at: pageIndex as! Int)
                self.pdfView.go(to: pagePdf!)
            }
            self.present(nav, animated: true, completion: nil)
        } else {
            self.showToast("Sách không có danh sách mục lục", andPos: 0)
        }
    }
    
    @IBAction func didPressBack() {
       unsubscribeFromNotifications()
        self.stopTimer()
        self.didRequestLogTime()
       self.navigationController?.popViewController(animated: true)
        if self.player()?.playState == Pause {
          self.embed()
       }
       if downLoad.percentComplete > 0 && downLoad.percentComplete < 100 {
            downLoad.forceStop()
           if !self.existingFile(fileName: isRestricted ? self.config.getValueFromKey("id") + "_preview" : self.config.getValueFromKey("id")) {
               self.deleteFile(fileName: self.pdfFile(fileName: isRestricted ? self.config.getValueFromKey("id") + "_preview" : self.config.getValueFromKey("id")))
            }
        }
    }
    
    @objc func didRequestLogTime() {
        if readTime == 0 {
            return
        }
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"pushReadingLog",
                                                    "header":["session":Information.token == nil ? "" : Information.token!],
                                                    "session":Information.token ?? "",
                                                    "item_id":self.config.getValueFromKey("id") ?? "",
                                                    "start_time":NSString().currentDate("HH:mm dd/MM/yyyy")!,
                                                    "time":readTime,
                                                    "overrideAlert":"1",
                                                    "overrideLoading":"1",
                                                    "host":self], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
            
            if result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
                self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
                return
            }
        })
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    @IBAction func didPressFull() {
//        UIView.animate(withDuration: 0.3) {
//            self.topHeight.constant = !self.show ? 0 : 64
//            self.showFull.alpha = !self.show ? 1 : 0
//            self.topView.layoutIfNeeded()
//        }
//        show = !show
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Int(self.screenWidth()), height: Int(self.screenHeight()) - 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Reader_Cell", for: indexPath as IndexPath)
        
            let data = dataList[indexPath.item] as! String

            let title = self.withView(cell, tag: 11) as! UITextView
                    
        title.setContentOffset(.zero, animated: false)
        title.text = data
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
}
