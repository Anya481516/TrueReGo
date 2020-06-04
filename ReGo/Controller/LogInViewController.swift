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
//import FirebaseStorage

protocol LogInDelegate {
    func goToRegistration()
    func updateInterface()
    func showLoggedInView()
    func showNotLoggedInView()
}

class LogInViewController : UIViewController {
    
    //MARK: variables:
    var delegate : LogInDelegate?
    
    // MARK: IBOutlets:
    @IBOutlet var logInView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
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
                Auth.auth().signIn(withEmail: userEmail, password: userPassword) { (user, error) in
                    if let error = error {
                        print(error)
                        if userPassword.isEmpty{
                            self.showAlert(alertTitle: myKeys.alert.noPasswordLabel, alertMessage: myKeys.alert.noPasswordMessage, actionTitle: myKeys.alert.okButton)
                        }
                        else if userEmail.isEmpty {
                            self.showAlert(alertTitle: myKeys.alert.noEmailLabel, alertMessage: myKeys.alert.noEmailMessage, actionTitle: myKeys.alert.okButton)
                        }
                        else {
                            self.showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: error.localizedDescription, actionTitle: myKeys.alert.okButton)
                        }
                    }
                    else {
                        print("Succesfully logged in")
                        self.dismiss(animated: true)
                        self.delegate?.showLoggedInView()
                        self.retrieveUserInfo()
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
        let result = currentUser.sendPasswordByEmail(email: currentUser.email)
        if result == "Success" {
            self.showAlert(alertTitle: myKeys.alert.successTitle, alertMessage: "\(myKeys.alert.linkSentTo)\(currentUser.email)\(myKeys.alert.checkEmail)", actionTitle: myKeys.alert.okButton)
        }
        else {
            self.showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: result, actionTitle: myKeys.alert.okButton)
        }
    }
    
    func retrieveUserInfo(){
        let userDB = Firebase.Database.database().reference().child("Users")
        
        currentUser.id = Auth.auth().currentUser!.uid
        currentUser.email = Auth.auth().currentUser!.email!
        
        userDB.child(currentUser.id).observeSingleEvent(of: .value, with: { (snapshot) in
            let snapshotValue = snapshot.value as! NSDictionary
            currentUser.name = snapshotValue["Name"] as! String
            currentUser.placesAdded = snapshotValue["PlacesAdded"] as! Int
            currentUser.hasProfileImage = snapshotValue["ProfilePicture"] as! Bool
            currentUser.superUser = snapshotValue["SuperUser"] as! Bool
            currentUser.imageURL = snapshotValue["ImageURL"] as! String
            print("Info retrieved !!!")
            self.delegate?.updateInterface()
            return
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}
