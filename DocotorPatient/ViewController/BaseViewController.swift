//
//  BaseViewController.swift
//  DocotorPatient
//
//  Created by Bhavesh on 14/05/20.
//  Copyright © 2020 Bhavesh. All rights reserved.
//

import UIKit
import Quickblox
import PushKit
import QuickbloxWebRTC

class BaseViewController: UIViewController {
    
    let userData = UserModel.loginUserModel
    let qbModel = QbUserModel.QBUserModel
    var startTime : String?
    var endTime : String?
    var patientId : String?
    var qbuserID : String?
    var callType : String?
    var patientName : String?
    
    //MARK: - Properties
    var dataSource: UsersDataSource = {
        let dataSource = UsersDataSource()
        return dataSource
    }()
    
    var navViewController: UINavigationController = {
        let navViewController = UINavigationController()
        return navViewController
        
    }()
    
    var session: QBRTCSession?
    var voipRegistry: PKPushRegistry = {
        let voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
        return voipRegistry
    }()
    var callUUID: UUID?
    var backgroundTask: UIBackgroundTaskIdentifier = {
        let backgroundTask = UIBackgroundTaskIdentifier.invalid
        return backgroundTask
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

// Connect to server For Chat
extension BaseViewController {
    func connectUser() {
        QBChat.instance.connect(withUserID: qbModel?.ID ?? 0, password: qbModel?.password ?? "", completion: { (error) in
            GeneralUtility.endProcessing()
            if error == nil {
                print("connected")
                GeneralUtility.endProcessing()
                //did Login action
                //       Constant.appDelegate.showDrawerView()
                //self.performApiCallforLogin()
            } else {
                if error?._code == QBResponseStatusCode.unAuthorized.rawValue {
                    // Clean profile
                    GeneralUtility.endProcessing()
                    Profile.clearProfile()
                    GeneralUtility.showAlert(message: "Connection Failed")
                } else {
                    self.handleError(error, domain: ErrorDomain.logIn)
                    // self.disconnectUser()
                }
                print(error as Any)
            }
        })
    }
    func handleError(_ error: Error?, domain: ErrorDomain) {
        GeneralUtility.endProcessing()
        guard let error = error else {
            return
        }
        var infoText = error.localizedDescription
        self.view.showToast(message: infoText)
        if error._code == NSURLErrorNotConnectedToInternet {
            infoText = LoginConstant.checkInternet
        }
    }
    
}

extension BaseViewController {
    
    func hasConnectivity() -> Bool {
        
        let status = Reachability.instance.networkConnectionStatus()
        guard status != NetworkConnectionStatus.notConnection else {
            GeneralUtility.showAlert(message: UsersAlertConstant.checkInternet)
            if CallKitManager.instance.isCallStarted() == false {
                CallKitManager.instance.endCall(with: callUUID) {
                    debugPrint("[UsersViewController] endCall")
                }
            }
            return false
        }
        return true
    }
    
    func cancelCallAlert() {
        let alert = UIAlertController(title: UsersAlertConstant.checkInternet, message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel) { (action) in
            
            CallKitManager.instance.endCall(with: self.callUUID) {
                debugPrint("[UsersViewController] endCall")
                
            }
            self.prepareCloseCall()
        }
        alert.addAction(cancelAction)
        present(alert, animated: false) {
        }
    }
    
    //Handle Error
    func errorMessage(response: QBResponse) -> String? {
        var errorMessage : String
        if response.status.rawValue == 502 {
            errorMessage = "Bad Gateway, please try again"
        } else if response.status.rawValue == 0 {
            errorMessage = "Connection network error, please try again"
        } else {
            guard let qberror = response.error,
                let error = qberror.error else {
                    return nil
            }
            
            errorMessage = error.localizedDescription.replacingOccurrences(of: "(",
                                                                           with: "",
                                                                           options:.caseInsensitive,
                                                                           range: nil)
            errorMessage = errorMessage.replacingOccurrences(of: ")",
                                                             with: "",
                                                             options: .caseInsensitive,
                                                             range: nil)
        }
        return errorMessage
    }
    func prepareCloseCall() {
        
        if self.session?.conferenceType == .audio {
            self.callType = "audio"
        } else {
            self.callType = "video"
        }
        
        self.qbuserID = "\(session?.opponentsIDs[0] ?? 0)"
        
        self.endTime = Date.getCurrentDateyyyyMMdd()
    
        self.performApiCallforAddHistory()
        self.callUUID = nil
        self.session = nil
        if QBChat.instance.isConnected == false {
            self.connectToChat()
        }
    }
    
    func connectToChat() {
        let profile = Profile()
        guard profile.isFull == true else {
            return
        }
        
        QBChat.instance.connect(withUserID: profile.ID,
                                password: profile.password,
                                completion: { [weak self] error in
                                    guard let self = self else { return }
                                    if let error = error {
                                        if error._code == QBResponseStatusCode.unAuthorized.rawValue {
                                            self.disconnectUser()
                                        } else {
                                            debugPrint("[UsersViewController] login error response:\n \(error.localizedDescription)")
                                        }
                                    } else {
                                        //did Login action
                                    }
        })
    }
}

extension BaseViewController: QBRTCClientDelegate {
    func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        if CallKitManager.instance.isCallStarted() == false && self.session?.id == session.id && self.session?.initiatorID == userID {
            CallKitManager.instance.endCall(with: callUUID) {
                debugPrint("[UsersViewController] endCall")
            }
            prepareCloseCall()
        }
    }
    
    func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil) {
        if self.session != nil {
            session.rejectCall(["reject": "busy"])
            return
        }
        
        self.session = session
        let uuid = UUID()
        callUUID = uuid
        var opponentIDs = [session.initiatorID]
        let profile = Profile()
        guard profile.isFull == true else {
            return
        }
        for userID in session.opponentsIDs {
            if userID.uintValue != profile.ID {
                opponentIDs.append(userID)
            }
        }
        
        var callerName = ""
        var opponentNames = [String]()
        var newUsers = [NSNumber]()
        for userID in opponentIDs {
            
            // Getting recipient from users.
            if let user = dataSource.user(withID: userID.uintValue),
                let fullName = user.fullName {
                opponentNames.append(fullName)
            } else {
                newUsers.append(userID)
            }
        }
        
        if newUsers.isEmpty == false {
            let loadGroup = DispatchGroup()
            for userID in newUsers {
                loadGroup.enter()
                dataSource.loadUser(userID.uintValue) { (user) in
                    if let user = user {
                        opponentNames.append(user.fullName ?? user.login ?? "")
                    } else {
                        opponentNames.append("\(userID)")
                    }
                    loadGroup.leave()
                }
            }
            loadGroup.notify(queue: DispatchQueue.main) {
                callerName = opponentNames.joined(separator: ", ")
                self.reportIncomingCall(withUserIDs: opponentIDs, outCallerName: callerName, session: session, uuid: uuid)
            }
        } else {
            callerName = opponentNames.joined(separator: ", ")
            self.reportIncomingCall(withUserIDs: opponentIDs, outCallerName: callerName, session: session, uuid: uuid)
        }
    }
    
    func reportIncomingCall(withUserIDs userIDs: [NSNumber], outCallerName: String, session: QBRTCSession, uuid: UUID) {
        if hasConnectivity() {
            CallKitManager.instance.reportIncomingCall(withUserIDs: userIDs,
                                                       outCallerName: outCallerName,
                                                       session: session,
                                                       uuid: uuid,
                                                       onAcceptAction: { [weak self] in
                                                        guard let self = self else {
                                                            return
                                                        }
                                                        
                                                        
                                                        let vc : VideoCallVC?
                                                                         
                                                                         if #available(iOS 13.0, *) {
                                                                             vc  = UIStoryboard.init(name: "Call", bundle: Bundle.main).instantiateViewController(identifier: "VideoCallVC") as? VideoCallVC
                                                                         } else {
                                                                             
                                                                             vc = UIViewController.instantiateFrom("Menu", "VideoCallVC") as? VideoCallVC
                                                                             // Fallback on earlier versions
                                                                         }
                                                        
                                                        let callViewController = vc
                                                        callViewController?.session = session
                                                        callViewController?.usersDataSource = self.dataSource
                                                        callViewController?.callUUID = self.callUUID
                                                        callViewController?.patientName = self.patientName
                                                        self.navViewController = UINavigationController(rootViewController: callViewController!)
                                                        
                                                        self.navViewController.modalTransitionStyle = .crossDissolve
                                                        self.present(self.navViewController , animated: false)
                                                        
                                                        
                }, completion: { (end) in
                    debugPrint("[UsersViewController] endCall")
            })
        } else {
            
        }
    }
    
    func sessionDidClose(_ session: QBRTCSession) {
        if let sessionID = self.session?.id,
            sessionID == session.id {
            if self.navViewController.presentingViewController?.presentedViewController == self.navViewController {
                self.navViewController.view.isUserInteractionEnabled = false
                self.navViewController.dismiss(animated: false)
            }
            CallKitManager.instance.endCall(with: self.callUUID) {
                debugPrint("[UsersViewController] endCall")
                
            }
            prepareCloseCall()
        }
    }
}

extension BaseViewController: PKPushRegistryDelegate {
    // MARK: - PKPushRegistryDelegate
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        guard let deviceIdentifier = UIDevice.current.identifierForVendor?.uuidString else {
            return
        }
        let subscription = QBMSubscription()
        subscription.notificationChannel = .APNSVOIP
        subscription.deviceUDID = deviceIdentifier
        subscription.deviceToken = pushCredentials.token
        
        QBRequest.createSubscription(subscription, successBlock: { response, objects in
            debugPrint("[UsersViewController] Create Subscription request - Success")
        }, errorBlock: { response in
            debugPrint("[UsersViewController] Create Subscription request - Error")
        })
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        guard let deviceIdentifier = UIDevice.current.identifierForVendor?.uuidString else {
            return
        }
        QBRequest.unregisterSubscription(forUniqueDeviceIdentifier: deviceIdentifier, successBlock: { response in
            debugPrint("[UsersViewController] Unregister Subscription request - Success")
        }, errorBlock: { error in
            debugPrint("[UsersViewController] Unregister Subscription request - Error")
        })
    }
    
    func pushRegistry(_ registry: PKPushRegistry,
                      didReceiveIncomingPushWith payload: PKPushPayload,
                      for type: PKPushType) {
        if payload.dictionaryPayload[UsersConstant.voipEvent] != nil {
            let application = UIApplication.shared
            if application.applicationState == .background && backgroundTask == .invalid {
                backgroundTask = application.beginBackgroundTask(expirationHandler: {
                    application.endBackgroundTask(self.backgroundTask)
                    self.backgroundTask = UIBackgroundTaskIdentifier.invalid
                })
            }
            if QBChat.instance.isConnected == false {
                connectToChat()
            }
        }
    }
}
extension BaseViewController {
    
    func call(with conferenceType: QBRTCConferenceType , op_id : [NSNumber] ) {
        
        if session != nil {
            return
        }
        
        if hasConnectivity() {
            CallPermissions.check(with: conferenceType) { granted in
                if granted {
                    let opponentsIDs = self.dataSource.ids(forUsers: self.dataSource.selectedUsers)
                    //Create new session
                    
                    let session = QBRTCClient.instance().createNewSession(withOpponents: opponentsIDs, with: conferenceType)
                    if session.id.isEmpty == false {
                        self.session = session
                        let uuid = UUID()
                        self.callUUID = uuid
                
                        CallKitManager.instance.startCall(withUserIDs: opponentsIDs, session: session, uuid: uuid)
                        
                        
                        let vc : VideoCallVC?
                        
                        if #available(iOS 13.0, *) {
                            vc  = UIStoryboard.init(name: "Menu", bundle: Bundle.main).instantiateViewController(identifier: "VideoCallVC") as? VideoCallVC
                        } else {
                            
                            vc = UIViewController.instantiateFrom("Menu", "VideoCallVC") as? VideoCallVC
                            // Fallback on earlier versions
                        }
                        self.startTime = Date.getCurrentDateyyyyMMdd()
                        if let callViewController = vc {
                            callViewController.session = self.session
                            callViewController.usersDataSource = self.dataSource
                            callViewController.callUUID = uuid
                            callViewController.patientName = self.patientName
                            let nav = UINavigationController(rootViewController: callViewController)
                            nav.modalTransitionStyle = .crossDissolve
                            self.present(nav , animated: false)
                            self.navViewController = nav
                        }
                        let profile = Profile()
                        guard profile.isFull == true else {
                            return
                        }
                        let opponentName = profile.fullName.isEmpty == false ? profile.fullName : "Unknown user"
                        let payload = ["message": "\(opponentName) is calling you.",
                            "ios_voip": "1", UsersConstant.voipEvent: "1"]
                        let data = try? JSONSerialization.data(withJSONObject: payload,
                                                               options: .prettyPrinted)
                        var message = ""
                        if let data = data {
                            message = String(data: data, encoding: .utf8) ?? ""
                        }
                        let event = QBMEvent()
                        event.notificationType = QBMNotificationType.push
                        let arrayUserIDs = opponentsIDs.map({"\($0)"})
                        event.usersIDs = arrayUserIDs.joined(separator: ",")
                        event.type = QBMEventType.oneShot
                        event.message = message
                        QBRequest.createEvent(event, successBlock: { response, events in
                            debugPrint("[UsersViewController] Send voip push - Success")
                        }, errorBlock: { response in
                            debugPrint("[UsersViewController] Send voip push - Error")
                        })
                    } else {
                        GeneralUtility.showAlert(message: UsersAlertConstant.shouldLogin)
                    }
                }
            }
        }
    }
}
extension BaseViewController {
    func performApiCallforAddHistory()  {

       // GeneralUtility.showProcessing()
        let parameter : [String:Any] = [ "userid": userData?.id as Any,
                                         "patientid": "21",//self.patientId as Any,
                                         "starttime": self.startTime as Any,
                                         "endtime": self.endTime as Any,
                                         "qbuserId": self.qbuserID as Any,
                                         "calltype": self.callType as Any]
        
        print(parameter)
        
        ServiceManager.shared.serverCommunicationManager.apiCall(forWebService: EnumWebService.addCallHistory(parameter)) { (status, message, statusCode, response, error) in
            GeneralUtility.endProcessing()
            if (status) {
              //  GeneralUtility.showAlert(message: message)
            } else {
               // GeneralUtility.showAlert(message: message)
            }
        }
        
    }
}
