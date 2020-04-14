//
//  AddPlaceController.swift
//  ReGo
//
//  Created by Анна Мельхова on 13.04.2020.
//  Copyright © 2020 Anna Melkhova. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class AddPlaceController : UIViewController,  MKMapViewDelegate, CLLocationManagerDelegate {
    
    // MARK: IBOutlets:
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var deletePhotoButton: UIButton!
    @IBOutlet weak var imaveView: UIImageView!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var otherButton: UIButton!
    @IBOutlet weak var bulbsButton: UIButton!
    @IBOutlet weak var batteriesButton: UIButton!
    @IBOutlet weak var buttlesButton: UIButton!
    @IBOutlet weak var whatCollectsLabel: UILabel!
    @IBOutlet weak var whatCollectsTextField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    // MARK: LOCATION MAN
    let locationManager = CLLocationManager()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
            
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    
    // MARK: ViewDidLoad:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        locationManager.delegate = self

        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
    }
    
    // MARK: IBActions:
    @IBAction func findMyLocationButtonPressed(_ sender: UIButton) {
         mapView.userTrackingMode = .follow
    }
    @IBAction func addPhotoButtonPressed(_ sender: Any) {
    }
    @IBAction func deletePhotoButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func bottlesButtonPressed(_ sender: UIButton) {
    }
    @IBAction func batteriesButtonPressed(_ sender: UIButton) {
    }
    @IBAction func bulbsButtonPressed(_ sender: UIButton) {
    }
    @IBAction func otherButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
    }
    
    // MARK: METHODS:
    func addNewAnnotationToDatabase(pinTitle : String, pinSubTitle : String, location : CLLocationCoordinate2D) {
        
    }
    
    func saveImageToDatabase() {
        
    }
    
    func showAlert(alertTitle : String, alertMessage : String) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (UIAlertAction) in
            
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
}
