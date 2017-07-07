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
    
    var sentRequests = [String:Bool]()
    
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
        let id = self.users[indexPath.row].id
        if let sentRequestCheck = sentRequests[id!] {
            if sentRequestCheck {
                cell.button.isEnabled = false
                cell.button.setTitle("Requested",for: .normal)
            }
        }else {
            cell.button.isEnabled = true
            cell.button.setTitle("Add", for: .normal)
        }
        cell.setFunction {
            FireBaseDataObject.system.sendRequestToUser(id!)
            FireBaseDataObject.system.saveSentRequestToUser(id!)
            cell.button.isEnabled = false
            cell.button.setTitle("Requested", for: .normal)
            self.sentRequests[id!] = true
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
                    FireBaseDataObject.system.CURRENT_USER_FRIENDS_REF.observeSingleEvent(of: .value, with: { (friendSnapshot) in
                        var friendCheck = false
                        for child in friendSnapshot.children.allObjects as! [FIRDataSnapshot] {
                            if child.key == user.id{
                                friendCheck = true
                            }
                        }
                        if !friendCheck{
                            FireBaseDataObject.system.CURRENT_USER_SENT_REQUESTS_REF.observeSingleEvent(of: .value, with: {(sentRequestSnapshot) in
                                var sentRequestCheck = false
                                for child in sentRequestSnapshot.children.allObjects as! [FIRDataSnapshot] {
                                    if child.key == user.id {
                                        sentRequestCheck = true
                                    }
                                }
                                if sentRequestCheck {
                                    self.sentRequests[user.id] = true
                                }
                                self.users.append(user)
                                self.tableView.insertRows(at: [IndexPath(row: self.users.count - 1, section: 0)], with: UITableViewRowAnimation.automatic)
                            })
                        }
                    })
                }
            })
        })
        FireBaseDataObject.system.USER_REF.observe(.childRemoved, with: { (snapshot) -> Void in
            self.findUserInTableAndRemove(key: snapshot.key)
          })
        FireBaseDataObject.system.CURRENT_USER_SENT_REQUESTS_REF.observe(.childRemoved, with: {(snapshot) in
            
            FireBaseDataObject.system.CURRENT_USER_FRIENDS_REF.observeSingleEvent(of: .value, with: {(friendSnapshot) in
                var friendCheck = false
                print("SNAP")
                print(friendSnapshot)
                for child in friendSnapshot.children.allObjects as! [FIRDataSnapshot]{
                    if snapshot.key == child.key {
                        if self.users.count != 0{
                            for i in 0...self.users.count - 1  {
                                if self.users[i].id == snapshot.key {
                                    friendCheck = true
                                    self.users.remove(at: i)
                                    self.tableView.deleteRows(at: [IndexPath(row: i,section: 0)], with: UITableViewRowAnimation.automatic)
                                    return
                                }
                            }
                        }
                    }
                }
                if !friendCheck {
                    if self.users.count != 0 {
                        for i in 0...self.users.count - 1 {
                            if self.users[i].id == snapshot.key {
                                guard let cell = self.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? UserTableViewCell else {
                                    return
                                }
                                cell.button.isEnabled = true
                                cell.button.setTitle("Add", for: .normal)
                                if self.sentRequests[self.users[i].id] != nil {
                                    self.sentRequests[self.users[i].id] = false
                                }
                            }
                        }
                    }
                }
            })
        })
    }
    func findUserInTableAndRemove(key: String) {
        var indexes = [Int]()
        if  self.users.count != 0 {
            for i in 0...self.users.count - 1 {
                if self.users[i].id == key{
                    indexes.append(i)
                }
            }
        }
        for index in indexes {
            self.users.remove(at: index)
            self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: UITableViewRowAnimation.automatic)
        }
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
