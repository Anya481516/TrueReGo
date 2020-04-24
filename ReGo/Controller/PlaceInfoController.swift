//
//  PlaceInfoController.swift
//  ReGo
//
//  Created by Анна Мельхова on 21.04.2020.
//  Copyright © 2020 Anna Melkhova. All rights reserved.
//

import UIKit

protocol PlaceInfoDelegate {
    func getPlace() -> Place
}

class PlaceInfoConteoller : UIViewController {
    
    // MARK:- Variables:
    var delegate : MapViewController?
    
    
    // MARK:- IBOutlets:
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var addresLabel: UILabel!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var whtaItCollectsLabel: UILabel!
    @IBOutlet weak var bottleImage: UIImageView!
    @IBOutlet weak var bulbImage: UIImageView!
    @IBOutlet weak var otherImage: UIImageView!
    @IBOutlet weak var batteryImage: UIImageView!
    @IBOutlet weak var otherTextField: UITextField!
    @IBOutlet weak var editButton: UIButton!
    
    
    //MARK:- ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    // MARK:- IBActions:
    
}
