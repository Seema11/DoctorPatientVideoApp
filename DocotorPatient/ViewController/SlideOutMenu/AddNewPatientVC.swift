//
//  AddNewPatientVC.swift
//  DocotorPatient
//
//  Created by Bhavesh on 02/05/20.
//  Copyright © 2020 Bhavesh. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC

class AddNewPatientVC: BaseViewController {

    @IBOutlet weak var imageViewProfile: UIImageView!
    
    @IBOutlet weak var textfieldUserName: CustomTextfield!
    
    @IBOutlet weak var textfieldEmail: CustomTextfield!
    
    @IBOutlet weak var textfiledPhoneNumber: CustomTextfield!
    
    @IBOutlet weak var textfieldTitle: CustomTextfield!
    
    let password : String = GeneralUtility.generatePassword(passwordLength: 8)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageViewProfile.downloadImage(fromURL: userData?.profileimage, placeHolderImage: UIImage.init(named: "man"), completion: nil)
        print(password)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func didTapButtonBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func didTapButtonSave(_ sender: Any) {
        if let username = self.textfieldUserName.text ,let email = self.textfieldEmail.text,let phone = self.textfiledPhoneNumber.text,let Dtitle = self.textfieldTitle.text {
             self.signUp(fullName: username, login: email)
        } else {
            self.view.showToast(message: "Enter Username ands Email")
        }
    }
    @IBAction func didTapButtonAdd(_ sender: Any) {
        self.clearTextfield()
    }
    func clearTextfield() {
        self.textfieldUserName.text = ""
        self.textfieldEmail.text = ""
        self.textfiledPhoneNumber.text = ""
        self.textfieldTitle.text = ""
        self.imageViewProfile.image = nil
    }
}

extension AddNewPatientVC {
    func performApiCallForAddPatient(paramater : [String:Any])  {
        
        ServiceManager.shared.serverCommunicationManager.apiCall(forWebService: EnumWebService.addPatient(paramater)) { (status, message, statusCode, response, error) in
            GeneralUtility.endProcessing()
            if (status) {
                self.clearTextfield()
                GeneralUtility.showAlert(message: message)
            } else {
                GeneralUtility.showAlert(message: message)
            }
        }
    }
}

extension AddNewPatientVC {
    
    private func signUp(fullName: String, login: String) {
           GeneralUtility.showProcessing()
        let newUser = QBUUser()
        newUser.login = login
        newUser.fullName = fullName
        newUser.password = self.password
        QBRequest.signUp(newUser, successBlock: { [weak self] response, user in
            if let username = self?.textfieldUserName.text ,let email = self?.textfieldEmail.text,let phone =   self?.textfiledPhoneNumber.text,let Dtitle = self?.textfieldTitle.text {
                let paramater : [String:Any] = ["userid": self?.userData?.id as Any,
                                                "username": username,
                                                "email": email,
                                                "phoneno":phone,
                                                "title":Dtitle,
                                                "password": self?.password as Any,
                                                "qbuserId" : "\(user.id)",
                                                "d_qbuserid": self?.userData?.qbuserId as Any]
            self!.performApiCallForAddPatient(paramater: paramater)
                } else {
                    GeneralUtility.endProcessing()
                    GeneralUtility.showAlert(message: "Please Fill All Detail")
                }
       
            }, errorBlock: { [weak self] response in
                   GeneralUtility.endProcessing()
                self?.handleError(response.error?.error, domain: ErrorDomain.signUp)
        })
    }
}
