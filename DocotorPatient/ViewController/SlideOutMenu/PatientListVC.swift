//
//  PatientListVC.swift
//  DocotorPatient
//
//  Created by Bhavesh on 01/05/20.
//  Copyright © 2020 Bhavesh. All rights reserved.
//  //    let dic : [String : Any =["ID":selectUser.id,"fullname":selectUser.username,"email":selectUser.email,"login":selectUser.username]

import UIKit
import Quickblox
import PushKit
import QuickbloxWebRTC


class PatientListVC: BaseViewController {

    var userList : [QBUUser] = []
    var patientList : [PatientListModel] = []
    @IBOutlet weak var buttonMenuView: UIView!
    @IBOutlet weak var buttonSearchView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var labelNodata: UILabel!
    @IBOutlet weak var buttonAdd: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.connectUser()
        self.setupView()
        // Do any additional setup after loading the view.
    }
    
    func setupView() {
        self.labelNodata.isHidden = true
        
//        if userData?.isset == "1" {
//            self.buttonAdd.isHidden = true
//            self.buttonSearchView.isHidden = true
//            self.buttonMenuView.isHidden = true
//        } else {
//            self.buttonAdd.isHidden = true
//            self.buttonSearchView.isHidden = true
//            self.buttonMenuView.isHidden = true
//        }
        
           QBRTCClient.instance().add(self)
          if Reachability.instance.networkConnectionStatus() != NetworkConnectionStatus.notConnection {
             loadUsers()
          }
         voipRegistry.delegate = self
         voipRegistry.desiredPushTypes = Set<PKPushType>([.voIP])
        
      //  perfromApiCallForPatientList()
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
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if userData?.isset == "1" { } else {
            perfromApiCallForPatientList() }
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
        
        let patientdata = patientList[sender.tag]
        self.patientId = patientdata.id
        self.callType = "audio"
        self.patientName = patientdata.username
        
        QBRequest.users(withIDs: [patientdata.qbuserId!], page: nil, successBlock: { (response, page, users) in
            print(users)
            let selectUser : QBUUser = users[0]
            self.dataSource.selectedUsers = [selectUser]
            let opid : NSNumber = NSNumber(value: selectUser.id)
            print("\(opid)")
            self.call(with: .audio, op_id: [opid])
            
        }) { (response) in
            GeneralUtility.showAlert(message: "\(self.errorMessage(response: response) ?? "")")
        }
        
//        let qbuser = QBUUser()
//        qbuser.login = patientdata.email
//        qbuser.fullName = patientdata.username
//        qbuser.id = UInt(patientdata.qbuserId ?? "0") ?? 0
//        self.dataSource.selectedUsers = [qbuser]
//        let opid : NSNumber = NSNumber(value: qbuser.id)
//        print("\(opid)")
//        self.call(with: .audio, op_id: [opid])
        
//        let qbUserId : UInt = UInt(patientdata.qbuserId ?? "0") ?? 0
//        print(qbUserId)
//        QBRequest.user(withID: qbUserId, successBlock: { (response, user) in
//            let selectUser : QBUUser = user
//            self.dataSource.selectedUsers = [selectUser]
//            let opid : NSNumber = NSNumber(value: selectUser.id)
//            print("\(opid)")
//            self.call(with: .audio, op_id: [opid])
//        }) { (response) in
//           GeneralUtility.showAlert(message: "\(self.errorMessage(response: response) ?? "")")
//        }
    }
    @IBAction func didTapButtonVideoCall(_ sender: UIButton) {
       let patientdata = patientList[sender.tag]
       let qbUserId : UInt = UInt(patientdata.qbuserId ?? "0") ?? 0
       self.patientId = patientdata.id
       self.callType = "video"
        QBRequest.users(withIDs: [patientdata.qbuserId!], page: nil, successBlock: { (response, page, users) in
                 print(users)
                 let selectUser : QBUUser = users[0]
                 self.dataSource.selectedUsers = [selectUser]
                 let opid : NSNumber = NSNumber(value: selectUser.id)
                 print("\(opid)")
                 self.call(with: .video, op_id: [opid])
                 
             }) { (response) in
                 GeneralUtility.showAlert(message: "\(self.errorMessage(response: response) ?? "")")
             }
//        QBRequest.user(withID: qbUserId, successBlock: { (response, user) in
//            let selectUser : QBUUser = user
//            self.dataSource.selectedUsers = [selectUser]
//            let opid : NSNumber = NSNumber(value: selectUser.id)
//            print("\(opid)")
//            self.call(with: .video, op_id: [opid])
//        }) { (response) in
//            GeneralUtility.showAlert(message: "\(self.errorMessage(response: response) ?? "")")
//        }
    }
}

extension PatientListVC : UITableViewDataSource,UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.patientList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "PatientListCell") as! PatientListCell
        cell.setUpData(response: patientList[indexPath.section])
      //  let qbuser : QBUUser = self.userList[indexPath.section]
       // cell.labelPatientName.text = qbuser.login
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
                self.handleGetPatientData(response: response as! [Any])
            } else {
                if error == nil {
                    self.labelNodata.isHidden = false
                } else {
                    GeneralUtility.showAlert(message: message)
                }
               
            }
        }
    }
    func handleGetPatientData(response : [Any]) {
         if let array = response as? [[String: Any]] {
            self.patientList.removeAll()
             array.forEach { (dictionary) in
                 let patientModel = PatientListModel.mappedObject(dictionary)
                if !(patientModel.qbuserId!.isEmpty) {
                 self.patientList.append(patientModel)
                }
             }
             
             self.tableView.reloadData()
             if patientList.count == 0 {
                 self.view.showToast(message: "No Patient Foud")
             }
         }
     }
}
