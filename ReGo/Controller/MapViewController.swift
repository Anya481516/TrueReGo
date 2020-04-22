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
    
    //MARK:- From Delegates:
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
    }
    
    // MARK: variables:
    var places = [Place]()
    var currentImage = UIImageView()
    var currentPlace = Place()
    
    // MARK: IBOutlets:
    @IBOutlet weak var addNewPlaceButton: UIButton!
    @IBOutlet weak var zoomInButton: UIButton!
    @IBOutlet weak var zoomOutButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var iconImage: UIImageView!
    
    // MARK: LOCATION MAN
    let locationManager = CLLocationManager()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
            
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    
    // MARK:- ViewDidLoad:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        locationManager.delegate = self

        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow

    
        if let user = Auth.auth().currentUser {
            retrieveUserInfo()
        }
        
        currentImage.image = UIImage(named: "vk")!
        
        retrieveAnnotations()
    }
    
    // MARK:- IBActions:
    
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
        print("\(mapView.region.span.latitudeDelta) ; \(mapView.region.span.longitudeDelta)")
        
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
        print("\(mapView.region.span.latitudeDelta) ; \(mapView.region.span.longitudeDelta)")
    }
    
    @IBAction func locationButtonPressed(_ sender: UIButton) {
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func addNewPlaceButtonPressed(_ sender: UIButton) {
        if sender.currentImage == UIImage(systemName: "mappin.slash") {
            sender.setImage(UIImage.init(systemName: "mappin"), for: [])
            doneButton.isHidden = true
            iconImage.isHidden = true
        }
        else if currentUser.name == "" {
            showAlert(alertTitle: "Error", alertMessage: "To add new places you have to log in")
        }
        else {
            // here go to new view to create a pin
            let alert = UIAlertController(title: "Create a new place", message: "Choose the location for  new place", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
                sender.setImage(UIImage.init(systemName: "mappin.slash"), for: [])
                self.doneButton.isHidden = false
                self.iconImage.isHidden = false
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
                
            }
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK:- METHODS:
    
    func showAlert(alertTitle : String, alertMessage : String) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (UIAlertAction) in
            
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    // prepare method
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromMapToPlaceInfo" {
            let destinationVC = segue.destination as! PlaceInfoConteoller
            destinationVC.delegate = self
        }
        
        if segue.identifier == "fromMapToAddPlace" {
            let destinationVC = segue.destination as! AddPlaceController
            destinationVC.placeLocation = mapView.region.center
            destinationVC.delegate = self
        }
    }
    
    func showCurrentLocation(){
        mapView.userTrackingMode = .follow
    }
    
    func imageFromDB(currentPlace : Place) -> UIImage {
        let vkImage = UIImage(named: "vk")!
        var newimage = UIImageView(image: vkImage)
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
            print("Info retrieved !!!")
            
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
        
            print(title, address, hasImage, imageURL, latitude, longitude, bottles, batteries, bulbs, other, userID)
        
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
        
            self.places.append(place)
            //self.messageArray.append(message)
            //self.configureTableView()
        
            //self.messageTableView.reloadData()
            self.updateInterface()
        }
    }
    
    // MARK:- Annotation extention
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // находим именно то место
        var currentPlace = Place()
        for place in places {
        if (place.title == annotation.title) && (place.coordinate.latitude == annotation.coordinate.latitude) && (place.coordinate.longitude == annotation.coordinate.longitude) {
                currentPlace = place
            }
        }
        //TODO: картинку загрузить ух
        let rect = CGRect(origin: .zero, size: CGSize(width: 200, height: 100))
        let snapshotView = UIView()
        snapshotView.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView(frame: rect)
        if currentPlace.imageURLString != "" {
            imageView.image = currentImage.image
        }
        
        guard annotation as? MKUserLocation != mapView.userLocation else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "AnnotationView")
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView")
        }
        
        if annotation.subtitle == "Bottles" {
            annotationView?.image = UIImage(named: "IconBottle")
            print("It's a bottle")
        } else if annotation.subtitle  == "Batteries" {
            annotationView?.image = UIImage(named: "IconBattery")
            print("It's a battery")
        } else if annotation.subtitle  == "Bulbs" {
            annotationView?.image = UIImage(named: "IconBulb")
            print("It's a bulb")
        } else if annotation.subtitle  == "BatteriesAndBulbs" {
            annotationView?.image = UIImage(named: "IconBatteryBulb")
            print("It's a battery bulb")
        } else if annotation.subtitle  == "Other" {
            annotationView?.image = UIImage(named: "IconOther")
            print("It's something else")
        }
        
       
        
        // делаем вью
        
        let button = UIButton(frame: CGRect(origin: .init(x: 0, y: 30), size: CGSize(width: 200, height: 40)))
        button.setTitle("More Information", for: .normal)
        button.backgroundColor = UIColor(named: "LightDarkGreenTransparent")
        button.setTitleColor(UIColor(named: "BlackWhite"), for: .normal)
        
        snapshotView.addSubview(imageView)
        snapshotView.addSubview(button)

        annotationView?.detailCalloutAccessoryView = snapshotView
        
        NSLayoutConstraint.activate([
            snapshotView.widthAnchor.constraint(equalToConstant: rect.width),
            snapshotView.heightAnchor.constraint(equalToConstant: rect.height)
        ])
        
        // done
        annotationView?.canShowCallout = true
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard view.annotation as? MKUserLocation != mapView.userLocation else { return }
        
        // находим именно то место
        for place in places {
            if (place.title == view.annotation?.title) && (place.coordinate.latitude == view.annotation?.coordinate.latitude) && (place.coordinate.longitude == view.annotation?.coordinate.longitude) {
                currentPlace = place
            }
        }
        
        
        let vkImage = UIImage(named: "vk")!
        var newimage = UIImageView(image: vkImage)
        let url = URL(string: currentPlace.imageURLString)
        let resource = ImageResource(downloadURL: url!)
            
        currentImage.kf.setImage(with: resource) { (image, error, cachType, url) in
                    if let error = error {
                        print(error)
                    }
                    else {
                        print("Success updated image in calout!")
                        
                    }
                }
        //currentImage = imageFromDB(currentPlace: currentPlace)
    
        // тут напишеем чтобы вызывалась вьюшка со всей инфрй йоу
        print("The annotation was selected: \(String(describing: currentPlace.title))")
        
        self.performSegue(withIdentifier: "fromMapToPlaceInfo", sender: self)
    }
}
