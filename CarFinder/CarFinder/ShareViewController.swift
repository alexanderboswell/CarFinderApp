//
//  ShareViewController.swift
//  CarFinder
//
//  Created by alexander boswell on 5/22/17.
//  Copyright © 2017 alexander boswell. All rights reserved.
//

import Foundation

import Firebase

class ShareViewController: UIViewController {
    
    var pin:Pin?
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("The value of myStringValue is: \(pin?.title! ?? "not initialized")")
    }
    
    @IBAction func exit(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {});
    }
    
    
}
