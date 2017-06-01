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

class ShareViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var pin:Pin?
    var users = TempSingleton.sharedInstance.users
    var filteredUsers = [User]()
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        users = TempSingleton.sharedInstance.users
        
        // Setup the Search Controller
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar

        for user in users {
            print(user.username)
        }
        
       // tableView.register(UserTableViewCell.self, forCellReuseIdentifier: "UserTableViewCell")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @IBAction func exit(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {});
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        TempSingleton.sharedInstance.pins.append(pin!)
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
        print("test")
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        print("blah")
        let user: User
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filteredUsers[indexPath.row]
            print("1")
            print(user.username)
        } else {
            user = users[indexPath.row]
            print("2")
            print(user.username)
        }
        print(user.username)
        cell.textLabel?.text = user.username
        return cell
    }
    func filterContentForSearchText(searchText: String) {
        filteredUsers = users.filter { user in
            return user.username.lowercased().contains(searchText)
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

