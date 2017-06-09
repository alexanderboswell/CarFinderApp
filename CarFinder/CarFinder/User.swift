//
//  User.swift
//  CarFinder
//
//  Created by alexander boswell on 5/31/17.
//  Copyright © 2017 alexander boswell. All rights reserved.
//

import Foundation

class User {
    
    // MARK: Class Variables
    var email: String!
    
    var id: String!
    
    // MARK: Initizalition
    init(userEmail: String, userID: String) {
        self.email = userEmail
        self.id = userID
    }
    
}
