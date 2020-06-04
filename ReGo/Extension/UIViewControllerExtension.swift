//
//  UIViewControllerExtension.swift
//  ReGo
//
//  Created by Анна Мельхова on 04.06.2020.
//  Copyright © 2020 Anna Melkhova. All rights reserved.
//

import UIKit

extension UIViewController {
    // alert
    func showAlert(alertTitle : String, alertMessage : String, actionTitle : String) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: actionTitle, style: .default) { (UIAlertAction) in
            
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertWithAction(alertTitle : String, alertMessage : String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: myKeys.alert.okButton, style: .default) { (UIAlertAction) in
            completion()
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertOkCancel(alertTitle : String, alertMessage : String, okActions: @escaping () -> Void, cancelActions: @escaping () -> Void) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let action1 = UIAlertAction(title: myKeys.alert.okButton, style: .default) { (UIAlertAction) in
            okActions()
        }
        let action2 = UIAlertAction(title: myKeys.alert.cancelButton, style: .cancel) { (UIAlertAction) in
            cancelActions()
        }
        alert.addAction(action1)
        alert.addAction(action2)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertYesNo(alertTitle : String, alertMessage : String, okActions: @escaping () -> Void, cancelActions: @escaping () -> Void) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let action1 = UIAlertAction(title: myKeys.alert.yesButton, style: .default) { (UIAlertAction) in
            okActions()
        }
        let action2 = UIAlertAction(title: myKeys.alert.noButton, style: .cancel) { (UIAlertAction) in
            cancelActions()
        }
        alert.addAction(action1)
        alert.addAction(action2)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertCustomActions(alertTitle : String, alertMessage : String, action1Title : String, action2Title : String, action1: @escaping () -> Void, action2: @escaping () -> Void) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let action1 = UIAlertAction(title: action1Title, style: .default) { (UIAlertAction) in
            action1()
        }
        let action2 = UIAlertAction(title: action2Title, style: .default) { (UIAlertAction) in
            action2()
        }
        alert.addAction(action1)
        alert.addAction(action2)
        self.present(alert, animated: true, completion: nil)
    }
    
    func gotoAnotherView(identifier: String, sender: UIViewController){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
               let singupVC = storyboard.instantiateViewController(identifier: identifier)
        singupVC.modalPresentationStyle = .fullScreen
        sender.dismiss(animated: true) {
            sender.present(singupVC, animated: true, completion: nil)
        }
    }
}
