//
//  HomeViewController.swift
//  ReGo
//
//  Created by Анна Мельхова on 30.03.2020.
//  Copyright © 2020 Anna Melkhova. All rights reserved.
//

import UIKit

class HomeViewController : UIViewController, RegistrationDelegate, LogInDelegate {
    //MARK: ---ABOutlets:---
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var placesLabel: UILabel!
    @IBOutlet weak var loggedInView: UIView!
    @IBOutlet weak var notLoggedInView: UIView!
    
    // MARK: didLoad
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    func goToLogIn(){
        goToLogInView()
    }
    
    func goToRegistration() {
        goToRegistrationView()
    }
    
    func showLoggedInView() {
        self.view.bringSubviewToFront(loggedInView)
    }
}
