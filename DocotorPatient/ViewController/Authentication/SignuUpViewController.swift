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
        
        if let fullName = textfieldUserName.text,
            let login = textfieldEmailAddress.text,let passowrd = textfieldPassword.text {
                       let user = QBUUser()
                       user.login = login
                       user.fullName = fullName
                       user.password = passowrd

                       QBRequest.signUp(user, successBlock: { (response, user) in
                        GeneralUtility.showAlert(message: "User Successfully created")
                            self.navigationController?.popViewController(animated: true)
                       }, errorBlock: { (response) in
                        GeneralUtility.showAlert(message: response.error!.debugDescription)
                       })
        } else {
            GeneralUtility.showAlert(message: "Value is not be null")
        }
    }
    @IBAction func didTapButtonLogin(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
}
