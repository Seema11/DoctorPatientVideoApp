//
//  ViewController.swift
//  DocotorPatient
//
//  Created by Bhavesh on 30/04/20.
//  Copyright © 2020 Bhavesh. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC
import SVProgressHUD
import Alamofire

class ViewController: UIViewController {

    @IBOutlet weak var textfielduserName: UITextField!
    
    @IBOutlet weak var textfieldPassword: UITextField!
    
    @IBOutlet weak var imageviewCheckMark: UIImageView!
    
    @IBOutlet weak var buttonOutletRemeberMe: UIButton!
    
    var check : Bool = false
    
    
    //MARK: - Properties
    private var inputEnabled = true {
        didSet {
            textfielduserName.isEnabled = inputEnabled
            textfieldPassword.isEnabled = inputEnabled
        }
    }
     
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
        
        if let password = textfieldPassword.text,
            let login = textfielduserName.text {
         //   self.performApiCallforLogin()
            self.login(fullName: "", login: login, password: password)
        } else {
            GeneralUtility.showAlert(message: "Username and password is not null")
        }
    }
    
    @IBAction func didTapButtonFBLogin(_ sender: Any) {
        
    }
    @IBAction func didTapButtonGoogleLogin(_ sender: Any) {
    }
    @IBAction func didTapButtonSignup(_ sender: Any) {
        
           if #available(iOS 13.0, *) {
             let signupVc = self.storyboard?.instantiateViewController(identifier: "SignuUpViewController") as! SignuUpViewController
             self.navigationController?.pushViewController(signupVc, animated: true)

                } else {
                    let signupVc = UIViewController.instantiateFrom("Main", "SignuUpViewController") as! SignuUpViewController
                    self.navigationController?.pushViewController(signupVc, animated: true)
                }
    }
    
}
extension ViewController {
    
    private func beginConnect() {
           isEditing = false
           inputEnabled = false
        //   loginButton.showLoading()
       }
    
    private func defaultConfiguration() {

          textfieldPassword.text = ""
          textfielduserName.text = ""
          inputEnabled = true
          
          //MARK: - Reachability
          let updateLoginInfo: ((_ status: NetworkConnectionStatus) -> Void)? = { [weak self] status in
              let notConnection = status == .notConnection
            _ = notConnection ? LoginConstant.checkInternet : LoginConstant.enterUsername
          }
          
          Reachability.instance.networkStatusBlock = { status in
              updateLoginInfo?(status)
          }
          updateLoginInfo?(Reachability.instance.networkConnectionStatus())
      }
    
    /**
     *  login
     */
    private func login(fullName: String, login: String, password: String) {
        beginConnect()
        GeneralUtility.showProcessing()
            QBRequest.logIn(withUserLogin: self.textfielduserName.text!, password: self.textfieldPassword.text!, successBlock: { (response, user) in
                
                let currentUser: QBUUser = user
                  currentUser.email = login
                  currentUser.password = password
                  currentUser.updatedAt = Date()
                  Profile.update(currentUser)
                                
                QBChat.instance.connect(withUserID: currentUser.id, password: currentUser.password!, completion: { (error) in
                    GeneralUtility.endProcessing()
                    if error == nil {
                      print("connected")
                        GeneralUtility.endProcessing()
                        //did Login action
                        Constant.appDelegate.showDrawerView()
                        //self.performApiCallforLogin()
                    } else {
                        if error?._code == QBResponseStatusCode.unAuthorized.rawValue {
                                                                     // Clean profile
                            GeneralUtility.endProcessing()
                            Profile.clearProfile()
                            self.defaultConfiguration()
                        } else {
                            self.handleError(error, domain: ErrorDomain.logIn)
                           self.disconnectUser()
                        }
                          print(error as Any)
                    }
                })
        }, errorBlock: { (response) in
            GeneralUtility.endProcessing()
            self.handleError(response.error as? Error, domain: ErrorDomain.logIn)
             if response.status == QBResponseStatusCode.unAuthorized {
                                                // Clean profile
                GeneralUtility.showAlert(message: "User Not Found")
                }
            })
//                        QBChat.instance.connect(withUserID: user.id, password: user.password!, completion: { (error) in
//                                    user.password = password
//                                    user.updatedAt = Date()
//                                    Profile.synchronize(user)
//
//
////                                    if user.fullName != fullName {
////                                        self.updateFullName(fullName: fullName, login: login)
////                                    } else {
//                                        self.connectToChat(user: user)
//                             //       }
//                        })
//                }, errorBlock: { (response) in
//                    self.handleError(response.error as? Error, domain: ErrorDomain.logIn)
//                      if response.status == QBResponseStatusCode.unAuthorized {
//                                        // Clean profile
//                                        Profile.clearProfile()
//                        self.defaultConfiguration()
//
//                    }
//                })
    }
    
    private func updateFullName(fullName: String, login: String) {
        let updateUserParameter = QBUpdateUserParameters()
        updateUserParameter.fullName = fullName
        QBRequest.updateCurrentUser(updateUserParameter, successBlock: {  [weak self] response, user in

            user.updatedAt = Date()
        
            Profile.update(user)
        //    self?.connectToChat(user: user)
            
            }, errorBlock: { [weak self] response in
                self?.handleError(response.error?.error, domain: ErrorDomain.signUp)
        })
    }
        
     private func connectUser(_ user: QBUUser) {
            Profile.synchronize(user)
            connectToChat(user: user)
        }
    
    private func connectToChat(user: QBUUser) {
          QBChat.instance.connect(withUserID: user.id,
                                  password: textfieldPassword.text!,
                                  completion: { [weak self] error in
                                      if let error = error {
                                          if error._code == QBResponseStatusCode.unAuthorized.rawValue {
                                              // Clean profile
                                              GeneralUtility.endProcessing()
                                              Profile.clearProfile()
                                              self?.defaultConfiguration()
                                          } else {
                                              self?.handleError(error, domain: ErrorDomain.logIn)
                                            self?.disconnectUser()
                                          }
                                      } else {
                                          GeneralUtility.endProcessing()
                                          //did Login action
                                        self?.performApiCallforLogin()
                                        //  self?.performSegue(withIdentifier: LoginConstant.showUsers, sender: nil)
                                      }
          })
      }
        
        //MARK: - Validation helpers
        private func isValid(userName: String?) -> Bool {
            let characterSet = CharacterSet.whitespaces
            let trimmedText = userName?.trimmingCharacters(in: characterSet)
            let regularExtension = LoginNameRegularExtention.user
            let predicate = NSPredicate(format: "SELF MATCHES %@", regularExtension)
            let isValid = predicate.evaluate(with: trimmedText)
            return isValid
        }
        
        private func isValid(login: String?) -> Bool {
            let characterSet = CharacterSet.whitespaces
            let trimmedText = login?.trimmingCharacters(in: characterSet)
            let regularExtension = LoginNameRegularExtention.passord
            let predicate = NSPredicate(format: "SELF MATCHES %@", regularExtension)
            let isValid: Bool = predicate.evaluate(with: trimmedText)
            return isValid
        }
    
    private func handleError(_ error: Error?, domain: ErrorDomain) {
        GeneralUtility.endProcessing()
           guard let error = error else {
               return
           }
           var infoText = error.localizedDescription
        GeneralUtility.showAlert(message: infoText)
           if error._code == NSURLErrorNotConnectedToInternet {
               infoText = LoginConstant.checkInternet
           }
           inputEnabled = true
       }
}
extension ViewController {
    func performApiCallforLogin() {
        GeneralUtility.showProcessing()
        let parameter : [String:Any] = ["username":self.textfielduserName.text!,"password":self.textfieldPassword.text!]

        ServiceManager.shared.serverCommunicationManager.apiCall(forWebService: EnumWebService.login(parameter)) { (status, message, statusCode, response, error) in
            GeneralUtility.endProcessing()
            if (status) {
                Constant.appDelegate.showDrawerView()
            } else {
                GeneralUtility.endProcessing()
                GeneralUtility.showAlert(message: message)
            }


        }
    }
//    func performApiCallforLogin() {
//        let url = "http://yashikainfotech.website/doctorapi/api/login.php"
//
//               let parameters = [
//                   "username":"Demo40",
//                   "password":"123456"
//                   ] as [String : Any]
//
//               Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
//                   switch response.result {
//                   case .success:
//                       if let value = response.result.value {
//                           print(value)
//                           let data : NSDictionary = value as! NSDictionary
//                        Constant.appDelegate.showDrawerView()
//
//                       }
//                   case .failure(let error):
//                       print(error)
//                       GeneralUtility.showAlert(message: error.localizedDescription)
//                   }
//               }
//
//           }
}
