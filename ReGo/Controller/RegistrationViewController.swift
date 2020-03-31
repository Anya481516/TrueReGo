//
//  RegistrationViewController.swift
//  ReGo
//
//  Created by Анна Мельхова on 31.03.2020.
//  Copyright © 2020 Anna Melkhova. All rights reserved.
//

import UIKit

class RegistrationViewController : UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func editingStarted(_ sender: UITextField) {
        // тут надо поднять вьюху йоу и так же еще сделать так чтобы когда закончили, она назад опускалась ух
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func logInButtonPressed(_ sender: UIButton) {
    
    }
    
}
