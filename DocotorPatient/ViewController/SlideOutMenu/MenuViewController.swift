//
//  MenuViewController.swift
//  bogo
//
//  Created by Appernaut on 06/07/19.
//  Copyright © 2019 Appernaut. All rights reserved.
//

import UIKit
import PopupDialog
import Quickblox
import QuickbloxWebRTC

struct MenuItem {
    let title: String
    let icon: UIImage
}

class MenuViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var labeluserName: UILabel!
    @IBOutlet weak var labelVersion: UILabel!
    
    var loginEmail : String?
    var menuItems: [MenuItem] = []
    var nav: UINavigationController?
    var imagePicker: ImagePicker!
    
    var loginTag : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuView()
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
    }
    
    @IBAction func menuWasPressed(_ sender: Any) {
        DispatchQueue.main.async {
            if let drawer = self.sideMenuController(), drawer.drawerState == .opened {
                drawer.setDrawerState(.closed, animated: true)
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
       print("view appear")
        self.setUpData()
    }
    
    @IBAction func didTapButtonEditPicture(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }
    @IBAction func didTapButtonLogOut(_ sender: Any) {
        //BaseViewController.moveToLoginViewController()
    }
    func dismissViewControllers() {

        guard let vc = self.presentingViewController else { return }

        while (vc.presentingViewController != nil) {
            vc.dismiss(animated: true, completion: nil)
        }
    }
}
extension MenuViewController: ImagePickerDelegate {
    func didSelectWithUrl(image: UIImage?, fileUrl: URL?) {
       // let imgName = fileUrl?.lastPathComponent
      
    }
    
    func didSelect(image: UIImage?) {
    }
}

// MARK: Helpers
extension MenuViewController {
    fileprivate func setupMenuView() {

        self.setUpData()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(MenuViewController.tappedMe))
        imageViewProfile.addGestureRecognizer(tap)
        imageViewProfile.isUserInteractionEnabled = true
        
        menuItems.append(MenuItem(title: "Patient List", icon: UIImage(named: "video-call 50-30")!))
        menuItems.append(MenuItem(title: "Add New Patient", icon: UIImage(named: "video-call 50-30")!))
        menuItems.append(MenuItem(title: "Call History", icon: UIImage(named: "video-call 50-30")!))
        menuItems.append(MenuItem(title: "Call Recording", icon: UIImage(named: "video-call 50-30")!))
        menuItems.append(MenuItem(title: "Edit Your Profile", icon: UIImage(named: "video-call 50-30")!))
        menuItems.append(MenuItem(title: "Logout", icon: UIImage(named: "video-call 50-30")!))
        
        
        tableView.register(MenuTableCell.nib, forCellReuseIdentifier: MenuTableCell.identifier)
        tableView.rowHeight = 60
        
        
        tableView.tableFooterView = UIView()

 //     Cast child controller of parent as UINavigationController
        
            guard let drawerController = parent as? BBDrawerController,
                      let navController = drawerController.mainViewController as! UINavigationController?
                      else { return }
                  nav = navController
                  nav?.isNavigationBarHidden = true
                  nav?.performSegue(withIdentifier: "PatientListVC", sender: nil)
    }
    
    func setUpData() {
        
    }
    
    @objc func tappedMe()
    {
        if let drawer = self.sideMenuController(), drawer.drawerState == .opened {
                       drawer.setDrawerState(.closed, animated: true)
                   }
        
        if #available(iOS 13.0, *) {
//            let profile = self.storyboard?.instantiateViewController(identifier: "ProfileViewController") as! ProfileViewController
//            profile.loginTag = self.loginTag
//            self.nav?.pushViewController(profile, animated: true)

        } else {
//            let profile = UIViewController.instantiateFrom("Menu", "ProfileViewController") as! ProfileViewController
//            profile.loginTag = self.loginTag
//            self.nav?.pushViewController(profile, animated: true)
        }
    }
}

// MARK: UITableViewDataSource
extension MenuViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MenuTableCell.identifier) as! MenuTableCell
        cell.menuItem = menuItems[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
}

// MARK: UITableViewDataSource
extension MenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            if let drawer = self.sideMenuController(), drawer.drawerState == .opened {
                drawer.setDrawerState(.closed, animated: true)
            }
            
            if indexPath.row == 0 {
                if #available(iOS 13.0, *) {
                    let patientListVc = self.storyboard?.instantiateViewController(identifier: "PatientListVC") as! PatientListVC
                    self.nav?.pushViewController(patientListVc, animated: true)
                } else {
                    let patientListVc = UIViewController.instantiateFrom("Menu", "PatientListVC") as! PatientListVC
                    self.nav?.pushViewController(patientListVc, animated: true)
                    // Fallback on earlier versions
                }
            }   else if indexPath.row == 1 {
                if #available(iOS 13.0, *) {
                    let addNewPatientVC = self.storyboard?.instantiateViewController(identifier: "AddNewPatientVC") as! AddNewPatientVC
                    self.nav?.pushViewController(addNewPatientVC, animated: true)
                } else {
                    let addNewPatientVC = UIViewController.instantiateFrom("Menu", "AddNewPatientVC") as! AddNewPatientVC
                    self.nav?.pushViewController(addNewPatientVC, animated: true)
                    // Fallback on earlier versions
                }
            }   else if indexPath.row == 2 {
                if #available(iOS 13.0, *) {
                    let callhistoryVc = self.storyboard?.instantiateViewController(identifier: "CallHistoryVC") as! CallHistoryVC
                    self.nav?.pushViewController(callhistoryVc, animated: true)
                } else {
                    let callhistoryVc = UIViewController.instantiateFrom("Menu", "CallHistoryVC") as! CallHistoryVC
                    self.nav?.pushViewController(callhistoryVc, animated: true)
                    // Fallback on earlier versions
                }
            }   else if indexPath.row == 3 {
                if #available(iOS 13.0, *) {
                    let callRecordingVc = self.storyboard?.instantiateViewController(identifier: "CallRecordingVC") as! CallRecordingVC
                    self.nav?.pushViewController(callRecordingVc, animated: true)
                } else {
                    let callRecordingVc = UIViewController.instantiateFrom("Menu", "CallRecordingVC") as! CallRecordingVC
                    self.nav?.pushViewController(callRecordingVc, animated: true)
                    // Fallback on earlier versions
                }
            }   else if indexPath.row == 4 {
                if #available(iOS 13.0, *) {
                    let editProfileVc = self.storyboard?.instantiateViewController(identifier: "EditProfileVC") as! EditProfileVC
                    self.nav?.pushViewController(editProfileVc, animated: true)
                } else {
                    let editProfileVc = UIViewController.instantiateFrom("Menu", "EditProfileVC") as! EditProfileVC
                    self.nav?.pushViewController(editProfileVc, animated: true)
                    // Fallback on earlier versions
                }
            } else if indexPath.row == 5 {
                self.logoutUser()
            }
        }
    }
}
extension MenuViewController {
    func logoutUser()
    {
        UserDefaults.removeObject(forKey: Constant.UserDefaultsKey.userLoginData)
        UserDefaults.removeObject(forKey: Constant.UserDefaultsKey.QBUserData)
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
        self.disconnectUser()
        
    }
    func performAPiCallForLogoutUser()  {
       
    }
    func performAPiCallForLogoutDriver()  {
    
    }
}
