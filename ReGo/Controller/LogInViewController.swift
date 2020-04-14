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
                    if error != nil {
                        print(error!)
                        // описать что делать при каждых ошибочках
                        if userPassword.isEmpty || userPassword.count < 6{
                            self.showAlert(alertTitle: "Incorrect Password", alertMessage: error!.localizedDescription)
                        }
                        else if userEmail.isEmpty {
                            self.showAlert(alertTitle: "Incorrect Email", alertMessage: error!.localizedDescription)
                        }
                        else {
                            self.showAlert(alertTitle: "Error", alertMessage: error!.localizedDescription)
                        }
                    }
                    else {
                        print("Succesfully logged in")
                        // TODO: тут мы убрали вьюху с регой, и надо теперь поставить вьюху с уже не тем что было до реги, а с тем что после (Сначала надо создать ихихих c фоткой!)
                        self.dismiss(animated: true)
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
    
    // MARK: METHODS:
    
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
    
    func sendPasswordByEmail() {
        let result = currentUser.sendPasswordByEmail(email: currentUser.email)
        if result == "Success" {
            self.showAlert(alertTitle: "Success!", alertMessage: "Your link to change password was sent to \(currentUser.email). Check you email")
        }
        else {
            self.showAlert(alertTitle: "Error", alertMessage: result)
        }
    }
    
    func showAlert(alertTitle : String, alertMessage : String) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (UIAlertAction) in
            
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
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
            // here
            self.delegate?.updateInterface()
            return
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}
