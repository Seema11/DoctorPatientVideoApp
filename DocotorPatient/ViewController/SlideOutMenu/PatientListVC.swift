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


class PatientListVC: BaseViewController {

    var userList : [QBUUser] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.connectUser()
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
        
        perfromApiCallForPatientList()
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
    func perfromApiCallForPatientList() {
        GeneralUtility.showProcessing()
        ServiceManager.shared.serverCommunicationManager.apiCall(forWebService: EnumWebService.patientList(["userid" : self.userData?.id as Any])) { (status, message, statusCode, response, error) in
            GeneralUtility.endProcessing()
            if (status) {
               print(response)
            } else {
                GeneralUtility.showAlert(message: message)
            }
        }
    }
}
