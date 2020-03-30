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

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // MARK: ELEMENTS INITS
    @IBOutlet weak var addNewPlaceButton: UIButton!
    @IBOutlet weak var zoomInButton: UIButton!
    @IBOutlet weak var zoomOutButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationButton: UIButton!
    
    // MARK: LOCATION MAN
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        locationManager.delegate = self

        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
    
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
            
        mapView.showsUserLocation = true
        showCurrentLocation()
    }
    
    // MARK: BUTTONS:
    
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
    }
    
    // MARK: METHODS:
    func showCurrentLocation(){
        mapView.userTrackingMode = .follow
    }
}
