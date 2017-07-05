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
import FirebaseStorage


class RegisterViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: UI Elements
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var profileImageView: UIImageView!
    // MARK: Overriden functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // set up tap to close keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RegisterViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImage)))
        profileImageView.layer.cornerRadius = 49
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
    }
    func handleSelectProfileImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled")
        self.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print(info)
        
        var selectedImageFromPicker: UIImage?
        
        
        if let editedImage = info ["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
            
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        
        self.dismiss(animated: true, completion: nil)
    }

    
    // MARK: UI Actions
    @IBAction func registerAccount(_ sender: UIButton) {
        
        let email = emailTextField.text
        let password = passwordTextField.text
        let name = nameTextField.text
        if email == "" {
            self.showAlert("Please enter a email")
            return
        } else if password == "" {
            self.showAlert("Please enter a pasword")
            return
        } else if name == "" {
            self.showAlert("Please enter a name")
            return
        } else {
        self.addNewUser(email: email!, password: password!, name:name!)
        }
    }
    @IBAction func backToLogin(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {})
    }
    func addNewUser(email: String, password: String, name: String ){
        present(LoadingOverlay.instance.showLoadingOverlay(message: "Registering..."), animated: true, completion: nil)
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if let error = error {
                if let errCode = FIRAuthErrorCode(rawValue: error._code) {
                    self.dismiss(animated: false, completion: { (err) in
                        switch errCode {
                        case .errorCodeInvalidEmail:
                            self.showAlert("Enter a valid email.")
                        case .errorCodeEmailAlreadyInUse:
                            self.showAlert("Email already in use.")
                        default:
                            self.showAlert("Error: \(error.localizedDescription)")
                        }
                        
                    })
                    return
                }
            }
            let imageName = NSUUID().uuidString
            let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).jpg")
            
            if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.02){
                
                storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                    
                    if error != nil {
                        print(error ?? "Error")
                        self.dismiss(animated: false, completion: { (error) in
                            return
                        })
                    }
                    if let profileImageURL = metadata?.downloadURL()?.absoluteString {
                        let values = ["name": name,"email":email,"profileImageURL": profileImageURL,"imageName": imageName]
                        FIRDatabase.database().reference().child("users").child((user!.uid)).updateChildValues(values, withCompletionBlock: { (err,ref) in
                            
                            if err != nil {
                                print(err ?? "Error in adding user info to database")
                                self.dismiss(animated: false, completion: { (error) in
                                    return
                                })
                            }
                            print("Saved User Success")
                            imageCache.object(forKey: profileImageURL as AnyObject)
                        })
                        self.dismiss(animated: false, completion: { (error) in
                            self.signIn()
                        })
                  
                    }
                })
            }
            

        })
    }
    
    // MARK: Other functions
    func showAlert(_ message: String){
            let alertController = UIAlertController(title: "Spot It", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController,animated: true,completion: nil)
        
        
    }
    func signIn(){
        performSegue(withIdentifier: "RegisterToMainView", sender: nil)
        nameTextField.text = ""
        emailTextField.text = ""
        passwordTextField.text = ""
        profileImageView.image  = UIImage(named: "Default Photo")
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
