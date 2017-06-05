//
//  FindAFriendViewController.swift
//  CarFinder
//
//  Created by alexander boswell on 6/5/17.
//  Copyright © 2017 alexander boswell. All rights reserved.
//

import Foundation

class FindAFriendViewController: UIViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBAction func addFriend(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "AddAFriendToMainView", sender: nil)
    }

    override func viewDidLoad() {
     
        if self.revealViewController() != nil {
            
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
}
