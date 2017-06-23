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
    
    // MARK: UI Elements
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Variables
    
    var friendRequests = [User]()
    
    // MARK: Overriden functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            FireBaseDataObject.system.acceptRequestToUser(id!)
            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            self.tableView.reloadData()
        }
        cell.setFunctionDecline {
            self.friendRequests.remove(at: indexPath.row)
            FireBaseDataObject.system.declineRequestToUser(id!)
            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            self.tableView.reloadData()
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
    func startObservingDataBase(){
        FireBaseDataObject.system.CURRENT_USER_REF.child("requests").observe(FIRDataEventType.value,with: {(snapshot) in
            var newFriendRequests = [User]()
            for child in snapshot.children.allObjects as! [FIRDataSnapshot] {
                let id = child.key
                FireBaseDataObject.system.getUser(id, completion: { (user) in
                    newFriendRequests.append(user)
                    self.friendRequests = newFriendRequests
                    self.tableView.reloadData()
                })
            }
        })
    }
}
