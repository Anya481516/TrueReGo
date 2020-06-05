//
//  EditProfileController.swift
//  ReGo
//
//  Created by Анна Мельхова on 10.04.2020.
//  Copyright © 2020 Anna Melkhova. All rights reserved.
//

import UIKit
import Kingfisher

protocol EditProfileDelegate {
    func updateInterface()
}

class EditProfileController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: variables:
    var delegate : EditProfileDelegate?
    var imagePicker = UIImagePickerController()
    var imageChanged = false
    var firebaseService = FirebaseService()
    var storageService = StorageService()
    var authService = AuthService()
    
    // MARK: IBOutlets:
    
    @IBOutlet var editProfileView: UIView!
    @IBOutlet weak var editProfileTitleLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var oldPasswordLabel: UILabel!
    @IBOutlet weak var newPasswordLabel: UILabel!
    @IBOutlet weak var saveChangesButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var editImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var waitingThing: UIActivityIndicatorView!
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(outOfKeyBoardTapped))
        editProfileView.addGestureRecognizer(tapGesture)
        self.emailTextField.keyboardType = UIKeyboardType.emailAddress
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        updateUserInfo()
        updateLang()
    }
    
    // MARK: IBActions:
    
    @IBAction func saveChangesButtonPressed(_ sender: UIButton) {
        if imageChanged {
            saveImageToDatabase()
        }
        var isChanged = false
        if let newUserName = userNameTextField.text {
            if let newEmail = emailTextField.text {
                if currentUser.email != newEmail {
                    authService.updateEmail(newEmail: newEmail, success: {
                        currentUser.email = newEmail
                        self.delegate?.updateInterface()
                        self.showAlert(alertTitle: myKeys.alert.successTitle, alertMessage: myKeys.alert.valuesChanged)
                        isChanged = true
                    }) { (error) in
                        self.showAlertWithPassword(newEmail: newEmail) {
                            self.resetEmail(email: newEmail)
                        }
                    }
                }
                if currentUser.name != newUserName {
                    firebaseService.changeUsername(id: currentUser.id, newUsername: newUserName) {
                        self.showAlert(alertTitle: myKeys.alert.successTitle, alertMessage: myKeys.alert.valuesChanged)
                        isChanged = true
                    }
                }
            }
        }
        if isChanged {
            self.delegate?.updateInterface()
        }
    }
    
    
    @IBAction func changePasswordButtonPressed(_ sender: UIButton) {
        if oldPasswordTextField.text?.isEmpty == false {
            authService.reauthenticateUser(email: currentUser.email, password: oldPasswordTextField.text!, success: {
                if self.newPasswordTextField.text!.count > 5 {
                    self.resetPassword(password: self.newPasswordTextField.text!)
                    self.oldPasswordTextField.text = ""
                    self.newPasswordTextField.text = ""
                }
            }) { (error) in
                self.showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: error)
            }
        }
        else {
            // show alert that the password is incorrect
            showAlertCustomActions(alertTitle: myKeys.alert.errTitle, alertMessage: myKeys.alert.passwordErrorMessage, action1Title: myKeys.alert.tryAgainButton, action2Title: myKeys.alert.sendByEmailButton, action1: { })
            {
                 self.sendPasswordByEmail()
            }
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
    
    
    // MARK:- METHODS:
    
    func showAlertWithPassword(newEmail: String, success: @escaping () -> Void) {
        let alert = UIAlertController(title: myKeys.alert.passwordIsRequiredTitle, message: myKeys.alert.passwordIsRequiredMessage, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.isSecureTextEntry = true
        }
        let action1 = UIAlertAction(title: myKeys.alert.cancelButton, style: .cancel) { (UIAlertAction) in
            
        }
        let action2 = UIAlertAction(title: myKeys.alert.doneButton, style: .default) { (UIAlertAction) in
            let textField = alert.textFields![0]
            if let password = textField.text {
                self.authService.reauthenticateUser(email: currentUser.email, password: password, success: {
                    success()
                }) { (error) in
                    self.showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: error)
                }
            }
        }
        alert.addAction(action1)
        alert.addAction(action2)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func outOfKeyBoardTapped(){
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= (keyboardSize.height)
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func updateLang() {
        editProfileTitleLabel.text = myKeys.editProfile.editProfileTitleLabel
        usernameLabel.text = myKeys.editProfile.usernameLabel
        userNameTextField.placeholder = myKeys.editProfile.userNameTextField
        emailLabel.text = myKeys.editProfile.emailLabel
        emailTextField.placeholder = myKeys.editProfile.emailTextField
        saveChangesButton.setTitle(myKeys.editProfile.saveChangesButton, for: .normal)
        oldPasswordLabel.text = myKeys.editProfile.oldPasswordLabel
        newPasswordLabel.text = myKeys.editProfile.newPasswordLabel
        changePasswordButton.setTitle(myKeys.editProfile.changePasswordButton, for: .normal)
        forgotPasswordButton.setTitle(myKeys.editProfile.forgotPasswordButton, for: .normal)
    }
    
    func updateUserInfo() {
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
        authService.sendLimkByEmail(email: currentUser.email, success: {
            self.showAlert(alertTitle: myKeys.alert.successTitle, alertMessage: "\(myKeys.alert.linkSentTo)\(currentUser.email)\(myKeys.alert.checkEmail)")
        }) { (error) in
            self.showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: error)
        }
    }
    func showAlert(alertTitle : String, alertMessage : String) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: myKeys.alert.okButton, style: .default) { (UIAlertAction) in
            
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func resetPassword(password : String) {
        authService.resetPassword(password: password, success: {
            self.showAlert(alertTitle: myKeys.alert.successTitle, alertMessage: myKeys.alert.passwordChanged)
        }) { (error) in
            self.showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: error)
        }
    }
    func resetEmail(email : String) {
        authService.updateEmail(newEmail: email, success: {
            currentUser.email = email
            self.delegate?.updateInterface()
            self.showAlert(alertTitle: myKeys.alert.successTitle, alertMessage: myKeys.alert.valuesChanged)
        }) { (error) in
            self.showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: error)
        }
    }
    
    func showImageChooseAlert() {
        let alert = UIAlertController(title: myKeys.alert.chooseNewProfileImageTitle, message: nil, preferredStyle: .alert)
        
        let cameraAction = UIAlertAction(title: myKeys.alert.cameraButton, style: .default){ UIAlertAction in
            self.openCamera()
        }
        let galleryAction = UIAlertAction(title: myKeys.alert.galleryButton, style: .default){ UIAlertAction in
            self.openGallery()
        }
        let cancelAction = UIAlertAction(title: myKeys.alert.cancelButton, style: .cancel){ UIAlertAction in
            
        }
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(.camera)){
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: myKeys.alert.cameraErrorMessage)
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
        waitingThing.isHidden = false
        guard let image = profileImageView.image,
            let data = image.jpegData(compressionQuality: 1.0) else {
                showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: myKeys.alert.saveImageToDatabaseErrorMessage)
                return
        }
        
        let imageName = currentUser.id
        
        storageService.saveUserPicToStorage(imageName: imageName, data: data, success: { (url) in
            currentUser.imageURL = url
            currentUser.hasProfileImage = true
            self.firebaseService.updateUserPicInDB(id: currentUser.id, urlString: url, success: {
                self.imageChanged = false
                self.waitingThing.isHidden = true
                self.showAlert(alertTitle: myKeys.alert.successTitle, alertMessage: myKeys.alert.imageSaved)
                self.delegate?.updateInterface()
                //self.dismiss(animated: true, completion: nil)
            }) { (error) in
                self.waitingThing.isHidden = true
                self.showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: error)
            }
        }) { (error) in
            self.waitingThing.isHidden = true
            self.showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: error)
        }
    }
    
    func retrieveUserInfo(){
        firebaseService.retrieveUserInfo(id: currentUser.id, success: {
            self.delegate?.updateInterface()
        }) { (error) in
            self.showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: error)
        }
    }

}
