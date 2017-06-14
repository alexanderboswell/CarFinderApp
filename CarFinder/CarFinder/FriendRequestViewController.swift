//
//  FriendRequestViewController.swift
//  CarFinder
//
//  Created by alexander boswell on 6/12/17.
//  Copyright © 2017 alexander boswell. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class FriendRequestViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    // MARK: Variables
    
    var friendRequests = [User]()
    
    // MARK: FireBase Variables
    var user: FIRUser!
    
    var ref: FIRDatabaseReference!
    
    private var databaseHandle: FIRDatabaseHandle!
    
    // MARK: Overriden functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up Firebase
        user = FIRAuth.auth()?.currentUser
        ref = FIRDatabase.database().reference()
        startObservingDataBase()
    }
    @IBAction func close(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {})
    }
    // MARK: tableView functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendRequests.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequestTableViewCell", for: indexPath) as? FriendRequestTableViewCell else {
            fatalError("The dequeued cell is not an instance of FriendRequestTableViewCell")
        }
        cell.emailTextField.text = self.friendRequests[indexPath.row].email
        cell.nameTextField.text = self.friendRequests[indexPath.row].name
        cell.setFunction {
            let id = self.friendRequests[indexPath.row].id
            self.acceptRequestToUser(id!)
        }
        return cell
    }
    func startObservingDataBase(){
        let current_user_ref = FIRDatabase.database().reference().child("users").child(user.uid)
        current_user_ref.child("requests").observe(FIRDataEventType.value,with: {(snapshot) in
            self.friendRequests.removeAll()
            for child in snapshot.children.allObjects as! [FIRDataSnapshot] {
                let id = child.key
                self.getUser(id, completion: { (user) in
                    self.friendRequests.append(user)
                self.tableView.reloadData()
                })
            }
            
        })
    }
    func getUser(_ userID: String, completion: @escaping (User) -> Void) {
        FIRDatabase.database().reference().child("users").child(userID).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            let email = snapshot.childSnapshot(forPath: "email").value as! String
            let name = snapshot.childSnapshot(forPath: "name").value as! String
            let id = snapshot.key
            completion(User(userEmail: email, userID: id, userName: name))
        })
    }
    func acceptRequestToUser(_ userID: String){
        
    }
    
}
