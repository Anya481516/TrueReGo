//
//  MapViewController.swift
//  ReGo
//
//  Created by Анна Мельхова on 30.03.2020.
//  Copyright © 2020 Anna Melkhova. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import Kingfisher

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, AddPlaceDelegate, PlaceInfoDelegate {
    
    // MARK:- PROPERTIES:
    var currentImage = UIImageView()
    var currentPlace = Place()
    var currentAddress = String()
    var allAnnotations = [MKAnnotation]()
    let locationManager = CLLocationManager()
    
    // MARK:- IBOutlets:
    @IBOutlet weak var addNewPlaceButton: UIButton!
    @IBOutlet weak var zoomInButton: UIButton!
    @IBOutlet weak var zoomOutButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var mapPinIcon: UIImageView!
    @IBOutlet weak var layerButton: UIButton!
    @IBOutlet weak var backFromDirectionButton: UIButton!
    
    // MARK:- ViewDidLoad:
    override func viewDidLoad() {
        super.viewDidLoad()
        showLocation = true
        
        self.mapView.delegate = self
        locationManager.delegate = self

        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        
        if isUsingLocation{
            mapView.showsUserLocation = true
            mapView.userTrackingMode = .follow
        }
    
        if Auth.auth().currentUser != nil {
            retrieveUserInfo()
        }
        
        currentImage.image = UIImage(named: "vk")!
        retrieveAnnotations()
        
        if defaults.string(forKey: "Lang") == nil{
            setLanguage()
        }
        
        updateaLang()
    }
    
    // MARK:- IBActions:
    
    @IBAction func backFromDirectionButton(_ sender: UIButton) {
        backFromDirectionButton.isHidden = true
        let anns = mapView.annotations
        mapView.removeAnnotations(anns)
        
        mapView.addAnnotations(allAnnotations)
        
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
    }
    
    @IBAction func layerButtonPressed(_ sender: UIButton) {
        if mapView.mapType == MKMapType.standard {
            mapView.mapType = MKMapType.satellite
        }
        else {
            mapView.mapType = MKMapType.standard
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "fromMapToAddPlace", sender: self)
    }
    
    @IBAction func zoomInButtonPressed(_ sender: UIButton) {
         mapView.userTrackingMode = .none
        
        if zoomOutButton.isEnabled == false {
            zoomOutButton.isEnabled = true
        }
        
        var newlongitudeLevel = (mapView.region.span.longitudeDelta)
        var newlatitudeLevel = (mapView.region.span.latitudeDelta)
        let location = mapView.region.center
        // останавливаемся зумировать когда уже дельта меньше чем 0.0061, чтообы все не покрашилось, иначе приравниваем к 0, то есть максимально приближаем и дихейблим кнопку ух
        if newlatitudeLevel > 0.01 {
            newlongitudeLevel = newlongitudeLevel / 2
            newlatitudeLevel = newlatitudeLevel / 2
            let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: newlatitudeLevel, longitudeDelta: newlongitudeLevel))
            mapView.setRegion(region, animated: true)
        }
        else {
            newlongitudeLevel = 0.0004
            newlatitudeLevel = 0.0004
            let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: newlatitudeLevel, longitudeDelta: newlongitudeLevel))
            mapView.setRegion(region, animated: true)
            zoomInButton.isEnabled = false
        }
    }
    
    @IBAction func zoomOutButtonPressed(_ sender: UIButton) {
        
        mapView.userTrackingMode = .none
        
        if zoomInButton.isEnabled == false {
            zoomInButton.isEnabled = true
        }
        
        var newlongitudeLevel = (mapView.region.span.longitudeDelta)
        var newlatitudeLevel = (mapView.region.span.latitudeDelta)
        let location = mapView.region.center
        if newlatitudeLevel < 60 {
            newlongitudeLevel = newlongitudeLevel * 2
            newlatitudeLevel = newlatitudeLevel * 2
            let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: newlatitudeLevel, longitudeDelta: newlongitudeLevel))
            mapView.setRegion(region, animated: true)
        }
        else {
            newlongitudeLevel = 120
            newlatitudeLevel = 110
            let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: newlatitudeLevel, longitudeDelta: newlongitudeLevel))
            mapView.setRegion(region, animated: true)
            zoomOutButton.isEnabled = false
        }
    }
    
    @IBAction func locationButtonPressed(_ sender: UIButton) {
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func addNewPlaceButtonPressed(_ sender: UIButton) {
        if sender.currentImage == UIImage(systemName: "mappin.slash") {
            sender.setImage(UIImage.init(systemName: "mappin"), for: [])
            doneButton.isHidden = true
            mapPinIcon.isHidden = true
            sender.backgroundColor = UIColor(named: "LightDarkGreenTransparent")
        }
        else if currentUser.name == "" {
            showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: myKeys.alert.loginReminder, actionTitle: myKeys.alert.okButton)
        }
        else {
            showAlertOkCancel(alertTitle: myKeys.alert.createNewPlaceTitle, alertMessage: myKeys.alert.createNewPlaceMessage, okActions: {
                sender.setImage(UIImage.init(systemName: "mappin.slash"), for: [])
                self.doneButton.isHidden = false
                self.mapPinIcon.isHidden = false
                sender.backgroundColor = UIColor(named: "RedTransparent")
            }) {
                
            }
        }
    }
    
    // MARK:- METHODS:
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        backFromDirectionButton.isHidden = true
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        mapView.showsUserLocation = showLocation
        showLocation = true
        mapView.userTrackingMode = .follow
        currentLocation = locationManager.location!
        
        CLGeocoder().reverseGeocodeLocation(locations.last!) { (placemarks, error) in
            if let placemarks = placemarks {
                let placemark = placemarks[0]
                if let address = placemark.addressDictionary!["Street"] as? String {
                    self.currentAddress = address
                    print("Address is - \(self.currentAddress)")
                }
            }
        }
    }
    
    func getCurretLocation() -> CLLocation {
        return locationManager.location!
    }

    //MARK: From Delegates:
    func getPlace() -> Place {
        return currentPlace
    }
    
    func addNewAnnotation(ann: Place) {
        mapView.addAnnotation(ann)
    }
    
    func updateInterface() {
        for place in places {
            addNewAnnotation(ann: place)
        }
        print(places.count)
    }
    
    func updateaLang() {
        doneButton.setTitle(myKeys.map.doneButton, for: .normal)
        backFromDirectionButton.setTitle(myKeys.map.back, for: .normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromMapToPlaceInfo" {
            let destinationVC = segue.destination as! PlaceInfoController
            destinationVC.delegate = self
        }
        
        if segue.identifier == "fromMapToAddPlace" {
            let destinationVC = segue.destination as! AddAndEditPlaceController
            destinationVC.placeLocation = mapView.region.center
            destinationVC.delegate = self
        }
    }
    
    func showCurrentLocation(){
        mapView.userTrackingMode = .follow
    }
    
    func imageFromDB(currentPlace : Place) -> UIImage {
        let vkImage = UIImage(named: "vk")!
        let newimage = UIImageView(image: vkImage)
        let url = URL(string: currentPlace.imageURLString)
        let resource = ImageResource(downloadURL: url!)
            
        newimage.kf.setImage(with: resource) { (image, error, cachType, url) in
                    if let error = error {
                        print(error)
                    }
                    else {
                        print("Success updated image in calout!")
                    }
                }
        return newimage.image!
    }
    
    func retrieveUserInfo(){
        let userDB = Firebase.Database.database().reference().child("Users")
        currentUser.id = Auth.auth().currentUser!.uid
        currentUser.email = Auth.auth().currentUser!.email!
        
        userDB.child(currentUser.id).observeSingleEvent(of: .value, with: { (snapshot) in
            let snapshotValue = snapshot.value as! NSDictionary
            currentUser.name = snapshotValue["Name"] as! String
            currentUser.placesAdded = snapshotValue["PlacesAdded"] as! Int
            currentUser.hasProfileImage = snapshotValue["ProfilePicture"] as! Bool
            currentUser.superUser = snapshotValue["SuperUser"] as! Bool
            currentUser.imageURL = snapshotValue["ImageURL"] as! String
            return
        }) { (error) in
            print(error.localizedDescription)
        }

    }

    
    func retrieveAnnotations() {
        let messageDB = Firebase.Database.database().reference().child("Places")
        
        messageDB.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String,Any>
        
            let title = snapshotValue["Title"] as! String
            let address = snapshotValue["Address"] as! String
            let hasImage = snapshotValue["HasImage"] as! Bool
            let imageURL = snapshotValue["ImageURL"] as! String
            let longitude = snapshotValue["Longitude"] as! CLLocationDegrees
            let latitude = snapshotValue["Latitude"] as! CLLocationDegrees
            let type = snapshotValue["Type"] as! String
            let bottles = snapshotValue["Bottles"] as! Bool
            let batteries = snapshotValue["Batteries"] as! Bool
            let bulbs = snapshotValue["Bulbs"] as! Bool
            let other = snapshotValue["Other"] as! String
            let userID = snapshotValue["UserID"] as! String
            let id = snapshotValue["ID"] as! String
        
            let place = Place()
            place.title = title
            place.subtitle = type // type
            place.hasImage = hasImage
            place.imageURLString = imageURL
            place.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            place.bottles = bottles
            place.batteries = batteries
            place.bulbs = bulbs
            place.other = other
            place.userId = userID
            place.address = address
            place.id = id
        
            places.append(place)
            
            if bottles {
                bottlePlaces.append(place)
            }
            if batteries {
                batteryPlaces.append(place)
            }
            if bulbs {
                bulbPlaces.append(place)
            }
            
            self.updateInterface()
        }
        
        messageDB.observe(.childChanged) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String,Any>
            
            let title = snapshotValue["Title"] as! String
            let address = snapshotValue["Address"] as! String
            let hasImage = snapshotValue["HasImage"] as! Bool
            let imageURL = snapshotValue["ImageURL"] as! String
            let longitude = snapshotValue["Longitude"] as! CLLocationDegrees
            let latitude = snapshotValue["Latitude"] as! CLLocationDegrees
            let type = snapshotValue["Type"] as! String
            let bottles = snapshotValue["Bottles"] as! Bool
            let batteries = snapshotValue["Batteries"] as! Bool
            let bulbs = snapshotValue["Bulbs"] as! Bool
            let other = snapshotValue["Other"] as! String
            let userID = snapshotValue["UserID"] as! String
            let id = snapshotValue["ID"] as! String
            
            for place in places {
                if place.id == id {
                    place.title = title
                    place.subtitle = type
                    place.address = address
                    place.hasImage = hasImage
                    place.imageURLString = imageURL
                    place.coordinate.latitude = latitude
                    place.coordinate.longitude = longitude
                    place.bottles = bottles
                    place.batteries = batteries
                    place.bulbs = bulbs
                    place.other = other
                    place.userId = userID
                    place.address = address
                }
            }
            
            if bottles {
                for place in bottlePlaces {
                    if place.id == id {
                        place.title = title
                        place.subtitle = type
                        place.address = address
                        place.hasImage = hasImage
                        place.imageURLString = imageURL
                        place.coordinate.latitude = latitude
                        place.coordinate.longitude = longitude
                        place.bottles = bottles
                        place.batteries = batteries
                        place.bulbs = bulbs
                        place.other = other
                        place.userId = userID
                        place.address = address
                    }
                }
            }
            if batteries {
                for place in batteryPlaces {
                    if place.id == id {
                        place.title = title
                        place.subtitle = type
                        place.address = address
                        place.hasImage = hasImage
                        place.imageURLString = imageURL
                        place.coordinate.latitude = latitude
                        place.coordinate.longitude = longitude
                        place.bottles = bottles
                        place.batteries = batteries
                        place.bulbs = bulbs
                        place.other = other
                        place.userId = userID
                        place.address = address
                    }
                }
            }
            if bulbs {
                for place in bulbPlaces {
                    if place.id == id {
                        place.title = title
                        place.subtitle = type
                        place.address = address
                        place.hasImage = hasImage
                        place.imageURLString = imageURL
                        place.coordinate.latitude = latitude
                        place.coordinate.longitude = longitude
                        place.bottles = bottles
                        place.batteries = batteries
                        place.bulbs = bulbs
                        place.other = other
                        place.userId = userID
                        place.address = address
                    }
                }
            }
            
            self.updateInterface()
        }
    }
    
    // MARK: Annotation extention
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard annotation as? MKUserLocation != mapView.userLocation else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "AnnotationView")
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView")
        }
        
        if annotation.subtitle == "Bottles" {
            annotationView?.image = UIImage(named: "IconBottle")
        } else if annotation.subtitle  == "Batteries" {
            annotationView?.image = UIImage(named: "IconBattery")
        } else if annotation.subtitle  == "Bulbs" {
            annotationView?.image = UIImage(named: "IconBulb")
        } else if annotation.subtitle  == "BatteriesAndBulbs" {
            annotationView?.image = UIImage(named: "IconBatteryBulb")
        } else if annotation.subtitle  == "Other" {
            annotationView?.image = UIImage(named: "IconOther")
        }
        
        let rect = CGRect(origin: .zero, size: CGSize(width: 200, height: 50))
        
        let yForButton = rect.height / 2 - 20
        let button = UIButton(frame: CGRect(origin: .init(x: 0, y: yForButton), size: CGSize(width: 100, height: 40)))
        button.setTitle(myKeys.map.moreInfoButton, for: .normal)
        button.sizeToFit()
        button.backgroundColor = UIColor(named: "LightDarkGreenTransparent")
        button.setTitleColor(UIColor(named: "BlackWhite"), for: .normal)
        
        annotationView?.leftCalloutAccessoryView = button
        annotationView?.sizeToFit()
        annotationView?.canShowCallout = true
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard view.annotation as? MKUserLocation != mapView.userLocation else { return }
        
        for place in places {
            if (place.title == view.annotation?.title) && (place.coordinate.latitude == view.annotation?.coordinate.latitude) && (place.coordinate.longitude == view.annotation?.coordinate.longitude) {
                currentPlace = place
            }
        }
        
        let vkImage = UIImage(named: "vk")!
        currentImage.image = vkImage
        if let url = URL(string: currentPlace.imageURLString) {
            print("it has an image")
            let resource = ImageResource(downloadURL: url)
            currentImage.kf.setImage(with: resource) { (image, error, cachType, url) in
                if let error = error {
                    print(error)
                }
                else {
                    print("Success updated image in calout!")
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        self.performSegue(withIdentifier: "fromMapToPlaceInfo", sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateaLang()
        if wasSelectedFromList {
            wasSelectedFromList = false
            let region = MKCoordinateRegion(center: selectedCoordinatesFromList, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
            mapView.setRegion(region, animated: true)
            selectAnnotation()
        }
    }
    
    func selectAnnotation(){
        for ann in mapView.annotations{
            if ann.coordinate.latitude == selectedCoordinatesFromList.latitude && ann.coordinate.longitude == selectedCoordinatesFromList.longitude{
                mapView.selectAnnotation(ann, animated: true)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = UIColor(named: "DarkLightGreen")
        return render
    }
    
    func setLanguage() {
        showAlertCustomActions(alertTitle: myKeys.alert.setLangTitle, alertMessage: myKeys.alert.setLangRequest, action1Title: myKeys.alert.rus, action2Title: myKeys.alert.eng, action1: {
            myKeys.changeToRus()
        }) {
            myKeys.changeToEng()
        }
    }
}
