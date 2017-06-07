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
    
    var pin:Pin?
    var users = TempSingleton.sharedInstance.users
    var filteredUsers = [User]()
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    // FireBase varibales
    var user: FIRUser!
    
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up Firebase
        user = FIRAuth.auth()?.currentUser
        ref = FIRDatabase.database().reference()

        users = TempSingleton.sharedInstance.users
        
        self.navigationController?.isNavigationBarHidden = true
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        tableView.tableHeaderView = searchController.searchBar
        tableView.allowsMultipleSelection = true
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @IBAction func exit(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {});
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        let newPinRef = self.ref.child("users").child(self.user.uid).child("pins").childByAutoId()
        _ = newPinRef.key
        let newPinData = [
            "title": pin?.title as! String,
            "locationName": pin?.locationName as! String,
            "latitude": pin?.latitude as! NSNumber,
            "longitude": pin?.longitude as! NSNumber
            ] as [String : Any]
        
        newPinRef.setValue(newPinData)
        
        
        performSegue(withIdentifier: "ShareToMainView", sender: nil)
    }
    
    
    // tableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredUsers.count
        }
        return users.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let user: User
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filteredUsers[indexPath.row]
        } else {
            user = users[indexPath.row]
        }
        cell.textLabel?.text = user.username
        cell.textLabel?.textColor = UIColor.darkGray
        cell.textLabel?.font = UIFont.init(name: "Avenir Next Regular", size: 17.0)
        cell.accessoryType = cell.isSelected ? .checkmark : .none
        cell.selectionStyle = .none // to prevent cells from being "highlighted"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    func filterContentForSearchText(searchText: String) {
        filteredUsers = users.filter { user in
            return user.username.lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }
}


extension ShareViewController: UISearchResultsUpdating {
    @available(iOS 8.0, *)
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }

    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}

