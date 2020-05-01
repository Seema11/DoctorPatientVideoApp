//
//  GeneralUtility.swift
//  bogo
//
//  Created by flamingo on 12/07/19.
//  Copyright © 2019 Appernaut. All rights reserved.
//
//
//  GeneralUtility.swift
//  TemplateProjSwift
//
//  Created by Mac22 on 24/09/18.
//  Copyright © 2018 Mac22. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices
import AVFoundation

struct GeneralUtility {
    
    private static var npCommonLoaderView: NPCommonLoaderView = {
        let instance = NPCommonLoaderView.init(frame: Constant.appDelegate.window!.bounds)
        instance.behaviour = NPCommonLoaderViewBehaviour.inactiveNavigationBar
        return instance
    }()
    
    static var currentViewController: UIViewController? {
        var currentVC: UIViewController?
        let rootVC = Constant.appDelegate.window?.rootViewController
        if let navController = rootVC as? UINavigationController  {
            currentVC = navController.topViewController
        } else {
            currentVC = rootVC
        }
        return currentVC
    }
    
    
    
    static func showProcessing(withFrame frame: CGRect = Constant.appDelegate.window!.bounds, message:String? = nil) {
          DispatchQueue.main.async {
              GeneralUtility.npCommonLoaderView.showProcessing(withFrame: frame, title: message)
          }
      }
      
      static func endProcessing(completion: (()->())? = nil) {
          DispatchQueue.main.async {
              GeneralUtility.npCommonLoaderView.endProcessing ({
                  completion?()
              })
          }
      }
    static func endAllProcessing(completion: (()->())? = nil) {
        DispatchQueue.main.async {
            GeneralUtility.npCommonLoaderView.endProcessing {
                Constant.appDelegate.window?.removeFromSuperview()
            }
        }
    }
    
    static func showAlert(withTitle title: String = Constant.appDisplayName, message: String, actions:[UIAlertAction] = [], defaultButtonAction:(()->())? = nil) {
        
      //  GeneralUtility.endAllProcessing()
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        if actions.count > 0 {
            for action in actions {
                alertController.addAction(action)
            }
        } else {
            let action = UIAlertAction.init(title: "OK", style: UIAlertAction.Style.default) { (alertAction) in
                defaultButtonAction?()
            }
            alertController.addAction(action)
        }
      UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
     //   GeneralUtility.currentViewController?.present(alertController, animated: true) {
    //    }
        
    }
    
    static func chekLocationPermission() -> Bool {
        
        let permission : Bool = self.chekLocationPermission()
        if permission == true
        {
            return true
        }
        else
        {
            settingAlertViewController()
            return false
        }
    }
    
    static func settingAlertViewController() {
        
        let alertController = UIAlertController.init(title: "Location is disable", message: "We need your location for getting restaurant near by you\n for Enable location CLick on Setting", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        
        DispatchQueue.main.async {
            var presentVC = Constant.appDelegate.window?.rootViewController
            while let next = presentVC?.presentedViewController {
                presentVC = next
            }
            presentVC?.present(alertController, animated: true, completion: nil)
        }
    }
}
extension GeneralUtility {
    
    static func isNonEmptyString(_ text: String?) -> Bool {
        return (text?.count ?? 0) > 0
    }
    
    static func isValidEmail(_ email: String?) -> Bool {
        if (email?.count ?? 0) > 0 {
            let regexPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
            do {
                let regex = try NSRegularExpression.init(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
                let regexMatches = regex.numberOfMatches(in: email!, options: NSRegularExpression.MatchingOptions.init(rawValue: 0), range: NSRange.init(location: 0, length: email!.count))
                if regexMatches == 0 {
                    return false
                } else {
                    return true
                }
            } catch {
                print(error)
            }
        }
        return false
    }
    
}

extension GeneralUtility {
    
    static func openMail(withSenderEmail to: String, subject: String?, body: String?) {
        let stringURL = "mailto:\(to)?subject=\(subject ?? "")&body=\(body ?? "")"
        if let url = URL.init(string: stringURL) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:]) { (_) in
                }
            }
        }
    }
    
    static func shareURL(_ stringURL: String?, sourceView: UIView?) {
        
        if stringURL?.count ?? 0 > 0 {
            let activityViewController = UIActivityViewController.init(activityItems: [stringURL ?? ""], applicationActivities: nil)
            activityViewController.excludedActivityTypes = nil
            activityViewController.popoverPresentationController?.sourceView = sourceView ?? GeneralUtility.currentViewController?.view
            if sourceView != nil {
                activityViewController.popoverPresentationController?.sourceRect = sourceView!.bounds
            }
            activityViewController.popoverPresentationController?.permittedArrowDirections = [.up, .down]
            GeneralUtility.currentViewController?.present(activityViewController, animated: true, completion: nil)
        }
        
    }
    static func getUniqueFilename() -> String {
           let uniqueName = Date.stringDate(fromDate: Date.init(), dateFormat: DateFormat.uniqueString)
           return uniqueName!
       }
       
    
}
extension UIImage
{
    func resizeImage(newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize.init(width: newWidth, height: newHeight))
        self.draw(in: CGRect.init(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        print(newImage ?? "")
        
        return newImage!
    }
    func resizeImageHeightWidth(newWidth: CGFloat,newHeight : CGFloat) -> UIImage {
        
        //        let scale = newWidth / self.size.width
        //         newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize.init(width: newWidth, height: newHeight))
        self.draw(in: CGRect.init(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        print(newImage ?? "")
        
        return newImage!
    }
}

extension UIView {

    func showToast(message : String) {

        let toastLabel = UILabel(frame: CGRect(x: 16, y: self.frame.size.height-100, width: self.frame.size.width - 32, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(1.0)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont.init(name: "System", size: 14)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.2, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
