//
//  CustomPin.swift
//  ReGo
//
//  Created by Анна Мельхова on 13.04.2020.
//  Copyright © 2020 Anna Melkhova. All rights reserved.
//

import UIKit
import MapKit

class CustomPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String? // address

    
    init(pinTitle : String, pinSubTitle : String, location : CLLocationCoordinate2D) {
        self.title = pinTitle
        self.subtitle = pinSubTitle
        self.coordinate = location
    }
    
    init(location: CLLocationCoordinate2D){
        self.coordinate = location
    }
    
    override init() {
        self.coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
}

struct RecycleType {
    var bottles = "Bottles"
    var batteries = "Batteries"
    var bulbs = "Bulbs"
    var other = "Other"
    var batteriesAndBulbs = "Batteries and bulbs"
}
