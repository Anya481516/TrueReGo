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
    
    func getRegisteredUserInfo() -> User {
        let newUser = User()
        if let user = Auth.auth().currentUser {
            newUser.id = user.uid
            newUser.email = user.email!
        }
        return newUser
    }
    
    func logout(success: @escaping () -> Void, failure: @escaping (_ error: String) -> Void) {
        do {
            try Auth.auth().signOut()
            currentUser = User()
            success()
        }
        catch {
            failure("error, there was a problem with signing out")
        }
    }
    
    func isUserLoggedIn() -> Bool{
        if Auth.auth().currentUser == nil {
            return false
        }
        return true
    }
    
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
    
    func register(userEmail: String, userPassword: String, success: @escaping () -> Void, failure: @escaping (_ error: String) -> Void) {
        Auth.auth().createUser(withEmail: userEmail, password: userPassword) { (user, error) in
            if let error = error {
                print(error)
                failure(error.localizedDescription)
            }
            else {
                self.putNewUserToDB(user: currentUser, success: {
                    success()
                }) { (error) in
                    failure(error)
                }
            }
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
    
    func login() {
        if let user = Auth.auth().currentUser {
            currentUser.id = user.uid
            retrieveUserInfo(id: currentUser.id, success: {
                print("retrieved user Info")
            }) { (error) in
                print(error)
            }
        }
    }

    func signin(email: String, password: String, success: @escaping () -> Void, failure: @escaping (_ error: String) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print(error)
                failure(error.localizedDescription)
            }
            else {
                print("Succesfully logged in")
                success()
            }
        }
    }
    
    func retrieveAnnotations(complition: @escaping () -> Void) {
        places.removeAll()
        bottlePlaces.removeAll()
        bulbPlaces.removeAll()
        batteryPlaces.removeAll()
        
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
    
    func addNewAnnotationToDB(user: User, place: Place, success: @escaping () -> Void, failure: @escaping (_ error: String) -> Void) {
        var userDB = DatabaseReference()
        if currentUser.superUser {
            userDB = Firebase.Database.database().reference().child("Places")
        }
        else {
            userDB = Firebase.Database.database().reference().child("NewPlaces")
        }
        let randomID = userDB.childByAutoId()
        place.id = randomID.key!
        let placeDictionary = ["Title" : place.title!, "Address" : place.address, "HasImage" : place.hasImage, "ImageURL" : place.imageURLString, "Longitude" : place.coordinate.longitude, "Latitude" : place.coordinate.latitude, "Type" : place.subtitle!, "Bottles" : place.bottles, "Batteries" : place.batteries, "Bulbs" : place.bulbs, "Other" : place.other, "UserID" : currentUser.id, "ID" : place.id] as [String : Any]
        userDB.child(place.id).setValue(placeDictionary)
        print("saved a place to database")
        success()
    }
    
    func editAnnotationInDB(user: User, newPlace: Place, success: @escaping () -> Void, failure: @escaping (_ error: String) -> Void) {
        var userDB = DatabaseReference()
        if currentUser.superUser {
            userDB = Firebase.Database.database().reference().child("Places")
        }
        else {
            userDB = Firebase.Database.database().reference().child("NewPlaces")
        }
               
        let placeDictionary = ["Title" : newPlace.title!, "Address" : newPlace.address, "HasImage" : newPlace.hasImage, "ImageURL" : newPlace.imageURLString, "Longitude" : newPlace.coordinate.longitude, "Latitude" : newPlace.coordinate.latitude, "Type" : newPlace.subtitle!, "Bottles" : newPlace.bottles, "Batteries" : newPlace.batteries, "Bulbs" : newPlace.bulbs, "Other" : newPlace.other, "UserID" : currentUser.id, "ID" : newPlace.id] as [String : Any]
               
        userDB.child(newPlace.id).updateChildValues(placeDictionary)
        print("Changed !")
        success()
    }
    
    func editUserPlacesAmountInDB(user: User) {
        let userDB = Firebase.Database.database().reference().child("Users")
        userDB.child(user.id).updateChildValues(["PlacesAdded" : currentUser.placesAdded])
    }
    
    func saveImageToDB(newPlace: Place, data: Data, success: @escaping () -> Void, failure: @escaping (_ error: String) -> Void) {
        let imageReference = Storage.storage().reference().child("PlaceImages").child(newPlace.id)
        imageReference.putData(data, metadata: nil) { (metadata, error) in
            if let error = error {
                failure(error.localizedDescription)
                //self.showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: error.localizedDescription, actionTitle: myKeys.alert.okButton)
                return
            }
            imageReference.downloadURL { (url, error) in
                if let error = error {
                    failure(error.localizedDescription)
                    //self.showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: error.localizedDescription, actionTitle: myKeys.alert.okButton)
                    return
                }
                guard let url = url else {
                    failure(myKeys.alert.somethingWendWrong)
                    //self.showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: myKeys.alert.somethingWendWrong, actionTitle: myKeys.alert.okButton)
                    return
                }
                let urlString = url.absoluteString
                newPlace.hasImage = true
                newPlace.imageURLString = urlString
                if currentUser.superUser {
                    let userDB = Firebase.Database.database().reference().child("Places")
                    userDB.child(newPlace.id).updateChildValues(["ImageURL" : urlString, "HasImage" : true])
                }
                else {
                    let userDB = Firebase.Database.database().reference().child("NewPlaces")
                    userDB.child(newPlace.id).updateChildValues(["ImageURL" : urlString, "HasImage" : true])
                }
                success()
            }
            return
        }
    }
}
