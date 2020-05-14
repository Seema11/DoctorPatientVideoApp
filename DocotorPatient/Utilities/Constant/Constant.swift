//
//  Constant.swift
//  DocotorPatient
//
//  Created by Bhavesh on 30/04/20.
//  Copyright © 2020 Bhavesh. All rights reserved.
//

import Foundation
import UIKit


struct Constant {
    
    static let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    static let appDisplayName: String = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? ""
    static let appVersionNumber: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    static let appBuildNumber: String = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String ?? ""
    
    static let navigationTitleAppName: String = Constant.appDisplayName
    
    
    static let googleApiKey : String = "AIzaSyBHBVzMxi_uL5HTUEd2Sc_vByz3WfqtU10"
    
    //   static let googleApiKey : String = "AIzaSyD7FE3V5sVtXzTbRjmliopODUzj4h6K1Qg"
    
    /*Bogo API Key*/
    //   static let googleApiKey : String = "AIzaSyCIferHmKtuJQP09j6wybvXE-VYzRUlACo"
    
    
    struct QuickBlox {
        static let applicationID:UInt = 82027
        static let authKey = "smbLb6S3PBtuyCP"
        static let authSecret = "QCe8HJwnEhZKABE"
        static let accountKey = "5YPWWfM81yFFASUEd1mF"
    }
    
    struct TimeIntervalConstant {
        static let answerTimeInterval: TimeInterval = 60.0
        static let dialingTimeInterval: TimeInterval = 5.0
    }

    struct AppDelegateConstant {
        static let enableStatsReports: UInt = 1
    }

    struct Device {
        #if targetEnvironment(simulator)
        static let isSimulator = true
        #else
        static let isSimulator = false
        #endif
        static let isIpad = (UIDevice.current.userInterfaceIdiom == .pad) ? true : false
        static let isIphone = (UIDevice.current.userInterfaceIdiom == .phone) ? true : false
    }
    
    struct View {
        struct Layer {
            static let shadowLayer = "shadowLayer"
        }
    }

}
extension Constant {
    
    struct Color {
        static let DarkBlue: UIColor = UIColor.init(named: "DarkBlue")!
        static let GreenButton: UIColor = UIColor.init(named: "GreenButton")!
        static let LightBlue: UIColor = UIColor.init(named: "LightBlue")!
    }
    
      struct UserDefaultsKey {
            static let authorization = "Authorization"
            static let fcmToken = "fcmToken"
            static let isLogin = "isLogin"
            static let _id = "_id"
            static let password = "password"
            static let userLoginData = "UserLoginData"
            static let QBUserData = "QBUserData"
        }
}
struct LoginConstant {
    static let notSatisfyingDeviceToken = "Invalid parameter not satisfying: deviceToken != nil"
    static let enterToChat = NSLocalizedString("Enter to Video Chat", comment: "")
    static let fullNameDidChange = NSLocalizedString("Full Name Did Change", comment: "")
    static let login = NSLocalizedString("Login", comment: "")
    static let checkInternet = NSLocalizedString("Please check your Internet connection", comment: "")
    static let enterUsername = NSLocalizedString("Please enter your login and username.", comment: "")
    static let shouldContainAlphanumeric = NSLocalizedString("Field should contain alphanumeric characters only in a range 3 to 20. The first character must be a letter.", comment: "")
    static let shouldContainAlphanumericWithoutSpace = NSLocalizedString("Field should contain alphanumeric characters only in a range 8 to 15, without space. The first character must be a letter.", comment: "")
    static let showUsers = "ShowUsersViewController"
    static let defaultPassword = "quickblox"
    static let infoSegue = "ShowInfoScreen"
    static let chatServiceDomain = "com.q-municate.chatservice"
    static let errorDomaimCode = -1000
}

enum ErrorDomain: UInt {
    case signUp
    case logIn
    case logOut
    case chat
}

struct LoginStatusConstant {
    static let signUp = "Signg up ..."
    static let intoChat = "Login in progress ..."
    static let withCurrentUser = "Login with current user ..."
}

struct LoginNameRegularExtention {
    static let user = "^[^_][\\w\\u00C0-\\u1FFF\\u2C00-\\uD7FF\\s]{2,19}$"
    static let passord = "^[a-zA-Z][a-zA-Z0-9]{4,14}$"
}

