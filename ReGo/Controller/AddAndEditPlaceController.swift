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
    let locationManager = CLLocationManager()
    var previousLocation : CLLocation?
    var firebaseService = FirebaseService()
    
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
    @IBOutlet weak var scrollView: UIScrollView!
    
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(outOfKeyBoardTapped))
        scrollView.addGestureRecognizer(tapGesture)
        
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
        newPlace.coordinate = mapView.region.center
        
        if titleTextField.text == "" {
            showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: myKeys.alert.enterTitle, actionTitle: myKeys.alert.okButton)
            waitingThing.isHidden = true
            return
        }
        else if addressTextField.text == "" {
            showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: myKeys.alert.enterAddress, actionTitle: myKeys.alert.okButton)
            waitingThing.isHidden = true
            return
        }
        else if !bottlesChecked && !batteriesChecked && !bulbsChecked && !otherChecked && whatCollectsTextField.text == ""{
            showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: myKeys.alert.whatRecycle, actionTitle: myKeys.alert.okButton)
            waitingThing.isHidden = true
            return
        }
        else if otherChecked && whatCollectsTextField.text == "" {
            showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: myKeys.alert.writeOther, actionTitle: myKeys.alert.okButton)
            waitingThing.isHidden = true
            return
        }
        else {
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
        whatCollectsTextField.placeholder = myKeys.addAndEdit.otherTextField
        addPhotoButton.setTitle(myKeys.addAndEdit.addPhotoButton, for: .normal)
        titleLabel.text = myKeys.addAndEdit.titleLabel
        titleTextField.placeholder = myKeys.addAndEdit.titleTextField
        addressLabel.text = myKeys.addAndEdit.addressLabel
        addressTextField.placeholder = myKeys.addAndEdit.addressTextField
        sendButton.setTitle(myKeys.addAndEdit.sendButton, for: .normal)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        
        if isUsingLocation{
            mapView.showsUserLocation = true
            mapView.userTrackingMode = .follow
        }
        
        previousLocation = getCenterLocation(for: mapView)

        if editView {
            placeLocation = oldPlace.coordinate
        }
        
        let region = MKCoordinateRegion(center: placeLocation, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        guard let previousLocation = self.previousLocation else {return}
        guard center.distance(from: previousLocation) > 30 else { return }
        self.previousLocation = center
        getAddress()
    }
    
    @objc func outOfKeyBoardTapped(){
        self.view.endEditing(true)
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
        firebaseService.addNewAnnotationToDB(user: currentUser, place: place, success: {
            if currentUser.superUser{
                self.addCountPlacesToUser()
                self.delegate?.addNewAnnotation(ann: self.newPlace)
            }
            if place.hasImage {
                self.saveImageToDatabase()
            }
            self.delegate?.retrieveAnnotations()
            self.showAlertWithClosingView(alertTitle: myKeys.alert.thankYou, alertMessage: myKeys.alert.placeAdded)
        }) { (error) in
            self.showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: error, actionTitle: myKeys.alert.okButton)
        }
    }
    
    func editAnnotationInDatabase(newPlace: Place, oldPlace: Place) {
        firebaseService.editAnnotationInDB(user: currentUser, newPlace: newPlace, success: {
            if currentUser.superUser{
                self.delegate?.addNewAnnotation(ann: self.newPlace)
            }
            if newPlace.hasImage && self.photoAdded {
                self.saveImageToDatabase()
            }
            self.delegate?.retrieveAnnotations()
            self.showAlertWithClosingView(alertTitle: myKeys.alert.thankYou, alertMessage: myKeys.alert.placeEdited)
        }) { (error) in
            self.showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: error, actionTitle: myKeys.alert.okButton)
        }
    }
    
    func saveImageToDatabase() {
        newPlace.hasImage = false;
        guard let image = placeImageView.image, let data = image.jpegData(compressionQuality: 1.0) else {
            showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: myKeys.alert.saveImageToDatabaseErrorMessage, actionTitle: myKeys.alert.okButton)
            return
        }
        firebaseService.saveImageToDB(newPlace: newPlace, data: data, success: {
            if self.editView {
                 self.showAlertWithClosingView(alertTitle: myKeys.alert.thankYou, alertMessage: myKeys.alert.placeEdited)
            }
            else {
                 self.showAlertWithClosingView(alertTitle: myKeys.alert.thankYou, alertMessage: myKeys.alert.placeAdded)
            }
        }) { (error) in
            self.showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: error, actionTitle: myKeys.alert.okButton)
        }
    }
    
    func addCountPlacesToUser() {
        currentUser.placesAdded = currentUser.placesAdded + 1
        firebaseService.editUserPlacesAmountInDB(user: currentUser)
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
            showAlert(alertTitle: myKeys.alert.okButton, alertMessage: myKeys.alert.cameraErrorMessage, actionTitle: myKeys.alert.okButton)
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
