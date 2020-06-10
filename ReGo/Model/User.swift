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

    
    func saveToDatabase() {
        
    }
}
