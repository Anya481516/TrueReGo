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

class AddAndEditPlaceController : UIViewController,  MKMapViewDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Variables:
    var imagePicker = UIImagePickerController()
    var delegate : MapViewController?
    var placeInfoDelegate : PlaceInfoController?
    var bottlesChecked = false
    var batteriesChecked = false
    var bulbsChecked = false
    var otherChecked = false
    var photoAdded = false
    var placeLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var newPlace = Place()
    var oldPlace = Place()
    var editView = false
    
    // MARK: IBOutlets:
    @IBOutlet weak var controllerTitleLabel: UILabel!
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
    @IBOutlet weak var mapEnablerButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var disableView: UIView!
    @IBOutlet weak var mapPin: UIImageView!
    @IBOutlet weak var waitingThing: UIActivityIndicatorView!
    
    // MARK:- LOCATION MAN
    let locationManager = CLLocationManager()
    var previousLocation : CLLocation?
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
            
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        previousLocation = getCenterLocation(for: mapView)

        if editView {
            placeLocation = oldPlace.coordinate
        }
        
        let region = MKCoordinateRegion(center: placeLocation, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        
        // checking if the new location canges a lot
        guard let previousLocation = self.previousLocation else {return}
        guard center.distance(from: previousLocation) > 50 else { return }
        self.previousLocation = center
        
        getAddress()
    }
    
    // MARK: ViewDidLoad:
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLang()
        waitingThing.isHidden = true
        
        self.mapView.delegate = self
        locationManager.delegate = self

        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        //showPlaceAddress()
        getAddress()
        
        if editView {
            controllerTitleLabel.text = myKeys.addAndEdit.editPlaceTitleLabel
            updateInterface()
            if oldPlace.hasImage {
                deletePhotoButton.isHidden = false
            }
            else {
                deletePhotoButton.isHidden = true
            }
        }
        else {
            deletePhotoButton.isHidden = true
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: IBActions:
    
    @IBAction func mapEnablerButtonPressed(_ sender: UIButton) {
        if mapView.isScrollEnabled {
            mapView.isScrollEnabled = false
            mapView.isZoomEnabled = false
            sender.setImage(UIImage(systemName: "lock.fill"), for: .normal)
            sender.backgroundColor = UIColor(named: "GreenTransparent")
            sender.setTitle(myKeys.addAndEdit.enableMapButton, for: .normal)
            //locationButton.isEnabled = false
            disableView.isHidden = false
        }
        else {
            mapView.isScrollEnabled = true
            mapView.isZoomEnabled = true
            sender.setImage(UIImage(systemName: "lock.open.fill"), for: .normal)
            sender.backgroundColor = UIColor(named: "RedTransparent")
            sender.setTitle(myKeys.addAndEdit.disableMapButton, for: .normal)
            //locationButton.isEnabled = true
            disableView.isHidden = true
        }
    }
    
    @IBAction func layerButtonPressed(_ sender: UIButton) {
        if mapView.mapType == MKMapType.standard {
            mapView.mapType = MKMapType.satellite
        }
        else {
            mapView.mapType = MKMapType.standard
        }
    }
    @IBAction func findMyLocationButtonPressed(_ sender: UIButton) {
        //mapView.userTrackingMode = .follow
        let region = MKCoordinateRegion(center: placeLocation, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func addPhotoButtonPressed(_ sender: Any) {
            showImageChooseAlert()
    }
    
    @IBAction func deletePhotoButtonPressed(_ sender: UIButton) {
        if photoAdded {
            deletePhotoButton.isHidden = true
            photoAdded = false
            newPlace.hasImage = false
            placeImageView.image = nil
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
        self.view.bringSubviewToFront(waitingThing)
        waitingThing.isHidden = false
        
        
        // initialize (with coordinates and id yo)
        newPlace.coordinate = mapView.region.center
        
        if titleTextField.text == "" {
            showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: myKeys.alert.enterTitle)
            return
        }
        else if addressTextField.text == "" {
            showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: myKeys.alert.enterAddress)
            return
        }
        else if !bottlesChecked && !batteriesChecked && !bulbsChecked && !otherChecked && whatCollectsTextField.text == ""{
            showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: myKeys.alert.whatRecycle)
            return
        }
        else if otherChecked && whatCollectsTextField.text == "" {
            showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: myKeys.alert.writeOther)
            return
        }
        // когда все необходимые поля заполнены то йоу идем дальше
        else {
            // выбираем тип
            if bottlesChecked && !batteriesChecked && !bulbsChecked && !otherChecked {
                newPlace.subtitle = "Bottles"
            }
            else if !bottlesChecked && batteriesChecked && !bulbsChecked && !otherChecked {
                newPlace.subtitle = "Batteries"
            }
            else if !bottlesChecked && !batteriesChecked && bulbsChecked && !otherChecked {
                newPlace.subtitle = "Bulbs"
            }
            else if !bottlesChecked && batteriesChecked && bulbsChecked && !otherChecked {
                newPlace.subtitle = "BatteriesAndBulbs"
            }
            else if !otherChecked {
                newPlace.subtitle = "Other"
            }
            else {
                newPlace.subtitle = "Other"
                newPlace.other = whatCollectsTextField.text!
            }
            
            // остальное заполняем
            if titleTextField.text != "" {
                newPlace.title = titleTextField.text!
            }
            if addressTextField.text != "" {
                newPlace.address = addressTextField.text!
            }
            
            if editView{
                editAnnotationInDatabase(newPlace: newPlace, oldPlace: oldPlace)
            }
            else {
                addNewAnnotationToDatabase(place: newPlace)
            }
            
            
        }
        
    }
    
    // MARK:- METHODS:
    
    func updateLang(){
        controllerTitleLabel.text = myKeys.addAndEdit.addNewPlaceTitleLabel
        mapEnablerButton.setTitle(myKeys.addAndEdit.enableMapButton, for: .normal)
        whatCollectsLabel.text = myKeys.addAndEdit.whatDoesItCollectLabel
        bottlesButton.setTitle(myKeys.addAndEdit.bottlesButton, for: .normal)
        batteriesButton.setTitle(myKeys.addAndEdit.batteriesButton, for: .normal)
        bulbsButton.setTitle(myKeys.addAndEdit.bulbsButton, for: .normal)
        otherButton.setTitle(myKeys.addAndEdit.otherButton, for: .normal)
        whatCollectsTextField.text = myKeys.addAndEdit.otherTextField
        addPhotoButton.setTitle(myKeys.addAndEdit.addPhotoButton, for: .normal)
        titleLabel.text = myKeys.addAndEdit.titleLabel
        titleTextField.placeholder = myKeys.addAndEdit.titleTextField
        addressLabel.text = myKeys.addAndEdit.addressLabel
        addressTextField.placeholder = myKeys.addAndEdit.addressTextField
        sendButton.setTitle(myKeys.addAndEdit.sendButton, for: .normal)
    }
    
    func getAddress() {
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            if let _ = error {
                //TODO: show alert
                return
            }
            guard let placemark = placemarks?.first else {
                //TODO: show alert
                return
            }
            
            let streetName = placemark.thoroughfare ?? ""
            let streetNumber = placemark.subThoroughfare ?? ""
            
            DispatchQueue.main.async {
                self.addressTextField.text = "\(streetName) \(streetNumber)"
            }
        }
    }
    
    // address
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
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
    
    func addNewAnnotationToDatabase(place : Place) {
        var userDB = DatabaseReference()
        
        if currentUser.superUser {
            addCountPlacesToUser()
            userDB = Firebase.Database.database().reference().child("Places")
            self.delegate?.addNewAnnotation(ann: newPlace)
            places.append(newPlace)
        }
        else {
            userDB = Firebase.Database.database().reference().child("NewPlaces")
        }
        
        // created an ID for DB
        let randomID = userDB.childByAutoId()
        newPlace.id = randomID.key!
        
        let placeDictionary = ["Title" : place.title!, "Address" : place.address, "HasImage" : place.hasImage, "ImageURL" : place.imageURLString, "Longitude" : place.coordinate.longitude, "Latitude" : place.coordinate.latitude, "Type" : place.subtitle!, "Bottles" : place.bottles, "Batteries" : place.batteries, "Bulbs" : place.bulbs, "Other" : place.other, "UserID" : currentUser.id, "ID" : newPlace.id] as [String : Any]
        print("yo bitch \(newPlace.id)")
        
        userDB.child(newPlace.id).setValue(placeDictionary)
    
        print("saved a place to database")
        
        if place.hasImage {
            // добавить фотку в сторадж и в базу данных url
            saveImageToDatabase()
        }
        else {
            self.delegate?.retrieveAnnotations()
            self.showAlertWithClosingView(alertTitle: myKeys.alert.thankYou, alertMessage: myKeys.alert.placeAdded)
        }
        
        
    }
    
    func editAnnotationInDatabase(newPlace: Place, oldPlace: Place) {
        var userDB = DatabaseReference()
        
        if currentUser.superUser {
            userDB = Firebase.Database.database().reference().child("Places")
            self.delegate?.addNewAnnotation(ann: newPlace)
            places.append(newPlace)
        }
        else {
            userDB = Firebase.Database.database().reference().child("NewPlaces")
        }
        
        let placeDictionary = ["Title" : newPlace.title!, "Address" : newPlace.address, "HasImage" : newPlace.hasImage, "ImageURL" : newPlace.imageURLString, "Longitude" : newPlace.coordinate.longitude, "Latitude" : newPlace.coordinate.latitude, "Type" : newPlace.subtitle!, "Bottles" : newPlace.bottles, "Batteries" : newPlace.batteries, "Bulbs" : newPlace.bulbs, "Other" : newPlace.other, "UserID" : currentUser.id, "ID" : newPlace.id] as [String : Any]
        print("yo bitch \(newPlace.id)")
        
        userDB.child(newPlace.id).updateChildValues(placeDictionary)
        
        if newPlace.hasImage {
            // добавить фотку в сторадж и в базу данных url
            saveImageToDatabase()
        }
        else {
            self.delegate?.retrieveAnnotations()
            self.showAlertWithClosingView(alertTitle: myKeys.alert.thankYou, alertMessage: myKeys.alert.placeEdited)
        }
    }
    
    func saveImageToDatabase() {
        newPlace.hasImage = false;
        guard let image = placeImageView.image, let data = image.jpegData(compressionQuality: 1.0) else {
                showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: myKeys.alert.saveImageToDatabaseErrorMessage)
            return
        }
        
        let imageReference = Storage.storage().reference().child("PlaceImages").child(newPlace.id)
        
        // to the storage
        imageReference.putData(data, metadata: nil) { (metadata, error) in
            if let error = error {
                self.showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: error.localizedDescription)
                return
            }
            imageReference.downloadURL { (url, error) in
                if let error = error {
                    self.showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: error.localizedDescription)
                    return
                }
                guard let url = url else {
                    self.showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: myKeys.alert.somethingWendWrong)
                    return
                }
                
                let urlString = url.absoluteString
                self.newPlace.hasImage = true
                self.newPlace.imageURLString = urlString
                
                // update the Place info in the database
                if currentUser.superUser {
                    let userDB = Firebase.Database.database().reference().child("Places")
                    userDB.child(self.newPlace.id).updateChildValues(["ImageURL" : urlString, "HasImage" : true])
                }
                else {
                    let userDB = Firebase.Database.database().reference().child("NewPlaces")
                    userDB.child(self.newPlace.id).updateChildValues(["ImageURL" : urlString, "HasImage" : true])
                }
                self.delegate?.retrieveAnnotations()
                if self.editView {
                     self.showAlertWithClosingView(alertTitle: myKeys.alert.thankYou, alertMessage: myKeys.alert.placeEdited)
                }
                else {
                     self.showAlertWithClosingView(alertTitle: myKeys.alert.thankYou, alertMessage: myKeys.alert.placeAdded)
                }
               
            }
            return
        }
        
       // self.dismiss(animated: true, completion: nil)
    }
    
    func addCountPlacesToUser() {
        currentUser.placesAdded = currentUser.placesAdded + 1
        let userDB = Firebase.Database.database().reference().child("Users")
        userDB.child(currentUser.id).updateChildValues(["PlacesAdded" : currentUser.placesAdded])
    }
    
    func showAlert(alertTitle : String, alertMessage : String) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: myKeys.alert.okButton, style: .default) { (UIAlertAction) in
            
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertWithClosingView(alertTitle : String, alertMessage : String) {
        waitingThing.isHidden = true
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: myKeys.alert.okButton, style: .default) { (UIAlertAction) in
            self.delegate?.mapPinIcon.isHidden = true
            self.delegate?.doneButton.isHidden = true
            self.delegate?.addNewPlaceButton.setImage(UIImage.init(systemName: "mappin"), for: [])
            self.delegate?.addNewPlaceButton.backgroundColor = UIColor(named: "LightDarkGreenTransparent")
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateInterface() {
        if oldPlace.batteries {
            batteriesButton.backgroundColor = UIColor(named: "DarkLightGreenTransparent")
            batteriesChecked = true
        }
        if oldPlace.bottles {
            bottlesButton.backgroundColor = UIColor(named: "DarkLightGreenTransparent")
            bottlesChecked = true
        }
        if oldPlace.bulbs {
            bulbsButton.backgroundColor = UIColor(named: "DarkLightGreenTransparent")
            bulbsChecked = true
        }
        if oldPlace.other != "" {
            otherButton.backgroundColor = UIColor(named: "DarkLightGreenTransparent")
            whatCollectsLabel.text = oldPlace.other
            otherChecked = true
        }
        if oldPlace.hasImage {
            placeImageView.image = placeInfoDelegate?.placeImage.image
            deletePhotoButton.isHidden = false
            photoAdded = true
        }
        titleTextField.text = oldPlace.title
        addressTextField.text = oldPlace.address
        sendButton.setTitle(myKeys.addAndEdit.sendChangesButton, for: .normal)
    }
    
    
    // MARK:- ImagePicker
    func showImageChooseAlert() {
        let alert = UIAlertController(title: myKeys.alert.chooseNewProfileImageTitle, message: nil, preferredStyle: .alert)
        
        let cameraAction = UIAlertAction(title: myKeys.alert.cameraButton, style: .default){ UIAlertAction in
            self.openCamera()
        }
        let galleryAction = UIAlertAction(title: myKeys.alert.galleryButton, style: .default){ UIAlertAction in
            self.openGallery()
        }
        let cancelAction = UIAlertAction(title: myKeys.alert.cancelButton, style: .cancel){ UIAlertAction in
            
        }
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(.camera)){
             imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            showAlert(alertTitle: myKeys.alert.okButton, alertMessage: myKeys.alert.cameraErrorMessage)
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
        photoAdded = true
        deletePhotoButton.isHidden = false
        newPlace.hasImage = true
    }
    
}
