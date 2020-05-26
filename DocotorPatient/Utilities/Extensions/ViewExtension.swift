//
//  ViewExtension.swift
//  TemplateProjSwift
//
//  Created by Mac22 on 13/09/18.
//  Copyright © 2018 Mac22. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import SDWebImage
import Photos
import MobileCoreServices

extension UIView {
    
    enum GradientLocation {
        case topBottom
        case bottomTop
        case leftRight
        case rightLeft
        
        var locations:[NSNumber] {
            switch self {
            case .topBottom:
                return [0.0, 1.0]
            case .bottomTop:
                return [0.0, 1.0]
            case .leftRight:
                return [0.0, 1.0]
            case .rightLeft:
                return [0.0, 1.0]
            }
        }
        
        var position:(startPosition: CGPoint, endPosition: CGPoint) {
            switch self {
            case .topBottom:
                return (startPosition: CGPoint.init(x: 0, y: 0), endPosition: CGPoint.init(x: 0, y: 1))
            case .bottomTop:
                return (startPosition: CGPoint.init(x: 0, y: 1), endPosition: CGPoint.init(x: 0, y: 0))
            case .leftRight:
                return (startPosition: CGPoint.init(x: 0, y: 1), endPosition: CGPoint.init(x: 1, y: 1))
            case .rightLeft:
                return (startPosition: CGPoint.init(x: 1, y: 1), endPosition: CGPoint.init(x: 0, y: 1))
            }
        }
        
    }
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.applyCornerRadius(radius: newValue)
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            return (self.layer.borderColor != nil) ? UIColor.init(cgColor: self.layer.borderColor!) : nil
        }
        set {
            self.layer.borderColor = newValue?.cgColor
        }
    }
    
    func applyCornerRadius(radius: CGFloat = 8) {
        if radius > 0 {
            self.clipsToBounds = true
        }
        self.layer.cornerRadius = radius
    }
    
    func removeCornerRadius() {
        self.layer.cornerRadius = 0
        self.clipsToBounds = false
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {

            layer.shadowRadius = newValue
        }
    }
    @IBInspectable
    var shadowOffset : CGSize{

        get{
            return layer.shadowOffset
        }set{

            layer.shadowOffset = newValue
        }
    }

    @IBInspectable
    var shadowColor : UIColor{
        get{
            return UIColor.init(cgColor: layer.shadowColor!)
        }
        set {
            layer.shadowColor = newValue.cgColor
        }
    }
    @IBInspectable
    var shadowOpacity : Float {

        get{
            return layer.shadowOpacity
        }
        set {

            layer.shadowOpacity = newValue

        }
    }        
    func applyBorder(_ borderWidth: CGFloat = 1, borderColor: UIColor = UIColor.black) {
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
    }
    
    func applyShadow(withColor color: UIColor, offSetSize: CGSize = CGSize.zero, opacity: Float = 1, radius: CGFloat = 4) {
        self.clipsToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
        self.layer.shadowOffset = offSetSize
        self.layer.masksToBounds = false
    }
    
    func applyShadowWithCornerRadius(_ cornerRadius: CGFloat = 8, color: UIColor, offSetSize: CGSize = CGSize.zero, opacity: Float = 1, radius: CGFloat = 8) {
        self.clipsToBounds = false
        self.layer.cornerRadius = cornerRadius
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
        self.layer.shadowOffset = offSetSize
    }
    
    func applyShadowWithBounds(_ bounds: CGRect, color: UIColor, offSetSize: CGSize = CGSize.zero, opacity: Float = 1, radius: CGFloat = 4) {
        self.clipsToBounds = false
        let shadowPath = UIBezierPath.init(rect: bounds).cgPath
        self.layer.shadowPath = shadowPath
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
        self.layer.shadowOffset = offSetSize
        self.layer.masksToBounds = false
    }
    
    func applyGradient(colors: [UIColor], forGradientLocation gradientLocation: GradientLocation) {
        if colors.count <= 0 {
            return
        }
        if let gradientLayer = self.layer.sublayers?.filter({$0.accessibilityLabel == "gradientLayer"}).first {
            gradientLayer.removeAllAnimations()
            gradientLayer.removeFromSuperlayer()
        }
        let gradientLayer = CAGradientLayer.init()
        gradientLayer.frame = self.bounds
        gradientLayer.accessibilityLabel = "gradientLayer"
        gradientLayer.colors = colors.map({$0.cgColor})
        gradientLayer.startPoint = gradientLocation.position.startPosition
        gradientLayer.endPoint = gradientLocation.position.endPosition
        self.layer.addSublayer(gradientLayer)
    }
    
    func applyDashedBorder(_ borderWidth: CGFloat = 1, borderColor: UIColor = UIColor.black, cornerRadius: CGFloat = 0) {
        
        self.layoutIfNeeded()
        if self.layer.sublayers?.count ?? 0 > 0 {
            let dashedBorderLayer = self.layer.sublayers!.filter({$0 is CAShapeLayer && $0.accessibilityHint == "dashedBorderLayer"}).first
            dashedBorderLayer?.removeFromSuperlayer()
        }
        
        let dashedBorderLayer = CAShapeLayer()
        dashedBorderLayer.accessibilityHint = "dashedBorderLayer"
        dashedBorderLayer.strokeColor = borderColor.cgColor
        dashedBorderLayer.lineDashPattern = [6, 2]
        dashedBorderLayer.frame = self.bounds
        dashedBorderLayer.fillColor = nil
        if cornerRadius > 0 {
            dashedBorderLayer.path = UIBezierPath.init(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath
        } else {
            dashedBorderLayer.path = UIBezierPath(rect: self.bounds).cgPath
        }
        self.layer.addSublayer(dashedBorderLayer)
        
    }
    
    func applyBottomRightLeftCornerWithShadow(_ cornerRadius: CGFloat = 10, color: UIColor) {
        
        self.layoutIfNeeded()
        if self.layer.sublayers?.count ?? 0 > 0 {
            let shadowLayer = self.layer.sublayers!.filter({$0 is CAShapeLayer && $0.accessibilityHint == Constant.View.Layer.shadowLayer}).first
            shadowLayer?.removeFromSuperlayer()
        }
        
        self.clipsToBounds = false
        
        let shadowLayer = CAShapeLayer()
        let shadowBounds = CGRect.init(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        let shadowPath = UIBezierPath(roundedRect: shadowBounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        shadowLayer.accessibilityHint = Constant.View.Layer.shadowLayer
        shadowLayer.path = shadowPath.cgPath
        shadowLayer.fillColor = self.backgroundColor?.cgColor
        
        shadowLayer.shadowColor = color.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        
        let shadowRadius = cornerRadius / 4
        
        shadowLayer.shadowOffset = CGSize(width: 0.0, height: shadowRadius + 2)
        shadowLayer.shadowOpacity = 1.0
        shadowLayer.shadowRadius = shadowRadius
        
        self.layer.insertSublayer(shadowLayer, at: 0)
        
    }
    
    func setEnable(_ isEnable: Bool, withPrimaryColor primaryColor: UIColor = Constant.Color.DarkBlue) {
        DispatchQueue.main.async {
            self.isUserInteractionEnabled = isEnable
            self.backgroundColor = isEnable ? primaryColor : UIColor.gray
        }
    }
    
}

extension UICollectionView {
    
    func reloadInMainQueue() {
        DispatchQueue.main.async {
            self.reloadData()
        }
    }
    
    func reloadItemsInMainQueue(indexPaths: [IndexPath], animation: Bool = true) {
        if animation == true {
            DispatchQueue.main.async {
                self.reloadItems(at: indexPaths)
            }
        } else {
            DispatchQueue.main.async {
                UIView.performWithoutAnimation {
                    self.reloadItems(at: indexPaths)
                }
            }
        }
    }
    
    func registerCell(identifier: String) {
        self.register(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
    }
    
}

//extension UITextField {
    
//    @IBInspectable
//    var rightImage: UIImage? {
//        get {
//            return (self.rightView as? UIImageView)?.image
//        }
//        set {
//            self.setRightImage(newValue)
//        }
//    }
//
//    func setRightImage(_ image: UIImage?) {
//        if image == nil {
//            return
//        }
//
//        let size: CGFloat = 14
//        let padding: CGFloat = self.bounds.height - size
//
//        let imageView = UIImageView.init(frame: CGRect.init(origin: CGPoint.init(x: (padding / 2), y: (padding / 2)), size: CGSize.init(width: size, height: size)))
//        imageView.image = image
//        imageView.backgroundColor = UIColor.clear
//        imageView.contentMode = .scaleAspectFit
//        self.rightViewMode = .always
//        self.rightView = imageView
//    }
//
//    @IBInspectable
//    var attributedPlaceHolder: String? {
//        get {
//            return self.placeholder
//        }
//        set {
//            self.setAttributedPlaceHolder(newValue ?? "")
//        }
//    }
//
//    func setAttributedPlaceHolder(_ string: String, color: UIColor = Constant.Color.DarkBlue) {
//        self.attributedPlaceholder = NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor: self.textColor ?? color])
//    }
//
//    func setAttributedPlaceHolder(withColor color: UIColor = Constant.Color.DarkBlue) {
//        self.setAttributedPlaceHolder(self.placeholder ?? "", color: self.textColor ?? color)
//    }
//
//    func setInputViewDatePicker(target: Any, selector: Selector) {
//        // Create a UIDatePicker object and assign to inputView
//        let screenWidth = UIScreen.main.bounds.width
//        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))//1
//        datePicker.datePickerMode = .date //2
//        datePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -18, to: Date())
//        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: -90, to: Date())
        
//        self.inputView = datePicker //3

        // Create a toolbar and assign it to inputAccessoryView
//        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 44.0)) //4
//        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil) //5
//        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: #selector(tapCancel)) // 6
//        let barButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: selector) //7
//        toolBar.setItems([cancel, flexible, barButton], animated: false) //8
//        self.inputAccessoryView = toolBar //9
        
//    }
    
//    @objc func tapCancel() {
//        self.resignFirstResponder()
//    }
    
//}

extension UISegmentedControl {
    
    @IBInspectable
    var fontSize: CGFloat {
        get {
            let titleTextAttributes = self.titleTextAttributes(for: .normal)
            let font = titleTextAttributes?[NSAttributedString.Key.font] as? UIFont
            return font?.pointSize ?? 17
        }
        set {
            let font = UIFont.font(UIFont.Font.gotham_regular, fontSize: newValue) ?? UIFont.systemFont(ofSize: newValue)
            self.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        }
    }
    
}

extension UIImage {
    
    class func createTabSelectionIndicator(color: UIColor, size: CGSize, lineHeight: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(origin: CGPoint(x: 0,y :size.height - lineHeight), size: CGSize(width: size.width, height: lineHeight)))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    class func downloadImage(fromURL stringURL: String?, progress: ((Int, Int, URL?)->())? = nil, completion:@escaping ((UIImage?, Data?, Error?, Bool)->())) {
        
             SDWebImageDownloader.init().downloadImage(with: URL.init(string: stringURL ?? ""), options: SDWebImageDownloaderOptions.useNSURLCache, progress: { (receivedSize, expectedSize, targetURL) in
                 progress?(receivedSize, expectedSize, targetURL)
             }, completed: { (image, data, error, status) in
                 completion(image, data, error, status)
             })
    }
    
}

extension UIImageView {
    
    func downloadImage(fromURL stringURL: String?, placeHolderImage: UIImage? = nil, completion: ((Bool, UIImage?, Error?, URL?)->())? = nil) {
        // Default cache option is memory
        self.sd_imageIndicator = SDWebImageActivityIndicator.gray
        self.sd_setImage(with: URL.init(string: stringURL ?? ""), placeholderImage: placeHolderImage, options: SDWebImageOptions.refreshCached) { (image, error, imageCacheType, url) in
            var status = false
            if image != nil && error == nil {
                status = true
            } else {
                print("Error downloading image:\n\(stringURL ?? "")\nError: \(error?.localizedDescription ?? "")")
            }
            completion?(status, image, error, url)
        }
        
    }
    
     func image(fromAsset asset: PHAsset?, withActivityIndicator activityIndicator: UIActivityIndicatorView? = nil, completion: ((UIImage?)->())? = nil) {
        
        DispatchQueue.main.async {
            self.image = nil
            activityIndicator?.isHidden = false
            activityIndicator?.startAnimating()
            if asset == nil {
                activityIndicator?.stopAnimating()
                self.image = nil
                completion?(nil)
                return
            }
        }
        
        DispatchQueue.global(qos: .background).async {
            
            let imageManager = PHCachingImageManager.init()
            let imageSize = CGSize(width: asset!.pixelWidth, height: asset!.pixelHeight)
            
            var resizedWidth: CGFloat = 800
            if imageSize.width < resizedWidth {
                resizedWidth = imageSize.width
            }
            
            let ratio = imageSize.width / imageSize.height
            let resizedHeight: CGFloat = resizedWidth / ratio
            
            let resizedSize = CGSize.init(width: resizedWidth, height: resizedHeight)
            
            /* For faster performance, and may be degraded image */
            let options = PHImageRequestOptions()
            options.deliveryMode = .fastFormat
            options.isSynchronous = true
            options.resizeMode = .exact
            
            imageManager.requestImage(for: asset!, targetSize: resizedSize, contentMode: PHImageContentMode.aspectFill, options: options, resultHandler: { (image, dictionaryHasable) in
                DispatchQueue.main.async {
                    activityIndicator?.stopAnimating()
                    self.image = image
                    completion?(image)
                }
                imageManager.stopCachingImagesForAllAssets()
            })
            
        }
        
    }
    
    class func getThumbnailImage(fromURL stringURL: String?, _ completion: @escaping ((UIImage?)->())) {
        
        if stringURL?.count ?? 0 > 0 {
            
            if let url = URL.init(string: stringURL!) {
                
                let asset = AVAsset(url: url)
                let durationSeconds = CMTimeGetSeconds(asset.duration)
                let generator = AVAssetImageGenerator(asset: asset)
                
                generator.appliesPreferredTrackTransform = true
                //                let time = CMTimeMakeWithSeconds(0.5, 600)
                let time = CMTimeMakeWithSeconds(durationSeconds/3.0, preferredTimescale: 600)
                
                generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { (requestedTime, thumbnail, actualTime, result, error) in
                    if thumbnail != nil {
                        let image = UIImage(cgImage: thumbnail!)
                        completion(image)
                        return
                    } else {
                        print("*************** Error generating image: ***************\n\(error?.localizedDescription ?? "")\n****************************************************")
                        completion(nil)
                        return
                    }
                }
                
            } else {
                completion(nil)
                return
            }
            
        } else {
            completion(nil)
            return
        }
        
    }
    
    class func getThumbnailImage(fromURLPath pathURL: URL?, _ completion: @escaping ((UIImage?)->())) {
        
        if let url = pathURL {
            
            let asset = AVAsset(url: url)
            let durationSeconds = CMTimeGetSeconds(asset.duration)
            let generator = AVAssetImageGenerator(asset: asset)
            
            generator.appliesPreferredTrackTransform = true
            //                let time = CMTimeMakeWithSeconds(0.5, 600)
            let time = CMTimeMakeWithSeconds(durationSeconds/3.0, preferredTimescale: 600)
            
            generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { (requestedTime, thumbnail, actualTime, result, error) in
                if thumbnail != nil {
                    let image = UIImage(cgImage: thumbnail!)
                    completion(image)
                    return
                } else {
                    print("*************** Error generating image: ***************\n\(error?.localizedDescription ?? "")\n****************************************************")
                    completion(nil)
                    return
                }
            }
            
        } else {
            completion(nil)
            return
        }
        
    }

    
}

extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(_ label: UILabel, inRange targetRange: NSRange) -> Bool {
        
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
        let textContainerOffset = CGPoint.init(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint.init(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
        
    }
    
}

extension UIApplication {
    var statusBarView: UIView? {
        if #available(iOS 13.0, *) {
            let tag = 38482458
            if let statusBar = self.keyWindow?.viewWithTag(tag) {
                return statusBar
            } else {
                let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
                statusBarView.tag = tag

                self.keyWindow?.addSubview(statusBarView)
                return statusBarView
            }
        } else {
            if responds(to: Selector(("statusBar"))) {
                return value(forKey: "statusBar") as? UIView
            }
        }
        return nil
    }
}

extension UIStoryboard {
    
    class func getLoginScreeenStoryBoard(forIdentifier identifier: String) -> UIViewController {
        let viewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
        return viewController
    }
    
    class func DriveMainStoryBoard(forIdentifier identifier: String) -> UIViewController {
        let viewController = UIStoryboard.init(name: "DriverMain", bundle: nil).instantiateViewController(withIdentifier: identifier)
        return viewController
    }
    class func UserMainStoryBoard(forIdentifier identifier: String) -> UIViewController {
         let viewController = UIStoryboard.init(name: "UserMain", bundle: nil).instantiateViewController(withIdentifier: identifier)
         return viewController
     }
    class func SideMenuStoryBoard(forIdentifier identifier: String) -> UIViewController {
           let viewController = UIStoryboard.init(name: "Menu", bundle: nil).instantiateViewController(withIdentifier: identifier)
           return viewController
       }
    class func getNotificationScreeenStoryBoard(forIdentifier identifier: String) -> UIViewController {
          let viewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
          return viewController
      }
    
}

extension Range where Bound == String.Index {
    var nsRange:NSRange {
        return NSRange(location: self.lowerBound.encodedOffset,
                       length: self.upperBound.encodedOffset -
                        self.lowerBound.encodedOffset)
    }
}

extension UIColor {
    func as1ptImage() -> UIImage {
        UIGraphicsBeginImageContext(CGSize.init(width: 1, height: 1))
        let ctx = UIGraphicsGetCurrentContext()
        self.setFill()
        ctx!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
extension UIView {

  enum Border {
    case left
    case right
    case top
    case bottoms
  }

  func setBorder(border: UIView.Border, weight: CGFloat, color: UIColor ) {

    let lineView = UIView()
    addSubview(lineView)
    lineView.backgroundColor = color
    lineView.translatesAutoresizingMaskIntoConstraints = false

    switch border {

    case .left:
      lineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
      lineView.topAnchor.constraint(equalTo: topAnchor).isActive = true
      lineView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
      lineView.widthAnchor.constraint(equalToConstant: weight).isActive = true

    case .right:
      lineView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
      lineView.topAnchor.constraint(equalTo: topAnchor).isActive = true
      lineView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
      lineView.widthAnchor.constraint(equalToConstant: weight).isActive = true

    case .top:
      lineView.topAnchor.constraint(equalTo: topAnchor).isActive = true
      lineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
      lineView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
      lineView.heightAnchor.constraint(equalToConstant: weight).isActive = true

    case .bottoms:
      lineView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
      lineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
      lineView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
      lineView.heightAnchor.constraint(equalToConstant: weight).isActive = true
    }
  }
}
extension CLLocationManager {
    
    func getCurrenLocation(_ completion : ((Bool ,String, String)-> ())) {
          
        let locManager = CLLocationManager()
        locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
           locManager.requestWhenInUseAuthorization()

                  if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
                      CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
                      guard let currentLocation = locManager.location else {
                        completion(false ,"","")
                          return
                      }
                      print(currentLocation.coordinate.latitude)
                      print(currentLocation.coordinate.longitude)
                   completion(true,"\(currentLocation.coordinate.latitude)","\(currentLocation.coordinate.longitude)")
                  }
       }
}
extension UIImage {

    func toJpegData (compressionQuality: CGFloat, hasAlpha: Bool = true, orientation: Int = 6) -> Data? {
        guard cgImage != nil else { return nil }
        let options: NSDictionary =     [
            kCGImagePropertyOrientation: orientation,
            kCGImagePropertyHasAlpha: hasAlpha,
            kCGImageDestinationLossyCompressionQuality: compressionQuality
        ]
        return toData(options: options, type: .jpeg)
    }

    func toData (options: NSDictionary, type: ImageType) -> Data? {
        guard cgImage != nil else { return nil }
        return toData(options: options, type: type.value)
    }

    // about properties: https://developer.apple.com/documentation/imageio/1464962-cgimagedestinationaddimage
    func toData (options: NSDictionary, type: CFString) -> Data? {
        guard let cgImage = cgImage else { return nil }
        return autoreleasepool { () -> Data? in
            let data = NSMutableData()
            guard let imageDestination = CGImageDestinationCreateWithData(data as CFMutableData, type, 1, nil) else { return nil }
            CGImageDestinationAddImage(imageDestination, cgImage, options)
            CGImageDestinationFinalize(imageDestination)
            return data as Data
        }
    }

    // https://developer.apple.com/documentation/mobilecoreservices/uttype/uti_image_content_types
    enum ImageType {
        case image // abstract image data
        case jpeg                       // JPEG image
        case jpeg2000                   // JPEG-2000 image
        case tiff                       // TIFF image
        case pict                       // Quickdraw PICT format
        case gif                        // GIF image
        case png                        // PNG image
        case quickTimeImage             // QuickTime image format (OSType 'qtif')
        case appleICNS                  // Apple icon data
        case bmp                        // Windows bitmap
        case ico                        // Windows icon data
        case rawImage                   // base type for raw image data (.raw)
        case scalableVectorGraphics     // SVG image
        case livePhoto                  // Live Photo

        var value: CFString {
            switch self {
            case .image: return kUTTypeImage
            case .jpeg: return kUTTypeJPEG
            case .jpeg2000: return kUTTypeJPEG2000
            case .tiff: return kUTTypeTIFF
            case .pict: return kUTTypePICT
            case .gif: return kUTTypeGIF
            case .png: return kUTTypePNG
            case .quickTimeImage: return kUTTypeQuickTimeImage
            case .appleICNS: return kUTTypeAppleICNS
            case .bmp: return kUTTypeBMP
            case .ico: return kUTTypeICO
            case .rawImage: return kUTTypeRawImage
            case .scalableVectorGraphics: return kUTTypeScalableVectorGraphics
            case .livePhoto: return kUTTypeLivePhoto
            }
        }
    }
}
extension UIScrollView {
   func scrollToBottom(animated: Bool) {
     if self.contentSize.height < self.bounds.size.height { return }
     let bottomOffset = CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height)
     self.setContentOffset(bottomOffset, animated: animated)
  }
}
extension UICollectionViewCell {
    func applyShadow() {
        self.contentView.layer.cornerRadius = 2.0;
        self.contentView.layer.borderWidth = 1.0;
        self.contentView.layer.borderColor = UIColor.clear.cgColor;
        self.contentView.layer.masksToBounds = true;

        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize.init(width: 0, height: 2.0)
        self.layer.shadowRadius = 2.0;
        self.layer.shadowOpacity = 1.0;
        self.layer.masksToBounds = false;
        self.layer.shadowPath = UIBezierPath(roundedRect:self.bounds, cornerRadius:self.contentView.layer.cornerRadius).cgPath;
    }
}
extension UIButton {
    func updateLayerProperties() {
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 2.0
        self.layer.masksToBounds = false
    }
        func setImageTintColor(_ color: UIColor) {
            let tintedImage = self.imageView?.image?.withRenderingMode(.alwaysTemplate)
            self.setImage(tintedImage, for: .normal)
            self.tintColor = color
        }

}
extension UIImageView {
    func changeImageColor( color:UIColor) -> UIImage
    {
        image = image!.withRenderingMode(.alwaysTemplate)
        tintColor = color
        return image!
    }
}
