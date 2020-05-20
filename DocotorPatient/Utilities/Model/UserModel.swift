//
//  UserModel.swift
//  DocotorPatient
//
//  Created by Bhavesh on 11/05/20.
//  Copyright © 2020 Bhavesh. All rights reserved.
//

import UIKit
import ObjectMapper

class UserModel: NSObject,Mappable {
    
    var id : String?
    var username : String?
    var email : String?
    var password : String?
    var trn_date : String?
    var phoneno : String?
    var title : String?
    var profileimage : String?
    var QBUserId : String?
    
    // check userdefault have already userdata or not
    static var loginUserModel: UserModel? {
          let userData : [String : Any]? = UserDefaults.getdictionary(forKey: Constant.UserDefaultsKey.userLoginData)
           if userData == nil {
               return nil
           }else {
               let userModel = UserModel.mappedObject(userData!)
               return userModel
           }
       }
    ////////////////////////////////////////////////////////////////////////////////
    
    
    override init() {
        super.init()
    }
    convenience required init?(map: Map) {
        self.init()
    }
    
    static func mappedObject(_ dictionary: Dictionary<String, Any>) -> UserModel {
        return Mapper<UserModel>().map(JSON: dictionary)! as UserModel
    }
    func mapping(map: Map) {
        id            <- map["id"]
        username      <- map["username"]
        email         <- map["email"]
        password      <- map["password"]
        trn_date      <- map["trn_date"]
        phoneno       <- map["phoneno"]
        title         <- map["title"]
        profileimage  <- map["profileimage"]
        QBUserId      <- map["QBUserId"]
        
    }
}
