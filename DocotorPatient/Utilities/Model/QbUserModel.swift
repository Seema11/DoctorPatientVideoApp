//
//  QbUserModel.swift
//  DocotorPatient
//
//  Created by Bhavesh on 14/05/20.
//  Copyright © 2020 Bhavesh. All rights reserved.
//

import UIKit
import ObjectMapper

class QbUserModel: NSObject,Mappable {

    var ID : UInt?
    var externalUserID : String?
    var facebookID : String?
    var fullname : String?
    var email : String?
    var login : String?
    var phone : String?
    var password : String?
    
    // check userdefault have already userdata or not
     static var QBUserModel: QbUserModel? {
           let userData : [String : Any]? = UserDefaults.getdictionary(forKey: Constant.UserDefaultsKey.QBUserData)
            if userData == nil {
                return nil
            }else {
                let QBUserModel = QbUserModel.mappedObject(userData!)
                return QBUserModel
            }
        }
    
     ////////////////////////////////////////////////////////////////////////////////
    
    override init() {
           super.init()
       }
       convenience required init?(map: Map) {
           self.init()
       }
       
       static func mappedObject(_ dictionary: Dictionary<String, Any>) -> QbUserModel {
           return Mapper<QbUserModel>().map(JSON: dictionary)! as QbUserModel
       }
    
    func mapping(map: Map) {
        
        ID              <- map["ID"]
        externalUserID  <- map["externalUserID"]
        facebookID      <- map["facebookID"]
        fullname        <- map["full name"]
        email           <- map["email"]
        login           <- map["login"]
        phone           <- map["phone"]
        password        <- map["password"]
          
      }

}
