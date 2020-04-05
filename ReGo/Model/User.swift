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
    var password : String
    var placesAdded : Int
    
    init (id : String, name : String, email : String, password : String) {
        self.id = id
        self.name = name
        self.email = email
        self.password = password
        placesAdded = 0
    }
    init (id : String) {
        self.id = id
        self.name = ""
        self.email = ""
        self.password = ""
        placesAdded = 0
    }
}
