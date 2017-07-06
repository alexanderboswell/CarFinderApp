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

class AccountViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    // MARK: UI Elements
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    // MARK: Variables
    var currentUser : User!
    
    // MARK: Overriden functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.profileImageView.layer.cornerRadius = 65
        self.profileImageView.clipsToBounds = true
        self.profileImageView.contentMode = .scaleAspectFill
        
        FireBaseDataObject.system.getCurrentUser { (user) in
            self.profileImageView.loadImageUsingCacheWithURLString(urlString: user.profileImageURL)
            self.emailLabel.text = user.email
            self.nameLabel.text = user.name
            self.currentUser = user
        }
        
        if self.revealViewController() != nil {
            
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImage)))
    }
    
    // MARK: ImagePicker functions
    func handleSelectProfileImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker,animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        
        if let editedImage = info ["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
            
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        let imageName = NSUUID().uuidString
        let storageRef = FIRStorage.storage().reference().child("profile_images")
        let oldImageName = currentUser.imageName + ".jpg"
        if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.02) {
            storageRef.child("\(imageName).jpg")
                .put(uploadData, metadata: nil, completion: {
                (metadata, error) in
                
                if error != nil {
                    print(error ?? "Error")
                    return
                }
                if let profileImageURL = metadata?.downloadURL()?.absoluteString {
                    FireBaseDataObject.system.CURRENT_USER_REF.child("profileImageURL").setValue(profileImageURL, withCompletionBlock: { (err,ref) in
                        
                        if err != nil {
                            print(err ?? "Error in adding user info to database")
                            return
                        }
                        
                        FireBaseDataObject.system.CURRENT_USER_REF.child("imageName").setValue(imageName, withCompletionBlock:
                            { (err, ref) in
                            
                                if err != nil {
                                 print(err ?? "Error in setting new image name")
                                    return
                                } else {
                                print("Saved User Success")
                                self.currentUser.imageName = imageName
                                let imageRef = storageRef.child(oldImageName)
                                imageRef.delete { error in
                                if let error = error {
                                    print(error)
                                    return
                                } else {
                                    print("deleted old profile image")
                                    self.dismiss(animated: true, completion: nil)
                                    }
                                }
                            }
                        })
                    })
                }
            })
        }
        
    }
    
    // MARK: UI Actions
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
   
    @IBAction func deleteAccount(_ sender: UIButton) {
       present(LoadingOverlay.instance.showLoadingOverlay(message: "Deleting Account..."), animated: true, completion: nil)
        removeFriends()
    }
    
    // MARK: Firebase functions
    func removeFriends(){
        print("delete friends")
        FireBaseDataObject.system.CURRENT_USER_FRIENDS_REF.observe(FIRDataEventType.value, with: { (snapshot) in
            for friend in snapshot.children.allObjects as! [FIRDataSnapshot] {
                let id = friend.key
                print(id)
                FireBaseDataObject.system.USER_REF.child(id).child("friends").child(self.currentUser.id).removeValue(completionBlock: { (error,ref)-> Void in
                    if error != nil {
                        print(error ?? "Error in removing friendship")
                        self.dismiss(animated: false, completion: { (dissmissOverlayError) in
                            return
                        })
                    } else {
                        print("removed friendships")
                        self.removeSentRequests()
                    }
                    
                })
            }
            if snapshot.children.allObjects.count == 0 {
                self.removeSentRequests()
            }
    
        })
    }
    func removeSentRequests(){
        FireBaseDataObject.system.CURRENT_USER_SENT_REQUESTS_REF.observe(FIRDataEventType.value, with: { (snapshot) in
            for sentRequest in snapshot.children.allObjects as! [FIRDataSnapshot] {
                let id = sentRequest.key
                print(id)
                FireBaseDataObject.system.USER_REF.child(id).child("requests").child(self.currentUser.id).removeValue(completionBlock: { (error,ref)-> Void in
                    if error != nil {
                        print(error ?? "Error in removing sent requests")
                        self.dismiss(animated: false, completion: { (dissmissOverlayError) in
                            return
                        })
                    } else {
                        print("removed sent requests")
                        self.removeRequests()
                    }
                    
                })
            }
            if snapshot.children.allObjects.count == 0 {
                self.removeRequests()
            }
        })
    }
    func removeRequests() {
        FireBaseDataObject.system.CURRENT_USER_REQUESTS_REF.observe(FIRDataEventType.value, with: { (snapshot) in
            for request in snapshot.children.allObjects as! [FIRDataSnapshot] {
                let id = request.key
                print(id)
                FireBaseDataObject.system.USER_REF.child(id).child("sent requests").child(self.currentUser.id).removeValue(completionBlock: {(error,ref)-> Void in
                    if error != nil {
                        print(error ?? "Error in removing requests")
                        self.dismiss(animated: false, completion: { (dissmissOverlayError) in
                            return
                        })
                    } else {
                        print("removed requests")
                        self.removeProfileImage()
                    }
                })
            }
            if snapshot.children.allObjects.count == 0 {
                self.removeProfileImage()
            }
        })
    }
    func removeProfileImage() {
        FIRStorage.storage().reference().child("profile_images").child(currentUser.imageName + ".jpg").delete(completion: { (Error) in
            if Error != nil {
                print(Error ?? "Error in removing profile image")
                self.dismiss(animated: false, completion: { (dissmissOverlayError) in
                    return
                })
            } else {
                print("removed profile image")
                self.removeUser()
            }
        })
    }
    func removeUser(){
        FireBaseDataObject.system.CURRENT_USER_REF.removeValue(completionBlock: { (Error) in
        FIRAuth.auth()?.currentUser?.delete(completion: { (err) in
                if  err != nil{
                    print(err ?? "Error deleting account")
                    self.dismiss(animated: false, completion: { (dissmissOverlayError) in
                        return
                    })
                }else {
                    print("removed user")
                    self.dismiss(animated: false, completion: { (dissmissOverlayError) in
                        self.showAlert("Your account has been removed.")
                    })
                }
            })
        })
    }
    
    // MARK: Other functions
    func showAlert(_ message: String) {
        let alertController = UIAlertController(title: "Spot It", message: message, preferredStyle: UIAlertControllerStyle.alert)
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
