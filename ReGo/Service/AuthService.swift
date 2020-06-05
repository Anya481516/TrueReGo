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
    var firebaseService = FirebaseService()
    
    func getRegisteredUserInfo() -> User {
        let newUser = User()
        if let user = Auth.auth().currentUser {
            newUser.id = user.uid
            newUser.email = user.email!
        }
        return newUser
    }
    
    func register(userEmail: String, userPassword: String, success: @escaping () -> Void, failure: @escaping (_ error: String) -> Void) {
        Auth.auth().createUser(withEmail: userEmail, password: userPassword) { (user, error) in
            if let error = error {
                print(error)
                failure(error.localizedDescription)
            }
            else {
                print("Successfully regestered")
                success()
            }
        }
    }
    
    func login() {
        if let user = Auth.auth().currentUser {
            currentUser.id = user.uid
            firebaseService.retrieveUserInfo(id: currentUser.id, success: {
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
            }
            else {
                success()
            }
        }
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
}
