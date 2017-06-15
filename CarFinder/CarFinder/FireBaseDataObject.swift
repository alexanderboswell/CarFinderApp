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
    let USER_REF = FIRDatabase.database().reference().child("users")
    
    
    func getUser(_ userID: String, completion: @escaping (User) -> Void) {
        FIRDatabase.database().reference().child("users").child(userID).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            let email = snapshot.childSnapshot(forPath: "email").value as! String
            let name = snapshot.childSnapshot(forPath: "name").value as! String
            let id = snapshot.key
            completion(User(userEmail: email, userID: id, userName: name))
        })
    }
    func acceptRequestToUser(_ userID: String){
        CURRENT_USER_REF.child("requests").child(userID).removeValue()
        CURRENT_USER_REF.child("friends").child(userID).setValue(true)
        FIRDatabase.database().reference().child("users").child(userID).child("friends").child(CURRENT_USER_ID).setValue(true)
        FIRDatabase.database().reference().child("users").child(userID).child("requests").child(CURRENT_USER_ID).removeValue()
    }
    func declineRequestToUser(_ userID: String){
        CURRENT_USER_REF.child("requests").child(userID).removeValue()
    }

}
