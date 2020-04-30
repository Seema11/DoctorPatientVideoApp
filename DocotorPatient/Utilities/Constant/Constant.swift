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
}
