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
import SVProgressHUD
//import FirebaseStorage

class HomeViewController : UIViewController, RegistrationDelegate, LogInDelegate, EditProfileDelegate {
    
    //MARK: ---ABOutlets:---
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var placesLabel: UILabel!
    @IBOutlet weak var loggedInView: UIView!
    @IBOutlet weak var notLoggedInView: UIView!
    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var languageButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var emailLabel: UILabel!
    
    // MARK: didLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        clearLoggedInView()
        
        if currentUser.name != "" {
            showLoggedInView()
            updateInterface()
        }
        else if let user = Auth.auth().currentUser {
            retrieveUserInfo()
        }
        else {
            showNotLoggedInView()
        }
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
    @IBAction func logOutButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Log out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Yes", style: .default) { (UIAlertAction) in
            do {
                try Auth.auth().signOut()
                self.showNotLoggedInView()
                currentUser = User()
                print("Logged Out")
            }
            catch {
                print("error, there was a problem with signing out")
            }
        }
        let action2 = UIAlertAction(title: "No", style: .default) { (UIAlertAction) in
            
        }
        alert.addAction(action1)
        alert.addAction(action2)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: METHODS:
    func goToLogInView() {
        self.performSegue(withIdentifier: "fromHomeToLogin", sender: self)
    }
    func goToRegistrationView() {
        self.performSegue(withIdentifier: "fromHomeToRegistration", sender: self)
    }
    
    func updateInterface() {
        self.usernameLabel.text = currentUser.name
        self.placesLabel.text = "Places added : \(currentUser.placesAdded)"
        self.emailLabel.text = "Email: \(currentUser.email)"
        print("updating info")
        print("UPDATING Name:\(currentUser.name), Places Added:\(currentUser.placesAdded)")
    }
    
    func clearLoggedInView() {
        usernameLabel.text = ""
        emailLabel.text = ""
        placesLabel.text = ""
    }
    
    // retrieve data from our FirebaseDatabase and put it to the current user
    func retrieveUserInfo() {
        let userDB = Firebase.Database.database().reference().child("Users")
        currentUser.id = Auth.auth().currentUser!.uid
        currentUser.email = Auth.auth().currentUser!.email as! String
        
        userDB.child(currentUser.id).observeSingleEvent(of: .value, with: { (snapshot) in
            let snapshotValue = snapshot.value as! NSDictionary
            currentUser.name = snapshotValue["Name"] as! String
            currentUser.placesAdded = snapshotValue["PlacesAdded"] as! Int
            currentUser.hasProfileImage = snapshotValue["ProfilePicture"] as! Bool
            self.updateInterface()
            self.showLoggedInView()
        }) { (error) in
            print(error)
        }
        
        // to check for updates
//        userDB.observe(.childChanged) { (snapshot) in
//            <#code#>
//        }
        
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
        else if (segue.identifier == "fromHomeToEdit") {
            let destinationVC = segue.destination as! EditProfileController
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
        //SVProgressHUD.show()
        profileImage.layer.cornerRadius = profileImage.frame.height / 3
        profileImage.layer.masksToBounds = true
        //SVProgressHUD.dismiss()
        logOutButton.isHidden = false
    }
    
    func showNotLoggedInView() {
        logOutButton.isHidden = true
        self.view.bringSubviewToFront(notLoggedInView)
    }
}
