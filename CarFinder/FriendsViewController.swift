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
    
    // MARK: Variables
    
    var friends = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // self.tableView.setEditing(true, animated: true)
        startObservingDataBase()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
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
        
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let user = friends[indexPath.row]
            self.friends.remove(at: indexPath.row)
            FireBaseDataObject.system.removeFriendRelationship(user.id!)
            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            self.tableView.reloadData()
        }
    }
    
    // MARK: FireBase functions
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
