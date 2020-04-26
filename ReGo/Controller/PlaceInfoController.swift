//
//  PlaceInfoController.swift
//  ReGo
//
//  Created by Анна Мельхова on 21.04.2020.
//  Copyright © 2020 Anna Melkhova. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import CoreLocation
import Kingfisher

protocol PlaceInfoDelegate {
    func getPlace() -> Place
    func getCurretLocation() -> CLLocation
}

class PlaceInfoController : UIViewController, AddPlaceDelegate {
    
    func addNewAnnotation(ann: Place) {
        
    }
    
    // MARK:- Variables:
    var delegate : MapViewController?
    var currentPlace = Place()
    var distanceM = Int()
    var distanceK = Int()
    
    // MARK:- IBOutlets:
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addresLabel: UILabel!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var whtaItCollectsLabel: UILabel!
    @IBOutlet weak var bottleImage: UIImageView!
    @IBOutlet weak var bulbImage: UIImageView!
    @IBOutlet weak var otherImage: UIImageView!
    @IBOutlet weak var batteryImage: UIImageView!
    @IBOutlet weak var otherTextField: UITextField!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var waitingThing: UIActivityIndicatorView!
    
    
    //MARK:- ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        waitingThing.isHidden = true
        currentPlace = Place( place: delegate!.getPlace() )
        let currentLocation = delegate?.getCurretLocation()
        distanceM = Int(CLLocation(latitude: currentPlace.coordinate.latitude, longitude: currentPlace.coordinate.longitude).distance(from: currentLocation!))
        if distanceM > 999 {
            distanceK = distanceM / 1000
            distanceM = distanceM - distanceK * 1000
        }
        updateInterface()
    }
    
    
    // MARK:- IBActions:
    @IBAction func editButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func goButtonPressed(_ sender: UIButton) {
        
    }
    
    
    //MARK:- METHODS:
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromInfoToEditPlace" {
            let destinationVC = segue.destination as! AddAndEditPlaceController
            destinationVC.placeInfoDelegate = self
            destinationVC.oldPlace = Place(place: currentPlace)
            destinationVC.newPlace = Place(place: currentPlace)
            destinationVC.editView = true
        }
    }
    
    func updateInterface() {
        if currentPlace.hasImage {
            waitingThing.isHidden = false
            if currentUser.imageURL != "" {
                let url = URL(string: currentPlace.imageURLString)
                //self.placeImage.sd_setImage(with: url) { (image, error, SDImageCacheType, URL) in }
                let resource = ImageResource(downloadURL: url!)
                self.placeImage.kf.setImage(with: resource) { (image, error, cacheType, url) in
                    if let error = error {
                        print(error)
                    }
                    else {
                        self.waitingThing.isHidden = true
                        print("Success updated image in edit view")
                    }
                }
            }
        }
        distanceLabel.text = "\(distanceK).\(distanceM) km from you"
        titleTextField.text = currentPlace.title
        addressTextField.text = currentPlace.address
        if currentPlace.bottles == false {
            bottleImage.image = UIImage(named: "BottleUnchecked")
        }
        if currentPlace.batteries == false {
            batteryImage.image = UIImage(named: "BatteryUnchecked")
        }
        if currentPlace.bulbs == false {
            bulbImage.image = UIImage(named: "BulbUnchecked")
        }
        if currentPlace.other == "" {
            otherImage.image = UIImage(named: "OtherUnchecked")
            otherTextField.text = "It doesn't collect any specific things"
        }
        else {
            otherImage.image = UIImage(named: "OtherChecked")
            otherTextField.text = currentPlace.other
        }
    }
    
}
