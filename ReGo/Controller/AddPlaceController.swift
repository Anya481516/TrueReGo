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
import Kingfisher

protocol AddPlaceDelegate {
    func updateInterface()
    func addNewAnnotation(ann : Place)
}

class AddPlaceController : UIViewController,  MKMapViewDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Variables:
    var imagePicker = UIImagePickerController()
    var delegate : MapViewController?
    var bottlesChecked = false
    var batteriesChecked = false
    var bulbsChecked = false
    var otherChecked = false
    var photoAdded = false
    
    var newPlace = Place()
    
    // MARK: IBOutlets:
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deletePhotoButton: UIButton!
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var otherButton: UIButton!
    @IBOutlet weak var bulbsButton: UIButton!
    @IBOutlet weak var batteriesButton: UIButton!
    @IBOutlet weak var bottlesButton: UIButton!
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
        
        // спрячем кнопку удаления фотки пока
        deletePhotoButton.isHidden = true
    }
    
    // MARK: IBActions:
    @IBAction func findMyLocationButtonPressed(_ sender: UIButton) {
         mapView.userTrackingMode = .follow
    }
    @IBAction func addPhotoButtonPressed(_ sender: Any) {
        if !photoAdded {
            photoAdded = true
            deletePhotoButton.isHidden = false
            showImageChooseAlert()
        }
    }
    @IBAction func deletePhotoButtonPressed(_ sender: UIButton) {
        if photoAdded {
            deletePhotoButton.isHidden = true
            photoAdded = false
        }
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
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        // initialize (with coordinates and id yo)
        newPlace.coordinate = mapView.region.center
        newPlace.id = "\(newPlace.coordinate.latitude)-\(newPlace.coordinate.longitude)"
        print(newPlace.id)
        
        if titleTextField.text == "" {
            showAlert(alertTitle: "Error", alertMessage: "Enter the title of the place")
            return
        }
        else if addressTextField.text == "" {
            showAlert(alertTitle: "Error", alertMessage: "Enter the address of the place")
            return
        }
        else if !bottlesChecked && !batteriesChecked && !bulbsChecked && !otherChecked && whatCollectsTextField.text == ""{
            showAlert(alertTitle: "Error", alertMessage: "Select what you can recycle at that place")
            return
        }
        else if otherChecked && whatCollectsTextField.text == "" {
            showAlert(alertTitle: "Error", alertMessage: "You have chosen option OTHER. Please enter ehat exaclty you can recycle at the place")
            return
        }
        // когда все необходимые поля заполнены то йоу идем дальше
        else {
            // выбираем тип
            if bottlesChecked && !batteriesChecked && !bulbsChecked && !otherChecked {
                newPlace.type = "Bottles"
            }
            else if !bottlesChecked && batteriesChecked && !bulbsChecked && !otherChecked {
                newPlace.type = "Batteries"
            }
            else if !bottlesChecked && !batteriesChecked && bulbsChecked && !otherChecked {
                newPlace.type = "Bulbs"
            }
            else if !bottlesChecked && batteriesChecked && bulbsChecked && !otherChecked {
                newPlace.type = "BatteriesAndBulbs"
            }
            else if !otherChecked {
                newPlace.type = "Other"
            }
            else {
                newPlace.type = "Other"
                newPlace.other = whatCollectsTextField.text!
            }
            
            // остальное заполняем
            if titleTextField.text != "" {
                newPlace.title = titleTextField.text!
            }
            if addressTextField.text != "" {
                newPlace.subtitle = addressTextField.text!
            }
            
            
            addNewAnnotationToDatabase(place: newPlace)
            
            
            if photoAdded {
                // добавить фотку в сторадж и в базу данных url
                saveImageToDatabase()
            }
            
            
        }
        
    }
    
    // MARK: METHODS:
    func addNewAnnotationToDatabase(place : Place) {
        var userDB = DatabaseReference()
        
        if currentUser.superUser {
            userDB = Firebase.Database.database().reference().child("Places")
            self.delegate?.addNewAnnotation(ann: newPlace)
            places.append(newPlace)
        }
        else {
            userDB = Firebase.Database.database().reference().child("NewPlaces")
        }
        
        let placeDictionary = ["Title" : place.title!, "Address" : place.subtitle!, "HasImage" : place.hasImage, "ImageURL" : place.imageURLString, "Longitude" : place.coordinate.longitude, "Latitude" : place.coordinate.latitude, "Type" : place.type, "Bottles" : place.bottles, "Batteries" : place.batteries, "Bulbs" : place.bulbs, "Other" : place.other, "UserID" : currentUser.id] as [String : Any]
        
        print("yo bitch \(place.id)")
        userDB.childByAutoId().setValue(placeDictionary)
    
        print("saved a place to database")
    }
    
    func saveImageToDatabase() {
        guard let image = placeImageView.image, let data = image.jpegData(compressionQuality: 1.0) else {
                showAlert(alertTitle: "Error", alertMessage: "Something went wrong with saving your Place photo to the storage.Try again.")
            return
        }
        
        let imageReference = Storage.storage().reference().child("PlaceImages").child(newPlace.id)
        
        // to the storage
        imageReference.putData(data, metadata: nil) { (metadata, error) in
            if let error = error {
                self.showAlert(alertTitle: "Error", alertMessage: error.localizedDescription)
                return
            }
            imageReference.downloadURL { (url, error) in
                if let error = error {
                    self.showAlert(alertTitle: "Error", alertMessage: error.localizedDescription)
                    return
                }
                guard let url = url else {
                    self.showAlert(alertTitle: "Error", alertMessage: "Something went wrong")
                    return
                }
                
                let urlString = url.absoluteString
                self.newPlace.imageURLString = urlString
                
                currentUser.hasProfileImage = true
                // update the Place info in the database
                if currentUser.superUser {
                    let userDB = Firebase.Database.database().reference().child("Places")
                    userDB.child(self.newPlace.id).updateChildValues(["ImageURL" : urlString, "HasImage" : true])
                }
                else {
                    let userDB = Firebase.Database.database().reference().child("NewPlaces")
                    userDB.child(self.newPlace.id).updateChildValues(["ImageURL" : urlString, "HasImage" : true])
                }
                
            }
            return
        }
    }
    
    func showAlert(alertTitle : String, alertMessage : String) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (UIAlertAction) in
            
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: ImagePicker
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
        placeImageView.image = image
    }
    
}
