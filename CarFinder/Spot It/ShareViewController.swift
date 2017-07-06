//
//  ShareViewController.swift
//  CarFinder
//
//  Created by alexander boswell on 5/22/17.
//  Copyright © 2017 alexander boswell. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class ShareViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Variables
    var pin:Pin?
        
    var selectedUserIndexes = [NSIndexPath]()
   
    var friends = [User]()
    
    // MARK: UI Elements
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: FireBase variables
    var user: FIRUser!
    
    var ref: FIRDatabaseReference!
    
    private var databaseHandle : FIRDatabaseHandle!
    
    // MARK: Overriden functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up Firebase
        user = FIRAuth.auth()?.currentUser
        ref = FIRDatabase.database().reference()
        startObservingDatabase()
        
        tableView.allowsMultipleSelection = true
        
        // set up navigation bar
        self.navigationController?.isNavigationBarHidden = true
        
        saveButton.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "Avenir Next", size: 16)!], for: UIControlState.normal)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: Firebase functions
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
                        if self.selectedUserIndexes.count != 0 {
                            for j in 0...self.selectedUserIndexes.count - 1 {
                                if self.selectedUserIndexes[j].row == i {
                                    self.selectedUserIndexes.remove(at: j)
                                    break
                                }
                            }
                        }
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
    
    //MARK: UI Actions
    @IBAction func exit(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {})
    }
    @IBAction func save(_ sender: UIBarButtonItem) {
        
        
        var newPinData = [
            "title": pin?.title as! String,
            "locationName": pin?.locationName as! String,
            "latitude": pin?.latitude as! NSNumber,
            "longitude": pin?.longitude as! NSNumber
            ] as [String : Any]
        var ids = [String]()
        
        for NSIndexPath in selectedUserIndexes {
            ids.append(friends[NSIndexPath.row].id)
        }
        for String in ids {
            FireBaseDataObject.system.USER_REF.child(String).child("pins").childByAutoId().setValue(newPinData)
        }
        newPinData["locationName"] = String((pin?.latitude)!) + " " + String((pin?.longitude)!)
        FireBaseDataObject.system.CURRENT_USER_REF.child("pins").childByAutoId().setValue(newPinData)
        
       performSegue(withIdentifier: "ShareToMainView", sender: nil)
    }

    // MARK: tableView functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendShareTableViewCell", for: indexPath) as? FriendShareTableViewCell else {
            fatalError("The dequeued cell is not an instance of FriendTableViewCell")
        }

        let user: User

        user = friends[indexPath.row]

        cell.nameTextField.text = user.name
        cell.emailTextField.text = user.email
        cell.accessoryType = cell.isSelected ? .checkmark : .none
        cell.selectionStyle = .none
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        selectedUserIndexes = (tableView.indexPathsForSelectedRows as [NSIndexPath]?)!
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
        for i in 0...selectedUserIndexes.count - 1  {
            if selectedUserIndexes[i] as IndexPath == indexPath {
                selectedUserIndexes.remove(at: i)
            }
        }
    }
    
}


