//
//  AppDelegate.swift
//  DocotorPatient
//
//  Created by Bhavesh on 30/04/20.
//  Copyright © 2020 Bhavesh. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Reachability
import Firebase
import Quickblox
import QuickbloxWebRTC
import SVProgressHUD


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    
     
    lazy private var backgroundTask: UIBackgroundTaskIdentifier = {
        let backgroundTask = UIBackgroundTaskIdentifier.invalid
        return backgroundTask
    }()
    var isCalling = false {
           didSet {
               if UIApplication.shared.applicationState == .background,
                   isCalling == false {
                   disconnect()
               }
           }
       }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.setupIQKeyboard()
        self.setupQuickBlox()
   //     checkLoginAndSetRootController()
        self.loginViewController()
        // Override point for customization after application launch.
        return true
    }

}

extension AppDelegate {
    
    func setupIQKeyboard() {
           IQKeyboardManager.shared.enable = true
           IQKeyboardManager.shared.enableAutoToolbar = true
           IQKeyboardManager.shared.placeholderColor = Constant.Color.DarkBlue
       }
    
    func setRootViewController(_ viewController: UIViewController) {
         if let navController = self.window?.rootViewController as? UINavigationController {
             navController.viewControllers = [viewController]
             self.window?.rootViewController = navController
         } else {
             self.window?.rootViewController = viewController
         }
         self.window?.makeKeyAndVisible()
     }
    func showDrawerView() {
         let vc = UIViewController.instantiateFrom("Menu", "BBDrawerController")
       self.window = self.window ?? UIWindow()
        // Set this scene's window's background color.
        self.window!.backgroundColor = UIColor.clear
        if #available(iOS 13.0, *) {
                     // Always adopt a light interface style.
                     vc.overrideUserInterfaceStyle = .light
                 }
        // Create a ViewController object and set it as the scene's window's root view controller.
        self.window!.rootViewController = vc

        // Make this scene's window be visible.
        self.window!.makeKeyAndVisible()
     }
   
    func loginViewController()
    {
        let vc = UIViewController.instantiateFrom("Main", "ViewController")
        let nvc = UINavigationController(rootViewController: vc)
        nvc.isNavigationBarHidden = true
        if #available(iOS 13.0, *) {
                        // Always adopt a light interface style.
                        nvc.overrideUserInterfaceStyle = .light
                    }
        window?.rootViewController = nvc
        window?.makeKeyAndVisible()
    }
    
    func setupQuickBlox() {
        QBSettings.applicationID = Constant.QuickBlox.applicationID
        QBSettings.authKey = Constant.QuickBlox.authKey
        QBSettings.authSecret = Constant.QuickBlox.authSecret
        QBSettings.accountKey = Constant.QuickBlox.accountKey
        QBSettings.autoReconnectEnabled = true
        QBSettings.logLevel = QBLogLevel.debug
        QBSettings.enableXMPPLogging()
        QBRTCConfig.setAnswerTimeInterval(Constant.TimeIntervalConstant.answerTimeInterval)
        QBRTCConfig.setDialingTimeInterval(Constant.TimeIntervalConstant.dialingTimeInterval)
        QBRTCConfig.setLogLevel(QBRTCLogLevel.verbose)
        
        if Constant.AppDelegateConstant.enableStatsReports == 1 {
            QBRTCConfig.setStatsReportTimeInterval(1.0)
        }
        
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.clear)
        QBRTCClient.initializeRTC()
    }
    
    
}
extension AppDelegate {

fileprivate func checkLoginAndSetRootController() {
    
    if UserModel.loginUserModel != nil || QbUserModel.QBUserModel != nil {
            print("User logged in")
              self.showDrawerView()
         } else {
              self.loginViewController()
         }
  }
}
extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print(#function,"\n\(notification.request.content.userInfo)")
        
         let userInfo = notification.request.content.userInfo
        
        if let messageID = userInfo[gcmMessageIDKey] {
             print("Message ID: \(messageID)")
           }

           // Print full message.
           print(userInfo)
        
        completionHandler([.alert, .badge, .sound])
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("\n************ FCM Token ************\n\(fcmToken)\n***********************************\n")
        UserDefaults.saveString(fcmToken, forKey: Constant.UserDefaultsKey.fcmToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(#function,"\n\(userInfo)")
        //        self.setBadgeCount()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(#function,"\n\(error)")
    }
    
}


// Mark : Notification Click
extension AppDelegate {
    
    fileprivate func handleRemoteNotificationResponse(_ response: [AnyHashable : Any]) {
        print(#function)
//        if let postID = (response[Constant.NotificationResponse.post_id] as? String)?.toInt() {
//            self.navigateToPost(withPostID: postID)
//        }
    }
}
extension AppDelegate {
    
        func pushMethod(){
            FirebaseApp.configure()
                   
                   Messaging.messaging().delegate = self
                   
                   if #available(iOS 10.0, *) {
                     // For iOS 10 display notification (sent via APNS)
                       UNUserNotificationCenter.current().delegate = self

                     let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                     UNUserNotificationCenter.current().requestAuthorization(
                       options: authOptions,
                       completionHandler: {_, _ in })
                   } else {
                     let settings: UIUserNotificationSettings =
                     UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
                    UIApplication.shared.registerUserNotificationSettings(settings)
                   }

                    UIApplication.shared.registerForRemoteNotifications()
        }
}
extension AppDelegate {
    func applicationDidEnterBackground(_ application: UIApplication) {
          // Logging out from chat.
          if isCalling == false {
              disconnect()
          }
      }
      
      func applicationWillEnterForeground(_ application: UIApplication) {
          // Logging in to chat.
          if QBChat.instance.isConnected == true {
              return
          }
          connect { (error) in
              if let error = error {
                  SVProgressHUD.showError(withStatus: error.localizedDescription)
                  return
              }
              SVProgressHUD.showSuccess(withStatus: "Connected")
          }
      }
      
      func applicationWillTerminate(_ application: UIApplication) {
          // Logging out from chat.
          disconnect()
      }
      
      //MARK: - Connect/Disconnect
      func connect(completion: QBChatCompletionBlock? = nil) {
          let currentUser = Profile()
          guard currentUser.isFull == true else {
              completion?(NSError(domain: LoginConstant.chatServiceDomain,
                                  code: LoginConstant.errorDomaimCode,
                                  userInfo: [
                                      NSLocalizedDescriptionKey: "Please enter your login and username."
                  ]))
              return
          }
          if QBChat.instance.isConnected == true {
              completion?(nil)
          } else {
              QBSettings.autoReconnectEnabled = true
              QBChat.instance.connect(withUserID: currentUser.ID, password: currentUser.password, completion: completion)
          }
      }
      
      func disconnect(completion: QBChatCompletionBlock? = nil) {
          QBChat.instance.disconnect(completionBlock: completion)
      }
}
