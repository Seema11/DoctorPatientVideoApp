//
//  ViewController.swift
//  DocotorPatient
//
//  Created by Bhavesh on 30/04/20.
//  Copyright © 2020 Bhavesh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textfielduserName: UITextField!
    
    @IBOutlet weak var textfieldPassword: UITextField!
    
    @IBOutlet weak var imageviewCheckMark: UIImageView!
    
    @IBOutlet weak var buttonOutletRemeberMe: UIButton!
    
    var check : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func didtapButtonRemeberMe(_ sender: Any) {
        
        if (check) {
            self.imageviewCheckMark.image = UIImage.init(named: "uncheck")
            check = false
        } else {
             self.imageviewCheckMark.image = UIImage.init(named: "check")
            check = true
        }
    }
    
    @IBAction func didTapButtonForgotPassword(_ sender: Any) {
    }
    @IBAction func didTapButtonLogin(_ sender: Any) {
        Constant.appDelegate.showDrawerView()
    }
    
    @IBAction func didTapButtonFBLogin(_ sender: Any) {
    }
    @IBAction func didTapButtonGoogleLogin(_ sender: Any) {
    }
    @IBAction func didTapButtonSignup(_ sender: Any) {
        let signupVc = self.storyboard?.instantiateViewController(identifier: "SignuUpViewController") as! SignuUpViewController
        self.navigationController?.pushViewController(signupVc, animated: true)
    }
    
}

