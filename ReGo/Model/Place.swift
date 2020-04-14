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

class Place : CustomPin {
    
    var id : String?
    var imageURLString : String?
    var otherThings : String?
    // как то еще коменты вставить бы сюда
    
    init(pin: CustomPin) {
        super.init()
        self.coordinate = pin.coordinate
    }
    
    override init() {
        super.init()
    }
    
    // MARK: METHODS:
    func saveToDatabase() {
        let userDB = Firebase.Database.database().reference().child("Places")
        
        let placeDictionary = ["Title" : title!, "Address" : subtitle!, "HasImage" : false, "ImageURL" : imageURLString!, "Longitude" : coordinate.longitude, "Latitude" : coordinate.latitude, "Type" : type!] as [String : Any]
        self.id = currentUser.id + self.type! + self.subtitle!
        userDB.child(self.id!).setValue(placeDictionary)
        
        print("saved a place to database")
        
    }
    
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
