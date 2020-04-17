//
//  TG_Room_Cell.swift
//  TourGuide
//
//  Created by Mac on 7/13/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

import FSPagerView

class TG_Room_Cell: UITableViewCell, FSPagerViewDataSource,FSPagerViewDelegate, UITextFieldDelegate {

    var images: NSMutableArray? = []
        
    var config: NSDictionary!

    @IBOutlet var pageControl: UIPageControl!
    
    var returnValue: ((_ value: Float)->())?
       
    var callBack: ((_ info: Any)->())?

    let itemHeight = Int(screenWidth() * 9 / 16)
    
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
            self.pagerView.itemSize = .zero
            self.pagerView.interitemSpacing = 10
            self.pagerView.alwaysBounceHorizontal = true
            self.pagerView.isInfinite = true
            self.pagerView.automaticSlidingInterval = 3
        }
    }
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return self.images!.count
    }
    
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        let image = (images![index] as! NSDictionary).getValueFromKey("avatar")
        cell.imageView?.imageUrl(url: image!)
        cell.imageView?.contentMode = .scaleAspectFill
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        let data = images![index] as! NSDictionary
        callBack?(["selection": data, "data": images])
    }
    
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        guard self.pageControl.currentPage != pagerView.currentIndex else {
            return
        }
        self.pageControl.currentPage = pagerView.currentIndex 
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
                
        self.pageControl.numberOfPages = self.images!.count
        
        if !(self.config["loaded"] as! Bool) {
            requestBanner()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func requestBanner() {
        let request = NSMutableDictionary.init(dictionary: ["session":Information.token ?? "", "overrideAlert":"1"])
        request.addEntries(from: self.config["url"] as! [AnyHashable : Any])
        LTRequest.sharedInstance()?.didRequestInfo((request as! [AnyHashable : Any]), withCache: { (cacheString) in
          }, andCompletion: { (response, errorCode, error, isValid, object) in
              let result = response?.dictionize() ?? [:]
              
              if result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
                  self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
                  return
              }
                                                          
              let data = (result["result"] as! NSArray)

              self.images?.removeAllObjects()

              self.images?.addObjects(from: data as! [Any])

              self.pagerView.reloadData()

              self.pageControl.numberOfPages = self.images!.count
            
              self.returnValue?(Float(self.images?.count == 0 ? 0 : self.itemHeight - 60))
          })
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
