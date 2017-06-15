//
//  FindAFriendViewController.swift
//  CarFinder
//
//  Created by alexander boswell on 6/5/17.
//  Copyright © 2017 alexander boswell. All rights reserved.
//

import Foundation
import FirebaseAuth
import Firebase
import FirebaseDatabase

class FindAFriendViewController: UIViewController, UITabBarDelegate, UITableViewDataSource {
    
//    var users = TempSingleton.sharedInstance.users
    
    var users = [User]()
    
    var requestCount = 0;
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: UI Elements
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var friendRequestsButton: UIBarButtonItem!
    // MARK: FireBase variables
    var user: FIRUser!
    
    var ref: FIRDatabaseReference!
    
    private var databaseHandle: FIRDatabaseHandle!
    
    // MARK: Overridden functions
    override func viewDidLoad() {

        // set up Firebase
        user = FIRAuth.auth()?.currentUser
        ref = FIRDatabase.database().reference()
        
        startObservingDataBase()
        startObervingNumberOfRequests()
        if self.revealViewController() != nil {
            
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    // MARK: UI Actions
    @IBAction func toRequests(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "toRequests", sender: nil)
    }
    
    
    // MARK: tableView functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return users.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath) as? UserTableViewCell else {
            fatalError("The dequeued cell is not an instance of UserTableViewCell")
        }

        let user = users[indexPath.row]
        cell.emailTextField.text = user.email
        cell.nameTextField.text = user.name
        cell.selectionStyle = .none
        cell.setFunction {
            let id = self.users[indexPath.row].id
            self.sendRequestToUser(id!)
        }
        return cell
    }
    
    // MARK: FireBase functions
    func startObservingDataBase () {
        databaseHandle = ref.child("users").observe(.value, with: { (snapshot) in
            var newUsers = [User]()
            for itemSnapShot in snapshot.children.allObjects as! [FIRDataSnapshot] {
                let id = itemSnapShot.key
                let user = User(snapshot: itemSnapShot )
                if(user.email != self.user.email){
                user.id = id
                newUsers.append(user)
                }
            }
            
            self.users = newUsers
            self.tableView.reloadData()
        })
    }
    deinit {
        ref.child("users").removeObserver(withHandle: databaseHandle)
    }
    func sendRequestToUser(_ userID: String) {
        print("friend request sent!")
        FIRDatabase.database().reference().child("users").child(userID).child("requests").child((FIRAuth.auth()?.currentUser!.uid)!).setValue(true)
    }
    func startObervingNumberOfRequests() {
        let current_user_ref = FIRDatabase.database().reference().child("users").child(user.uid)
        current_user_ref.child("requests").observe(FIRDataEventType.value,with: {(snapshot) in
            self.requestCount = 0
            for child in snapshot.children.allObjects as! [FIRDataSnapshot] {
                self.requestCount += 1
            }
            self.friendRequestsButton.title = "FriendRequests (" + String(self.requestCount) + ")"
        })
        
    }
}
