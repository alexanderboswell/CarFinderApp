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
    
    var requestCount = 0
    
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: UI Elements
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var friendRequestsButton: UIBarButtonItem!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        users.removeAll()
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
    
    // MARK: FireBase functions
    func startObservingDataBase(){
        
        startObervingNumberOfRequests()
        FireBaseDataObject.system.USER_REF.observe(.childAdded, with: { (snapshot) -> Void in
            FireBaseDataObject.system.getUser(snapshot.key, completion: { (user) in
                if FIRAuth.auth()?.currentUser?.uid != user.id {
                    self.users.append(user)
                    self.tableView.insertRows(at: [IndexPath(row: self.users.count - 1, section: 0)], with: UITableViewRowAnimation.automatic)
                }
            })
        
        })
        FireBaseDataObject.system.USER_REF.observe(.childRemoved, with: { (snapshot) -> Void in
            var indexes = [Int]()
            if  self.users.count != 0 {
                for i in 0...self.users.count - 1 {
                    if self.users[i].id == snapshot.key{
                        indexes.append(i)
                    }
                }
            }
            for index in indexes {
            self.users.remove(at: index)
            self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: UITableViewRowAnimation.automatic)
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
