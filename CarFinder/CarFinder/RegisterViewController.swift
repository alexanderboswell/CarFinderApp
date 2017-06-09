//
//  RegisterViewController.swift
//  CarFinder
//
//  Created by alexander boswell on 5/5/17.
//  Copyright © 2017 alexander boswell. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase


class RegisterViewController: UIViewController {

    // MARK: UI Elements
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: Overriden functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // set up tap to close keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RegisterViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    // MARK: UI Actions
    @IBAction func registerAccount(_ sender: UIButton) {
        let email = emailTextField.text
        let password = passwordTextField.text
        // check to see if name field is empty
        FIRAuth.auth()?.createUser(withEmail: email!, password: password!, completion: { (user, error) in
            if let error = error {
                if let errCode = FIRAuthErrorCode(rawValue: error._code) {
                    switch errCode {
                    case .errorCodeInvalidEmail:
                        self.showAlert("Enter a valid email.")
                    case .errorCodeEmailAlreadyInUse:
                        self.showAlert("Email already in use.")
                    default:
                        self.showAlert("Error: \(error.localizedDescription)")
                    }
                }
                return
            }
            let values = ["name": self.nameTextField.text!,"email":self.emailTextField.text!]
            FIRDatabase.database().reference().child("users").child((user!.uid)).updateChildValues(values, withCompletionBlock: { (err,ref) in
                
                if err != nil {
                    print(err ?? "Error in adding user info to database")
                    return
                }
                print("Saved User Success")
                
            })
            self.signIn()
        })
    }
    @IBAction func backToLogin(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {})
    }
    
    // MARK: Other functions
    func showAlert(_ message: String){
            let alertController = UIAlertController(title: "CarFinder", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController,animated: true,completion: nil)
        
        
    }
    func signIn(){
        performSegue(withIdentifier: "RegisterToMainView", sender: nil)
        nameTextField.text = ""
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
