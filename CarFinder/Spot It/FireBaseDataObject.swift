//
//  FireBaseDataObject.swift
//  CarFinder
//
//  Created by alexander boswell on 6/8/17.
//  Copyright © 2017 alexander boswell. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase

class FireBaseDataObject {
    
    static let system = FireBaseDataObject()
    
    var CURRENT_USER_ID: String {
        let id = FIRAuth.auth()?.currentUser!.uid
        return id!
    }
    var CURRENT_USER_REF: FIRDatabaseReference {
        let id = FIRAuth.auth()?.currentUser!.uid
        return USER_REF.child("\(id!)")
    }
    var CURRENT_USER_FRIENDS_REF: FIRDatabaseReference {
        return CURRENT_USER_REF.child("friends")
    }
    var CURRENT_USER_PINS_REF: FIRDatabaseReference {
        return CURRENT_USER_REF.child("pins")
    }
    var CURRENT_USER_SENT_REQUESTS_REF: FIRDatabaseReference {
        return CURRENT_USER_REF.child("sent requests")
    }
    var CURRENT_USER_REQUESTS_REF: FIRDatabaseReference {
        return CURRENT_USER_REF.child("requests")
    }
    var current_user_name : String {
        return (CURRENT_USER_REF.value(forKey: "name") as? String)!
    }
    var current_user_email : String {
        return (CURRENT_USER_REF.value(forKey: "email") as? String)!
    }
    
    
    let USER_REF = FIRDatabase.database().reference().child("users")
    
    let BASE_REF = FIRDatabase.database().reference()
    
    
    func getUser(_ userID: String, completion: @escaping (User) -> Void) {
        FIRDatabase.database().reference().child("users").child(userID).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            let email = snapshot.childSnapshot(forPath: "email").value as! String
            let name = snapshot.childSnapshot(forPath: "name").value as! String
            let profileImage = snapshot.childSnapshot(forPath: "profileImageURL").value as! String
            let imageName = snapshot.childSnapshot(forPath: "imageName").value as! String
            let id = snapshot.key
            completion(User(userEmail: email, userID: id, userName: name, profileImageURL: profileImage, imageName: imageName))
        })
    }
    func getCurrentUser(_ completion: @escaping (User) -> Void) {
        CURRENT_USER_REF.observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            let email = snapshot.childSnapshot(forPath: "email").value as! String
            let id = snapshot.key
            let name = snapshot.childSnapshot(forPath: "name").value as! String
            let profileImage = snapshot.childSnapshot(forPath: "profileImageURL").value as! String
            let imageName = snapshot.childSnapshot(forPath: "imageName").value as! String
            completion(User(userEmail: email, userID: id, userName: name, profileImageURL : profileImage, imageName: imageName))
        })
    }
    func sendRequestToUser(_ userID: String) {
        USER_REF.child(userID).child("requests").child((FIRAuth.auth()?.currentUser!.uid)!).setValue(true)
    }
    func saveSentRequestToUser(_ userID: String) {
        CURRENT_USER_REF.child("sent requests").child(userID).setValue(true)
    }
    func removeSentRequestToUser(_ userID: String) {
        USER_REF.child(userID).child("sent requests").child(CURRENT_USER_ID).removeValue()
    }
    func acceptRequestToUser(_ userID: String){
        removeSentRequestToUser(userID)
        CURRENT_USER_REF.child("requests").child(userID).removeValue()
        CURRENT_USER_REF.child("friends").child(userID).setValue(true)
        FIRDatabase.database().reference().child("users").child(userID).child("friends").child(CURRENT_USER_ID).setValue(true)
        FIRDatabase.database().reference().child("users").child(userID).child("requests").child(CURRENT_USER_ID).removeValue()
    }

    func declineRequestToUser(_ userID: String){
        removeSentRequestToUser(userID)
        CURRENT_USER_REF.child("requests").child(userID).removeValue()
    }
    func removeUserObserver() {
        USER_REF.removeAllObservers()
    }
    func removeFriendRelationship(_ friendUserID: String){
        USER_REF.child(CURRENT_USER_ID).child("friends").child(friendUserID).removeValue()
        USER_REF.child(friendUserID).child("friends").child(CURRENT_USER_ID)
        .removeValue()
    }
}
