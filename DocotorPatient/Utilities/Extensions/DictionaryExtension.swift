//
//  DictionaryExtension.swift
//  TemplateProjSwift
//
//  Created by Mac22 on 13/09/18.
//  Copyright © 2018 Mac22. All rights reserved.
//

import Foundation

enum TargetType {
    case string
    case integer
    case float
    case array
    case dictionary
    case bool
}

extension Dictionary where Key:Hashable, Value:Any {
    
    static func evaluate(obj: Any?) -> Dictionary<String, Any> {
        if obj != nil {
            if let dictionary = obj as? Dictionary<String, Any> {
                return dictionary
            }
        }
        return [:]
    }
    
    mutating func convertBoolToInt() {
        let boolKeys = self.filter({$0.value is Bool}).map({$0.key})
        boolKeys.forEach { (key) in
            let oldValue = (self[key] as? Bool) ?? false
            let newValue = Int(truncating: NSNumber.init(value: oldValue)) as! Value
            self.updateValue(newValue, forKey: key)
        }
    }
    
    func toString() -> String {
        let jsonData = try? JSONSerialization.data(withJSONObject: self, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        return jsonString ?? ""
    }
    
}
