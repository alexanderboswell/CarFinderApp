//
//  SetAPinViewController.swift
//  CarFinder
//
//  Created by alexander boswell on 5/15/17.
//  Copyright © 2017 alexander boswell. All rights reserved.
//

import Foundation
import UIKit

class SetAPinViewController: UIViewController {

    override func viewDidLoad() {
        print("loaded this view")
    }
    @IBAction func closeNewPin(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {});
    }
    
}
