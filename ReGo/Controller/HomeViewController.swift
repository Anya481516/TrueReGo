//
//  HomeViewController.swift
//  ReGo
//
//  Created by Анна Мельхова on 30.03.2020.
//  Copyright © 2020 Anna Melkhova. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
//import FirebaseStorage

class HomeViewController : UIViewController, RegistrationDelegate, LogInDelegate {
    
    // MARK: variables:
    var currentUser = User()
    
    
    //MARK: ---ABOutlets:---
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var placesLabel: UILabel!
    @IBOutlet weak var loggedInView: UIView!
    @IBOutlet weak var notLoggedInView: UIView!
    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var languageButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    // MARK: didLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.layer.cornerRadius = profileImage.frame.height / 2 - 15
        profileImage.layer.masksToBounds = true
    }
    
    // MARK: ---IBActions:---
    //
    // MARK: not loged in
    @IBAction func LoginButtonPressed(_ sender: ButtonWithImage) {
    }
    @IBAction func SignupButtonPressed(_ sender: ButtonWithImage) {
    }
    // MARK: loged in
    @IBAction func aboutButtonPressed(_ sender: UIButton) {
    }
    @IBAction func changeLanguageButtonPressed(_ sender: Any) {
    }
    @IBAction func editProfileButtonPressed(_ sender: Any) {
    }
    
    // MARK: METHODS:
    func goToLogInView() {
        self.performSegue(withIdentifier: "fromHomeToLogin", sender: self)
    }
    func goToRegistrationView() {
        self.performSegue(withIdentifier: "fromHomeToRegistration", sender: self)
    }
    
    func updateInterface() {
        
    }
    
    // retrieve data from our FirebaseDatabase and put it to the current user
    func retrieveUserInfo() {
        
        let userDB = Firebase.Database.database().reference().child("Users")
        self.currentUser.id = Auth.auth().currentUser!.uid
        
        userDB.child(currentUser.id).observeSingleEvent(of: .value, with: { (snapshot) in
            let snapshotValue = snapshot.value as! NSDictionary
            self.currentUser.name = snapshotValue["Name"] as! String
            self.currentUser.placesAdded = snapshotValue["PlacesAdded"] as! Int
            self.currentUser.hasProfileImage = snapshotValue["ProfilePicture"] as! Bool
            self.currentUser.email = Auth.auth().currentUser!.email as! String

            //print(text, sender)

            self.usernameLabel.text = self.currentUser.name
            self.placesLabel.text = "Places added : \(self.currentUser.placesAdded)"
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    // prepare method
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromHomeToRegistration" {
            let destinationVC = segue.destination as! RegistrationViewController
            destinationVC.delegate = self
        }
        else if segue.identifier == "fromHomeToLogin" {
            let destinationVC = segue.destination as! LogInViewController
            destinationVC.delegate = self
        }
    }
    
    //MARK: from delegate
    func goToLogIn(){
        goToLogInView()
    }
    
    func goToRegistration() {
        goToRegistrationView()
    }
    
    func showLoggedInView() {
        self.view.bringSubviewToFront(loggedInView)
        // взять инфу о юзере с firebase
        retrieveUserInfo()
        updateInterface()
    }
}
