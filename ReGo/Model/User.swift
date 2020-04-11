//
//  User.swift
//  ReGo
//
//  Created by Анна Мельхова on 03.04.2020.
//  Copyright © 2020 Anna Melkhova. All rights reserved.
//

import Foundation

class User {
    var id : String
    var name : String
    var email : String
    //var password : String
    var placesAdded : Int
    var hasProfileImage : Bool
    
    init (id : String, name : String, email : String, password : String) {
        self.id = id
        self.name = name
        self.email = email
        //self.password = password
        placesAdded = 0
        hasProfileImage = false
    }
    init (id : String) {
        self.id = id
        self.name = ""
        self.email = ""
        //self.password = ""
        placesAdded = 0
        hasProfileImage = false
    }
    init () {
        self.id = ""
        self.name = ""
        self.email = ""
        //self.password = ""
        placesAdded = 0
        hasProfileImage = false
    }
}
