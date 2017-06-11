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
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: UI Elements
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    // MARK: Overridden functions
    override func viewDidLoad() {

        FIRDatabase.database().reference().child("users").observe(.value, with: { (snapshot) in
            
            var newUsers = [User]()
            for itemSnapShot in snapshot.children {
                let email = (itemSnapShot as AnyObject).childSnapshot(forPath: "email").value as! String
                if email != FIRAuth.auth()?.currentUser?.email!{
                let user = User(snapshot: itemSnapShot as! FIRDataSnapshot)
                newUsers.append(user)
                }
            }
            self.users = newUsers
            self.tableView.reloadData()
            
        }, withCancel : nil)
        if self.revealViewController() != nil {
            
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    // MARK: UI Actions
    @IBAction func addFriend(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "AddAFriendToMainView", sender: nil)
    }
    
    // MARK: tableView functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return users.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserTableViewCell", for: indexPath) as? UserTableViewCell else {
            fatalError("The dequeued ceel is not an instance of UserTableViewCell")
        }

        let user = users[indexPath.row]
        cell.emailTextField.text = user.email
        cell.nameTextField.text = user.name
        cell.selectionStyle = .none
        return cell
    }
}
