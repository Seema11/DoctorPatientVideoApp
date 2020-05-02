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
    
    @IBOutlet weak var textfieldUserName: UITextField!
    
    @IBOutlet weak var textfieldEmail: UITextField!
    
    @IBOutlet weak var textfiledPhoneNumber: UITextField!
    
    @IBOutlet weak var textfieldTitle: UITextField!
    
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
