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
    
    // MARK: UI Elements
    @IBOutlet var myTableView: UITableView!

    @IBOutlet weak var friendRequestsBackground: UIImageView!
    
    @IBOutlet weak var numberOfRequests: UILabel!
    
    // MARK: Other variables
    var requestCount = 0
    
    // MARK: Overridden funcions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        self.friendRequestsBackground.layer.cornerRadius = 12
        self.friendRequestsBackground.clipsToBounds = true
        self.friendRequestsBackground.isHidden = true
        self.numberOfRequests.isHidden = true
        
        startObervingNumberOfRequests()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        FireBaseDataObject.system.removeObservers()
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
    
    // FireBase functions
    func startObervingNumberOfRequests() {
        FireBaseDataObject.system.CURRENT_USER_REF.child("requests").observe(FIRDataEventType.value,with: {(snapshot) in
            self.requestCount = 0
            for _ in snapshot.children.allObjects as! [FIRDataSnapshot] {
                self.requestCount += 1
            }
            if self.requestCount == 0 {
                self.friendRequestsBackground.isHidden = true
                self.numberOfRequests.isHidden = true
            }else {
                self.friendRequestsBackground.isHidden = false
                self.numberOfRequests.isHidden = false
                
                if self.requestCount > 9 {
    
                    self.numberOfRequests.font =  self.numberOfRequests.font.withSize(12)
                    self.numberOfRequests.text = String(self.requestCount)
    
                } else if self.requestCount > 100 {
                    
                    self.numberOfRequests.font =  self.numberOfRequests.font.withSize(8)
                
                }else {
                    self.numberOfRequests.font =  self.numberOfRequests.font.withSize(18)
                    self.numberOfRequests.text = String(self.requestCount)
                }
            }
        })
        
    }
}
