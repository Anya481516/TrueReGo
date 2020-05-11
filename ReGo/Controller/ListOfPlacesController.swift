//
//  ListOfPlacesController.swift
//  ReGo
//
//  Created by Анна Мельхова on 27.04.2020.
//  Copyright © 2020 Anna Melkhova. All rights reserved.
//

import UIKit

class ListOfPlacesController: UIViewController {
    
    //MARK:_variables:
    
    // MARK:- IBOutlets:
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK:- ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLang()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateLang()
    }
    
    // MARK:-METHODS:
    func updateLang(){
        titleLabel.text = myKeys.list.listOfPlacesTitle
    }
}
