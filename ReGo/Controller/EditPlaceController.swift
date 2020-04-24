//
//  EditPlaceController.swift
//  ReGo
//
//  Created by Анна Мельхова on 25.04.2020.
//  Copyright © 2020 Anna Melkhova. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import Kingfisher

class EditPlaceController : UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK:- Variables
    var imagePicker = UIImagePickerController()
    var delegate : MapViewController?
    var bottlesChecked = false
    var batteriesChecked = false
    var bulbsChecked = false
    var otherChecked = false
    var photoAdded = false
    var placeLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var newPlace = Place()
    
    // MARK:- IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var whatCollectsLabel: UILabel!
    @IBOutlet weak var bottlesButton: UIButton!
    @IBOutlet weak var batteriesButton: UIButton!
    @IBOutlet weak var bulbsButton: UIButton!
    @IBOutlet weak var otherButton: UIButton!
    @IBOutlet weak var otherThingsTextFiewld: UITextField!
    @IBOutlet weak var changePhotoButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var deletePhotoButton: UIButton!
    @IBOutlet weak var placeTitleLabel: UILabel!
    @IBOutlet weak var placeTitleTextField: UITextField!
    @IBOutlet weak var placeAddressLabel: UILabel!
    @IBOutlet weak var placeAddressTextField: UITextField!
    @IBOutlet weak var sendChangesButton: UIButton!
    
    
    // MARK:- LOCATION MAN
    let locationManager = CLLocationManager()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
            
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        let region = MKCoordinateRegion(center: placeLocation, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        mapView.setRegion(region, animated: true)
    }
    
    // MARK:- viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        locationManager.delegate = self

        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        
        // спрячем кнопку удаления фотки пока
        deletePhotoButton.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    // MARK:- IBActions
    @IBAction func locationButtonPressed(_ sender: UIButton) {
        //_____________-------------------------_______________---------___________-------
    }
    @IBAction func bottlesButtonPressed(_ sender: UIButton) {
        if bottlesChecked {
            bottlesChecked = false
            sender.backgroundColor = UIColor(named: "WhiteGray")
            newPlace.bottles = false
        }
        else {
            bottlesChecked = true
            sender.backgroundColor = UIColor(named: "DarkLightGreenTransparent")
            newPlace.bottles = true
        }
    }
    @IBAction func batteriesButtonPressed(_ sender: UIButton) {
        if batteriesChecked {
            batteriesChecked = false
            sender.backgroundColor = UIColor(named: "WhiteGray")
            newPlace.batteries = false
        }
        else {
            batteriesChecked = true
            sender.backgroundColor = UIColor(named: "DarkLightGreenTransparent")
            newPlace.batteries = true
        }
    }
    @IBAction func bulbsButtonPressed(_ sender: UIButton) {
        if bulbsChecked {
            bulbsChecked = false
            sender.backgroundColor = UIColor(named: "WhiteGray")
            newPlace.bulbs = false
        }
        else {
            bulbsChecked = true
            sender.backgroundColor = UIColor(named: "DarkLightGreenTransparent")
            newPlace.bulbs = true
        }
    }
    @IBAction func otherButtonPressed(_ sender: UIButton) {
        if otherChecked {
            otherChecked = false
            sender.backgroundColor = UIColor(named: "WhiteGray")
        }
        else {
            otherChecked = true
            sender.backgroundColor = UIColor(named: "DarkLightGreenTransparent")
        }
    }
    
    @IBAction func changePhotoButtonPressed(_ sender: UIButton) {
        showImageChooseAlert()
    }
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        if photoAdded {
            deletePhotoButton.isHidden = true
            photoAdded = false
            newPlace.hasImage = false
        }
    }
    @IBAction func sendChangesButtonPressed(_ sender: UIButton) {
        //_________________________________________________________________________________
    }
    
    // MARK:- METHODS:
    
    func showAlert(alertTitle : String, alertMessage : String) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (UIAlertAction) in
            
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    // with the keyboard
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= (keyboardSize.height)
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    
    // MARK:- ImagePicker
    func showImageChooseAlert() {
        var alert = UIAlertController(title: "Choose new profile image", message: nil, preferredStyle: .alert)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default){ UIAlertAction in
            self.openCamera()
        }
        let galleryAction = UIAlertAction(title: "Gallery", style: .default){ UIAlertAction in
            self.openGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){ UIAlertAction in
            
        }
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(.camera)){
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            showAlert(alertTitle: "Camera error", alertMessage: "We don't have access to your camera")
        }
    }
    
    func openGallery() {
        imagePicker.delegate = self
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false

        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        imageView.image = image
        photoAdded = true
        deletePhotoButton.isHidden = false
        newPlace.hasImage = true
    }
}
