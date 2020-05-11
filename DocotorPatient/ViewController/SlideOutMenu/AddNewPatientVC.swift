//
//  AddNewPatientVC.swift
//  DocotorPatient
//
//  Created by Bhavesh on 02/05/20.
//  Copyright © 2020 Bhavesh. All rights reserved.
//

import UIKit

class AddNewPatientVC: UIViewController {

    @IBOutlet weak var imageViewProfile: UIImageView!
    
    @IBOutlet weak var textfieldUserName: CustomTextfield!
    
    @IBOutlet weak var textfieldEmail: CustomTextfield!
    
    @IBOutlet weak var textfiledPhoneNumber: CustomTextfield!
    
    @IBOutlet weak var textfieldTitle: CustomTextfield!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func didTapButtonBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func didTapButtonSave(_ sender: Any) {
    }
    @IBAction func didTapButtonAdd(_ sender: Any) {
        self.textfieldUserName.text = ""
        self.textfieldEmail.text = ""
        self.textfiledPhoneNumber.text = ""
        self.textfieldTitle.text = ""
        self.imageViewProfile.image = nil
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
