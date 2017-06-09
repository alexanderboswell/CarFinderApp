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
            print("user found")
            print(snapshot)
            
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let user = users[indexPath.row]
        cell.textLabel?.text = user.email
        cell.textLabel?.textColor = UIColor.darkGray
        cell.textLabel?.font = UIFont.init(name: "Avenir Next Regular", size: 17.0)
//        cell.accessoryType = cell.isSelected ? .checkmark : .none
//        cell.selectionStyle = .none
        return cell
    }
}
