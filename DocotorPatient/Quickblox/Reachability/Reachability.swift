//
//  Reachability.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 3/11/19.
//  Copyright © 2019 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox
import SVProgressHUD
import SystemConfiguration

enum NetworkConnectionStatus: UInt {
    case notConnection
    case viaWiFi
    case viaWWAN
}

typealias NetworkStatusBlock = ((_ status: NetworkConnectionStatus) -> Void)?

class Reachability: NSObject {
    // MARK: shared Instance
    static let instance: Reachability = {
        let instance = Reachability()
        instance.commonInit()
        return instance
    }()
    
    //MARK: - Properties
    var networkStatusBlock: NetworkStatusBlock?
    private var currentReachabilityFlags: SCNetworkReachabilityFlags?
    private let reachabilitySerialQueue = DispatchQueue.main
    var reachabilityRef: SCNetworkReachability?
    
    // MARK: - Common Init
    private func commonInit() {
        QBSettings.autoReconnectEnabled = true
        self.startReachabliyty()
    }
    
    // MARK: - Reachability
    /**
     *  Cheker for internet connection
     */
    public func networkConnectionStatus() -> NetworkConnectionStatus {
        let status: NetworkConnectionStatus = .notConnection
        if let reachabilityRef = reachabilityRef {
            var flags: SCNetworkReachabilityFlags = []
            if SCNetworkReachabilityGetFlags(reachabilityRef, &flags) {
                return self.networkStatusForFlags(flags)
            }
        }
        return status
    }
    
    private func networkStatusForFlags(_ flags: SCNetworkReachabilityFlags) -> NetworkConnectionStatus {
        if flags.contains(.reachable) == false {
            return .notConnection
        }
        else if flags.contains(.isWWAN) == true {
            return .viaWWAN
        }
        else if flags.contains(.connectionRequired) == false {
            return .viaWiFi
        }
        else if (flags.contains(.connectionOnDemand) == true
            || flags.contains(.connectionOnTraffic) == true)
            && flags.contains(.interventionRequired) == false {
            return .viaWiFi
        }
        else {
            return .notConnection
        }
    }
    
    private func checkReachability(flags: SCNetworkReachabilityFlags) {
        if currentReachabilityFlags != flags {
            currentReachabilityFlags = flags
            reachabilityChanged(flags)
        }
    }
    
    private func startReachabliyty() {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        self.reachabilityRef = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        })
        
        guard let defaultRouteReachability = self.reachabilityRef else {
            return
        }
        
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        context.info = UnsafeMutableRawPointer(Unmanaged<Reachability>.passUnretained(self).toOpaque())
        
        let callbackClosure: SCNetworkReachabilityCallBack? = {
            (reachability:SCNetworkReachability, flags: SCNetworkReachabilityFlags, info: UnsafeMutableRawPointer?) in
            guard let info = info else {
                return
            }
            let handler = Unmanaged<Reachability>.fromOpaque(info).takeUnretainedValue()
            
            DispatchQueue.main.async {
                handler.checkReachability(flags: flags)
            }
        }
        
        if SCNetworkReachabilitySetCallback(defaultRouteReachability, callbackClosure, &context) {
            if (SCNetworkReachabilitySetDispatchQueue(defaultRouteReachability, self.reachabilitySerialQueue)) {
            }
            else {
                SCNetworkReachabilitySetCallback(defaultRouteReachability, nil, nil);
            }
        }
    }
    
    func reachabilityChanged(_ flags: SCNetworkReachabilityFlags) {
        DispatchQueue.main.async(execute: { [weak self] in
            guard let self = self,
                let networkStatusBlock = self.networkStatusBlock else {
                    return
            }
            networkStatusBlock?(self.networkStatusForFlags(flags))
        })
    }
    
    class func isConnectedToNetwork() -> Bool {

          var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
          zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
          zeroAddress.sin_family = sa_family_t(AF_INET)

          let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
              $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                  SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
              }
          }

          var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
          if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
              return false
          }

          /* Only Working for WIFI
          let isReachable = flags == .reachable
          let needsConnection = flags == .connectionRequired

          return isReachable && !needsConnection
          */

          // Working for Cellular and WIFI
          let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
          let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
          let ret = (isReachable && !needsConnection)

          return ret

      }
}

