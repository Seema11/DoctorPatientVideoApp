//
//  EditProfileVC.swift
//  DocotorPatient
//
//  Created by Bhavesh on 02/05/20.
//  Copyright © 2020 Bhavesh. All rights reserved.
//

import UIKit

class EditProfileVC: BaseViewController {

    
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var textfieldUserName: CustomTextfield!
    @IBOutlet weak var textfieldEmail: CustomTextfield!
    @IBOutlet weak var textfieldPassword: CustomTextfield!
    @IBOutlet weak var textfieldPhoneNumber: CustomTextfield!
    @IBOutlet weak var textfieldTitle: CustomTextfield!
    
    @IBOutlet weak var buttonChangePassword: UIButton!
    
    var imagePicker: ImagePicker!
    var imageData: Data?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
        // Do any additional setup after loading the view.
    }
    
    func setUpView()  {
        print(userData)
          self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        self.textfieldUserName.text = userData?.username
        self.textfieldEmail.text = userData?.email
        self.textfieldPhoneNumber.text = userData?.phoneno
        self.textfieldTitle.text = userData?.title
        self.imageViewProfile.downloadImage(fromURL: userData?.profileimage, placeHolderImage: UIImage.init(named: "man"), completion: nil)
    }
    
    @IBAction func didTapButttonBack(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
        
    }
    @IBAction func didTapButtonSave(_ sender: Any) {
        let options: NSDictionary =  [:]
                     let convertToPng = imageViewProfile.image!.toData(options: options, type: .png)
                     guard let pngData = convertToPng else {
                         GeneralUtility.endProcessing()
                         GeneralUtility.showAlert(message: "Error to load Image .Please Try Again")
                         print("😡 ERROR: could not convert image to a png pngData var.")
                         return
                     }
               self.imageData = pngData
        self.performApiCallForEditUserProfile()
    }
    @IBAction func didTapButtonChangePhoto(_ sender: Any) {
        self.imagePicker.present(from: self.imageViewProfile)     
    }
    @IBAction func didTapButtonChangePassword(_ sender: Any) {
    }
    
    @IBAction func didTapButtonAdd(_ sender: Any) {
        if #available(iOS 13.0, *) {
        let signupVc = self.storyboard?.instantiateViewController(identifier: "AddNewPatientVC") as! AddNewPatientVC
        self.navigationController?.pushViewController(signupVc, animated: true)

           } else {
               let signupVc = UIViewController.instantiateFrom("Menu", "AddNewPatientVC") as! AddNewPatientVC
               self.navigationController?.pushViewController(signupVc, animated: true)
           }
    }
    func clearTextfield() {
       }

}
extension EditProfileVC : ImagePickerDelegate {
    func didSelectWithUrl(image: UIImage?, fileUrl: URL?) {
        // let imgName = fileUrl?.lastPathComponent
    }
    
    func didSelect(image: UIImage?) {
        
        self.imageViewProfile.image = image
    }
}
extension EditProfileVC {
    func performApiCallForEditUserProfile()  {
        GeneralUtility.showProcessing()
        
        let imageString = self.imageData?.base64EncodedString()
        
        let paramater : [String : Any] = ["userid":userData?.id! as Any,
                                          "username":self.textfieldUserName.text!,
                                          "email":self.textfieldEmail.text!,
                                          "phoneno":self.textfieldPhoneNumber.text! as Any,
                                          "title":self.textfieldTitle.text!,
                                          "profileimage": imageString!]
        
        ServiceManager.shared.serverCommunicationManager.apiCall(forWebService: EnumWebService.editProfile(paramater)) { (status, message, statusCode, response, error) in
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
