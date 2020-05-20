//
//  PatientListModel.swift
//  DocotorPatient
//
//  Created by Bhavesh on 14/05/20.
//  Copyright © 2020 Bhavesh. All rights reserved.
//

import UIKit
import ObjectMapper

class PatientListModel: NSObject,Mappable {
     var id : String?
     var username : String?
     var email : String?
     var phoneno : String?
     var title : String?
     var userid : String?
     var roomno : String?
    var qbuserId : String?
     var trn_date : String?
    
    override init() {
        super.init()
    }
    
    required convenience init?(map: Map) {
        self.init()
      }
    
    static func mappedObject(_ dictionary: Dictionary<String, Any>) -> PatientListModel {
        return Mapper<PatientListModel>().map(JSON: dictionary)! as PatientListModel
    }
    
    func mapping(map: Map) {
          id          <- map["id"]
          username    <- map["username"]
          email       <- map["email"]
          phoneno     <- map["phoneno"]
          title       <- map["title"]
          userid      <- map["userid"]
          roomno      <- map["roomno"]
          qbuserId    <- map["qbuserId"]
          trn_date    <- map["trn_date"]
      }


}
