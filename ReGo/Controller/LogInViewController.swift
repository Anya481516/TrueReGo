//
//  LogInViewController.swift
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

protocol LogInDelegate {
    func goToRegistration()
    func retrieveUserInfo()
    func showLoggedInView()
}

class LogInViewController : UIViewController {
    
    //MARK: variables:
       var delegate : LogInDelegate?
    
    // MARK: IBOutlets:
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var eyeButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        //signUpButton.currentTitleColor = UIColor.init(named: "BlackWhite")
        //signUpButton.setTitleColor(UIColor.init(named: "BlackWhite"), for: .normal)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func editingStarted(_ sender: UITextField) {
        // тут надо поднять вьюху йоу и так же еще сделать так чтобы когда закончили, она назад опускалась ух
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.goToRegistration()
        }
    }
    
    @IBAction func logInButtonPressed(_ sender: UIButton) {
        if let userEmail = emailTextField.text {
            if let userPassword = passwordTextField.text {
                Auth.auth().signIn(withEmail: userEmail, password: userPassword) { (user, error) in
                    if error != nil {
                        print(error!)
                        // описать что делать при каждых ошибочках
                        if userPassword.isEmpty || userPassword.count < 6{
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
                        print("Succesfully logged in")
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
