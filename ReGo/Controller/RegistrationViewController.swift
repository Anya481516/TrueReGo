//
//  RegistrationViewController.swift
//  ReGo
//
//  Created by Анна Мельхова on 31.03.2020.
//  Copyright © 2020 Anna Melkhova. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD
//import FirebaseStorage

protocol RegistrationDelegate {
    func goToLogIn()
    func retrieveUserInfo()
    func showLoggedInView()
}

class RegistrationViewController : UIViewController {
    
    //Declare the delegate variable here:
    var delegate : RegistrationDelegate?
    
    // MARK: IBOutlets:
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    
    // MARK: DID_LOAD:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logInButton.setTitleColor(UIColor.init(named: "WhiteBlack"), for: .normal)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: IBActions:
    
    @IBAction func showPasswordButtonPressed(_ sender: UIButton) {
        if passwordTextField.isSecureTextEntry == true {
            passwordTextField.isSecureTextEntry = false
            passwordTextField.placeholder = "123456"
            sender.setImage(UIImage.init(systemName: "eye.slash.fill"), for: [])
        }
        else {
            passwordTextField.isSecureTextEntry = true
            passwordTextField.placeholder = "******"
            sender.setImage(UIImage.init(systemName: "eye.fill"), for: [])
        }
    }
    
    @IBAction func editingStarted(_ sender: UITextField) {
        if sender.layer.borderColor == UIColor.red.cgColor
        {
            sender.layer.borderColor = UIColor.gray.cgColor
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        //SVProgressHUD.show()
        if let userName = usernameTextField.text {
            if let userEmail = emailTextField.text {
                if let userPassword = passwordTextField.text {
                    Auth.auth().createUser(withEmail: userEmail, password: userPassword) { (user, error) in
                        if error != nil {
                            print(error!)
                            // описать что делать при каждых ошибочках
                            if userName.isEmpty {
                                // alert
                                self.showAlert(alertTitle: "Incorrect Username", alertMessage: "Please insert the Username", actionTitle: "OK", textField: self.usernameTextField)
                            }
                            else if userPassword.isEmpty || userPassword.count < 6 {
                                self.showAlert(alertTitle: "Incorrect Password", alertMessage: error!.localizedDescription, actionTitle: "OK", textField: self.emailTextField)
                            }
                            else if userEmail.isEmpty {
                                self.showAlert(alertTitle: "Incorrect Email", alertMessage: error!.localizedDescription, actionTitle: "OK", textField: self.emailTextField)
                            }
                            else {
                                self.showAlert(alertTitle: "Error", alertMessage: error!.localizedDescription, actionTitle: "OK", textField: self.emailTextField)
                            }
                        }
                        else {
                            print("Succesfully registered")
                            // в каретн юзера занеcли инфу
                            currentUser = User(id: Auth.auth().currentUser!.uid, name: userName, email: userEmail, password: userPassword)
                            // сохранить инфу о юзере так же в базе данных йоууу
                            let userDB = Firebase.Database.database().reference().child("Users")
                                   
                            let userDictionary = ["Name" : currentUser.name, "PlacesAdded" : currentUser.placesAdded, "ProfilePicture" : false] as [String : Any]
                                   userDB.child(currentUser.id).setValue(userDictionary) {
                                       (error, reference) in
                                       if error != nil {
                                           print(error!)
                                       }
                                       else{
                                           print("User added to the DB")
                                       }
                                   }
                            //SVProgressHUD.dismiss()
                            // TODO: тут мы убрали вьюху с регой, и надо теперь поставить вьюху с уже не тем что было до реги, а с тем что после (Сначала надо создать ихихих c фоткой!)
                            self.dismiss(animated: true) {
                                self.delegate?.retrieveUserInfo()
                                 self.delegate?.showLoggedInView()
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func logInButtonPressed(_ sender: UIButton) {
        // TODO: self.parent!.performSegue(withIdentifier: "fromHomeToLogin", sender: self.parent!)
        self.dismiss(animated: true) {
            self.delegate?.goToLogIn()
        }
        
    }
    
    // MARK: METHODS:
    func showAlert(alertTitle : String, alertMessage : String, actionTitle : String, textField : UITextField) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: actionTitle, style: .default) { (UIAlertAction) in
            textField.layer.borderColor = UIColor.red.cgColor
            self.view.layoutIfNeeded()
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    // with the keyboard
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= (keyboardSize.height - 80)
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    
}
