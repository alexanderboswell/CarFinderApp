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
        let user = friendRequests[indexPath.row]
        cell.emailTextField.text = user.email
        cell.nameTextField.text = user.name
        let id = user.id
        cell.setFunction {
            self.friendRequests.remove(at:indexPath.row)
            self.acceptRequestToUser(id!)
            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            self.tableView.reloadData()
        }
        cell.setFunctionDecline {
            self.friendRequests.remove(at: indexPath.row)
            self.declineRequestToUser(id!)
            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            self.tableView.reloadData()
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
        CURRENT_USER_REF.child("requests").child(userID).removeValue()
        CURRENT_USER_REF.child("friends").child(userID).setValue(true)
        FIRDatabase.database().reference().child("users").child(userID).child("friends").child(CURRENT_USER_ID).setValue(true)
        FIRDatabase.database().reference().child("users").child(userID).child("requests").child(CURRENT_USER_ID).removeValue()
    }
    func declineRequestToUser(_ userID: String){
        CURRENT_USER_REF.child("requests").child(userID).removeValue()
    }
    var CURRENT_USER_ID: String {
        let id = FIRAuth.auth()?.currentUser!.uid
        return id!
    }
    var CURRENT_USER_REF: FIRDatabaseReference {
        let id = FIRAuth.auth()?.currentUser!.uid
        return USER_REF.child("\(id!)")
    }
    let USER_REF = FIRDatabase.database().reference().child("users")
    
}
