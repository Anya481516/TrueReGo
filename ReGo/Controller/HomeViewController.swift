//
//  HomeViewController.swift
//  ReGo
//
//  Created by Анна Мельхова on 30.03.2020.
//  Copyright © 2020 Anna Melkhova. All rights reserved.
//

import UIKit

class HomeViewController : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: METHODS:
    func goToNextView() {
        self.performSegue(withIdentifier: "fromHomeToLogin", sender: self)
    }
}
