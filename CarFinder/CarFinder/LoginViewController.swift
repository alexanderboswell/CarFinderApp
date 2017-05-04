//
//  LoginViewController.swift
//  CarFinder
//
//  Created by alexander boswell on 5/3/17.
//  Copyright © 2017 alexander boswell. All rights reserved.
//

import Foundation

import UIKit
import FirebaseAuth


class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let _ = FIRAuth.auth()?.currentUser {
            self.signIn()
        }
    }
    
    @IBAction func signIn(_ sender: UIButton) {
        let email = emailTextField.text
        let password = passwordTextField.text
        FIRAuth.auth()?.signIn(withEmail: email!, password: password!, completion: {(user, error) in
            guard let _ = user else {
                if let error = error {
                    if let errCode = FIRAuthErrorCode(rawValue: error._code) {
                        switch errCode {
                        case .errorCodeUserNotFound:
                            self.showAlert("User account not found. Try registering")
                        case .errorCodeWrongPassword:
                            self.showAlert("Incorrect username/password combination")
                        default:
                            self.showAlert("Error: \(error.localizedDescription)")
                        }
                    }
                    return
                }
                assertionFailure("user and error are nil")
                return
            }
            self.signIn()
        })
    }
    @IBAction func forgotPassword(_ sender: UIButton) {
        let prompt = UIAlertController(title: "CarFinder", message: "Email:", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            let userInput = prompt.textFields![0].text
            if (userInput!.isEmpty) {
                return
            }
            FIRAuth.auth()?.sendPasswordReset(withEmail: userInput!, completion: { (error) in
                if let error = error {
                    if let errCode = FIRAuthErrorCode(rawValue: error._code) {
                        switch errCode {
                        case .errorCodeUserNotFound:
                            DispatchQueue.main.async {
                                self.showAlert("User account not found. Try registering")
                            }
                        default:
                            DispatchQueue.main.async {
                                self.showAlert("Error: \(error.localizedDescription)")
                            }
                        }
                    }
                    return
                } else {
                    DispatchQueue.main.async {
                        self.showAlert("You'll receive an email shortly to reset your password.")
                    }
                }
            })
        }
        prompt.addTextField(configurationHandler: nil)
        prompt.addAction(okAction)
        present(prompt, animated: true, completion: nil)
    }
    
    func showAlert(_ message: String) {
        let alertController = UIAlertController(title: "CarFinder", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
        func signIn() {
                    performSegue(withIdentifier: "LoginToMainView", sender: nil)
    }
}
