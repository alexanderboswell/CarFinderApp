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
    
    var users = [User]()
    
   // var sentRequests = [User]()
    
    var requestCount = 0
    
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: UI Elements
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var friendRequestsButton: UIBarButtonItem!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        startObservingDataBase()
        
        if self.revealViewController() != nil {
            
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        friendRequestsButton.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "Avenir Next", size: 16)!], for: UIControlState.normal)
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
        cell.profileImageView.layer.cornerRadius = 25
        cell.profileImageView.clipsToBounds = true
        cell.profileImageView.contentMode = .scaleAspectFill
        if let profileImageURL = user.profileImageURL {
            
            cell.profileImageView.loadImageUsingCacheWithURLString(urlString: profileImageURL)
            
        }else {
            print (" no user profile image")
        }
        
        return cell
    }
    
    // MARK: FireBase functions
    func startObservingDataBase(){
        
        FireBaseDataObject.system.addFriendObserver {
            self.tableView.reloadData()
        }
        
        // FireBaseDataObject.system.addUserObserver {
        //   self.tableView.reloadData()
        //}
        
        FireBaseDataObject.system.addSentRequestObserver {
            self.tableView.reloadData()
            print("requests: " + String(FireBaseDataObject.system.sentRequests.count))
        }
        
        startObervingNumberOfRequests()
        startObservingUsers()
                
    
    }
    
    func startObservingUsers() {
    FireBaseDataObject.system.USER_REF.observe(.value, with: { (snapshot) in
            var newUsers = [User]()
            for itemSnapShot in snapshot.children.allObjects as! [FIRDataSnapshot] {
                let id = itemSnapShot.key
                let user = User(snapshot: itemSnapShot )
                user.id = id
                if user.email != FIRAuth.auth()?.currentUser?.email!{
                   // if !self.checkFriends(user: user){
                    for r in FireBaseDataObject.system.sentRequests {
                        print(r.name)
                    }
                        newUsers.append(user)
                    //}
                }
            }
    
            self.users = newUsers
            self.tableView.reloadData()
        })
    }
    deinit {
        FireBaseDataObject.system.removeUserObserver()
    }
    
//    func checkFriends(user: User) -> Bool {
//        print("FRIEND TEST")
//        for friend in FireBaseDataObject.system.friends {
//            print(user.id + " " + friend.id)
//            if user.id == friend.id {
//                print(user.id + " " + friend.id)
//                print ("found friend")
//                return true
//            }
//        }
//        print("didnt find friend")
//        return false
//    }
    
    
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
