//
//  MainViewController.swift
//  CarFinder
//
//  Created by alexander boswell on 5/6/17.
//  Copyright © 2017 alexander boswell. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import MapKit

class MainViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        mapView.delegate = self
        // set initial location of the mapview
        let initialLocation = CLLocation(latitude: 38.623283, longitude: -90.190816)
        centerMapOnLocation(location: initialLocation)
    }
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)

        for pin in TempSingleton.sharedInstance.pins {
            mapView.addAnnotation(pin)
        }
    }

    @IBAction func signOut(_ sender: UIBarButtonItem) {
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
