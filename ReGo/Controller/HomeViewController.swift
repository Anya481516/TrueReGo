//
//  HomeViewController.swift
//  ReGo
//
//  Created by Анна Мельхова on 30.03.2020.
//  Copyright © 2020 Anna Melkhova. All rights reserved.
//

import UIKit
import FirebaseStorage
import Kingfisher

class HomeViewController : UIViewController, RegistrationDelegate, LogInDelegate, EditProfileDelegate {
    
    //MARK:- PROPERTIES:
    let firebaseService = FirebaseService()
    
    //MARK: ---ABOutlets:---
    @IBOutlet weak var controllerTitleLabel: UILabel!
    @IBOutlet weak var requestLabel: UILabel!
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
    @IBOutlet weak var logInButton: ButtonWithImage!
    @IBOutlet weak var signUpButton: ButtonWithImage!
    @IBOutlet weak var langButton: ButtonWithImage!
    

    
    // MARK: didLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        clearLoggedInView()
        updateLang()
        
        // when info retrieced already
        if currentUser.name != "" {
            updateInterface()
        }
        // when info not retrieved but user is logged in
        else if firebaseService.isUserLoggedIn() {
            showLoggedInView()
            retrieveUserInfo()
            updateInterface()
        }
        else {
            print("not logged in")
            showNotLoggedInView()
        }
    }
    
    // MARK: ---IBActions:---
    
    // MARK: not loged in
    @IBAction func LoginButtonPressed(_ sender: ButtonWithImage) {
    }
    @IBAction func SignupButtonPressed(_ sender: ButtonWithImage) {
    }
    // MARK: loged in
    @IBAction func aboutButtonPressed(_ sender: UIButton) {
    }
    @IBAction func changeLanguageButtonPressed(_ sender: Any) {
        showAlertYesNo(alertTitle: myKeys.alert.changeLangTitle, alertMessage: myKeys.alert.changeLangQuestion, okActions: {
            if language == "RUS" {
                language = "ENG"
                myKeys.changeToEng()
            }
            else {
                language = "RUS"
                myKeys.changeToRus()
            }
            UserDefaults.standard.set(language, forKey: "Lang")
            self.updateLang()
        }) { }
    }
    @IBAction func editProfileButtonPressed(_ sender: Any) {
    }
    @IBAction func logOutButtonPressed(_ sender: Any) {
        showAlertYesNo(alertTitle: myKeys.alert.logoutTitle, alertMessage: myKeys.alert.logoutQuestion, okActions: {
            self.firebaseService.logout(success: {
                self.showAlertWithAction(alertTitle: myKeys.alert.successTitle, alertMessage: myKeys.alert.loggedoutMessage) {
                    self.showNotLoggedInView()
                }
            }) { (error) in
                self.showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: error, actionTitle: myKeys.alert.okButton)
            }
        }) { }
    }
    
    // MARK: METHODS:
    
    func updateLang() {
        controllerTitleLabel.text = myKeys.home.titleLabel
        logOutButton.setTitle(myKeys.home.logOutButton, for: .normal)
        requestLabel.text = myKeys.home.loginRequest
        logInButton.setTitle(myKeys.home.logInButton, for: .normal)
        signUpButton.setTitle(myKeys.home.signUpButton, for: .normal)
        usernameLabel.text = myKeys.home.usernameLabel
        emailLabel.text = myKeys.home.emailLabel
        placesLabel.text = myKeys.home.placesAddedLabel
        aboutButton.setTitle(myKeys.home.aboutButton, for: .normal)
        languageButton.setTitle(myKeys.home.changeLangButton, for: .normal)
        editButton.setTitle(myKeys.home.editPofileButton, for: .normal)
        langButton.setTitle(myKeys.home.changeLangButton, for: .normal)
        updateInterface()
    }
    
    func goToLogInView() {
        self.performSegue(withIdentifier: "fromHomeToLogin", sender: self)
    }
    func goToRegistrationView() {
        self.performSegue(withIdentifier: "fromHomeToRegistration", sender: self)
    }
    
    func updateInterface() {
        if currentUser.hasProfileImage {
            let url = URL(string: currentUser.imageURL)
            let resource = ImageResource(downloadURL: url!)
            self.profileImage.kf.setImage(with: resource) { (image, error, cacheType, url) in
                if let error = error {
                    print(error)
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
        self.placesLabel.text = "\(myKeys.home.placesAddedLabel)\(currentUser.placesAdded)"
        self.emailLabel.text = currentUser.email
        
        if firebaseService.isUserLoggedIn() {
            showLoggedInView()
        }
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        updateLang()
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
    
    func retrieveUserInfo(){
        firebaseService.retrieveUserInfo(id: currentUser.id) { (error) in
            self.showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: error, actionTitle: myKeys.alert.okButton)
        }
    }
}
