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
    
    var friends = [User]()
    
    var sentRequests = [User]()
    
    var requestCount = 0;
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: UI Elements
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var friendRequestsButton: UIBarButtonItem!

    override func viewDidLoad() {
        
        startObservingDataBase()
        
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
            FireBaseDataObject.system.sendRequestToUser(id!)
            FireBaseDataObject.system.saveSentRequestToUser(id!)
            
        }
        return cell
    }
    
    // MARK: FireBase functions
    func startObservingDataBase(){
        
        startObservingUsers()
        startObservingFriends()
        startObservingSentRequests()
        startObervingNumberOfRequests()
    }
    
    func startObservingUsers() {
    FireBaseDataObject.system.USER_REF.observe(.value, with: { (snapshot) in
            var newUsers = [User]()
            for itemSnapShot in snapshot.children.allObjects as! [FIRDataSnapshot] {
                let id = itemSnapShot.key
                let user = User(snapshot: itemSnapShot )
                if user.email != FIRAuth.auth()?.currentUser?.email! {
                user.id = id
                newUsers.append(user)
                }
            }
        
            self.users = newUsers
            self.tableView.reloadData()
        })
    }
    deinit {
        FireBaseDataObject.system.removeUserObserver()
    }
    
    func startObservingFriends() {
        FireBaseDataObject.system.CURRENT_USER_REF.child("friends").observe (FIRDataEventType.value,with: {(snapshot) in
            self.friends.removeAll()
            print("friends")
            for child in snapshot.children.allObjects as! [FIRDataSnapshot] {
                let id = child.key
                FireBaseDataObject.system.getUser(id, completion: { (user) in
                    print(user.name)
                    self.friends.append(user)
                    self.tableView.reloadData()
                })
            }
        })
    }
    
    func startObservingSentRequests() {
        FireBaseDataObject.system.CURRENT_USER_REF.child("sent requests").observe (FIRDataEventType.value, with: {(snapshot) in
            self.sentRequests.removeAll()
            print("sent requests")
            for child in snapshot.children.allObjects as! [FIRDataSnapshot] {
                let id = child.key
                FireBaseDataObject.system.getUser(id, completion: { (user) in
                    print(user.name)
                    self.sentRequests.append(user)
                    self.tableView.reloadData()
                })
            }
        })
    }
    
    
    func startObervingNumberOfRequests() {
        FireBaseDataObject.system.CURRENT_USER_REF.child("requests").observe(FIRDataEventType.value,with: {(snapshot) in
            self.requestCount = 0
            for _ in snapshot.children.allObjects as! [FIRDataSnapshot] {
                self.requestCount += 1
            }
            self.friendRequestsButton.title = "Friend Requests (" + String(self.requestCount) + ")"
        })
        
    }
}
