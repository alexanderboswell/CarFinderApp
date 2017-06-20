//
//  AccountViewController.swift
//  CarFinder
//
//  Created by alexander boswell on 6/19/17.
//  Copyright © 2017 alexander boswell. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class AccountViewController: UIViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    var currentUser : User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FireBaseDataObject.system.getCurrentUser { (user) in
            self.emailLabel.text = user.email
            self.nameLabel.text = user.name
            self.currentUser = user
        }
        
        if self.revealViewController() != nil {
            
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    @IBAction func resetPassword(_ sender: UIButton) {
        FIRAuth.auth()?.sendPasswordReset(withEmail: currentUser.email, completion: {
            (error) in
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
    
    // MARK: Other functions
    func showAlert(_ message: String) {
        let alertController = UIAlertController(title: "CarFinder", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: { action in
                self.signOut()
        }))
        self.present(alertController, animated: true, completion:nil)
    }
    func signOut(){
        do {
            try FIRAuth.auth()?.signOut()
            performSegue(withIdentifier: "signOutAfterPasswordReset", sender: nil)
        } catch let error {
            assertionFailure("Error signing out: \(error)")
          }
       }
}
