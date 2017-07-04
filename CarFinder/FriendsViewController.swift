//
//  FriendsViewController.swift
//  CarFinder
//
//  Created by alexander boswell on 6/14/17.
//  Copyright © 2017 alexander boswell. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class FriendsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: UI Elements
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: Othe Variables
    private var databaseHandle: FIRDatabaseHandle!
    
    var friends = [User]()
    
    var user: FIRUser!
    
    var ref : FIRDatabaseReference!
    
    // MARK: Overriden functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user = FIRAuth.auth()?.currentUser
        ref = FIRDatabase.database().reference()
        startObservingDatabase()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        editButton.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "Avenir Next", size: 16)!], for: UIControlState.normal)
        
    }
    
//    func startObservingDatabase() {
//        activityIndicator.startAnimating()
//        databaseHandle = FIRDatabase.database().reference().child("users").child(self.user.uid).child("friends").observe(.value, with : { (snapshot) in
//                self.friends.removeAll()
//            for child in snapshot.children.allObjects as! [FIRDataSnapshot] {
//                FireBaseDataObject.system.getUser(child.key, completion: { (user) in
//                    self.friends.append(user)
//                    self.tableView.reloadData()
//                    print("USER NAME")
//                        print(user.name)
//                })
//            }
//            self.activityIndicator.stopAnimating()
//
//        })
//    }
//    deinit {
//        ref.child("users/\(self.user.uid)/friends").removeObserver(withHandle: databaseHandle)
//    }
    func startObservingDatabase () {
        activityIndicator.startAnimating()
        databaseHandle = ref.child("users/\(self.user.uid)/friends").observe(.value, with: { (snapshot) in
            var newFriends = [User]()
            for itemSnapShot in snapshot.children.allObjects as! [FIRDataSnapshot] {
                FireBaseDataObject.system.getUser(itemSnapShot.key, completion: { (user) in
                    newFriends.append(user)
                    self.friends = newFriends
                    self.tableView.reloadData()
                })
            }
            self.activityIndicator.stopAnimating()
            
        })
    }
    
    
    // MARK: UI Actions
    @IBAction func editButton(_ sender: UIBarButtonItem) {
        if editButton.title == "Edit"{
        self.tableView.setEditing(true, animated: true)
            editButton.title = "Done"
        }else if editButton.title == "Done" {
            self.tableView.setEditing(false, animated: true)
            editButton.title = "Edit"
        }
    }
    
    // MARK: tableView functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  friends.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendTableViewCell", for: indexPath) as? FriendTableViewCell else {
            fatalError("The dequeued cell is not an instance of FriendTableViewCell")
        }
        let user = friends[indexPath.row]
        cell.nameTextField.text = user.name
        cell.emailTextField.text = user.email
        cell.profileImageView.layer.cornerRadius = 25
        cell.profileImageView.clipsToBounds = true
        cell.profileImageView.contentMode = .scaleAspectFill
        cell.selectionStyle = .none
        if let profileImageURL = user.profileImageURL {
            
            cell.profileImageView.loadImageUsingCacheWithURLString(urlString: profileImageURL)
            
        }else {
            print (" no user profile image")
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
 
            let id = friends[indexPath.row].id
            if let uid = id {
                friends.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)

                FireBaseDataObject.system.removeFriendRelationship(uid)
                self.tableView.reloadData()
            }
        }
    }
    
}
