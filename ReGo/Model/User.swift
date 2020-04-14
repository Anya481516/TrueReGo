//
//  User.swift
//  ReGo
//
//  Created by Анна Мельхова on 03.04.2020.
//  Copyright © 2020 Anna Melkhova. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import UIKit

class User {
    var id : String
    var name : String
    var email : String
    var placesAdded : Int
    var hasProfileImage : Bool
    var imageURL : String
    var superUser : Bool
    
    init (id : String, name : String, email : String, password : String) {
        self.id = id
        self.name = name
        self.email = email
        //self.password = password
        placesAdded = 0
        hasProfileImage = false
        imageURL = ""
        superUser = false
    }
    init (id : String) {
        self.id = id
        self.name = ""
        self.email = ""
        //self.password = ""
        placesAdded = 0
        hasProfileImage = false
        imageURL = ""
        superUser = false
    }
    init () {
        self.id = ""
        self.name = ""
        self.email = ""
        //self.password = ""
        placesAdded = 0
        hasProfileImage = false
        imageURL = ""
        superUser = false
    }
    
    // все хуйня, я тупица и не могу норм сделать
//    func retrieveInfoFromDatabase(complition : (_ success : Bool) -> Void) {
//        var success = false
//        let userDB = Firebase.Database.database().reference().child("Users")
//
//        currentUser.id = Auth.auth().currentUser!.uid
//        currentUser.email = Auth.auth().currentUser!.email!
//
//        userDB.child(currentUser.id).observeSingleEvent(of: .value, with: { (snapshot) in
//            let snapshotValue = snapshot.value as! NSDictionary
//            currentUser.name = snapshotValue["Name"] as! String
//            currentUser.placesAdded = snapshotValue["PlacesAdded"] as! Int
//            currentUser.hasProfileImage = snapshotValue["ProfilePicture"] as! Bool
//            currentUser.superUser = snapshotValue["SuperUser"] as! Bool
//            currentUser.imageURL = snapshotValue["ImageURL"] as! String
//            print("Info retrieved !!!")
//            success = true
//            //complition(success)
//            return
//        }) { (error) in
//            print(error.localizedDescription)
//            success = false
//        }
//
//        complition(success)
//    }
    
    func saveToDatabase() {
        
    }
    
    func sendPasswordByEmail(email : String) -> String {
        var result = ""
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                result = error.localizedDescription
            }
            else {
                result = "Success"
            }
        }
        return result
    }
}
