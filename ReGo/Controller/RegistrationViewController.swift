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
//import FirebaseStorage

protocol RegistrationDelegate {
    func goToLogIn()
    func updateInterface()
    func showLoggedInView()
    func showNotLoggedInView()
}

class RegistrationViewController : UIViewController {
    
    //MARK:- PROPERTIES:
    var delegate : RegistrationDelegate?
    var firebaseService = FirebaseService()
    
    // MARK: IBOutlets:
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet var registrationView: UIView!
    
    // MARK: DID_LOAD:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLang()
        logInButton.setTitleColor(UIColor.init(named: "WhiteBlack"), for: .normal)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(outOfKeyBoardTapped))
        registrationView.addGestureRecognizer(tapGesture)
        self.emailTextField.keyboardType = UIKeyboardType.emailAddress
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
        if let userName = usernameTextField.text {
            if userName.isEmpty {
                // alert
                self.showAlertHighlitingTextfield(alertTitle: myKeys.alert.noUsernameLabel, alertMessage: myKeys.alert.noUsernameMessage, actionTitle: myKeys.alert.okButton, textField: self.usernameTextField)
            }
            else if let userEmail = emailTextField.text {
                if let userPassword = passwordTextField.text {
                    Auth.auth().createUser(withEmail: userEmail, password: userPassword) { (user, error) in
                        if let error = error {
                            print(error)
                            // описать что делать при каждых ошибочках
                            if userPassword.isEmpty {
                                self.showAlertHighlitingTextfield(alertTitle: myKeys.alert.noPasswordLabel, alertMessage: myKeys.alert.noPasswordMessage, actionTitle: myKeys.alert.okButton, textField: self.emailTextField)
                            }
                            else if userEmail.isEmpty {
                                self.showAlertHighlitingTextfield(alertTitle: myKeys.alert.noEmailLabel, alertMessage: myKeys.alert.noEmailMessage, actionTitle: myKeys.alert.okButton, textField: self.emailTextField)
                            }
                            else {
                                self.showAlertHighlitingTextfield(alertTitle: myKeys.alert.errTitle, alertMessage: error.localizedDescription, actionTitle: myKeys.alert.okButton, textField: self.emailTextField)
                            }
                        }
                        else {
                            print("Succesfully registered")
                            let userDB = Firebase.Database.database().reference().child("Users")
                                   
                            let userDictionary = ["Name" : currentUser.name, "PlacesAdded" : currentUser.placesAdded, "ProfilePicture" : false, "ImageURL" : currentUser.imageURL, "SuperUser" : currentUser.superUser] as [String : Any]
                                   userDB.child(currentUser.id).setValue(userDictionary) {
                                       (error, reference) in
                                       if let error = error {
                                           print(error)
                                        self.showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: error.localizedDescription, actionTitle: myKeys.alert.okButton)
                                       }
                                       else{
                                           print("User added to the DB")
                                        self.showAlert(alertTitle: myKeys.alert.successTitle, alertMessage: myKeys.alert.successfulRefistrataion, actionTitle: myKeys.alert.okButton)
                                       }
                                   }
                            self.dismiss(animated: true)
                            self.delegate?.showLoggedInView()
                            self.retrieveUserInfo()
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func logInButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.goToLogIn()
        }
    }
    
    // MARK: METHODS:
    
    func updateLang(){
        titleLabel.text = myKeys.loginRegistration.registrationTitleLabel
        usernameLabel.text = myKeys.loginRegistration.usenameLabel
        usernameTextField.placeholder = myKeys.loginRegistration.usernameTextField
        emailLabel.text = myKeys.loginRegistration.emailLabel
        emailTextField.placeholder = myKeys.loginRegistration.emailTextField
        passwordLabel.text = myKeys.loginRegistration.passwordLabel
        signupButton.setTitle(myKeys.loginRegistration.signUpButton, for: .normal)
        logInButton.setTitle(myKeys.loginRegistration.logInButton, for: .normal)
    }
    
    func showAlertHighlitingTextfield(alertTitle : String, alertMessage : String, actionTitle : String, textField : UITextField) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: actionTitle, style: .default) { (UIAlertAction) in
            textField.isHighlighted = true
            self.view.layoutIfNeeded()
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func outOfKeyBoardTapped(){
        self.view.endEditing(true)
    }
    
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
    
    func retrieveUserInfo(){
        firebaseService.retrieveUserInfo(id: currentUser.id, success: {
            self.delegate?.updateInterface()
        }) { (error) in
            self.showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: error, actionTitle: myKeys.alert.okButton)
        }
//        let userDB = Firebase.Database.database().reference().child("Users")
//
//        currentUser.id = Auth.auth().currentUser!.uid
//        currentUser.email = Auth.auth().currentUser!.email!
//
//        userDB.child(currentUser.id).observeSingleEvent(of: .value, with: { (snapshot) in
//            let snapshotValue = snapshot.value as! NSDictionary
//            currentUser.name = snapshotValue["Name"] as! String
//            currentUser.placesAdded = snapshotValue["PlacesAdded"] as! Int
//            currentUser.hasProfileImage = snapshotValue["ProfilePicture"] as! Bool
//            currentUser.superUser = snapshotValue["SuperUser"] as! Bool
//            currentUser.imageURL = snapshotValue["ImageURL"] as! String
//            print("Info retrieved !!!")
//            self.delegate?.updateInterface()
//            return
//        }) { (error) in
//            print(error.localizedDescription)
//        }
    }
}
