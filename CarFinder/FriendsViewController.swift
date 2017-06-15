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
    
    // MARK: Variables
    
    var friends = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
      //  let user = User(userEmail: "testing@gmail.com", userID: "alejfqhoqgoqegiqo", userName: "billy bob")
       // friends.append(user)
       // self.tableView.reloadData()
        // set up side menu
        
        startObservingDataBase()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
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
        
        return cell
    }
    func startObservingDataBase() {
        FireBaseDataObject.system.CURRENT_USER_REF.child("friends").observe (FIRDataEventType.value,with: {(snapshot) in
            self.friends.removeAll()
            for child in snapshot.children.allObjects as! [FIRDataSnapshot] {
                let id = child.key
                FireBaseDataObject.system.getUser(id, completion: { (user) in
                self.friends.append(user)
                self.tableView.reloadData()
                })
            }
        })
    }
}
