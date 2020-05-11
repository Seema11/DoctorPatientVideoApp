//
//  SignuUpViewController.swift
//  DocotorPatient
//
//  Created by Bhavesh on 30/04/20.
//  Copyright © 2020 Bhavesh. All rights reserved.
//

import UIKit
import QuickbloxWebRTC
import Quickblox

class SignuUpViewController: UIViewController {

    @IBOutlet weak var textfieldEmailAddress: UITextField!
    
    @IBOutlet weak var textfieldUserName: UITextField!
    
    @IBOutlet weak var textfieldPassword: UITextField!
    
    @IBOutlet weak var imageViewCheckMark: UIImageView!
    
    @IBOutlet weak var buttonIacceptTerms: UIButton!
    
    var check : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func didTapButtonTerms(_ sender: Any) {
        if (check) {
                   self.imageViewCheckMark.image = UIImage.init(named: "uncheck")
                   check = false
               } else {
                    self.imageViewCheckMark.image = UIImage.init(named: "check")
                   check = true
               }
    }
    @IBAction func didTapButtonSignUp(_ sender: Any) {
        performApiCallforSigup()
    }
    @IBAction func didTapButtonLogin(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
}
extension SignuUpViewController {
    func performApiCallforSigup() {
        GeneralUtility.showProcessing()
        let parameter : [String:Any] = ["email":self.textfieldEmailAddress.text!,"username":self.textfieldUserName.text!,"password":self.textfieldPassword.text!]
        
        ServiceManager.shared.serverCommunicationManager.apiCall(forWebService: EnumWebService.registration(parameter)) { (status, message, statusCode, response, error) in
            GeneralUtility.endProcessing()
            if (status) {
                self.signuInQb()
            } else {
                GeneralUtility.endProcessing()
                GeneralUtility.showAlert(message: message)
            }
            
            
        }
    }
    func signuInQb() {
        if let fullName = textfieldUserName.text,
                 let login = textfieldEmailAddress.text,let passowrd = textfieldPassword.text {
                     GeneralUtility.showProcessing()
                            let user = QBUUser()
                            user.login = login
                            user.fullName = fullName
                            user.password = passowrd

                            QBRequest.signUp(user, successBlock: { (response, user) in
                             GeneralUtility.endProcessing()
                             GeneralUtility.showAlert(message: "User Successfully created")
                                 self.navigationController?.popViewController(animated: true)
                            }, errorBlock: { (response) in
                             GeneralUtility.endProcessing()
                             GeneralUtility.showAlert(message: response.error!.debugDescription)
                            })
             } else {
                       GeneralUtility.endProcessing()
                 GeneralUtility.showAlert(message: "Value is not be null")
             }
    }
}
