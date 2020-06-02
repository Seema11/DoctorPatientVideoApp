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
    
    var imagePicker: ImagePicker!
    var imageData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(password)
        self.setUpView()
        // Do any additional setup after loading the view.
    }
    
    func setUpView() {
        
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        let tap = UITapGestureRecognizer(target: self, action: #selector(AddNewPatientVC.tappedMe))
        imageViewProfile.addGestureRecognizer(tap)
        imageViewProfile.isUserInteractionEnabled = true
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
    @objc func tappedMe(_ sender : Any)
       {
           self.imagePicker.present(from: self.imageViewProfile )
       }
}
extension AddNewPatientVC : ImagePickerDelegate {
    func didSelectWithUrl(image: UIImage?, fileUrl: URL?) {
        // let imgName = fileUrl?.lastPathComponent
    }
    
    func didSelect(image: UIImage?) {
        self.imageViewProfile.image = image
        let options: NSDictionary =  [:]
            let convertToPng = imageViewProfile.image!.toData(options: options, type: .png)
            guard let pngData = convertToPng else {
                GeneralUtility.endProcessing()
                GeneralUtility.showAlert(message: "Error to load Image .Please Try Again")
                print("😡 ERROR: could not convert image to a png pngData var.")
                return
            }
        self.imageData = pngData
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
                if error != nil {
                     
                } else {
                    self.clearTextfield()
                }
                
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
                var paramater : [String:Any] = ["userid": self?.userData?.id as Any,
                                                "username": username,
                                                "email": email,
                                                "phoneno":phone,
                                                "title":Dtitle,
                                                "password": self?.password as Any,
                                                "qbuserId" : "\(user.id)",
                                                "d_qbuserid": self?.userData?.qbuserId as Any]
                var imageString = self?.imageData?.base64EncodedString()
                    imageString = "data:image/png;base64,\(imageString ?? "")"
                paramater.updateValue(imageString as Any, forKey: "profileimage")
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
