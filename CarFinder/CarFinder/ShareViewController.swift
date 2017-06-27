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
    
    var filteredUsers = [User]()
    
    var selectedUserIndexes = [NSIndexPath]()
    
 //   let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: UI Elements
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    // MARK: FireBase variables
    var user: FIRUser!
    
    var ref: FIRDatabaseReference!
    
    // MARK: Overriden functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up Firebase
        user = FIRAuth.auth()?.currentUser
        ref = FIRDatabase.database().reference()
        
        FireBaseDataObject.system.addFriendObserver {
            self.tableView.reloadData()
        }
        
        // set up the Search Controller
 //       searchController.searchResultsUpdater = self
 //       searchController.dimsBackgroundDuringPresentation = false
 //       definesPresentationContext = true
        
 //       tableView.tableHeaderView = searchController.searchBar
 //       tableView.allowsMultipleSelection = true
        
        // set up navigation bar
        self.navigationController?.isNavigationBarHidden = true
        
        saveButton.setTitleTextAttributes([ NSFontAttributeName: UIFont(name: "Avenir Next", size: 16)!], for: UIControlState.normal)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: UI Actions
    @IBAction func exit(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {})
    }
    @IBAction func save(_ sender: UIBarButtonItem) {
        let newPinData = [
            "title": pin?.title as! String,
            "locationName": pin?.locationName as! String,
            "latitude": pin?.latitude as! NSNumber,
            "longitude": pin?.longitude as! NSNumber
            ] as [String : Any]
        var ids = [String]()
        ids.append(self.user.uid)
        for NSIndexPath in selectedUserIndexes {
            ids.append(FireBaseDataObject.system.friends[NSIndexPath.row].id)
        }
        for String in ids {
            FireBaseDataObject.system.USER_REF.child(String).child("pins").childByAutoId().setValue(newPinData)
        }
        
        
       performSegue(withIdentifier: "ShareToMainView", sender: nil)
    }

    // MARK: tableView functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
   //     if searchController.isActive && searchController.searchBar.text != "" {
     //       return filteredUsers.count
      //  }
        return FireBaseDataObject.system.friends.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendShareTableViewCell", for: indexPath) as? FriendShareTableViewCell else {
            fatalError("The dequeued cell is not an instance of FriendTableViewCell")
        }

        let user: User
     //   if searchController.isActive && searchController.searchBar.text != "" {
     //       user = filteredUsers[indexPath.row]
     //   } else {
            user = FireBaseDataObject.system.friends[indexPath.row]
     //   }
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
    }
    
    func filterContentForSearchText(searchText: String) {
        filteredUsers = FireBaseDataObject.system.friends.filter { user in
            return user.email.lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }
    
}

// MARK: Search Controller Extension
extension ShareViewController: UISearchResultsUpdating {
    @available(iOS 8.0, *)
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }

    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}

