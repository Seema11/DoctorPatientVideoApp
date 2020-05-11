//
//  PatientListVC.swift
//  DocotorPatient
//
//  Created by Bhavesh on 01/05/20.
//  Copyright © 2020 Bhavesh. All rights reserved.
//

import UIKit
import Quickblox
import PushKit
import QuickbloxWebRTC


class PatientListVC: UIViewController {

    var userList : [QBUUser] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Properties
    lazy private var dataSource: UsersDataSource = {
        let dataSource = UsersDataSource()
        return dataSource
    }()

    lazy private var navViewController: UINavigationController = {
           let navViewController = UINavigationController()
           return navViewController
           
       }()
       private weak var session: QBRTCSession?
       lazy private var voipRegistry: PKPushRegistry = {
           let voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
           return voipRegistry
       }()
       private var callUUID: UUID?
       lazy private var backgroundTask: UIBackgroundTaskIdentifier = {
           let backgroundTask = UIBackgroundTaskIdentifier.invalid
           return backgroundTask
       }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        // Do any additional setup after loading the view.
    }
    
    func setupView() {
          QBRTCClient.instance().add(self)
         if Reachability.instance.networkConnectionStatus() != NetworkConnectionStatus.notConnection {
             loadUsers()
         }
         voipRegistry.delegate = self
         voipRegistry.desiredPushTypes = Set<PKPushType>([.voIP])
     }
    
    @objc func loadUsers() {
        let firstPage = QBGeneralResponsePage(currentPage: 1, perPage: 100)
        QBRequest.users(withExtendedRequest: ["order": "desc date updated_at"],
                        page: firstPage,
                        successBlock: { [weak self] (response, page, users) in
                            self?.userList = users
                         //   self?.dataSource.update(users: users)
                            self?.tableView.reloadData()
            }, errorBlock: { response in
                GeneralUtility.showAlert(message: "\(self.errorMessage(response: response) ?? "")")
                debugPrint("[UsersViewController] loadUsers error: \(self.errorMessage(response: response) ?? "")")
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           
           //MARK: - Reachability
           let updateConnectionStatus: ((_ status: NetworkConnectionStatus) -> Void)? = { [weak self] status in
               let notConnection = status == .notConnection
               if notConnection == true {
                   self?.cancelCallAlert()
               } else {
                   self?.loadUsers()
               }
           }
           Reachability.instance.networkStatusBlock = { status in
               updateConnectionStatus?(status)
           }
           navigationController?.isToolbarHidden = true
       }
       
       override func viewWillDisappear(_ animated: Bool) {
           super.viewWillDisappear(animated)
           
           navigationController?.isToolbarHidden = true
       }

    @IBAction func didTapButtonMenu(_ sender: Any) {
        sideMenuController()?.openDrawer()
    }
    @IBAction func didTapButtonSearch(_ sender: Any) {
    }
    @IBAction func didTapButtonAddPatient(_ sender: Any) {
        if #available(iOS 13.0, *) {
          let signupVc = self.storyboard?.instantiateViewController(identifier: "AddNewPatientVC") as! AddNewPatientVC
          self.navigationController?.pushViewController(signupVc, animated: true)

             } else {
                 let signupVc = UIViewController.instantiateFrom("Menu", "AddNewPatientVC") as! AddNewPatientVC
                 self.navigationController?.pushViewController(signupVc, animated: true)
             }
    }
    @IBAction func didTapButtonAudoiCall(_ sender: UIButton) {
        
        let selectUser : QBUUser = userList[sender.tag]
         self.dataSource.selectedUsers = [selectUser]
        let opid : NSNumber = NSNumber(value: selectUser.id)
        self.call(with: .audio, op_id: [opid])
    }
    @IBAction func didTapButtonVideoCall(_ sender: UIButton) {
        
       let selectUser : QBUUser = userList[sender.tag]
        self.dataSource.selectedUsers = [selectUser]
               let opid : NSNumber = NSNumber(value: selectUser.id)
               self.call(with: .video, op_id: [opid])
        
//           if #available(iOS 13.0, *) {
//                    let videoCallVC = self.storyboard?.instantiateViewController(identifier: "VideoCallVC") as! VideoCallVC
//
//                    self.navigationController?.pushViewController(videoCallVC, animated: true)
//
//                } else {
//                    let videoCallVC = UIViewController.instantiateFrom("Menu", "VideoCallVC") as! VideoCallVC
//
//                    self.navigationController?.pushViewController(videoCallVC, animated: true)
//                }
    }
    
}
extension PatientListVC : UITableViewDataSource,UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.userList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "PatientListCell") as! PatientListCell
        let qbuser : QBUUser = self.userList[indexPath.section]
        cell.labelPatientName.text = qbuser.login
        cell.buttonAudioCall.tag = indexPath.section
        cell.buttonVideoCall.tag = indexPath.section
        return cell
    }
}
extension PatientListVC {
    
    private func hasConnectivity() -> Bool {
        
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
    
    private func cancelCallAlert() {
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
      private func errorMessage(response: QBResponse) -> String? {
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
    private func prepareCloseCall() {
          self.callUUID = nil
          self.session = nil
          if QBChat.instance.isConnected == false {
              self.connectToChat()
          }
      }
    
    private func connectToChat() {
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

extension PatientListVC: QBRTCClientDelegate {
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
    
    private func reportIncomingCall(withUserIDs userIDs: [NSNumber], outCallerName: String, session: QBRTCSession, uuid: UUID) {
        if hasConnectivity() {
            CallKitManager.instance.reportIncomingCall(withUserIDs: userIDs,
                                                       outCallerName: outCallerName,
                                                       session: session,
                                                       uuid: uuid,
                                                       onAcceptAction: { [weak self] in
                                                        guard let self = self else {
                                                            return
                                                        }
                                                        
                                                        
                                                        let callViewController : CallViewController?
                                                                              
                                                                              if #available(iOS 13.0, *) {
                                                                                  callViewController  = UIStoryboard.init(name: "Call", bundle: Bundle.main).instantiateViewController(identifier: "CallViewController") as? CallViewController
                                                                              } else {
                                                                                  
                                                                                  callViewController = UIViewController.instantiateFrom("Call", "CallViewController") as? CallViewController
                                                                                  // Fallback on earlier versions
                                                                              }
                                                        
                                                      
                                                        callViewController?.session = session
                                                        callViewController?.usersDataSource = self.dataSource
                                                        callViewController?.callUUID = self.callUUID
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

extension PatientListVC: PKPushRegistryDelegate {
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
extension PatientListVC {
    
    private func call(with conferenceType: QBRTCConferenceType , op_id : [NSNumber] ) {
        
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
                        
                        
                        let vc : CallViewController?
                        
                        if #available(iOS 13.0, *) {
                            vc  = UIStoryboard.init(name: "Call", bundle: Bundle.main).instantiateViewController(identifier: "CallViewController") as? CallViewController
                        } else {
                            
                            vc = UIViewController.instantiateFrom("Call", "CallViewController") as? CallViewController
                            // Fallback on earlier versions
                        }
                        
                        if let callViewController = vc {
                            callViewController.session = self.session
                            callViewController.usersDataSource = self.dataSource
                            callViewController.callUUID = uuid
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
