//
//  MenuController.swift
//  CarFinder
//
//  Created by alexander boswell on 6/2/17.
//  Copyright © 2017 alexander boswell. All rights reserved.
//
import UIKit
import Firebase

class MenuController: UITableViewController {
    
    @IBOutlet var myTableView: UITableView!

    // MARK: Overridden funcions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        let indexPath = NSIndexPath(row: 1, section: 0)
//
//        myTableView.selectRow(at: indexPath as IndexPath, animated: false, scrollPosition: .none)

    }
    
    // MARK: UI Actions
    @IBAction func signOut(_ sender: UIButton) {
            do {
                try FIRAuth.auth()?.signOut()
            } catch let error {
                assertionFailure("Error signing out: \(error)")
            }
            signOut()
        }
        func signOut() {
            performSegue(withIdentifier: "signOutSegue", sender: nil)
        }
}
