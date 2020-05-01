//
//  ArrayExtension.swift
//  TemplateProjSwift
//
//  Created by Mac22 on 13/09/18.
//  Copyright © 2018 Mac22. All rights reserved.
//

import Foundation

extension Array {
    
    static func evaluate(obj: Any?) -> Array<Any> {
        if obj != nil {
            if let array = obj as? [Any] {
                return array
            }
        }
        return []
    }
    
}
