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
import FirebaseStorage
import Kingfisher

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
        
        // when info retrieced already
        if currentUser.name != "" {
            updateInterface()
            
        }
        // when info not retrieved but user is logged in
        else if let user = Auth.auth().currentUser{
            //retrieveUserInfo()
            currentUser.retrieveInfoFromDatabase { (success) in
                updateInterface()
            }
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
        
        // TODO: KINGFISHER TO DOWNLOAD THE IMAGE!!! ______________________________________________
        if currentUser.hasProfileImage {
            let url = URL(string: currentUser.imageURL)
            let resource = ImageResource(downloadURL: url!)
            self.profileImage.kf.setImage(with: resource) { (image, error, cacheType, url) in
                if let error = error {
                    print("Error!!!!!! from updating image in Home")
                }
                else {
                    print("Success updated image in Home")
                }
            }
        }
        else {
            profileImage.image = UIImage(named: "ReGO iPhone8 LoadScreen")
        }
        
        self.usernameLabel.text = currentUser.name
        self.placesLabel.text = "Places added : \(currentUser.placesAdded)"
        self.emailLabel.text = "Email: \(currentUser.email)"
        
        print("updating info")
        print("UPDATING Name:\(currentUser.name), Places Added:\(currentUser.placesAdded)")
        showLoggedInView()
    }
    
    func clearLoggedInView() {
        usernameLabel.text = ""
        emailLabel.text = ""
        placesLabel.text = ""
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
        profileImage.layer.cornerRadius = profileImage.frame.height / 3
        profileImage.layer.masksToBounds = true
        logOutButton.isHidden = false
    }
    
    func showNotLoggedInView() {
        logOutButton.isHidden = true
        self.view.bringSubviewToFront(notLoggedInView)
    }
}
