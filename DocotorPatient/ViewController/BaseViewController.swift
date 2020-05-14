//
//  BaseViewController.swift
//  DocotorPatient
//
//  Created by Bhavesh on 14/05/20.
//  Copyright © 2020 Bhavesh. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC

class BaseViewController: UIViewController {

    let userData = UserModel.loginUserModel
    let qbModel = QbUserModel.QBUserModel
    
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
                Constant.appDelegate.showDrawerView()
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
    private func handleError(_ error: Error?, domain: ErrorDomain) {
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
