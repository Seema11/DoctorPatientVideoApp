//
//  AddNewPatientVC.swift
//  DocotorPatient
//
//  Created by Bhavesh on 02/05/20.
//  Copyright © 2020 Bhavesh. All rights reserved.
//

import UIKit

class AddNewPatientVC: BaseViewController {

    @IBOutlet weak var imageViewProfile: UIImageView!
    
    @IBOutlet weak var textfieldUserName: CustomTextfield!
    
    @IBOutlet weak var textfieldEmail: CustomTextfield!
    
    @IBOutlet weak var textfiledPhoneNumber: CustomTextfield!
    
    @IBOutlet weak var textfieldTitle: CustomTextfield!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageViewProfile.downloadImage(fromURL: userData?.profileimage, placeHolderImage: UIImage.init(named: "man"), completion: nil)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func didTapButtonBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func didTapButtonSave(_ sender: Any) {
        if let username = self.textfieldUserName.text ,let email = self.textfieldEmail.text,let phone = self.textfiledPhoneNumber.text,let Dtitle = self.textfieldTitle.text {
            let paramater : [String:Any] = ["userid":userData?.id ?? "",
                                            "username": username,
                                            "email": email,
                                            "phoneno":phone,
                                            "title":Dtitle]
            self.performApiCallForAddPatient(paramater: paramater)
        } else {
            GeneralUtility.showAlert(message: "Please Fill All Detail")
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
        GeneralUtility.showProcessing()
        
        ServiceManager.shared.serverCommunicationManager.apiCall(forWebService: EnumWebService.addPatient(paramater)) { (status, message, statusCode, response, error) in
            GeneralUtility.endProcessing()
            if (status) {
                GeneralUtility.showAlert(message: message)
                self.clearTextfield()
            } else {
                GeneralUtility.showAlert(message: message)
            }
        }
    }
}
