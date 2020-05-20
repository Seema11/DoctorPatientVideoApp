//
//  CallHistoryVC.swift
//  DocotorPatient
//
//  Created by Bhavesh on 02/05/20.
//  Copyright © 2020 Bhavesh. All rights reserved.
//

import UIKit
import Quickblox

class CallHistoryVC: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var historyData : [Any] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.performAPICallforViewHistory()
    }
    
    @IBAction func didTapButtonSideMenu(_ sender: Any) {
        sideMenuController()?.openDrawer()
    }
    @IBAction func didTapButtonSearch(_ sender: Any) {
    }
    @IBAction func didTapButtonCall(_ sender: UIButton) {
        let selectUser : HistoryModel = historyData[sender.tag] as! HistoryModel
        let qbuser = QBUUser()
        qbuser.email = selectUser.email
        qbuser.id = UInt(selectUser.qbuserId!)!
        qbuser.fullName = selectUser.username
        qbuser.login = selectUser.email
        self.callType = selectUser.calltype
        self.dataSource.selectedUsers = [qbuser]
        let opid : NSNumber = NSNumber(value: qbuser.id)
        
        if self.callType == "audio" {
            self.call(with: .audio, op_id: [opid])
        } else {
            self.call(with: .video, op_id: [opid])
        }
        
    }
    
}
extension CallHistoryVC : UITableViewDataSource,UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.historyData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "CallHistoryCell") as! CallHistoryCell
        cell.setUpData(response: historyData[indexPath.section] as! HistoryModel)
        cell.buttonCall.tag = indexPath.section
        return cell
    }
}
extension CallHistoryVC {
    func performAPICallforViewHistory() {
        GeneralUtility.showProcessing()
        let parameter : [String:Any] = ["userid":userData?.id as Any,
                                        "patientid" : "0"]
        ServiceManager.shared.serverCommunicationManager.apiCall(forWebService: EnumWebService.callHistory(parameter)) { (status, message, statusCode, response, error) in
            GeneralUtility.endProcessing()
            if (status){
                self.handleGetHistoryData(response: response as! [Any])
            } else {
                GeneralUtility.showAlert(message: message)
            }
        }
    }
    func handleGetHistoryData(response : [Any]) {
        if let array = response as? [[String: Any]] {
            array.forEach { (dictionary) in
                let historyModel = HistoryModel.mappedObject(dictionary)
//                if !(historyModel.qbuserId!.isEmpty){
                    self.historyData.append(historyModel)
//                }
            }
            self.tableView.reloadData()
            if historyData.count == 0 {
                self.view.showToast(message: "No History Foud")
            }
        }
    }
}
