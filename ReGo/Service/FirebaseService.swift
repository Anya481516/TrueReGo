//
//  FirebaseService.swift
//  ReGo
//
//  Created by Анна Мельхова on 04.06.2020.
//  Copyright © 2020 Anna Melkhova. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import CoreLocation

class FirebaseService {
    
    func retrieveUserInfo(id: String, success: @escaping () -> Void, failure: @escaping (_ error: String) -> Void){
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
            success()
            return
        }) { (error) in
            failure(error.localizedDescription)
            print(error.localizedDescription)
        }
    }
    
    func putNewUserToDB(user: User, success: @escaping () -> Void, failure: @escaping (_ error: String) -> Void) {
        let userDB = Firebase.Database.database().reference().child("Users")
        let userDictionary = ["Name" : user.name, "PlacesAdded" : user.placesAdded, "ProfilePicture" : false, "ImageURL" : user.imageURL, "SuperUser" : user.superUser] as [String : Any]
            userDB.child(user.id).setValue(userDictionary) {
                (error, reference) in
                if let error = error {
                    print(error)
                    failure(error.localizedDescription)
                }
                else{
                    print("User added to the DB")
                    success()
                }
            }
    }
    
    func addCountPlacesToUser(user: User) {
           let userDB = Firebase.Database.database().reference().child("Users")
           userDB.child(user.id).updateChildValues(["PlacesAdded" : currentUser.placesAdded])
       }
    
    func addNewUserToDB(user: User, success: @escaping () -> Void, failure: @escaping (_ error: String) -> Void){
        let userDB = Firebase.Database.database().reference().child("Users")
        let userDictionary = ["Name" : currentUser.name, "PlacesAdded" : currentUser.placesAdded, "ProfilePicture" : false, "ImageURL" : currentUser.imageURL, "SuperUser" : currentUser.superUser] as [String : Any]
            userDB.child(currentUser.id).setValue(userDictionary) {
                (error, reference) in
                if let error = error {
                    print(error)
                    failure(error.localizedDescription)
                }
                else{
                    print("User added to the DB")
                    success()
                }
            }
    }
    
    func updateUserPicInDB(id: String, urlString: String, success: @escaping () -> Void, failure: @escaping (_ error: String) -> Void) {
        let userDB = Firebase.Database.database().reference().child("Users")
        userDB.child(id).updateChildValues(["ImageURL" : urlString, "ProfilePicture" : true])
        success()
    }
    
    func updatePlacePicInDB(place: Place, urlString: String, success: @escaping () -> Void, failure: @escaping (_ error: String) -> Void) {
        
        if currentUser.superUser {
            let userDB = Firebase.Database.database().reference().child("Places")
            userDB.child(place.id).updateChildValues(["ImageURL" : urlString, "HasImage" : true])
        }
        else {
            let userDB = Firebase.Database.database().reference().child("NewPlaces")
            userDB.child(place.id).updateChildValues(["ImageURL" : urlString, "HasImage" : true])
        }
        success()
    }
    
    func changeUsername(id: String, newUsername: String, success: @escaping () -> Void) {
        let userDB = Firebase.Database.database().reference().child("Users")
        currentUser.name = newUsername
        userDB.child(id).updateChildValues(["Name" : newUsername])
        success()
    }
    
    func retrieveAnnotations(complition: @escaping () -> Void) {
        places.removeAll()
        bottlePlaces.removeAll()
        batteryPlaces.removeAll()
        bulbPlaces.removeAll()
        
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
            place.subtitle = type
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
            complition()
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
            complition()
        }
    }
    
    func editAnnotationInDatabase(newPlace: Place, success: @escaping () -> Void, failure: @escaping (_ error: String) -> Void) {
        var userDB = DatabaseReference()
        
        if currentUser.superUser {
            userDB = Firebase.Database.database().reference().child("Places")
            //places.append(newPlace)
        }
        else {
            userDB = Firebase.Database.database().reference().child("EditedPlaces")
        }
        
        let placeDictionary = ["Title" : newPlace.title!, "Address" : newPlace.address, "HasImage" : newPlace.hasImage, "ImageURL" : newPlace.imageURLString, "Longitude" : newPlace.coordinate.longitude, "Latitude" : newPlace.coordinate.latitude, "Type" : newPlace.subtitle!, "Bottles" : newPlace.bottles, "Batteries" : newPlace.batteries, "Bulbs" : newPlace.bulbs, "Other" : newPlace.other, "UserID" : currentUser.id, "ID" : newPlace.id] as [String : Any]
        
        if currentUser.superUser {
            userDB.child(newPlace.id).updateChildValues(placeDictionary)
        }
        else {
            userDB.child(newPlace.id).setValue(placeDictionary)
        }
        
        success()
    }
    
    func addNewAnnotationToDatabase(place : Place, user: User, success: @escaping (_ savedPlace: Place) -> Void) {
        var userDB = DatabaseReference()
        
        if currentUser.superUser {
            userDB = Firebase.Database.database().reference().child("Places")
            places.append(place)
        }
        else {
            userDB = Firebase.Database.database().reference().child("NewPlaces")
        }
        
        let randomID = userDB.childByAutoId()
        place.id = randomID.key!
        
        let placeDictionary = ["Title" : place.title!, "Address" : place.address, "HasImage" : place.hasImage, "ImageURL" : place.imageURLString, "Longitude" : place.coordinate.longitude, "Latitude" : place.coordinate.latitude, "Type" : place.subtitle!, "Bottles" : place.bottles, "Batteries" : place.batteries, "Bulbs" : place.bulbs, "Other" : place.other, "UserID" : currentUser.id, "ID" : place.id] as [String : Any]
        print("yo bitch \(place.id)")
        
        userDB.child(place.id).setValue(placeDictionary)
        
        success(place)
    }
    
    
    func saveRequestForSuperUserToDB(user: User, reason: String, success: @escaping () -> Void, failure: @escaping (_ error: String) -> Void){
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedDate = format.string(from: date)
        print(formattedDate)
        
        let requestsDB = Firebase.Database.database().reference().child("RequestsForSuperuser")
        let requestDictionary = ["Time": formattedDate, "Username" : user.name, "UserEmail": user.email, "Reason": reason] as [String : Any]
        requestsDB.child(user.id).setValue(requestDictionary) {
            (error, reference) in
            if let error = error {
                print(error)
                failure(error.localizedDescription)
            }
            else{
                print("Request has been added to the DB")
                success()
            }
        }
    }
    
    func requestExists(id: String, result: @escaping (_ result: Bool) -> Void) {
        let requestsDB = Firebase.Database.database().reference().child("RequestsForSuperuser")
        requestsDB.observe(.value) { (snapshot) in
            if snapshot.hasChild(id) {
                result(true)
            }
            else {
                result(false)
            }
        }
    }
    
    func ratingIsSent(id: String, result: @escaping (_ result: Double) -> Void){
        let requestsDB = Firebase.Database.database().reference().child("Ratings")
        requestsDB.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild(id) {
                let snapshotValue = snapshot.value as! Dictionary<String,Any>
                let snapshotValue1 = snapshotValue[id] as! Dictionary<String,Any>
                let rating = snapshotValue1["Rating"] as! Double
                result(rating)
            }
            else {
                result(-1)
            }
        }
    }
    
    func sendRatingToDB(user: User, rating: Double, comment: String, success: @escaping () -> Void, failure: @escaping (_ error: String) -> Void) {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedDate = format.string(from: date)
        print(formattedDate)
        
        let raitingDB = Firebase.Database.database().reference().child("Ratings")
        let raitingDictionary = ["Time": formattedDate, "Username" : user.name, "UserEmail": user.email, "Rating": rating, "Comment" : comment] as [String : Any]
        raitingDB.child(user.id).setValue(raitingDictionary) {
            (error, reference) in
            if let error = error {
                print(error)
                failure(error.localizedDescription)
            }
            else{
                print("Raiting has been sent")
                success()
            }
        }
    }
    
    func countRating(result: @escaping (_ totalRating: Double, _ count: Double) -> Void){
        var totalRating: Double = 0
        var count: Double = 0
        
        let requestsDB = Firebase.Database.database().reference().child("Ratings")
        requestsDB.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String,Any>
            let rating = snapshotValue["Rating"] as! Double
            totalRating = totalRating + rating
            count = count + 1
            result(totalRating, count)
        }
        
        
    }
}
