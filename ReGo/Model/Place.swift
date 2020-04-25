//
//  Place.swift
//  ReGo
//
//  Created by Анна Мельхова on 14.04.2020.
//  Copyright © 2020 Anna Melkhova. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import MapKit

class Place : CustomPin {
    
    var id : String = ""
    var hasImage : Bool = false
    var imageURLString : String = ""
    var bottles : Bool = false
    var batteries : Bool = false
    var bulbs : Bool = false
    var other : String = ""
    var userId : String = ""
    var address : String = ""
    // как то еще коменты вставить бы сюда
    
    init(pin: CustomPin) {
        super.init()
        self.coordinate = pin.coordinate
        id = String(coordinate.latitude) + String(coordinate.longitude)
    }
    
    override init() {
        super.init()
    }
    
    init(place : Place) {
        super.init()
        id = place.id
        hasImage = place.hasImage
        imageURLString = place.imageURLString
        bottles = place.bottles
        batteries = place.batteries
        bulbs = place.bulbs
        other = place.other
        userId = place.userId
        address = place.address
        title = place.title
        subtitle = place.subtitle
        coordinate = place.coordinate
    }
    
     override init(location: CLLocationCoordinate2D){
        super.init()
        id = String(location.latitude) + String(location.longitude)
    }
    
    // MARK: METHODS:
//    func saveToDatabase() {
//        let userDB = Firebase.Database.database().reference().child("Places")
//
//        let placeDictionary = ["Title" : title!, "Address" : subtitle!, "HasImage" : false, "ImageURL" : imageURLString!, "Longitude" : coordinate.longitude, "Latitude" : coordinate.latitude, "Type" : type!] as [String : Any]
//        self.id = currentUser.id + self.type! + self.subtitle!
//        userDB.child(self.id!).setValue(placeDictionary)
//
//        print("saved a place to database")
//
//    }
    
    func saveImageToStorage(imageView : UIImageView) -> String {
        // save image to a variable
        guard let image = imageView.image, let data = image.jpegData(compressionQuality: 1.0) else {
                return "Something went wrong with saving your Place image to the storage.Try again."
        }
        // name the image as our user id
        let imageName = currentUser.id
        
        var returnString = "Image was saved successfully"
        
        let imageReference = Storage.storage().reference().child("PlaceImages").child(imageName)
        imageReference.putData(data, metadata: nil) { (metadata, error) in
            if let error = error {
                returnString = error.localizedDescription
                return
            }
            imageReference.downloadURL { (url, error) in
                if let error = error {
                    returnString = error.localizedDescription
                    return
                }
                guard let url = url else {
                    returnString = "Something went wrong"
                    return
                }
                
                let urlString = url.absoluteString
                self.imageURLString = urlString
                
                currentUser.hasProfileImage = true
                // update the User info in the database
                let userDB = Firebase.Database.database().reference().child("Places")
                userDB.child(currentUser.id).updateChildValues(["ImageURL" : urlString, "HasImage" : true])
            }
            return
        }
        return returnString
    }
}
