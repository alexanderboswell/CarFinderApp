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
    


    func startObservingDatabase () {
        FireBaseDataObject.system.CURRENT_USER_FRIENDS_REF.observe(.childAdded, with: { (snapshot) -> Void in
            self.activityIndicator.startAnimating()
                FireBaseDataObject.system.getUser(snapshot.key, completion: { (user) in
                 self.friends.append(user)
                    self.tableView.insertRows(at: [IndexPath(row: self.friends.count - 1, section:0)], with: UITableViewRowAnimation.automatic)
                })
            self.activityIndicator.stopAnimating()
        })
        FireBaseDataObject.system.CURRENT_USER_FRIENDS_REF.observe(.childRemoved, with: { (snapshot) ->
            Void in
            if self.friends.count != 0 {
                var indexes = [Int]()
                for i in 0 ... self.friends.count - 1  {
                    if self.friends[i].id == snapshot.key {
                        indexes.append(i)
                    }
                }
                for index in indexes {
                    self.friends.remove(at: index)
                    self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: UITableViewRowAnimation.automatic)
                }
            }
        })
     activityIndicator.stopAnimating()
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
                FireBaseDataObject.system.removeFriendRelationship(uid)
                self.tableView.reloadData()
            }
        }
    }
    
}
