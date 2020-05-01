//
//  ServiceManager.swift
//  TemplateProjSwift
//
//  Created by Mac22 on 13/09/18.
//  Copyright © 2018 Mac22. All rights reserved.
//

import Foundation

class ServiceManager {
    
    static let shared = ServiceManager.init()
    
    let serverCommunicationManager: ServerCommunicationManager
    
    init() {
        self.serverCommunicationManager = ServerCommunicationManager.init()
    }
    
}
