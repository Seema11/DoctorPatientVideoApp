//
//  SignuUpViewController.swift
//  DocotorPatient
//
//  Created by Bhavesh on 30/04/20.
//  Copyright © 2020 Bhavesh. All rights reserved.
//

import UIKit

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
    }
    @IBAction func didTapButtonLogin(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
}
