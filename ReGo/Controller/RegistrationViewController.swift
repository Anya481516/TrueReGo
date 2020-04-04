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

class RegistrationViewController : UIViewController {
    
    // MARK: ELEMENTS INIT:
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var currentUser : User?
    
    // MARK: DID_LOAD:
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: IBActions:
    @IBAction func editingStarted(_ sender: UITextField) {
        if sender.layer.borderColor == UIColor.red.cgColor
        {
            sender.layer.borderColor = UIColor.gray.cgColor
            self.view.layoutIfNeeded()
        }
        
        // тут надо поднять вьюху йоу и так же еще сделать так чтобы когда закончили, она назад опускалась ух
//        UIView.animate(withDuration: 0.5) {
//            //self.heightConstraint.constant = 308
//            self.view.layoutIfNeeded()
//        }
        
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        //SVProgressHUD.show()
        if let userName = usernameTextField.text {
            if let userEmail = emailTextField.text {
                if let userPassword = passwordTextField.text {
                    Auth.auth().createUser(withEmail: userEmail, password: userPassword) { (user, error) in
                        if error != nil {
                            print(error!)
                        }
                        else {
                            print("Succesfully registered")
                            // в каретн юзера занеcли инфу
                            self.currentUser = User(id: Auth.auth().currentUser!.uid, name: userName, email: userEmail, password: userPassword)
                            // сохранить инфу о юзере так же в базе данных йоууу
                            let userDB = Firebase.Database.database().reference().child("Users")
                                   
                            let userDictionary = ["UserId" : self.currentUser!.id, "Name" : self.currentUser!.name, "PlacesAdded" : self.currentUser!.placesAdded, "ProfilePicture" : false] as [String : Any]
                                   
                                   userDB.childByAutoId().setValue(userDictionary) {
                                       (error, reference) in
                                       if error != nil {
                                           print(error!)
                                       }
                                       else{
                                           print("User added to the DB")
                                       }
                                   }
                            //SVProgressHUD.dismiss()
                            // тут мы убрали вьюху с регой, и надо теперь поставить вьюху с уже не тем что было до реги, а с тем что после (Сначала надо создать ихихих c фоткой!)
                            self.dismiss(animated: true) {
                                
                            }
                        }
                    }
                }
                else {
                    passwordTextField.layer.borderColor = UIColor.red.cgColor
                    self.view.layoutIfNeeded()
                }
            }
            else {
                emailTextField.layer.borderColor = UIColor.red.cgColor
                self.view.layoutIfNeeded()
            }
        }
        else {
            usernameTextField.layer.borderColor = UIColor.red.cgColor
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func logInButtonPressed(_ sender: UIButton) {
    
    }
    
    // MARK: METHODS:
}
