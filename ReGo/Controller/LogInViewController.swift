//
//  LogInViewController.swift
//  ReGo
//
//  Created by Анна Мельхова on 31.03.2020.
//  Copyright © 2020 Anna Melkhova. All rights reserved.
//

import UIKit

protocol LogInDelegate {
    func goToRegistration()
    func updateInterface()
    func showLoggedInView()
    func showNotLoggedInView()
}

class LogInViewController : UIViewController {
    
    //MARK: variables:
    var delegate : LogInDelegate?
    let firebaseService = FirebaseService()
    let authService = AuthService()
    
    // MARK: IBOutlets:
    @IBOutlet var logInView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var eyeButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLang()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(outOfKeyBoardTapped))
        logInView.addGestureRecognizer(tapGesture)
        self.emailTextField.keyboardType = UIKeyboardType.emailAddress
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func editingStarted(_ sender: UITextField) {
       
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: UIButton) {
        sendPasswordByEmail()
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.goToRegistration()
        }
    }
    
    @IBAction func logInButtonPressed(_ sender: UIButton) {
        if let userEmail = emailTextField.text {
            if let userPassword = passwordTextField.text {
                if userEmail.isEmpty {
                    self.showAlert(alertTitle: myKeys.alert.noEmailLabel, alertMessage: myKeys.alert.noEmailMessage, actionTitle: myKeys.alert.okButton)
                }
                else {
                    if userPassword.isEmpty {
                        self.showAlert(alertTitle: myKeys.alert.noPasswordLabel, alertMessage: myKeys.alert.noPasswordMessage, actionTitle: myKeys.alert.okButton)
                    }
                    else {
                        //
                        authService.signin(email: userEmail, password: userPassword, success: {
                            self.dismiss(animated: true)
                            self.delegate?.showLoggedInView()
                            self.retrieveUserInfo()
                        }, failure: { (error) in
                            self.showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: error, actionTitle: myKeys.alert.okButton)
                        })
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
    
    // MARK:- METHODS:
    
    func updateLang(){
        titleLabel.text = myKeys.loginRegistration.logInTitleLabel
        emailLabel.text = myKeys.loginRegistration.emailLabel
        emailTextField.placeholder = myKeys.loginRegistration.emailTextField
        passwordLabel.text = myKeys.loginRegistration.passwordLabel
        loginButton.setTitle(myKeys.loginRegistration.logInButton, for: .normal)
        forgotPasswordButton.setTitle(myKeys.loginRegistration.forgotPasswordButton, for: .normal)
        signUpButton.setTitle(myKeys.loginRegistration.signUpButton, for: .normal)
    }
    
    // with the keyboard
    
    @objc func outOfKeyBoardTapped(){
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= (keyboardSize.height)
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func sendPasswordByEmail() {
        let alert = UIAlertController(title: myKeys.alert.attention, message: myKeys.loginRegistration.enterTheEmail, preferredStyle: .alert)
        alert.addTextField { (textField) in

        }
        let action1 = UIAlertAction(title: myKeys.alert.cancelButton, style: .cancel) { (UIAlertAction) in
            
        }
        let action2 = UIAlertAction(title: myKeys.alert.doneButton, style: .default) { (UIAlertAction) in
            let textField = alert.textFields![0]
            if let email = textField.text {
                self.firebaseService.sendPasswordByEmail(email: email) { (result) in
                   self.showAlert(alertTitle: myKeys.alert.attention, alertMessage: result, actionTitle: myKeys.alert.okButton)
               }
            }
        }
        alert.addAction(action1)
        alert.addAction(action2)
        self.present(alert, animated: true, completion: nil)
    }
    
    func retrieveUserInfo(){
        firebaseService.retrieveUserInfo(id: currentUser.id, success: {
            self.delegate?.updateInterface()
        }) { (error) in
            self.showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: error, actionTitle: myKeys.alert.okButton)
        }
    }
}
