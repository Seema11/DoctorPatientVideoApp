//
//  HistoryModel.swift
//  DocotorPatient
//
//  Created by Bhavesh on 15/05/20.
//  Copyright © 2020 Bhavesh. All rights reserved.
//

import UIKit
import ObjectMapper

class HistoryModel: NSObject,Mappable {

    var starttime : String?
    var endtime : String?
    var username : String?
    var email : String?
    var phoneno : String?
    var title : String?
    var qbuserId : String?
    var calltype : String?
    override init() {
        super.init()
    }
    
    convenience required init?(map: Map) {
        self.init()
    }
    
    
    static func mappedObject(_ dictionary : Dictionary<String,Any>) -> HistoryModel {
        return Mapper<HistoryModel>().map(JSON: dictionary)! as HistoryModel
    }
    
    func mapping(map: Map) {
        starttime   <- map["starttime"]
        endtime     <- map["endtime"]
        username    <- map["username"]
        email       <- map["email"]
        phoneno     <- map["phoneno"]
        title       <- map["title"]
        qbuserId    <- map["qbuserId"]
        calltype    <- map["calltype"]
    }
    
    
}
