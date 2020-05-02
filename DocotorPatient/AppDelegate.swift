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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.setupIQKeyboard()
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
}
extension AppDelegate {

fileprivate func checkLoginAndSetRootController() {
    if (UserDefaults.getBool(forKey: Constant.UserDefaultsKey.isLogin)) {
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
