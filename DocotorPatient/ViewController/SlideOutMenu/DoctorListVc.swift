//
//  DoctorListVc.swift
//  DocotorPatient
//
//  Created by Bhavesh on 21/05/20.
//  Copyright © 2020 Bhavesh. All rights reserved.
//

import UIKit
import QuickbloxWebRTC
import Quickblox
import PushKit

class DoctorListVc: BaseViewController {

    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelDoctorName: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.connectUser()
        self.setupView()
        // Do any additional setup after loading the view.
    }
    

        func setupView() {
        
               QBRTCClient.instance().add(self)
              if Reachability.instance.networkConnectionStatus() != NetworkConnectionStatus.notConnection {
              }
             voipRegistry.delegate = self
             voipRegistry.desiredPushTypes = Set<PKPushType>([.voIP])
            
          //  perfromApiCallForPatientList()
         }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           
           //MARK: - Reachability
           let updateConnectionStatus: ((_ status: NetworkConnectionStatus) -> Void)? = { [weak self] status in
               let notConnection = status == .notConnection
               if notConnection == true {
                   self?.cancelCallAlert()
               } else {

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
    
    @IBAction func didTapButttonSideMenu(_ sender: Any) {
         sideMenuController()?.openDrawer()
    }
    
    @IBAction func didTapButtonAudioCall(_ sender: Any) {
        let qbUserId = self.userData!.qbuserId ?? "0"
        QBRequest.users(withIDs: [qbUserId], page: nil, successBlock: { (response, page, users) in
                       print(users)
                       let selectUser : QBUUser = users[0]
                       self.dataSource.selectedUsers = [selectUser]
                       let opid : NSNumber = NSNumber(value: selectUser.id)
                       print("\(opid)")
                       self.call(with: .audio, op_id: [opid])

                   }) { (response) in
                       GeneralUtility.showAlert(message: "\(self.errorMessage(response: response) ?? "")")
                   }


//           QBRequest.user(withID: qbUserId, successBlock: { (response, user) in
//               let selectUser : QBUUser = user
//               self.dataSource.selectedUsers = [selectUser]
//               let opid : NSNumber = NSNumber(value: selectUser.id)
//               print("\(opid)")
//               self.call(with: .audio, op_id: [opid])
//           }) { (response) in
//              GeneralUtility.showAlert(message: "\(self.errorMessage(response: response) ?? "")")
//           }
    }
    
    @IBAction func didTapButtonVideoCall(_ sender: Any) {
            let qbUserId = self.userData!.qbuserId ?? "0"
           
               QBRequest.users(withIDs: [qbUserId], page: nil, successBlock: { (response, page, users) in
                          print(users)
                          let selectUser : QBUUser = users[0]
                          self.dataSource.selectedUsers = [selectUser]
                          let opid : NSNumber = NSNumber(value: selectUser.id)
                          print("\(opid)")
                          self.call(with: .video, op_id: [opid])

                      }) { (response) in
                          GeneralUtility.showAlert(message: "\(self.errorMessage(response: response) ?? "")")
                      }
    }
}
