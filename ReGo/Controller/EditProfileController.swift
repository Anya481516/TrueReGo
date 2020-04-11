//
//  EditProfileController.swift
//  ReGo
//
//  Created by Анна Мельхова on 10.04.2020.
//  Copyright © 2020 Anna Melkhova. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD
//import FirebaseStorage

protocol EditProfileDelegate {
    func retrieveUserInfo()
    func showLoggedInView()
}

class EditProfileController : UIViewController {
    
    //MARK: variables:
    var delegate : EditProfileDelegate?
    
    // MARK: IBOutlets:
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userNameTextField.text = currentUser.name
        emailTextField.text = currentUser.email

    }
    
    // MARK: IBActions:
    
    @IBAction func saveChangesButtonPressed(_ sender: UIButton) {
        if let newUserName = userNameTextField.text {
            if let newEmail = emailTextField.text {
                if currentUser.email != newEmail {
                    Auth.auth().currentUser?.updateEmail(to: newEmail, completion: { (error) in
                        if let error = error {
                            //self.showAlert(alertTitle: "Error!", alertMessage: error.localizedDescription)
                            // need toreauthenticate
                            let alert = UIAlertController(title: "Password is required", message: "To change the email please insert your password below:", preferredStyle: .alert)
                            alert.addTextField { (textField) in
                                textField.isSecureTextEntry = true
                            }
                            let action1 = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
                                
                            }
                            let action2 = UIAlertAction(title: "Done", style: .default) { (UIAlertAction) in
                                let textField = alert.textFields![0]
                                if let password = textField.text {
                                    let eMail = EmailAuthProvider.credential(withEmail: currentUser.email, password: password)
                                    Auth.auth().currentUser?.reauthenticate(with: eMail, completion: { (authDataResult, error) in
                                        if let error = error {
                                            self.showAlert(alertTitle: "Error!", alertMessage: error.localizedDescription)
                                        }
                                        else {
                                            // now you can change the email yo
                                            self.resetEmail(email: newEmail)
                                        }
                                    })
                                }
                            }
                            alert.addAction(action1)
                            alert.addAction(action2)
                            self.present(alert, animated: true, completion: nil)
                        }
                        else {
                            currentUser.email = newEmail
                            self.showAlert(alertTitle: "Success!", alertMessage: "Values have been changed")
                        }
                    })
                }
                if currentUser.name != newUserName {
                    let userDB = Firebase.Database.database().reference().child("Users")
                    currentUser.name = newUserName
                    userDB.child(currentUser.id).updateChildValues(["Name" : newUserName])
                    showAlert(alertTitle: "Success!", alertMessage: "Values have been changed")
                }
            }
        }
    }
    @IBAction func changePasswordButtonPressed(_ sender: UIButton) {
        if oldPasswordTextField.text?.isEmpty == false {
            // reauthenticate the user
            let eMail = EmailAuthProvider.credential(withEmail: currentUser.email, password: oldPasswordTextField.text!)
            Auth.auth().currentUser?.reauthenticate(with: eMail, completion: { (authDataResult, error) in
                if let error = error {
                    self.showAlert(alertTitle: "Error!", alertMessage: error.localizedDescription)
                }
                else {
                    // now you can change the password yo
                    if self.newPasswordTextField.text!.count > 5 {
                        self.resetPassword(password: self.newPasswordTextField.text!)
                        self.oldPasswordTextField.text = ""
                        self.newPasswordTextField.text = ""
                    }
                    
                }
            })
            
        }
        else {
            // show alert that the password is incorrect
            let alert = UIAlertController(title: "Password error", message: "Your old password is incorrect. Do you want to try again or to get a link to reset the password by email?", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "Try again", style: .default) { (UIAlertAction) in
                
            }
            let action2 = UIAlertAction(title: "Send by email", style: .default) { (UIAlertAction) in
                self.sendPasswordByEmail()
            }
            alert.addAction(action1)
            alert.addAction(action2)
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func forgotPasswordButtonPressed(_ sender: UIButton) {
        sendPasswordByEmail()
    }
    
    @IBAction func oldEyeButtonPressed(_ sender: UIButton) {
        if oldPasswordTextField.isSecureTextEntry == true {
            oldPasswordTextField.isSecureTextEntry = false
            oldPasswordTextField.placeholder = "123456"
            sender.setImage(UIImage.init(systemName: "eye.slash.fill"), for: [])
        }
        else {
            oldPasswordTextField.isSecureTextEntry = true
            oldPasswordTextField.placeholder = "******"
            sender.setImage(UIImage.init(systemName: "eye.fill"), for: [])
        }
    }
    @IBAction func newEyeButtonPressed(_ sender: UIButton) {
        if newPasswordTextField.isSecureTextEntry == true {
            newPasswordTextField.isSecureTextEntry = false
            newPasswordTextField.placeholder = "123456"
            sender.setImage(UIImage.init(systemName: "eye.slash.fill"), for: [])
        }
        else {
            newPasswordTextField.isSecureTextEntry = true
            newPasswordTextField.placeholder = "******"
            sender.setImage(UIImage.init(systemName: "eye.fill"), for: [])
        }
    }
    
    // MARK: METHODS:
    
    func sendPasswordByEmail() {
        Auth.auth().sendPasswordReset(withEmail: currentUser.email) { error in
            if let error = error {
                self.showAlert(alertTitle: "Error", alertMessage: error.localizedDescription)
            }
            else {
                self.showAlert(alertTitle: "Success!", alertMessage: "Your link to change password was sent to \(currentUser.email). Check you email")
            }
        }
    }
    func showAlert(alertTitle : String, alertMessage : String) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (UIAlertAction) in
            self.delegate?.retrieveUserInfo()
            self.delegate?.showLoggedInView()
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func resetPassword(password : String) {
        Auth.auth().currentUser?.updatePassword(to: password, completion: { (error) in
            if let error = error {
                self.showAlert(alertTitle: "Error", alertMessage: error.localizedDescription)
            }
            else {
                self.showAlert(alertTitle: "Success", alertMessage: "Your password has changed!")
                
            }
        })
    }
    func resetEmail(email : String) {
        Auth.auth().currentUser?.updateEmail(to: email, completion: { (error) in
            if let error = error {
                self.showAlert(alertTitle: "Error", alertMessage: error.localizedDescription)
            }
            else {
                self.showAlert(alertTitle: "Success", alertMessage: "Your email has changed!")
            }
        })
    }
}
