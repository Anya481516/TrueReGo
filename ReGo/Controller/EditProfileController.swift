//
//  EditProfileController.swift
//  ReGo
//
//  Created by Анна Мельхова on 10.04.2020.
//  Copyright © 2020 Anna Melkhova. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import Kingfisher

protocol EditProfileDelegate {
    func updateInterface()
}

class EditProfileController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: variables:
    var delegate : EditProfileDelegate?
    var imagePicker = UIImagePickerController()
    var imageChanged = false
    
    // MARK: IBOutlets:
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var editImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        updateInterface()
    }
    
    // MARK: IBActions:
    
    @IBAction func saveChangesButtonPressed(_ sender: UIButton) {
        if imageChanged {
            saveImageToDatabase()
            showAlert(alertTitle: "Success", alertMessage: "Image was saved to the database")
        }
        var isChanged = false
        if let newUserName = userNameTextField.text {
            if let newEmail = emailTextField.text {
                if currentUser.email != newEmail {
                    Auth.auth().currentUser?.updateEmail(to: newEmail, completion: { (error) in
                        if error != nil {
                            //self.showAlert(alertTitle: "Error!", alertMessage: error.localizedDescription)
                            // need toreauthenticate
                            let alert = UIAlertController(title: "Password is required", message: "To change the email please insert your password below:", preferredStyle: .alert)
                            alert.addTextField { (textField) in
                                textField.isSecureTextEntry = true
                            }
                            let action1 = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
                                
                            }
                            let action2 = UIAlertAction(title: "Done", style: .default) { (UIAlertAction) in
                                let textField = alert.textFields![0]
                                if let password = textField.text {
                                    let eMail = EmailAuthProvider.credential(withEmail: currentUser.email, password: password)
                                    Auth.auth().currentUser?.reauthenticate(with: eMail, completion: { (authDataResult, error) in
                                        if let error = error {
                                            self.showAlert(alertTitle: "Error!", alertMessage: error.localizedDescription)
                                        }
                                        else {
                                            // now you can change the email yo
                                            self.resetEmail(email: newEmail)
                                        }
                                    })
                                }
                            }
                            alert.addAction(action1)
                            alert.addAction(action2)
                            self.present(alert, animated: true, completion: nil)
                        }
                        else {
                            currentUser.email = newEmail
                            self.showAlert(alertTitle: "Success!", alertMessage: "Values have been changed")
                            isChanged = true
                        }
                    })
                }
                if currentUser.name != newUserName {
                    let userDB = Firebase.Database.database().reference().child("Users")
                    currentUser.name = newUserName
                    userDB.child(currentUser.id).updateChildValues(["Name" : newUserName])
                    showAlert(alertTitle: "Success!", alertMessage: "Values have been changed")
                    isChanged = true
                }
            }
        }
        if isChanged {
            self.delegate?.updateInterface()
        }
    }
    
    
    @IBAction func changePasswordButtonPressed(_ sender: UIButton) {
        if oldPasswordTextField.text?.isEmpty == false {
            // reauthenticate the user
            let eMail = EmailAuthProvider.credential(withEmail: currentUser.email, password: oldPasswordTextField.text!)
            Auth.auth().currentUser?.reauthenticate(with: eMail, completion: { (authDataResult, error) in
                if let error = error {
                    self.showAlert(alertTitle: "Error!", alertMessage: error.localizedDescription)
                }
                else {
                    // now you can change the password yo
                    if self.newPasswordTextField.text!.count > 5 {
                        self.resetPassword(password: self.newPasswordTextField.text!)
                        self.oldPasswordTextField.text = ""
                        self.newPasswordTextField.text = ""
                    }
                    
                }
            })
            
        }
        else {
            // show alert that the password is incorrect
            let alert = UIAlertController(title: "Password error", message: "Your old password is incorrect. Do you want to try again or to get a link to reset the password by email?", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "Try again", style: .default) { (UIAlertAction) in
                
            }
            let action2 = UIAlertAction(title: "Send by email", style: .default) { (UIAlertAction) in
                self.sendPasswordByEmail()
            }
            alert.addAction(action1)
            alert.addAction(action2)
            self.present(alert, animated: true, completion: nil)
        }
    }
    @IBAction func forgotPasswordButtonPressed(_ sender: UIButton) {
        sendPasswordByEmail()
    }
    
    @IBAction func oldEyeButtonPressed(_ sender: UIButton) {
        if oldPasswordTextField.isSecureTextEntry == true {
            oldPasswordTextField.isSecureTextEntry = false
            oldPasswordTextField.placeholder = "123456"
            sender.setImage(UIImage.init(systemName: "eye.slash.fill"), for: [])
        }
        else {
            oldPasswordTextField.isSecureTextEntry = true
            oldPasswordTextField.placeholder = "******"
            sender.setImage(UIImage.init(systemName: "eye.fill"), for: [])
        }
    }
    @IBAction func newEyeButtonPressed(_ sender: UIButton) {
        if newPasswordTextField.isSecureTextEntry == true {
            newPasswordTextField.isSecureTextEntry = false
            newPasswordTextField.placeholder = "123456"
            sender.setImage(UIImage.init(systemName: "eye.slash.fill"), for: [])
        }
        else {
            newPasswordTextField.isSecureTextEntry = true
            newPasswordTextField.placeholder = "******"
            sender.setImage(UIImage.init(systemName: "eye.fill"), for: [])
        }
    }
    
    @IBAction func imageButtonPressed(_ sender: UIButton) {
        showImageChooseAlert()
    }
    
    
    // MARK: METHODS:
    
    // with the keyboard
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= (keyboardSize.height - 80)
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func updateInterface() {
        userNameTextField.text = currentUser.name
        emailTextField.text = currentUser.email
        if currentUser.hasProfileImage {
            let url = URL(string: currentUser.imageURL)
            let resource = ImageResource(downloadURL: url!)
            self.profileImageView.kf.setImage(with: resource) { (image, error, cacheType, url) in
                if let error = error {
                    print(error)
                }
                else {
                    print("Success updated image in edit view")
                }
            }
        }
    }
    
    func sendPasswordByEmail() {
        Auth.auth().sendPasswordReset(withEmail: currentUser.email) { error in
            if let error = error {
                self.showAlert(alertTitle: "Error", alertMessage: error.localizedDescription)
            }
            else {
                self.showAlert(alertTitle: "Success!", alertMessage: "Your link to change password was sent to \(currentUser.email). Check you email")
            }
        }
    }
    func showAlert(alertTitle : String, alertMessage : String) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (UIAlertAction) in
            
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func resetPassword(password : String) {
        Auth.auth().currentUser?.updatePassword(to: password, completion: { (error) in
            if let error = error {
                self.showAlert(alertTitle: "Error", alertMessage: error.localizedDescription)
            }
            else {
                self.showAlert(alertTitle: "Success", alertMessage: "Your password has changed!")
                
            }
        })
    }
    func resetEmail(email : String) {
        Auth.auth().currentUser?.updateEmail(to: email, completion: { (error) in
            if let error = error {
                self.showAlert(alertTitle: "Error", alertMessage: error.localizedDescription)
            }
            else {
                self.showAlert(alertTitle: "Success", alertMessage: "Your email has changed!")
            }
        })
    }
    
    
    func showImageChooseAlert() {
        let alert = UIAlertController(title: "Choose new profile image", message: nil, preferredStyle: .alert)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default){ UIAlertAction in
            self.openCamera()
        }
        let galleryAction = UIAlertAction(title: "Gallery", style: .default){ UIAlertAction in
            self.openGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){ UIAlertAction in
            
        }
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(.camera)){
            imagePicker.sourceType = .camera
            imageChanged = true
            self.present(imagePicker, animated: true, completion: nil)
            updateInterface()
            retrieveUserInfo()
        } else {
            showAlert(alertTitle: "Camera error", alertMessage: "We don't have access to your camera")
        }
    }
    
    func openGallery() {
        imagePicker.delegate = self
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false

        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        profileImageView.image = image
        imageChanged = true
    }
    
    func saveImageToDatabase() {
        // save image to a variable
        guard let image = profileImageView.image,
            let data = image.jpegData(compressionQuality: 1.0) else {
                showAlert(alertTitle: "Error", alertMessage: "Something went wrong with saving your Profile image to the storage.Try again.")
                return
        }
        // name the image as our user id
        let imageName = currentUser.id
        
        // saving the image to the storage
        let imageReference = Storage.storage().reference().child("ProfileImages").child(imageName)
        imageReference.putData(data, metadata: nil) { (metadata, error) in
            if let error = error {
                self.showAlert(alertTitle: "Error", alertMessage: error.localizedDescription)
                return
            }
            imageReference.downloadURL { (url, error) in
                if let error = error {
                    self.showAlert(alertTitle: "Error", alertMessage: error.localizedDescription)
                    return
                }
                guard let url = url else {
                    self.showAlert(alertTitle: "Error", alertMessage: "Something went wrong")
                    return
                }
                //let dataReference = Firestore.firestore().collection("ProfileImages").document()
                //let documentUid = dataReference.documentID
                
                let urlString = url.absoluteString
                //let data = ["ImageUID" : documentUid, "ImageURL" : urlString]
                
                currentUser.imageURL = urlString
                currentUser.hasProfileImage = true
                // update the User info in the database
                let userDB = Firebase.Database.database().reference().child("Users")
                userDB.child(currentUser.id).updateChildValues(["ImageURL" : urlString, "ProfilePicture" : true])
                self.delegate?.updateInterface()
            }
        }
    }
    
    func retrieveUserInfo(){
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
            print("Info retrieved !!!")
            // here
            self.delegate?.updateInterface()
            return
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}
