//
//  AboutViewController.swift
//  ReGo
//
//  Created by Анна Мельхова on 06.06.2020.
//  Copyright © 2020 Anna Melkhova. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    //MARK:- PROPERTIES
    let firebaseService = FirebaseService()
    var rating: Double = -1
    var coment = String()
    var oldRating: Double = -1
    var appRating: Double = 0
    
    //MARK:- IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendReviewButton: UIButton!
    @IBOutlet weak var superUserButton: UIButton!

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var star1: UIButton!
    @IBOutlet weak var star2: UIButton!
    @IBOutlet weak var star3: UIButton!
    @IBOutlet weak var star4: UIButton!
    @IBOutlet weak var star5: UIButton!
    
    
    //MARK:- ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLang()
        fitStars()
        sendReviewButton.isEnabled = false
        sendReviewButton.backgroundColor = UIColor(named: "unabledButton")
        
        firebaseService.countRating { (totalRating, count) in
            self.appRating = totalRating / count
            self.updateInterface()
        }
    }

    //MARK:- IBActions
    @IBAction func sendReviewButtonPressed(_ sender: UIButton) {
        firebaseService.ratingIsSent(id: currentUser.id) { (result) in
            self.oldRating = result
            
            if self.oldRating == -1 {
                self.rate()
            }
            else {
                self.showAlertYesNo(alertTitle: myKeys.alert.attention, alertMessage: "\(myKeys.about.stillRate1) \(Int(self.oldRating)) \(myKeys.about.stillRate2)", okActions: {
                    self.rate()
                }) {
                    
                }
            }
        }
    }
    
    @IBAction func superUserButtonPressed(_ sender: UIButton) {
        if currentUser.superUser {
            showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: myKeys.about.userIsSuperMessage, actionTitle: myKeys.alert.okButton)
        }
        else {
            firebaseService.requestExists(id: currentUser.id) { (result) in
                if result == true {
                    self.showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: myKeys.about.requestExists, actionTitle: myKeys.alert.okButton)
                }
                else {
                    self.superUserRequest()
                }
            }
             
        }
    }
    // stars:
    @IBAction func star1Pressed(_ sender: UIButton) {
        star1.setImage(UIImage(systemName: "star.fill"), for: .normal)
        star2.setImage(UIImage(systemName: "star"), for: .normal)
        star3.setImage(UIImage(systemName: "star"), for: .normal)
        star4.setImage(UIImage(systemName: "star"), for: .normal)
        star5.setImage(UIImage(systemName: "star"), for: .normal)
        sendReviewButton.isEnabled = true
        sendReviewButton.backgroundColor = UIColor(named: "DarkLightGreenTransparent")
        rating = 1
    }
    @IBAction func star2Pressed(_ sender: UIButton) {
        star1.setImage(UIImage(systemName: "star.fill"), for: .normal)
        star2.setImage(UIImage(systemName: "star.fill"), for: .normal)
        star3.setImage(UIImage(systemName: "star"), for: .normal)
        star4.setImage(UIImage(systemName: "star"), for: .normal)
        star5.setImage(UIImage(systemName: "star"), for: .normal)
        sendReviewButton.isEnabled = true
        sendReviewButton.backgroundColor = UIColor(named: "DarkLightGreenTransparent")
        rating = 2
    }
    @IBAction func star3Pressed(_ sender: UIButton) {
        star1.setImage(UIImage(systemName: "star.fill"), for: .normal)
        star2.setImage(UIImage(systemName: "star.fill"), for: .normal)
        star3.setImage(UIImage(systemName: "star.fill"), for: .normal)
        star4.setImage(UIImage(systemName: "star"), for: .normal)
        star5.setImage(UIImage(systemName: "star"), for: .normal)
        sendReviewButton.isEnabled = true
        sendReviewButton.backgroundColor = UIColor(named: "DarkLightGreenTransparent")
        rating = 3
    }
    @IBAction func star4Pressed(_ sender: UIButton) {
        star1.setImage(UIImage(systemName: "star.fill"), for: .normal)
        star2.setImage(UIImage(systemName: "star.fill"), for: .normal)
        star3.setImage(UIImage(systemName: "star.fill"), for: .normal)
        star4.setImage(UIImage(systemName: "star.fill"), for: .normal)
        star5.setImage(UIImage(systemName: "star"), for: .normal)
        sendReviewButton.isEnabled = true
        sendReviewButton.backgroundColor = UIColor(named: "DarkLightGreenTransparent")
        rating = 4
    }
    @IBAction func star5Pressed(_ sender: UIButton) {
        star1.setImage(UIImage(systemName: "star.fill"), for: .normal)
        star2.setImage(UIImage(systemName: "star.fill"), for: .normal)
        star3.setImage(UIImage(systemName: "star.fill"), for: .normal)
        star4.setImage(UIImage(systemName: "star.fill"), for: .normal)
        star5.setImage(UIImage(systemName: "star.fill"), for: .normal)
        sendReviewButton.isEnabled = true
        sendReviewButton.backgroundColor = UIColor(named: "DarkLightGreenTransparent")
        rating = 5
    }
    
    
    //MARK:- METHODS
    func updateLang(){
        titleLabel.text = myKeys.about.title
        sendReviewButton.setTitle(myKeys.about.sendReviewButton, for: .normal)
        superUserButton.setTitle(myKeys.about.superUserButton, for: .normal)
        textView.text = myKeys.about.infoText
    }
    
    func updateInterface() {
        textView.text = "\(myKeys.about.infoText) \(appRating)"
    }
    
    func fitStars() {
        star1.imageView?.contentMode = .scaleAspectFit
        star2.imageView?.contentMode = .scaleAspectFit
        star3.imageView?.contentMode = .scaleAspectFit
        star4.imageView?.contentMode = .scaleAspectFit
        star5.imageView?.contentMode = .scaleAspectFit
    }
    
    func superUserRequest() {
        let alert = UIAlertController(title: myKeys.about.requestForReasonTitle, message: myKeys.about.requestForReason, preferredStyle: .alert)
        alert.addTextField { (textField) in
            
        }
        let action1 = UIAlertAction(title: myKeys.alert.cancelButton, style: .cancel) { (UIAlertAction) in
        }
        let action2 = UIAlertAction(title: myKeys.alert.doneButton, style: .default) { (UIAlertAction) in
            let textField = alert.textFields![0]
            if let reason = textField.text {
                self.firebaseService.saveRequestForSuperUserToDB(user: currentUser, reason: reason, success: {
                    self.showAlert(alertTitle: myKeys.alert.successTitle, alertMessage: myKeys.about.superuserRequestSent, actionTitle: myKeys.alert.okButton)
                }) { (error) in
                    self.showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: error, actionTitle: myKeys.alert.okButton)
                }
            }
        }
        alert.addAction(action1)
        alert.addAction(action2)
        self.present(alert, animated: true, completion: nil)
    }
    
    func rate() {
        let alert = UIAlertController(title: "\(Int(rating)) \(myKeys.about.stars)", message: myKeys.about.commentRequest, preferredStyle: .alert)
        alert.addTextField { (textField) in
            
        }
        let action1 = UIAlertAction(title: myKeys.alert.cancelButton, style: .cancel) { (UIAlertAction) in
        }
        let action2 = UIAlertAction(title: myKeys.alert.doneButton, style: .default) { (UIAlertAction) in
            let textField = alert.textFields![0]
            if let comment = textField.text {
                self.firebaseService.sendRatingToDB(user: currentUser, rating: self.rating, comment: comment, success: {
                    self.showAlert(alertTitle: myKeys.alert.successTitle, alertMessage: myKeys.about.thanksForRating, actionTitle: myKeys.alert.okButton)
                }) { (error) in
                    self.showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: error, actionTitle: myKeys.alert.okButton)
                }
            }
        }
        alert.addAction(action1)
        alert.addAction(action2)
        self.present(alert, animated: true, completion: nil)
    }
}
