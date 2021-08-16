
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

class Reader_ViewController: UIViewController {

    @objc var config: NSDictionary!

    @IBOutlet var titleLabel: MarqueeLabel!

    @IBOutlet var topView: UIView!

    @IBOutlet var cover: UIImageView!

    @IBOutlet var pageNumber: UILabel!

    @IBOutlet var failLabel: UILabel!

    @IBOutlet var restart: UIButton!

    @IBOutlet var showFull: UIButton!

    @IBOutlet var pdfView: PDFView!

    @IBOutlet var downLoad: DownLoad!

    @IBOutlet var topHeight: NSLayoutConstraint!

    var show: Bool = false
    
    var pdfDocument: PDFDocument!

    enum PDFError: Error {
        case failedToLoadPDFDocument
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        cover.imageUrl(url: config.getValueFromKey("avatar"))

        titleLabel.text = config.getValueFromKey("name")

        downLoad.transform = downLoad.transform.scaledBy(x: 1.2, y: 1.9)

//        pdfView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            pdfView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
//            pdfView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
//            pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            pdfView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
//        ])

        pdfView.pageShadowsEnabled = true
        pdfView.autoScales = true
        pdfView.displaysPageBreaks = false
        pdfView.displayMode = .singlePage
        pdfView.displayDirection = .horizontal
        pdfView.usePageViewController(true, withViewOptions: [
            UIPageViewController.OptionsKey.interPageSpacing: 0
        ])
        pdfView.overrideCenterAlign()
        queueingScrollView?.showsHorizontalScrollIndicator = false
        subscribeToNotifications()
        
        if !self.existingFile(fileName: self.config.getValueFromKey("id")) {
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
        }
        print("Page changed: \(currentPageIndex().map(String.init) ?? "nil")")
    }

    fileprivate var queueingScrollView: UIScrollView? {
        return pdfView.firstSubview(withClassName: "_UIQueuingScrollView") as? UIScrollView
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

    func viewPDF() {
        showHide(show: false)
        let path = self.pdfFile(fileName: self.config.getValueFromKey("id"))
        if let document = PDFDocument(url: URL(fileURLWithPath: path)) {
            self.pdfDocument = document
            self.pageNumber.text = "%i / %i".format(parameters: 1, document.documentRef?.numberOfPages as! CVarArg)
        } else {
            self.failLabel.alpha = 1
            self.failLabel.text = "Không mở được file PDF, mời bạn tải lại."
            self.restart.alpha = 1
            self.cover.alpha = 1
        }
//        self.pdfDocument = PDFDocument(url: URL(fileURLWithPath: path)) {
//            pdfView.autoresizesSubviews = true
//            pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//            pdfView.displayDirection = .horizontal
//            pdfView.displayMode = IS_IPAD ? .twoUpContinuous : .singlePageContinuous
//            pdfView.displaysPageBreaks = false
////            pdfView.scaleFactorForSizeToFit = true
//            pdfView.minScaleFactor = 1.0
//            pdfView.scaleFactor = 0.6
//            pdfView.maxScaleFactor = 4.0
//            pdfView.autoScales = false
//            pdfView.setValue(true, forKey: "forcesTopAlignment")
//            pdfView.displayMode = .singlePageContinuous
//            pdfView.autoScales = true
//            pdfView.translatesAutoresizingMaskIntoConstraints = false
//            pdfView.setValue(true, forKey: "forcesTopAlignment")
//            pdfView.document = pdfDocument
            
//        }
//        else {
//            self.failLabel.alpha = 1
//            self.failLabel.text = "Không mở được file PDF, mời bạn tải lại."
//            self.restart.alpha = 1
//            self.cover.alpha = 1
//        }
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
        if !self.existingFile(fileName: self.config.getValueFromKey("id")) {
           self.deleteFile(fileName: self.pdfFile(fileName: self.config.getValueFromKey("id")))
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
            self.showToast("Không có mục lục", andPos: 0)
        }
    }

    @IBAction func didPressBack() {
       unsubscribeFromNotifications()
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
