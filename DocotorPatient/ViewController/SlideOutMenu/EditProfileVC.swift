//
//  EditProfileVC.swift
//  DocotorPatient
//
//  Created by Bhavesh on 02/05/20.
//  Copyright © 2020 Bhavesh. All rights reserved.
//

import UIKit

class EditProfileVC: UIViewController {

    
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var textfieldUserName: CustomTextfield!
    @IBOutlet weak var textfieldEmail: CustomTextfield!
    @IBOutlet weak var textfieldPassword: CustomTextfield!
    @IBOutlet weak var textfieldPhoneNumber: CustomTextfield!
    @IBOutlet weak var textfieldTitle: CustomTextfield!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func didTapButttonBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func didTapButtonSave(_ sender: Any) {
    }
    @IBAction func didTapButtonChangePhoto(_ sender: Any) {
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
}
