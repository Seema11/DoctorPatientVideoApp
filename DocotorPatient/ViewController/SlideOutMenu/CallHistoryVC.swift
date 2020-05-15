//
//  CallHistoryVC.swift
//  DocotorPatient
//
//  Created by Bhavesh on 02/05/20.
//  Copyright © 2020 Bhavesh. All rights reserved.
//

import UIKit

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
    @IBAction func didTapButtonCall(_ sender: Any) {
        if #available(iOS 13.0, *) {
                let videoCallVC = self.storyboard?.instantiateViewController(identifier: "VideoCallVC") as! VideoCallVC
                self.navigationController?.pushViewController(videoCallVC, animated: true)
            } else {
                let videoCallVC = UIViewController.instantiateFrom("Menu", "VideoCallVC") as! VideoCallVC
                self.navigationController?.pushViewController(videoCallVC, animated: true)
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
                self.historyData = (response as? [[String : Any]])!
                self.tableView.reloadData()
            } else {
                GeneralUtility.showAlert(message: message)
            }
        }
    }
    func handleGetHistoryData(response : [Any]) {
        if let array = response as? [[String: Any]] {
            array.forEach { (dictionary) in
                let historyModel = HistoryModel.mappedObject(dictionary)
                self.historyData.append(historyModel)
            }
            self.tableView.reloadData()
            if historyData.count == 0 {
                self.view.showToast(message: "No History Foud")
            }
        }
    }
}
