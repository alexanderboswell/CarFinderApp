//
//  User.swift
//  CarFinder
//
//  Created by alexander boswell on 5/31/17.
//  Copyright © 2017 alexander boswell. All rights reserved.
//

import Foundation
import FirebaseDatabase

class User {
    
    // MARK: Class Variables
    var email: String!
    
    var id: String!
    
    var name: String!
    
    var ref : FIRDatabaseReference?
    
    // MARK: Initizalition
    init(userEmail: String, userID: String, userName: String) {
        self.email = userEmail
        self.id = userID
        self.name = userName
    }
    init (snapshot: FIRDataSnapshot) {
        ref = snapshot.ref
        
        let data = snapshot.value as! Dictionary<String, Any>
        
        self.email = data["email"] as? String
        self.name = data["name"] as? String
    }
    
}
