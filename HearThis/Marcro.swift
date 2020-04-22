//
//  Marcro.swift
//  InformationCollector
//
//  Created by thanhhaitran on 5/10/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

import Foundation

import Photos

import PhotosUI

let screenWidth = UIScreen.main.bounds.size.width

let screenHeight = UIScreen.main.bounds.size.height

let IS_IPHONE_4 = screenHeight < 568.0

let IS_IPHONE_5 = screenHeight == 568.0

let IS_IPHONE_6 = screenHeight == 667.0

let IS_IPHONE_6P = screenHeight == 736.0

let IS_IPAD = UIDevice.current.userInterfaceIdiom == .pad

func IS_IPHONE_X () -> Bool {
    var iphoneX = false
    if #available(iOS 11.0, *) {
        if ((UIApplication.shared.keyWindow?.safeAreaInsets.top)! > CGFloat(0.0)) {
            iphoneX = true
        }
    }
    return iphoneX
}

func iOS_VERSION_EQUAL_TO(version: String) -> Bool {
    return UIDevice.current.systemVersion.compare(version, options: NSString.CompareOptions.numeric) == ComparisonResult.orderedSame
}

func iOS_VERSION_GREATER_THAN(version: String) -> Bool {
    return UIDevice.current.systemVersion.compare(version, options: NSString.CompareOptions.numeric) == ComparisonResult.orderedDescending
}

func iOS_VERSION_GREATER_THAN_OR_EQUAL_TO(version: String) -> Bool {
    return UIDevice.current.systemVersion.compare(version, options: NSString.CompareOptions.numeric) != ComparisonResult.orderedAscending
}

func iOS_VERSION_LESS_THAN(version: String) -> Bool {
    return UIDevice.current.systemVersion.compare(version, options: NSString.CompareOptions.numeric) == ComparisonResult.orderedAscending
}

func iOS_VERSION_LESS_THAN_OR_EQUAL_TO(version: String) -> Bool {
    return UIDevice.current.systemVersion.compare(version, options: NSString.CompareOptions.numeric) != ComparisonResult.orderedDescending
}

func root() -> UIViewController {
    let root: AppDelegate = UIApplication.shared.delegate as! AppDelegate

    return (root.window?.rootViewController)!
}

func appDelegate() -> AppDelegate {
//    let delegation: AppDelegate = UIApplication.shared.delegate as! AppDelegate

    return UIApplication.shared.delegate as! AppDelegate
}

//func tabbar() -> TG_Root_ViewController {
//    return (root() as! UINavigationController).viewControllers.first as! TG_Root_ViewController
//}

//func last() -> Bool {
//    return ((((root() as! UINavigationController).viewControllers.last)?.isKind(of: TG_Root_ViewController.self)))!
//}

//func user() -> TG_User_ViewController {
//    return ((root() as! UINavigationController).viewControllers.first as! TG_Root_ViewController).viewControllers?.last as! TG_User_ViewController
//}
//
func logged() -> Bool {
    return Information.token != nil
}

func INFO() -> NSDictionary {
    return Information.userInfo!
}

extension String {
    func replace(target: String, withString: String) -> String {
        return self.replacingOccurrences(of: target, with: withString)
    }
    
//    var htmlToAttributedString: NSAttributedString? {
//            guard let data = data(using: .utf8) else { return NSAttributedString() }
//            do {
//                return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
//            } catch {
//                return NSAttributedString()
//            }
//        }
//    var htmlToString: String {
//        return htmlToAttributedString?.string ?? ""
//    }
}

extension String {
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    func format(parameters: CVarArg...) -> String {
        return String(format: self, arguments: parameters)
    }
    
    func stringImage() -> UIImage {
        let dataDecoded:NSData = NSData(base64Encoded: self, options: NSData.Base64DecodingOptions(rawValue: 0))!
        let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
        return decodedimage
    }
    
    func urlGet(postFix: String) -> String {
        let host = root().infoPlist()["host"]
        return "%@/%@".format(parameters:host as! String, postFix)
    }
    
    func dictionize() -> NSDictionary {
        return (self as NSString).objectFromJSONString() as! NSDictionary
    }
}

extension UIImage {
    func imageString() -> String {
        return (self.jpegData(compressionQuality: 0.5)?.base64EncodedString(options: .endLineWithLineFeed))!
    }

    func fullImageString() -> String {
        let data: Data? = self.jpegData(compressionQuality: 1)
        return (data?.base64EncodedString(options: .endLineWithLineFeed))!
    }
    
    func imageData() -> NSData {
        let data: Data? = self.jpegData(compressionQuality: 0.5)
        return (data! as NSData)
    }
}

extension UIImageView {
    var imageWithFade: UIImage? {
        get{
            return self.image
        }
        set{
            UIView.transition(with: self,
                              duration: 1, options: .transitionCrossDissolve, animations: {
                                self.image = newValue
            }, completion: nil)
        }
    }
    
    @objc func imageUrl (url: String) {
        self.sd_setImage(with: NSURL.init(string: (url as NSString).encodeUrl())! as URL, placeholderImage: UIImage.init(named: "book_cover")) { (image, error, cacheType, url) in
            if error != nil {
                return
            }
            
            if ((image != nil) && cacheType == .none)
            {
                UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    self.image = image
                }, completion: nil)
            }
        }
    }
    
    @objc func imageUrlHolder (url: String, holder: String) {
           self.sd_setImage(with: NSURL.init(string: (url as NSString).encodeUrl())! as URL, placeholderImage: UIImage.init(named: holder)) { (image, error, cacheType, url) in
               if error != nil {
                   return
               }
               
               if ((image != nil) && cacheType == .none)
               {
                   UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve, animations: {
                       self.image = image
                   }, completion: nil)
               }
           }
       }
    
    func imageUrlNoCache (url: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            SDWebImageManager.shared().loadImage(with: NSURL.init(string: (url as NSString).encodeUrl())! as URL, options: .continueInBackground, progress: { (progress, current, url) in
            }) { (img, data, error, cacheType, isDone, url) in
                if error != nil {
                    return
                }
                self.alpha = 0.3
                self.addValue(img?.fullImageString(), andKey: "bbgg")
                Information.saveBG()
                UIView.transition(with: self, duration: 1.5, options: .transitionCrossDissolve, animations: { () -> Void in
                    self.image = img
                    self.alpha = 1
                }, completion: {(done) in
                   }
                )
            }
        })
    }
    
    func imageUrlNoCacheNoSave (url: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            SDWebImageManager.shared().loadImage(with: NSURL.init(string: (url as NSString).encodeUrl())! as URL, options: .continueInBackground, progress: { (progress, current, url) in
            }) { (img, data, error, cacheType, isDone, url) in
                if error != nil {
                    return
                }
                self.alpha = 0.3
                UIView.transition(with: self, duration: 1.0, options: .transitionCrossDissolve, animations: { () -> Void in
                    self.image = img
                    self.alpha = 1
                }, completion: {(done) in
                }
                )
            }
        })
    }
    
    func imageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}

extension Date {
    func dateComp(type: Int) -> String {
        let calendar = Calendar.current
        let time = calendar.dateComponents([.month, .weekday, .day], from: self)
        return "%i".format(parameters: (type == 0 ? time.day : type == 1 ? time.weekday : time.month)!)
    }
}

extension UIImage {
    func toBase64() -> String? {
        guard let imageData = self.pngData() else { return nil }
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
}

extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint.init(x:(labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                               y:(labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let locationOfTouchInTextContainer = CGPoint.init(x:locationOfTouchInLabel.x - textContainerOffset.x,
                                                          y:locationOfTouchInLabel.y - textContainerOffset.y);
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}

extension String {
    var isInt: Bool {
        return Int(self) != nil
    }
    
    var isNumber: Bool {
       return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
    
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
    
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
    
    func index(at position: Int, from start: Index? = nil) -> Index? {
        let startingIndex = start ?? startIndex
        return index(startingIndex, offsetBy: position, limitedBy: endIndex)
    }
    
    func character(at position: Int) -> Character? {
        guard position >= 0, let indexPosition = index(at: position) else {
            return nil
        }
        return self[indexPosition]
    }
}

extension UISearchBar {
    
    func getTextField() -> UITextField? { return value(forKey: "searchField") as? UITextField }
    
    func setClearButton(color: UIColor) {
        getTextField()?.setClearButton(color: color)
    }
}

extension UITextField {
    func modifyClearButtonWithImage(image : UIImage) {
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(image, for: .normal)
        clearButton.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
        clearButton.contentMode = .scaleAspectFit
        clearButton.addTarget(self, action: #selector(self.clear(sender:)), for: .touchUpInside)
        self.rightView = clearButton
        self.rightViewMode = .unlessEditing
    }
    
    @objc func clear(sender : AnyObject) {
        self.text = ""
    }
    
    private class ClearButtonImage {
        static private var _image: UIImage?
        static private var semaphore = DispatchSemaphore(value: 1)
        static func getImage(closure: @escaping (UIImage?)->()) {
            DispatchQueue.global(qos: .userInteractive).async {
                semaphore.wait()
                DispatchQueue.main.async {
                    if let image = _image { closure(image); semaphore.signal(); return }
                    guard let window = UIApplication.shared.windows.first else { semaphore.signal(); return }
                    let searchBar = UISearchBar(frame: CGRect(x: 0, y: -200, width: UIScreen.main.bounds.width, height: 44))
                    window.rootViewController?.view.addSubview(searchBar)
                    searchBar.text = "txt"
                    searchBar.layoutIfNeeded()
                    _image = UIImage(named: "icon_close") // searchBar.getTextField()?.getClearButton()?.image(for: .normal)
                    closure(_image)
                    searchBar.removeFromSuperview()
                    semaphore.signal()
                }
            }
        }
    }
    
    func setClearButton(color: UIColor) {
        ClearButtonImage.getImage { [weak self] image in
            guard   let image = image,
                let button = self?.getClearButton() else { return }
            button.imageView?.tintColor = color
            button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }
    
    func getClearButton() -> UIButton? { return value(forKey: "clearButton") as? UIButton }
}

extension UIViewController {
    
    var isModal: Bool {
        
        let presentingIsModal = presentingViewController != nil
        let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
        let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController
        
        return presentingIsModal || presentingIsNavigation || presentingIsTabBar
    }
    
    func callNumber(phoneNumber: String) {
        
        if let phoneCallURL = URL(string: "telprompt://\(phoneNumber)") {
            
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                if #available(iOS 10.0, *) {
                    application.open(phoneCallURL, options: [:], completionHandler: nil)
                } else {
                    application.openURL(phoneCallURL as URL)
                }
            }
        }
    }
    
    func removeKey(info: NSMutableDictionary) -> NSDictionary {
        (info["url"] as! NSMutableDictionary).removeObjects(forKeys: ["page_index", "page_size"])
        
        return info
    }
    
    func existingFile(fileName: String) -> Bool {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent("video/\(fileName)/\(fileName).pdf") {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
            return true
        } else {
            return false
        }
        } else {
            return false
        }
    }
    
    func pdfFile(fileName: String) -> String {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent("video/\(fileName)/\(fileName).pdf") {
            let filePath = pathComponent.path
            return filePath
        }
        return ""
    }
    
    func deleteFile(fileName: String) {
        guard let fileUrl = URL(string: "\(fileName)") else { return }

        do {
            try FileManager.default.removeItem(at: fileUrl)
            print("Remove successfully")
        }
        catch let error as NSError {
            print("An error took place: \(error)")
        }
    }
    
    func didRequestMP3Link(info: NSDictionary) {
         let request = NSMutableDictionary.init(dictionary: [
                                                             "session":Information.token ?? "",
                                                             "overrideAlert":"1",
                                                             ])
            request["id"] = info.getValueFromKey("id")
            request["CMD_CODE"] = "getBookContent"
         LTRequest.sharedInstance()?.didRequestInfo((request as! [AnyHashable : Any]), withCache: { (cacheString) in
         }, andCompletion: { (response, errorCode, error, isValid, object) in
             let result = response?.dictionize() ?? [:]
             
             if result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
                 self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
                 return
             }
            
            let information = NSMutableDictionary.init(dictionary: info)
            
            information["stream_url"] = (result["result"] as! NSDictionary).getValueFromKey("file_url")
             
            self.startPlaying("", andInfo: (information as! [AnyHashable : Any]))
         })
     }
    
    @objc func didRequestUrl(info: NSDictionary) {
        let request = NSMutableDictionary.init(dictionary: [
                                                            "session":Information.token ?? "",
                                                            "overrideAlert":"1",
                                                            ])
        request["CMD_CODE"] = "getPackageInfo"
        LTRequest.sharedInstance()?.didRequestInfo((request as! [AnyHashable : Any]), withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            print("===========", response)
            let result = response?.dictionize() ?? [:]
            
            if result.getValueFromKey("error_code") != "0" || result["result"] is NSNull {
                self.showToast(response?.dictionize().getValueFromKey("error_msg") == "" ? "Lỗi xảy ra, mời bạn thử lại" : response?.dictionize().getValueFromKey("error_msg"), andPos: 0)
                return
            }
            if !self.checkRegister(package: response?.dictionize()["result"] as! NSArray, type: "AUDIOBOOK") {
                if self.isFullEmbed() {
                    self.goDown()
                }
                self.center()?.pushViewController(Package_ViewController.init(), animated: true)
            } else {
                self.didRequestMP3Link(info: info)
            }
        })
    }
    
    func checkRegister(package: NSArray, type: String) -> Bool {
        var isReg = false //// dev test package change to true
        for dict in package {
            let expDate = ((dict as! NSDictionary).getValueFromKey("expireTime")! as NSString).date(withFormat: "dd-MM-yyyy")
            print("ALLOWING", expDate! > Date())
            if (dict as! NSDictionary).getValueFromKey("status") == "1" && expDate! > Date()
                && (dict as! NSDictionary).getValueFromKey("package_code") == type {
                isReg = true
                break
            }
        }
        return isReg
    }
}

extension UITableView {
    func scrollToBottom(animated: Bool = true, scrollPostion: UITableView.ScrollPosition = .top) {
        let no = self.numberOfRows(inSection: 0)
        if no > 0 {
            let index = IndexPath(row: 0, section: 0)
            scrollToRow(at: index, at: scrollPostion, animated: animated)
        }
    }
}

extension UIImage {
    func alpha(_ value:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

extension UILabel {

    func sizeForString(string: NSString, constrainedToWidth width: Double) -> CGSize {

        return string.boundingRect(
            with: CGSize(
                width: width,
                height: DBL_MAX
            ),
            options: .usesLineFragmentOrigin,
            attributes: [
                NSAttributedString.Key.font : self.font as Any
            ],
            context: nil).size
    }
}

extension PHAsset {

    func getURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
                completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
            })
        } else if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
    }
}

extension String {
    func htmlAttributedString(fontSize: CGFloat = 17.0) -> NSAttributedString? {
        let fontName = UIFont.systemFont(ofSize: fontSize).fontName
        let string = self.appending(String(format: "<style>body{font-family: '%@'; font-size:%fpx;}</style>", fontName, fontSize))
        guard let data = string.data(using: String.Encoding.utf16, allowLossyConversion: false) else { return nil }

        guard let html = try? NSMutableAttributedString (
             data: data,
             options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
             documentAttributes: nil) else { return nil }
        return html
    }
}

extension UIView {
    
    func topRadius() {
        if #available(iOS 11.0, *){
            self.clipsToBounds = false
            self.layer.cornerRadius = 8
            self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }else{
            let rectShape = CAShapeLayer()
            rectShape.bounds = self.frame
            rectShape.position = self.center
            rectShape.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft , .topRight], cornerRadii: CGSize(width: 8, height: 8)).cgPath
            self.layer.mask = rectShape
        }
    }
    
    func image() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
   @objc var heightConstaint: NSLayoutConstraint? {
        get {
            return constraints.first(where: {
                $0.firstAttribute == .height && $0.relation == .equal
            })
        }
        set { setNeedsLayout() }
    }
    
   @objc var widthConstaint: NSLayoutConstraint? {
        get {
            return constraints.first(where: {
                $0.firstAttribute == .width && $0.relation == .equal
            })
        }
        set { setNeedsLayout() }
    }
    
    private struct AssociatedKeys {
        static var descriptiveName = "AssociatedKeys.DescriptiveName.blurView"
    }
    
    private (set) var blurView: BlurView {
        get {
            if let blurView = objc_getAssociatedObject(
                self,
                &AssociatedKeys.descriptiveName
                ) as? BlurView {
                return blurView
            }
            self.blurView = BlurView(to: self)
            return self.blurView
        }
        set(blurView) {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.descriptiveName,
                blurView,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    class BlurView {
        
        private var superview: UIView
        private var blur: UIVisualEffectView?
        private var editing: Bool = false
        private (set) var blurContentView: UIView?
        private (set) var vibrancyContentView: UIView?
        
        var animationDuration: TimeInterval = 0.1
        
        /**
         * Blur style. After it is changed all subviews on
         * blurContentView & vibrancyContentView will be deleted.
         */
        var style: UIBlurEffect.Style = .light {
            didSet {
                guard oldValue != style,
                    !editing else { return }
                applyBlurEffect()
            }
        }
        /**
         * Alpha component of view. It can be changed freely.
         */
        var alpha: CGFloat = 0 {
            didSet {
                guard !editing else { return }
                if blur == nil {
                    applyBlurEffect()
                }
                let alpha = self.alpha
                UIView.animate(withDuration: animationDuration) {
                    self.blur?.alpha = alpha
                }
            }
        }
        
        init(to view: UIView) {
            self.superview = view
        }
        
        func setup(style: UIBlurEffect.Style, alpha: CGFloat) -> Self {
            self.editing = true
            
            self.style = style
            self.alpha = alpha
            
            self.editing = false
            
            return self
        }
        
        func enable(isHidden: Bool = false) {
            if blur == nil {
                applyBlurEffect()
            }
            
            self.blur?.isHidden = isHidden
        }
        
        private func applyBlurEffect() {
            blur?.removeFromSuperview()
            
            applyBlurEffect(
                style: style,
                blurAlpha: alpha
            )
        }
        
        private func applyBlurEffect(style: UIBlurEffect.Style,
                                     blurAlpha: CGFloat) {
            superview.backgroundColor = UIColor.clear
            
            let blurEffect = UIBlurEffect(style: style)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            
            let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
            let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
            blurEffectView.contentView.addSubview(vibrancyView)
            
            blurEffectView.alpha = blurAlpha
            
            superview.insertSubview(blurEffectView, at: 0)
            
            blurEffectView.addAlignedConstrains()
            vibrancyView.addAlignedConstrains()
            
            self.blur = blurEffectView
            self.blurContentView = blurEffectView.contentView
            self.vibrancyContentView = vibrancyView.contentView
        }
    }
    
    private func addAlignedConstrains() {
        translatesAutoresizingMaskIntoConstraints = false
        addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute.top)
        addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute.leading)
        addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute.trailing)
        addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute.bottom)
    }
    
    private func addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute) {
        superview?.addConstraint(
            NSLayoutConstraint(
                item: self,
                attribute: attribute,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: superview,
                attribute: attribute,
                multiplier: 1,
                constant: 0
            )
        )
    }
}

import UIKit

class PaddingLabel: UILabel {

   @IBInspectable var topInset: CGFloat = 7.0
   @IBInspectable var bottomInset: CGFloat = 7.0
   @IBInspectable var leftInset: CGFloat = 7.0
   @IBInspectable var rightInset: CGFloat = 7.0

   override func drawText(in rect: CGRect) {
      let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
      super.drawText(in: rect.inset(by: insets))
   }

   override var intrinsicContentSize: CGSize {
      get {
         var contentSize = super.intrinsicContentSize
         contentSize.height += topInset + bottomInset
         contentSize.width += leftInset + rightInset
         return contentSize
      }
   }
}
