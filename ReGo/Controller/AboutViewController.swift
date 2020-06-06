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
    
    //MARK:- IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendReviewButton: UIButton!
    @IBOutlet weak var superUserButton: UIButton!
    
    //MARK:- ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLang()
    }

    //MARK:- IBActions
    @IBAction func sendReviewButtonPressed(_ sender: UIButton) {
        
    }
    @IBAction func superUserButtonPressed(_ sender: UIButton) {
        if currentUser.superUser {
            showAlert(alertTitle: myKeys.alert.errTitle, alertMessage: myKeys.about.userIsSuperMessage, actionTitle: myKeys.alert.okButton)
        }
        else {
            superUserRequest()
        }
    }
    
    //MARK:- METHODS
    func updateLang(){
        titleLabel.text = myKeys.about.title
        sendReviewButton.setTitle(myKeys.about.sendReviewButton, for: .normal)
        superUserButton.setTitle(myKeys.about.superUserButton, for: .normal)
        textView.text = myKeys.about.infoText
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
}
