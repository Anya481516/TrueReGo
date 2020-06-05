//
//  StorageService.swift
//  ReGo
//
//  Created by Анна Мельхова on 06.06.2020.
//  Copyright © 2020 Anna Melkhova. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class StorageService {
    func saveUserPicToStorage(imageName: String, data: Data, success: @escaping (_ urlString: String) -> Void, failure: @escaping (_ error: String) -> Void) {
        let imageReference = Storage.storage().reference().child("ProfileImages").child(imageName)
        imageReference.putData(data, metadata: nil) { (metadata, error) in
            if let error = error {
                failure(error.localizedDescription)
                //self.showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: error.localizedDescription)
            }
            imageReference.downloadURL { (url, error) in
                if let error = error {
                    failure(error.localizedDescription)
                    //self.showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: error.localizedDescription)
                }
                guard let url = url else {
                    failure(myKeys.alert.somethingWendWrong)
                    //self.showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: myKeys.alert.somethingWendWrong)
                    return
                }
                
                let urlString = url.absoluteString
                //currentUser.imageURL = urlString
                //currentUser.hasProfileImage = true
                success(urlString)
            }
        }
    }
}
