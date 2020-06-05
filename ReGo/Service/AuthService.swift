//
//  AuthService.swift
//  ReGo
//
//  Created by Анна Мельхова on 06.06.2020.
//  Copyright © 2020 Anna Melkhova. All rights reserved.
//

import Foundation
import FirebaseAuth

class AuthService {
    
    func reauthenticateUser(email: String, password: String, success: @escaping () -> Void, failure: @escaping(_ error: String) -> Void) {
        let eMail = EmailAuthProvider.credential(withEmail: email, password: password)
        Auth.auth().currentUser?.reauthenticate(with: eMail, completion: { (authDataResult, error) in
            if let error = error {
                failure(error.localizedDescription)
            }
            else {
                success()
            }
        })
    }
    
    func updateEmail(newEmail: String, success: @escaping () -> Void, failure: @escaping(_ error: String) -> Void) {
        Auth.auth().currentUser?.updateEmail(to: newEmail, completion: { (error) in
            if let error = error {
                failure(error.localizedDescription)
            }
            else {
                success()
            }
        })
    }
    
    func resetPassword(password: String, success: @escaping () -> Void, failure: @escaping(_ error: String) -> Void) {
        Auth.auth().currentUser?.updatePassword(to: password, completion: { (error) in
            if let error = error {
                failure(error.localizedDescription)
                //self.showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: error.localizedDescription)
            }
            else {
                success()
                //self.showAlert(alertTitle: myKeys.alert.successTitle, alertMessage: myKeys.alert.passwordChanged)
            }
        })
    }
    
    func sendLimkByEmail(email: String, success: @escaping () -> Void, failure: @escaping(_ error: String) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                failure(error.localizedDescription)
                //self.showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: error.localizedDescription)
            }
            else {
                success()
                //self.showAlert(alertTitle: myKeys.alert.successTitle, alertMessage: "\(myKeys.alert.linkSentTo)\(currentUser.email)\(myKeys.alert.checkEmail)")
            }
        }
    }
}
